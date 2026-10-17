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

## Current playable farm

Start a Play test after connecting Rojo. Each player receives an autumn farm with
two open beds and 40 coins. Use **Посадити**, or approach an empty bed, to open the
catalogue. Buying a plant places it directly on the selected bed. Plants grow in
three visible stages and then add coins to the wallet automatically every five
seconds. No collector or second currency is involved.

| Plant | Rarity | Price | Growth | Mature income |
| --- | --- | ---: | ---: | ---: |
| Pumpkin | Common | 15 | 10 s | 3 coins / 5 s |
| Forest mushroom | Rare | 75 | 18 s | 12 coins / 5 s |
| Golden apple tree | Epic | 240 | 30 s | 42 coins / 5 s |

Rarity belongs to the plant type; purchases do not roll random rewards. Open up
to eight beds through the catalogue or the next locked bed. Expansion prices are
50, 100, 180, 300, 480 and 750 coins. A plant reaching maturity gives 10 XP.

Purchases, growth, payouts and farm ownership are server-authoritative. The server
checks funds, bed state and that the player is on their own farm. The catalogue
uses the same 3D plant models as the world and adapts to narrow screens.

Wooden fences, tilled beds, a red barn, hay bales, fallen leaves and golden trees
share the warm `Theme` palette. Geometry is generated at runtime so the farm stays
in Git. Progress currently resets between sessions; saving and train expeditions
are later milestones. The parked train is scenery at this checkpoint.
