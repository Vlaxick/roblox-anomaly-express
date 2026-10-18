--!strict

local Config = require(script.Parent.GameConfig)
local Catalog = require(script.Parent.LootCatalog)

return Catalog.Build(Config.ActiveLootEvent)
