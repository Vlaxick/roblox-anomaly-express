# Collector courtyard validation

## 2026-10-18: Depot Trial replacement

The original twelve-square obby below is historical, replaced by six authored
obstacle sections and twenty-eight route surfaces in an enclosed depot.

Live Studio checks:

- Gate 01 starts the new course. All 28 surfaces, the full depot shell and the
  personal next-surface marker construct without game-script runtime errors.
- A client-owned rider remained on a travelling cargo deck for three seconds;
  measured horizontal drift relative to the deck was under 0.01 studs.
- The section HUD, instruction and two-line checkpoint/reward footer fit a
  375 × 400 GUI safe area. This is not a real-device touch test.
- Teleporting to the final balcony before the intermediate surfaces did not
  complete the activity or grant coins. Falling to the service floor reset the
  first checkpoint.
- Controlled server landing fixtures advanced the real private session through
  every surface. A deliberate rotor hit restored section 3, and a deliberate fall
  restored section 5. Completing the remaining ordered surfaces paid exactly
  25 coins and 12 XP, and recorded the elapsed best time.
- The fading-stair fixture initially waited on a temporary plate and correctly
  fell when it disappeared. Repeating the four plates in one continuous solid
  window passed; this is the intended timing challenge, not a safe waiting area.
- Rotor testing caught loss of angular precision from epoch-sized CFrame angles.
  Both client and server now reduce time to a single revolution before creating
  the rotation; the repeated checkpoint/landing checks passed afterwards.
- A separate gap-by-gap fixture used server-owned Humanoid movement/jumps at
  WalkSpeed 16, without awarding route progress. Every static transition landed
  on its intended surface, including the narrow corners and rising roof beams.
  The two exits from moving decks failed when taken in an arbitrary phase;
  after approaching the correct phase, both timed edge jumps passed. Cargo decks
  were widened to 10 studs to make that timing less brittle.
- `MoveTo` is unsuitable for a carrying-platform walking fixture because direct
  CFrame carry ends an AI MoveTo goal. A client fixture using ordinary per-frame
  Humanoid movement instead walked 3.1 studs relative to the deck and reached a
  jump peak 10.83 studs above its surface centre. Carry now explicitly excludes
  Jumping/Freefall so it cannot interrupt takeoff.
- A native rotor sample rotated smoothly by 0.10 radians over roughly 0.15 s,
  confirming the epoch-angle precision fix in the running game.
- A clean final restart built the widened decks and takeoff guard. A component
  fixture checked all six actual hint strings, progress and reward text in both
  375 × 400 and 801 × 413 safe areas. Gate 01 then started normally with 40 coins;
  the outlined next landing and full depot interior were visually inspected.

Markers: `DEPOT_GATE_CONSTRUCTION_PASS`, `DEPOT_CLIENT_DECK_CARRY_PASS`,
`DEPOT_NARROW_HUD_PASS`, `DEPOT_SKIP_FINISH_REJECTED`,
`DEPOT_FIRST_FALL_RESET_PASS`, `DEPOT_FRESH_MARKER_PASS`,
`DEPOT_ROTOR_CHECKPOINT_3_PASS`, `DEPOT_FALL_CHECKPOINT_5_PASS`,
`DEPOT_ORDERED_ROUTE_REWARD_PASS`, `DEPOT_GAP_PHYSICS`,
`DEPOT_TIMED_CARGO_JUMP_PASS`, `DEPOT_CLIENT_WALK_JUMP_PASS`,
`DEPOT_ROTOR_PRECISION_PASS`, `DEPOT_ALL_SECTION_LAYOUTS_PASS`,
`DEPOT_FINAL_FRESH_GATE_PASS`.

The ordered landing fixtures verify rules, not an unaided full-course playthrough.
Before release, run multiplayer contention checks on shared moving/fading parts,
test real touch/gamepad controls and tune difficulty with new players. Play-only
fixtures and temporary physics ownership changes are discarded when Play stops.

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
