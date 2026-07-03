# Debugging & Investigation

How to investigate before you fix. Distilled from repeated lessons — each line here cost a wasted
debugging session at least once. The flow-ship-issue implement/fix work should follow these.

## Debug state, not logs
When something misbehaves, **query the system's own state first** — its status API, admin command,
or state table — before tailing logs. Logs show symptoms and are full of ghosts (old errors,
red herrings, benign warnings). State shows what's actually true right now. "The logs said X" has
sent more debugging down the wrong path than any other habit.

## Classify the bug variant before fixing
Map the incident to the **exact code path / variant** it hit before writing a line of fix. The same
symptom often has several causes; a fix aimed at the wrong variant is pure churn and can mask the
real one. Name the variant, point at the code, *then* fix.

## Don't explain away the first anomaly
A check's **first** WARN / failure gets investigated, never dismissed as "transient" or "flaky".
Run the boundary query, pull the offending row, and find out why. The first anomaly is the cheapest
one you'll ever get to look at; "it's probably nothing" is how a real bug gets a week's head start.

## Fix the pattern, not the example
A reported case is usually one instance of a class. Find the **root cause**, then **sweep every
instance** (grep the whole repo for the same shape). Fixing only the reported example guarantees the
next one shows up next week wearing a different hat.

## Verify before classifying or recommending
Before answering "is this X or Y?" or "you should add X" — **read the actual code** (one grep, one
file). Confident answers from memory about a specific codebase are wrong often enough that the
30-second check always pays for itself. This applies doubly before recommending a change to code you
haven't opened.

## Read the tool's `--help` before a manual workaround
"I don't want the default behavior X" is almost always a flag away. Before scripting around a CLI or
building a workaround, read its help/docs. The manual workaround is usually more code, more brittle,
and already built into the tool.
