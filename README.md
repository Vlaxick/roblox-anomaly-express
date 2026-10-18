# Anomaly Express

Roblox tycoon + survival + extraction game.

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
**Знахідки**, or approach an empty stand. Place a sealed find, wait for unpacking,
then explicitly choose **Відкрити** on its stand or the HUD. One random character
replaces the container and generates coins automatically every five seconds.
Containers stay full-sized: nothing grows in planting beds.

| Find | Rarity | Coins | Unpacking | Character pool (coins / 5 s) |
| --- | --- | ---: | ---: | --- |
| Дорожній кофр — canvas travel case | Common | 15 | 8 s | Шестерик 70% (+3), Камінчик 30% (+5) |
| Мандрівна капсула — enamel expedition pod | Rare | 75 | 15 s | Мохоспин 65% (+13), Поштарик 35% (+18) |
| Кристалічна жеода — stone/crystal specimen | Epic | 240 | 25 s | Призма 60% (+44), Атлас 40% (+60) |
| Астральна сфера — armillary globe | Legendary | 650 | 40 s | Зорекрил 75% (+130), Небоплав 25% (+180) |

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
