--!strict

local Types = require(script.Parent.Parent.LootTypes)
local common = Color3.fromRGB(208, 191, 162)
local rare = Color3.fromRGB(164, 195, 154)
local epic = Color3.fromRGB(175, 188, 225)
local legendary = Color3.fromRGB(239, 186, 98)

-- Year-round expedition companions, independent of the world's seasonal skin.
local collection: Types.Collection = {
	Id = "Permanent",
	Name = "Permanent Collection",
	Characters = {
		{ Id = "Scrapling", Name = "Scrapling", Rarity = "Common", Income = 3, SellPrice = 8, Color = common },
		{ Id = "Pebble", Name = "Pebble", Rarity = "Common", Income = 5, SellPrice = 12, Color = common },
		{ Id = "MossTurtle", Name = "Mossback", Rarity = "Rare", Income = 13, SellPrice = 35, Color = rare },
		{ Id = "CourierBird", Name = "Postbird", Rarity = "Rare", Income = 18, SellPrice = 45, Color = rare },
		{ Id = "PrismFox", Name = "Prism", Rarity = "Epic", Income = 44, SellPrice = 110, Color = epic },
		{ Id = "AtlasGolem", Name = "Atlas", Rarity = "Epic", Income = 60, SellPrice = 140, Color = epic },
		{ Id = "StarRay", Name = "Starray", Rarity = "Legendary", Income = 130, SellPrice = 300, Color = legendary },
		{ Id = "CloudWhale", Name = "Skywhale", Rarity = "Legendary", Income = 180, SellPrice = 400, Color = legendary },
	},
	Finds = {
		{ Id = "TravelCase", Name = "Travel Case", Rarity = "Common", Price = 15, OpenSeconds = 8, Color = common,
			Clue = "Recovered from luggage at an old station", Drops = { { Id = "Scrapling", Weight = 70 }, { Id = "Pebble", Weight = 30 } } },
		{ Id = "TrailCapsule", Name = "Trail Capsule", Rarity = "Rare", Price = 75, OpenSeconds = 15, Color = rare,
			Clue = "Equipment left by a lost expedition", Drops = { { Id = "MossTurtle", Weight = 65 }, { Id = "CourierBird", Weight = 35 } } },
		{ Id = "PrismGeode", Name = "Prism Geode", Rarity = "Epic", Price = 240, OpenSeconds = 25, Color = epic,
			Clue = "A sealed mineral specimen from a deep quarry", Drops = { { Id = "PrismFox", Weight = 60 }, { Id = "AtlasGolem", Weight = 40 } } },
		{ Id = "AtlasSphere", Name = "Atlas Sphere", Rarity = "Legendary", Price = 650, OpenSeconds = 40, Color = legendary,
			Clue = "A mysterious instrument from an old observatory", Drops = { { Id = "StarRay", Weight = 75 }, { Id = "CloudWhale", Weight = 25 } } },
	},
}

return collection
