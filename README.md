# Anomaly Express

Roblox tycoon + survival + extraction game.

## Central Station and town

The world now has a 330 × 280-stud brick-and-glass station, barrel-vault roof,
clock, ticket counters, waiting benches, directory, four gates, long platform and
four-car parked train. A town square, shopfront scenery, lit avenue and connected
home lanes surround it. Six bases occupy a separate residential district.

Use the **Station** and **Home** HUD buttons for quick travel, or walk the streets.
At the back of the main hall, approach a gate control and use **Enter**:

| Gate | Destination | Play | Reward |
| --- | --- | --- | --- |
| 01 | Skyline Obby | 12 stages, checkpoints at 5 and 9, safe fall resets | 25 coins + 12 XP |
| 02 | Circuit Run | Walk over all six floor buttons within 30 seconds | 15 coins + 8 XP |
| 03 | Memory Room | Study four numbers for 5 seconds, then step on them in order | 20 coins + 10 XP |
| 04 | Platform 1 | Explore the train platform | No reward / train service not active yet |

Button-room progress and patterns are individual, not shared across players.
Each activity pays at most once per player every 90 seconds; practice is always
available. Death, travel, leaving the room and timeouts clear the active attempt.
Only server-validated physical contacts advance progress. The client cannot submit
a completed stage, arbitrary position, reward amount or activity teleport.

All authored game UI, signs, loot names, rarity labels and error messages are now
English, including the disabled Halloween collection. Roblox's own system menus,
keyboard-key glyphs and player display names follow the user's Roblox settings.
Activity instructions/progress replace the collection HUD while playing, leaving
the lower screen clear for movement controls.

The departure board explicitly marks expedition service as in development. There
is no fake departure countdown: these are working lobby activities, not a claim
that train extraction/saving is implemented. Shops are town scenery at this stage.

## Development workflow

1. Keep Luau source and project configuration in this repository.
2. Run `rojo serve` from the repository root.
3. Open the place in Roblox Studio and connect with the Rojo plugin.
4. Build maps and visual assets in Studio; implement game systems in `src`.
5. Test in Studio, then commit a small, working change to Git.

## Source layout

- `src/server` — authoritative game logic and data handling
- `src/client` — interface, camera, effects, and player input
- `src/shared` — configuration and modules used by both sides
- `docs` — design decisions and milestone descriptions

## Current playable base

Start a Play test after connecting Rojo. Each player receives a collector's
autumn courtyard, two circular display stands and 40 earned coins. Open
**Finds**, or approach an empty stand. Place a sealed find, wait for unpacking,
then explicitly choose **Open** on its stand or the HUD. One random character
replaces the container and generates coins automatically every five seconds.
Containers stay full-sized: nothing grows in planting beds.

| Find | Rarity | Coins | Unpacking | Character pool (coins / 5 s) |
| --- | --- | ---: | ---: | --- |
| Travel Case — canvas travel case | Common | 15 | 8 s | Scrapling 70% (+3), Pebble 30% (+5) |
| Trail Capsule — enamel expedition pod | Rare | 75 | 15 s | Mossback 65% (+13), Postbird 35% (+18) |
| Prism Geode — stone/crystal specimen | Epic | 240 | 25 s | Prism 60% (+44), Atlas 40% (+60) |
| Atlas Sphere — armillary globe | Legendary | 650 | 40 s | Starray 75% (+130), Skywhale 25% (+180) |

Loot is year-round: a tool robot, mineral creature, moss-backed turtle, postal
bird, crystal fox, compass golem, star ray and sky whale. These have their own
slate, enamel, brass and porcelain palette, not colours inherited from the world
season. World decoration remains the previously approved autumn/Halloween skin.

`Config/GameConfig.ActiveLootEvent = ""` means only the permanent collection is
available. Original Halloween finds/art are preserved in `LootCollections/Halloween`
and `EventAssets/HalloweenAssets`; they do not appear in the normal catalogue or
drop pools. `"Halloween"` explicitly adds that collection to the permanent one.
The server rejects placement of disabled event finds even if a client knows an ID.
Known event residents/art remain resolvable after an event ends; persistence itself
is still a later milestone. Event availability never depends on the map's palette,
calendar date, client clock, or a client-provided event flag.

The catalogue shows exact odds and income from the same shared table used by the
server. There are no Robux purchases, paid keys, roulette near-misses or premium
luck mechanics. Earned-coin supplies are the current test source of finds; train
expedition recovery is not implemented yet.

Expand to eight stands for 50, 100, 180, 300, 480 and 750 coins. Opening grants
10 XP. Approach a resident to inspect its 3D portrait and income. Selling requires
a second confirmation, frees its stand, and grants the displayed fixed resale
value. This allows upgrading a full base rather than becoming stuck with commons.

Placement, timers, random rolls, XP, sale and income are server-authoritative.
Requests validate ownership, location, balance, slot bounds/state and rate limit.
Repeat/early opens and occupied placement are rejected without another charge or
reward. No yielding occurs while a find is consumed and its single drop assigned.

Circular stone-and-wood plinths follow the edge of a cobbled courtyard around a
clear walking area. A collector's workshop, map-covered workbench, instruction
board, fallen leaves, carved pumpkins, cobwebs and candle lanterns replace the old
farm beds and hay. The interface retains dark plum, cream and burnt-orange tones,
with actual 3D container previews, transparent drop pools and a focused character
reveal. Catalogue, reveal and touch targets adapt to narrow and landscape screens.

Stand information is mutually exclusive with the nearby Roblox interaction prompt:
the name/status plaque is visible at a distance, then hidden while its action
prompt is shown. Locked plaques remain hidden until they are the next expansion.
Catalogues and character cards suppress world prompts and stand labels until
closed. Visibility is per-client, so one player's interaction cannot hide another
player's stand information. The floating Roblox player list is temporarily hidden
during these menus so it cannot cover close controls; its previous state is restored.

Geometry is generated at runtime so the base stays in Git. Progress currently
resets between sessions; saving and train expeditions are later milestones.
The parked train is scenery at this checkpoint.
