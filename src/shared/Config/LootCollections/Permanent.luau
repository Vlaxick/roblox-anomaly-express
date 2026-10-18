--!strict

local Types = require(script.Parent.Parent.LootTypes)
local common = Color3.fromRGB(208, 191, 162)
local rare = Color3.fromRGB(164, 195, 154)
local epic = Color3.fromRGB(175, 188, 225)
local legendary = Color3.fromRGB(239, 186, 98)

-- Year-round expedition companions, independent of the world's seasonal skin.
local collection: Types.Collection = {
	Id = "Permanent",
	Name = "Постійна колекція",
	Characters = {
		{ Id = "Scrapling", Name = "Шестерик", Rarity = "Звичайний", Income = 3, SellPrice = 8, Color = common },
		{ Id = "Pebble", Name = "Камінчик", Rarity = "Звичайний", Income = 5, SellPrice = 12, Color = common },
		{ Id = "MossTurtle", Name = "Мохоспин", Rarity = "Рідкісний", Income = 13, SellPrice = 35, Color = rare },
		{ Id = "CourierBird", Name = "Поштарик", Rarity = "Рідкісний", Income = 18, SellPrice = 45, Color = rare },
		{ Id = "PrismFox", Name = "Призма", Rarity = "Епічний", Income = 44, SellPrice = 110, Color = epic },
		{ Id = "AtlasGolem", Name = "Атлас", Rarity = "Епічний", Income = 60, SellPrice = 140, Color = epic },
		{ Id = "StarRay", Name = "Зорекрил", Rarity = "Легендарний", Income = 130, SellPrice = 300, Color = legendary },
		{ Id = "CloudWhale", Name = "Небоплав", Rarity = "Легендарний", Income = 180, SellPrice = 400, Color = legendary },
	},
	Finds = {
		{ Id = "TravelCase", Name = "Дорожній кофр", Rarity = "Звичайна", Price = 15, OpenSeconds = 8, Color = common,
			Clue = "Знайдений серед багажу на старій станції", Drops = { { Id = "Scrapling", Weight = 70 }, { Id = "Pebble", Weight = 30 } } },
		{ Id = "TrailCapsule", Name = "Мандрівна капсула", Rarity = "Рідкісна", Price = 75, OpenSeconds = 15, Color = rare,
			Clue = "Спорядження загубленої експедиції", Drops = { { Id = "MossTurtle", Weight = 65 }, { Id = "CourierBird", Weight = 35 } } },
		{ Id = "PrismGeode", Name = "Кристалічна жеода", Rarity = "Епічна", Price = 240, OpenSeconds = 25, Color = epic,
			Clue = "Закрита кам’яна знахідка з глибин кар’єру", Drops = { { Id = "PrismFox", Weight = 60 }, { Id = "AtlasGolem", Weight = 40 } } },
		{ Id = "AtlasSphere", Name = "Астральна сфера", Rarity = "Легендарна", Price = 650, OpenSeconds = 40, Color = legendary,
			Clue = "Загадковий прилад зі старої обсерваторії", Drops = { { Id = "StarRay", Weight = 75 }, { Id = "CloudWhale", Weight = 25 } } },
	},
}

return collection
