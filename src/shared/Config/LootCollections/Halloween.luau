--!strict

local Types = require(script.Parent.Parent.LootTypes)
local common = Color3.fromRGB(208, 191, 162)
local rare = Color3.fromRGB(164, 195, 154)
local epic = Color3.fromRGB(198, 167, 218)
local legendary = Color3.fromRGB(239, 186, 98)

-- Preserved prototype collection, NOT available unless its event is enabled.
local collection: Types.Collection = {
	Id = "Halloween",
	Name = "Halloween",
	Characters = {
		{ Id = "Buttonling", Name = "Buttonling", Rarity = "Common", Income = 3, SellPrice = 8, Color = common },
		{ Id = "SockGhost", Name = "Sock Ghost", Rarity = "Common", Income = 5, SellPrice = 12, Color = common },
		{ Id = "WanderingLantern", Name = "Walking Lantern", Rarity = "Rare", Income = 13, SellPrice = 35, Color = rare },
		{ Id = "RavenGuard", Name = "Raven Guard", Rarity = "Rare", Income = 18, SellPrice = 45, Color = rare },
		{ Id = "DuskMoth", Name = "Dusk Moth", Rarity = "Epic", Income = 44, SellPrice = 110, Color = epic },
		{ Id = "MidnightClock", Name = "Midnight Keeper", Rarity = "Epic", Income = 60, SellPrice = 140, Color = epic },
		{ Id = "MoonCat", Name = "Moon Cat", Rarity = "Legendary", Income = 130, SellPrice = 300, Color = legendary },
		{ Id = "PumpkinKing", Name = "Pumpkin King", Rarity = "Legendary", Income = 180, SellPrice = 400, Color = legendary },
	},
	Finds = {
		{ Id = "LostSatchel", Name = "Lost Satchel", Rarity = "Common", Price = 15, OpenSeconds = 8, Color = common,
			Clue = "Lost at an abandoned station", Drops = { { Id = "Buttonling", Weight = 70 }, { Id = "SockGhost", Weight = 30 } } },
		{ Id = "WhisperCage", Name = "Whisper Cage", Rarity = "Rare", Price = 75, OpenSeconds = 15, Color = rare,
			Clue = "Hanging from branches in a dark forest", Drops = { { Id = "WanderingLantern", Weight = 65 }, { Id = "RavenGuard", Weight = 35 } } },
		{ Id = "ThornCocoon", Name = "Dusk Cocoon", Rarity = "Epic", Price = 240, OpenSeconds = 25, Color = epic,
			Clue = "Hidden among roots and cobwebs", Drops = { { Id = "DuskMoth", Weight = 60 }, { Id = "MidnightClock", Weight = 40 } } },
		{ Id = "MoonSeal", Name = "Moon Seal", Rarity = "Legendary", Price = 650, OpenSeconds = 40, Color = legendary,
			Clue = "A relic from a forgotten shrine", Drops = { { Id = "MoonCat", Weight = 75 }, { Id = "PumpkinKing", Weight = 25 } } },
	},
}

return collection
