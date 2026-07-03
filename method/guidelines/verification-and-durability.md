# Verification & Durability

The *why* behind the ship gates. The enforcement mechanics live in
`skills/flow-ship-issue/references/ac-classification.md` (the three-class AC taxonomy) and the ship
phase's hard gates; this doc is the reasoning they encode, so the gates aren't cargo-culted.

## Aggregate "green" hides invariants
CI ✓ + CD ✓ + `/health` 200 does **not** prove your system is in a state you can survive a failure
from. Each green proves a *narrow* claim — syntax, connectivity, liveness — and none proves
durability. Never read a wall of green as "we're fine"; ask which specific invariant each check
actually asserts, and which ones nothing asserts.

## "Deploy succeeded" ≠ "the code is running"
A successful deploy and an "up" container do not mean the code you merged is the code executing.
Prove it: **prod SHA == merge commit**, and the **runtime loaded the expected code** (asset/route/
handler set matches). An AC checked against stale or half-loaded code is worse than no check — it's
a false all-clear.

## Liveness ≠ durability — chaos-test what you claim survivable
If an AC says "survives a host reboot", the criterion is a **failure injection** (`restart docker`,
kill the process, pull the network) followed by an assertion that everything came back — not a ping
that returned 200 while nothing had failed yet. Test the claim you're actually making.

## Evidence over assertion
An execution claim ("returns 200", "data populated", "sensor running") is proven by a **command and
its literal output**, never by "looks good" or code inspection. If you can't paste the bytes, you
haven't verified it. (This is the dev/prod-execution AC contract — see ac-classification.)

## Sample broadly, not the happy path
When spot-checking derived or transformed data, sample across **every** dimension — each row type,
each timeframe, each branch — not one convenient case. Bugs hide in the dimension you didn't check
(the quarterly rows, the empty-input case, the second locale).

## Real domain bounds, not "not null"
Checks earn their keep with **real bounds**: a percentage is 0–100, a price is > 0, a ratio is null
when its denominator is near zero. "Not null" passes broken data; real bounds catch actual formula
bugs — including ones code review missed.

## Runtime state must be declarative
Schedules, sensors, feature flags, restart policies — set them **in code** (config, `default:
running`, `restart: unless-stopped`), never "I toggled it in the UI that once". A fresh deploy must
reproduce the exact runtime state the docs describe, or the next deploy silently reverts it.
