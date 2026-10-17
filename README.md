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

Start a Play test after connecting Rojo. Each player receives a Halloween clearing
with two open spaces and 40 coins. Use **Розмістити**, or approach an empty space,
to open the catalogue. Place a unique living object, let it grow through three
visible stages, and receive coins automatically every five seconds after maturity.
This is a base for growing unusual objects, not a vegetable farm.

| Object | Rarity | Price | Growth | Mature income |
| --- | --- | ---: | ---: | ---: |
| Mimic chest | Common | 15 | 10 s | 3 coins / 5 s |
| Wandering lantern | Rare | 75 | 18 s | 12 coins / 5 s |
| Midnight clock | Epic | 240 | 30 s | 42 coins / 5 s |

Rarity belongs to the object type; purchases do not roll random rewards. Open up
to eight spaces through the catalogue or the next locked space. Expansion prices
are 50, 100, 180, 300, 480 and 750 coins. Reaching maturity gives 10 XP.

Purchases, growth, payouts and farm ownership are server-authoritative. The server
checks funds, space availability and that the player is on their own base. The
catalogue uses the same 3D object models as the world and adapts to narrow screens.

Wooden fences, stone growth pads, fallen leaves and rusty foliage frame a moonlit
night. Candle lanterns, warm windows, decorative jack-o'-lanterns and cobwebs give
the clearing a Halloween theme. The dusk-coloured HUD uses cream text and amber
accents. Pumpkins are scenery, not income-generating objects.

Geometry is generated at runtime so the base stays in Git. Progress currently
resets between sessions; saving and train expeditions are later milestones.
The parked train is scenery at this checkpoint.
