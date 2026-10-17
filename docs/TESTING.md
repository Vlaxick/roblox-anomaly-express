# Collector courtyard validation

Validated in a Roblox Studio Play session with Rojo connected. These are live
smoke checks, not an offline Luau typecheck or a multiplayer load test.

## Checks performed

| Check | Observed result |
| --- | --- |
| Fresh base | 40 coins, 2 open stands, 8 stands total, no planting beds |
| First placement | LostSatchel charged exactly 15 coins; state became Sealed |
| Early open | Rejected before the 8-second timer expired |
| Occupied placement / insufficient funds / NaN slot | Rejected without another charge |
| First reveal | Buttonling dropped, 10 XP awarded, reveal card displayed |
| Passive income | +3 after the first payout interval; no income from sealed finds |
| Model construction | All 4 containers and 8 characters constructed; character parts anchored, non-colliding, no Neon |
| Expansion | All 6 additional stands unlocked in order; expansion beyond 8 rejected |
| All rarity tiers | Each of 4 finds placed, waited its real timer, opened once; drop belonged to that find's pool |
| Duplicate open | Rejected after the character was assigned |
| Combined income | Sum of resident incomes matched HUD/server Income and subsequent payout |
| Sale | Character removed, stand became Empty, income decreased; repeat sale rejected |
| Outside own base / unknown find / invalid slot / empty open | Rejected |
| Empty-stand proximity prompt | Opened catalogue for the selected stand |
| Resident proximity prompt | Opened character inspection with resale value |
| 375 × 400 safe area | Catalogue 351 × 384; card titles/odds fit, placement controls >=44px |
| 801 × 413 safe area | Landscape catalogue 730 × 397; text and controls fit |
| Narrow reveal | Name/income fit at 375px; primary control >=44px |

Rarity/expansion checks temporarily granted 5,000 coins on the **Play server**.
No production configuration, persistent save, or Robux balance was changed.
Stopping Play discards these fixtures.

Output markers: `COLLECTION_LOOP_PASS`, `COLLECTION_MODELS_PASS`,
`COLLECTION_375PX_CATALOGUE_PASS`, `COLLECTION_LANDSCAPE_PASS`,
`COLLECTION_REVEAL_375PX_PASS`, `COLLECTION_TIERS_INCOME_SELL_PASS`,
`COLLECTION_REQUEST_VALIDATION_PASS`, `COLLECTION_INSPECT_PROMPT_PASS`.

Studio also emitted pre-existing CorePackages FoundationProvider and asset-type
warnings; no runtime errors from the game scripts were observed in these checks.

## Repeat before a release

1. Connect Rojo and start a fresh Play session. Verify the first find with the
   normal 40-coin balance, using the actual placement and opening buttons.
2. Check character inspection, first sale tap (confirmation only), cancel, and
   confirmed sale. Confirm that the freed stand can accept a new find.
3. Use a second Studio client to verify separate ownership, reject actions at the
   other player's base, and check base reset/reassignment after a player leaves.
4. Test in the actual mobile simulator/on-device, including touch/gamepad focus,
   not only resized GUI safe-area checks.
5. Saving, train loot recovery, paid randomness and production economy balancing
   are not implemented or validated by this checkpoint.

Build check:

```sh
rojo build default.project.json -o /tmp/anomaly-collection.rbxlx
git diff --check
```
