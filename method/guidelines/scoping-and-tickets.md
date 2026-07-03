# Scoping & Ticket Hygiene

How to size, split, and bundle work. These keep the tracker honest and stop churn. The
cadence/scope skills (flow-change-scope, flow-cycle-end, flow-retro) should apply them.

## Reactive work is ~half of true scope
A phase's planned issues ship alongside a comparable pile of reactive follow-ups (incidents, polish,
things you only learned by building). **Budget a retro-sweep after every substantive phase.** A
milestone marked "complete" without a retro doesn't have zero bugs — it has undiscovered ones.

## The reactive sizing trap
When you've filed **3+ tickets ratcheting the same resource or bound** (raise the limit again, retry
harder again), stop patching. That's a signal the design is wrong, not the number. Step back and
find the structural alternative — the fourth increment is rarely the last.

## Cut, don't re-scope a third time
By the **third** time a ticket gets re-scoped, change the question from "how do I re-plan this?" to
"what can I delete?". A requirement that resists definition three times is usually a requirement you
don't actually need.

## Bundle follow-ups; don't fragment
Diagnose the **whole** problem, write **all** the fixes, ship **once**. Two small fixes on the same
feature are one ticket, not two. A cluster of "fold this in as a follow-up" items is a branch +
commit + PR referencing the parent — not a fleet of throwaway tickets.

## Template-pattern PRs
When one shape applies to N places (the same guard across five services, the same rename across a
package), **design the shape once, apply it to all N, ship one PR** with a multi-close. Don't file N
near-identical tickets.

## Defer AC owned by a dedicated ticket
If an acceptance criterion is really the subject of another, dedicated ticket, **defer to that
ticket and ship** — don't duplicate the work under two IDs.

## Build while the calibration is fresh
Don't defer work whose sizing signals are **in front of you right now**. The context that tells you
how big something is (a fresh benchmark, a just-observed incident, live numbers) decays fast. If you
can act on it now, acting later means re-deriving it.
