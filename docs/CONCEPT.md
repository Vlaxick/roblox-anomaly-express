# Anomaly Express

Tycoon, survival, extraction, and collection game for Roblox.

## Core loop

1. Recover a strange sealed find; its silhouette hints at its region and rarity.
2. Put it on a display stand at home and wait for unpacking, not plant growth.
3. Open it to reveal one collectible character with a known drop probability.
4. Keep the character on the stand to earn coins automatically.
5. Expand the collection or sell a resident to make room for a new find.
6. In a later milestone, board the train every five minutes, survive dangerous
   regions and bring finds home. Current earned-coin supplies exercise the base loop.

## First playable milestone

- One personal autumn base per player, currently dressed for Halloween
- A clear find → unpack → open → character → automatic coins loop
- Four permanent container silhouettes, four rarities and eight year-round companions
- Separate opt-in event collections; no seasonal items in normal drop pools
- Two starting display stands, expandable to eight
- One catalogue showing 3D previews, exact odds, prices and opening times
- A character reveal and inspection/sale with explicit confirmation
- Player levels with movement-speed progression
- Train trips and recoverable specimens after the base loop is proven

## Current playable checkpoint

Six fenced collector courtyards are generated in a moonlit autumn clearing. Each
player starts with 40 coins and two stands. The first find costs 15 coins and takes
8 seconds to unpack. The player explicitly opens it, revealing Шестерик (70%, +3 / 5 s)
or Камінчик (30%, +5 / 5 s). Higher tiers have separate, clearly shown character
pools and more income. A sealed find itself never produces coins.

## Distinct finds and future expedition placement

- **Дорожній кофр / Common:** blue canvas, brass buckles, luggage tag and carry
  handle. Future habitat: train platforms, camps and abandoned luggage.
- **Мандрівна капсула / Rare:** rounded enamel pod with a circular latched hatch,
  reinforcement hoops and a top handle. Future habitat: lost survey camps.
- **Кристалічна жеода / Epic:** faceted rock, exposed crystal points, survey seal
  and brass binding. Future habitat: caves, quarries and ancient excavations.
- **Астральна сфера / Legendary:** sealed blue globe in three navigation rings on
  a tripod. Future habitat: observatories and ruined exploration outposts.

These habitats are design intent, not working expedition content yet. Keep shape,
material, seal and written rarity cues together so rarity is not conveyed by colour
alone. All models are authored in code and reused in the catalogue and world.

Companions include a goggle-eyed tool robot (Шестерик), smiling mineral creature
(Камінчик), moss-backed turtle (Мохоспин), blue postal bird (Поштарик), crystalline
fox (Призма), compass-chested stone golem (Атлас), constellation ray (Зорекрил)
and floating sky whale (Небоплав). Their silhouettes, not recolours of one mascot,
distinguish them. Materials are enamel, stone, porcelain and brass, without neon.
They stay on display stands and earn automatically;
there is no reactor, energy management, manual coin collection or vegetable farming.

The base is now a cobbled collector's courtyard with circular display plinths,
an archive workshop and map workbench. Rustic fences, rusty leaves, moonlight,
candle lanterns and cobwebs retain the Halloween atmosphere. The interface keeps
dark plum, cream text and burnt-orange actions. Saving and train expeditions remain
later milestones. The world skin and available loot are independent settings.
Random finds currently use earned coins only; any future paid
random-reward feature would need a separate policy and player-safety review.

## Event content policy

The year-round collection is always available. A season adds a separate, clearly
marked pool; it never replaces the core collection or injects event characters
into a permanent find. The original spooky bags, whisper cages, thorn cocoons,
moon seals and eight Halloween residents are preserved as a disabled event pack.
They return only through the explicit server-owned event setting, not simply
because the base has orange trees, pumpkins or a night sky.

The catalogue builder validates unique IDs, per-collection pools and 100% odds.
Acquisition uses the active catalogue; rendering and existing-resident resolution
use the known-content registry. An event ending should stop new acquisition, not
delete already-earned residents. Persistence and event scheduling are future work.

## Readability around stands

Use one information surface at a time. A distant stand shows its name/rarity/status
plaque. When Roblox displays the nearby action prompt, that stand's plaque hides
locally and returns when the player steps away. Unpacking keeps the countdown
plaque because there is no action yet. Menus suppress world plaques/prompts until
closed. This avoids the former stacked labels without merely nudging them apart.
