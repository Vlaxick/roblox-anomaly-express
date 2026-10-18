--!strict

local Types = require(script.Parent.Parent.LootTypes)
local common = Color3.fromRGB(208, 191, 162)
local rare = Color3.fromRGB(164, 195, 154)
local epic = Color3.fromRGB(198, 167, 218)
local legendary = Color3.fromRGB(239, 186, 98)

-- Preserved prototype collection, NOT available unless its event is enabled.
local collection: Types.Collection = {
	Id = "Halloween",
	Name = "Геловін",
	Characters = {
		{ Id = "Buttonling", Name = "Ґудзик", Rarity = "Звичайний", Income = 3, SellPrice = 8, Color = common },
		{ Id = "SockGhost", Name = "Шкарпетик", Rarity = "Звичайний", Income = 5, SellPrice = 12, Color = common },
		{ Id = "WanderingLantern", Name = "Ліхтар-блукач", Rarity = "Рідкісний", Income = 13, SellPrice = 35, Color = rare },
		{ Id = "RavenGuard", Name = "Ворон-вартовий", Rarity = "Рідкісний", Income = 18, SellPrice = 45, Color = rare },
		{ Id = "DuskMoth", Name = "Сутінковий метелик", Rarity = "Епічний", Income = 44, SellPrice = 110, Color = epic },
		{ Id = "MidnightClock", Name = "Хранитель опівночі", Rarity = "Епічний", Income = 60, SellPrice = 140, Color = epic },
		{ Id = "MoonCat", Name = "Місячний кіт", Rarity = "Легендарний", Income = 130, SellPrice = 300, Color = legendary },
		{ Id = "PumpkinKing", Name = "Гарбузовий король", Rarity = "Легендарний", Income = 180, SellPrice = 400, Color = legendary },
	},
	Finds = {
		{ Id = "LostSatchel", Name = "Забута валіза", Rarity = "Звичайна", Price = 15, OpenSeconds = 8, Color = common,
			Clue = "Загублена на покинутій станції", Drops = { { Id = "Buttonling", Weight = 70 }, { Id = "SockGhost", Weight = 30 } } },
		{ Id = "WhisperCage", Name = "Клітка шепотів", Rarity = "Рідкісна", Price = 75, OpenSeconds = 15, Color = rare,
			Clue = "Висить на гілках у темному лісі", Drops = { { Id = "WanderingLantern", Weight = 65 }, { Id = "RavenGuard", Weight = 35 } } },
		{ Id = "ThornCocoon", Name = "Кокон сутінків", Rarity = "Епічна", Price = 240, OpenSeconds = 25, Color = epic,
			Clue = "Ховається серед коріння й павутиння", Drops = { { Id = "DuskMoth", Weight = 60 }, { Id = "MidnightClock", Weight = 40 } } },
		{ Id = "MoonSeal", Name = "Місячна печать", Rarity = "Легендарна", Price = 650, OpenSeconds = 40, Color = legendary,
			Clue = "Реліквія забутого святилища", Drops = { { Id = "MoonCat", Weight = 75 }, { Id = "PumpkinKing", Weight = 25 } } },
	},
}

return collection
