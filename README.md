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
Halloween courtyard, two circular display stands and 40 earned coins. Open
**Знахідки**, or approach an empty stand. Place a sealed find, wait for unpacking,
then explicitly choose **Відкрити** on its stand or the HUD. One random character
replaces the container and generates coins automatically every five seconds.
Containers stay full-sized: nothing grows in planting beds.

| Find | Rarity | Coins | Unpacking | Character pool (coins / 5 s) |
| --- | --- | ---: | ---: | --- |
| Забута валіза — canvas station bag | Common | 15 | 8 s | Ґудзик 70% (+3), Шкарпетик 30% (+5) |
| Клітка шепотів — domed birdcage | Rare | 75 | 15 s | Ліхтар-блукач 65% (+13), Ворон-вартовий 35% (+18) |
| Кокон сутінків — bound silk cocoon | Epic | 240 | 25 s | Сутінковий метелик 60% (+44), Хранитель опівночі 40% (+60) |
| Місячна печать — crescent reliquary | Legendary | 650 | 40 s | Місячний кіт 75% (+130), Гарбузовий король 25% (+180) |

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

Geometry is generated at runtime so the base stays in Git. Progress currently
resets between sessions; saving and train expeditions are later milestones.
The parked train is scenery at this checkpoint.
