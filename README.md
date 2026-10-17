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

The first development milestone is the complete loop from planting an anomaly to
recovering and incubating a specimen from an expedition.
