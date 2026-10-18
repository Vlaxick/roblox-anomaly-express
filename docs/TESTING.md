# Collector courtyard validation

## 2026-10-18: English UI, Central Station and lobby activities

Live single-client Studio checks with Rojo connected:

- The default game text, base prompts, catalogue, companions, errors and archived
  event names are English. A source scan found no remaining Cyrillic game strings.
- The new station constructs with four numbered gates, a glass vaulted hall,
  platform, parked train and connected residential lanes. The departure board
  explicitly says that expedition routes are still in development.
- HUD travel rejects arbitrary activity destinations; Station travel works and
  the physical gate prompts start their matching activities.
- Circuit Run completed by walking across its six actual pressure plates in time;
  the first clear awarded exactly 15 coins and 8 XP.
- Memory Room presents a four-number pattern. A wrong step resets the attempt;
  staying on that plate for six seconds does not repeatedly trigger it. Correct
  steps complete the activity and award 20 coins / 10 XP.
- A second Memory clear during its 90-second reward cooldown awarded no further
  coins or XP, while still allowing practice. The HUD countdown updates live.
- All twelve obby platforms were reached using Humanoid movement and jumps,
  with temporary server-owned physics for a repeatable test. An injected fall at
  stage five returned to its saved checkpoint; completion awarded 25 coins and
  recorded a best time. The earlier centre-to-centre client test was not used as
  proof of jump feasibility; the passing route approaches platform edges first.
- Pressure inputs are once per visit, with server-side position, order, timer and
  activity checks. Test commands and physics ownership changes are Play-only
  fixtures; stopping the session discards them.
- A fresh restart retained the normal 40-coin balance. Activity text and >=44px
  buttons fit both 375 × 400 and 801 × 413 GUI safe areas. The Roblox player list
  hides during an activity and restores afterwards.
- Letting Circuit Run expire cancelled it without a reward. Gate 04 reached the
  platform, Home returned to the assigned base with base actions visible, and
  Station returned to the entrance.

Output markers: `CITY_CIRCUIT_WALK_REWARD_PASS`, `CITY_MEMORY_STEP_EDGE_PASS`,
`CITY_MEMORY_REWARD_PASS`, `CITY_REWARD_COOLDOWN_PASS`,
`CITY_OBBY_CHECKPOINT_PASS`, `CITY_OBBY_PHYSICS_CLEAR_PASS`,
`CITY_FRESH_ENGLISH_LAYOUT_PASS`, `CITY_TIMEOUT_PLATFORM_HOME_PASS`.

These checks are not a multiplayer contention/load test or a real mobile-device
test. Train departures, expedition recovery, shop interiors and persistent saves
remain outside this milestone.

## 2026-10-18: permanent loot and overlapping labels

Live Studio checks with the event setting left empty:

- Default catalogue has exactly 4 permanent finds and 8 permanent companions.
  Every normal drop belongs to the permanent collection.
- `LootCatalog.Build("Halloween")` adds the archived collection (8 finds / 16
  companions total); a subsequent empty-event build returns only 4 / 8 again.
  Unknown event identifiers are rejected. This did not enable the live event.
- All permanent models construct with anchored, non-colliding, non-Neon parts.
  All archived models also still construct through the event-art route.
- Approaching an empty stand hides its plaque while the native action prompt is
  visible. Stepping away restores the plaque. Screenshots confirm a single text
  surface instead of the previously stacked labels.
- Opening the catalogue disables world prompts and hides plaques; closing it
  restores prompt behaviour. The unpacking countdown remains visible while its
  action is disabled; ready finds switch back to one action prompt.
- With the normal 40-coin start, TravelCase charged 15, unpacked for 8 seconds,
  revealed Scrapling, awarded 10 XP and paid its configured passive income.
  The character reveal also suppressed world prompts/plaques.
- The new catalogue and collection caption fit a 375 × 400 safe area, including
  wrapped names, odds, subtitle and placement controls >=44px.
- A temporary 4 × 2 art-review grid was used to inspect all eight companions;
  it is a Play-only fixture, not shipped UI.
- All four permanent rarities completed their real unpack/open cycle. Drop IDs
  matched each find's pool, combined income matched resident totals, and sale
  freed a stand and rejected repeat sale.
- With sufficient test coins and an unlocked empty stand, all four disabled
  Halloween find IDs were explicitly rejected by the server's active catalogue.
- Landscape catalogue text and controls fit an 801 × 413 safe area. The automated
  proximity activation was retried after waiting for the shown prompt following
  a test teleport; the menu and layout checks then passed.
- A clean restart validated the final model constructors and menu controller
  with the normal 40-coin balance. Opening a catalogue hides the Roblox player
  list as well as world prompts; closing it restores the prior player-list state
  and the nearby-prompt/distant-plaque behaviour.

Output markers: `PERMANENT_CATALOG_MODELS_PASS`, `LABEL_PROMPT_EXCLUSIVE_PASS`,
`PERMANENT_UI_375PX_PASS`, `PERMANENT_LOOP_MODAL_LABEL_PASS`,
`EVENT_ARCHIVE_RENDER_PASS`, `PERMANENT_TIERS_INCOME_SELL_PASS`,
`DISABLED_EVENT_SERVER_GATE_PASS`, `PERMANENT_LANDSCAPE_PASS`,
`PERMANENT_CLEAN_RESTART_UI_PASS`.

## 2026-10-17: original collector checkpoint (historical)

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
