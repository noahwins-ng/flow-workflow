#!/usr/bin/env bash
# Linear tracker adapter for the ship-issue skill. Harness-neutral: talks to the Linear
# GraphQL API over curl+jq, so it works in any harness with a shell (no MCP required).
#
# Auth: export LINEAR_API_KEY (a Linear personal API key, "lin_api_...").
# Deps: curl, jq.
#
# Usage:
#   linear.sh issue get     <IDENT>                 # normalized JSON on stdout
#   linear.sh issue status  <IDENT> "<State Name>"  # move to a workflow state (resolved to UUID)
#   linear.sh issue comment <IDENT>                 # comment body read from stdin
#   linear.sh cycle active  "<Team Name>"           # active cycle + its issues (for cycle-start/end)
#   linear.sh project status-update "<Project>" <onTrack|atRisk|offTrack>   # body on stdin
#
# NOTE: not yet smoke-tested — run each subcommand once with a real LINEAR_API_KEY before relying
# on it in the pipeline. Verified design points: state is resolved to a UUID (never set by name,
# which collides with Linear's type words); identifier is parsed into team-key + number.
set -euo pipefail

API="https://api.linear.app/graphql"
: "${LINEAR_API_KEY:?export LINEAR_API_KEY (a Linear personal API key)}"

# gql <query> <variables-json> -> raw response JSON
gql() {
  curl -sS -X POST "$API" \
    -H "Authorization: ${LINEAR_API_KEY}" \
    -H "Content-Type: application/json" \
    --data "$(jq -nc --arg q "$1" --argjson v "$2" '{query:$q, variables:$v}')"
}

# split "QNT-305" -> team key + number
parse_ident() {
  TEAM="${1%%-*}"; NUM="${1##*-}"
  [[ "$TEAM" && "$NUM" =~ ^[0-9]+$ ]] || { echo "bad identifier: $1" >&2; exit 1; }
}

# fetch the raw issue node (id, title, state, branchName, project, milestone, relations, team states)
fetch_node() {
  parse_ident "$1"
  local q='query($t:String!,$n:Float!){issues(filter:{team:{key:{eq:$t}},number:{eq:$n}}){nodes{
    id identifier title description branchName
    state{name type}
    project{name} projectMilestone{name}
    team{states{nodes{id name}}}
    relations{nodes{type relatedIssue{identifier title state{name}}}}
  }}}'
  local resp; resp=$(gql "$q" "$(jq -nc --arg t "$TEAM" --argjson n "$NUM" '{t:$t,n:$n}')")
  echo "$resp" | jq -e '.data.issues.nodes[0] // empty' >/dev/null \
    || { echo "issue $1 not found (or GraphQL error): $(echo "$resp" | jq -c '.errors // .')" >&2; exit 1; }
  echo "$resp" | jq '.data.issues.nodes[0]'
}

case "${1:-} ${2:-}" in
  "issue get")
    fetch_node "$3" | jq '{
      id, identifier, title, description, branchName,
      status: .state.name,
      milestone: (.projectMilestone.name // .project.name),
      blockedBy: [ .relations.nodes[] | select(.type=="blocks" or .type=="blocked_by")
                   | {identifier: .relatedIssue.identifier, title: .relatedIssue.title,
                      status: .relatedIssue.state.name} ]
    }'
    ;;

  "issue status")
    node=$(fetch_node "$3")
    issue_id=$(echo "$node" | jq -r '.id')
    # resolve the target state NAME to its UUID within this issue's team (avoids name/type collision)
    state_id=$(echo "$node" | jq -r --arg s "$4" '.team.states.nodes[] | select(.name==$s) | .id')
    [[ "$state_id" ]] || { echo "no workflow state named '$4' on this team" >&2; exit 1; }
    m='mutation($id:String!,$state:String!){issueUpdate(id:$id,input:{stateId:$state}){success}}'
    gql "$m" "$(jq -nc --arg id "$issue_id" --arg state "$state_id" '{id:$id,state:$state}')" \
      | jq -e '.data.issueUpdate.success' >/dev/null \
      && echo "OK: $3 -> $4" || { echo "status update failed" >&2; exit 1; }
    ;;

  "issue comment")
    issue_id=$(fetch_node "$3" | jq -r '.id')
    body=$(cat)  # body on stdin
    m='mutation($id:String!,$body:String!){commentCreate(input:{issueId:$id,body:$body}){success}}'
    gql "$m" "$(jq -nc --arg id "$issue_id" --arg body "$body" '{id:$id,body:$body}')" \
      | jq -e '.data.commentCreate.success' >/dev/null \
      && echo "OK: commented on $3" || { echo "comment failed" >&2; exit 1; }
    ;;

  "cycle active")
    T="$3"; [[ "$T" ]] || { echo "usage: linear.sh cycle active <TEAM_NAME>" >&2; exit 1; }
    q='query($t:String!){teams(filter:{name:{eq:$t}}){nodes{key activeCycle{number startsAt endsAt
      issues{nodes{identifier title priority state{name type}}}}}}}'
    resp=$(gql "$q" "$(jq -nc --arg t "$T" '{t:$t}')")
    echo "$resp" | jq -e '.data.teams.nodes[0].activeCycle // empty' >/dev/null \
      || { echo "no active cycle for team '$T' (or error): $(echo "$resp" | jq -c '.errors // .')" >&2; exit 1; }
    echo "$resp" | jq '.data.teams.nodes[0].activeCycle
      | {number, startsAt, endsAt,
         issues: [.issues.nodes[] | {identifier, title, priority, status: .state.name}]}'
    ;;

  "project status-update")
    P="$3"; HEALTH="${4:-onTrack}"; BODY=$(cat)  # markdown body on stdin
    case "$HEALTH" in onTrack|atRisk|offTrack) ;; *) echo "health must be onTrack|atRisk|offTrack" >&2; exit 1;; esac
    pid=$(gql 'query($p:String!){projects(filter:{name:{eq:$p}}){nodes{id}}}' \
            "$(jq -nc --arg p "$P" '{p:$p}')" | jq -r '.data.projects.nodes[0].id // empty')
    [[ "$pid" ]] || { echo "project '$P' not found" >&2; exit 1; }
    m='mutation($p:String!,$b:String!,$h:ProjectUpdateHealthType!){projectUpdateCreate(input:{projectId:$p,body:$b,health:$h}){success}}'
    gql "$m" "$(jq -nc --arg p "$pid" --arg b "$BODY" --arg h "$HEALTH" '{p:$p,b:$b,h:$h}')" \
      | jq -e '.data.projectUpdateCreate.success' >/dev/null \
      && echo "OK: status update on $P ($HEALTH)" || { echo "status update failed" >&2; exit 1; }
    ;;

  *)
    echo "usage: linear.sh {issue get|issue status|issue comment|cycle active|project status-update} ..." >&2
    exit 1 ;;
esac
