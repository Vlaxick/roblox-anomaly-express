--!strict

local Types = require(script.Parent.LootTypes)
local permanent: Types.Collection = require(script.Parent.LootCollections.Permanent)
local halloween: Types.Collection = require(script.Parent.LootCollections.Halloween)
local collections: {Types.Collection} = { permanent, halloween }
local Catalog = {}

-- Availability is an explicit setting, independent of world decoration or date.
-- Tests can build either catalogue without changing the live event.
function Catalog.Build(activeEvent: string)
	assert(activeEvent == "" or activeEvent == halloween.Id, "Unknown loot event: " .. activeEvent)
	local list: {Types.Find} = {}
	local characters: {Types.Character} = {}
	local byId: {[string]: Types.Find} = {}
	local allById: {[string]: Types.Find} = {}
	local characterById: {[string]: Types.Character} = {}
	local findCollections: {[string]: string} = {}
	local characterCollections: {[string]: string} = {}
	for _, collection in collections do
		local available = collection.Id == permanent.Id or collection.Id == activeEvent
		for _, c in collection.Characters do
			assert(not characterById[c.Id], "Duplicate character: " .. c.Id)
			assert(c.Income > 0 and c.SellPrice >= 0, "Invalid character economy: " .. c.Id)
			characterById[c.Id] = c
			characterCollections[c.Id] = collection.Id
			if available then table.insert(characters, c) end
			if not table.isfrozen(c) then table.freeze(c) end
		end
		for _, f in collection.Finds do
			assert(not allById[f.Id], "Duplicate find: " .. f.Id)
			assert(f.Price > 0 and f.OpenSeconds > 0, "Invalid find economy: " .. f.Id)
			local total = 0
			for _, drop in f.Drops do
				assert(characterCollections[drop.Id] == collection.Id, "Cross-collection drop: " .. drop.Id)
				assert(drop.Weight > 0 and drop.Weight % 1 == 0, "Invalid drop weight: " .. f.Id)
				total += drop.Weight
				if not table.isfrozen(drop) then table.freeze(drop) end
			end
			assert(total == 100, "Find odds must total 100: " .. f.Id)
			if not table.isfrozen(f.Drops) then table.freeze(f.Drops) end
			if not table.isfrozen(f) then table.freeze(f) end
			allById[f.Id] = f
			findCollections[f.Id] = collection.Id
			if available then byId[f.Id] = f; table.insert(list, f) end
		end
	end
	return table.freeze({
		List = table.freeze(list), ById = table.freeze(byId), AllById = table.freeze(allById),
		Characters = table.freeze(characters), CharacterById = table.freeze(characterById),
		FindCollectionById = table.freeze(findCollections), CharacterCollectionById = table.freeze(characterCollections),
		ActiveEvent = activeEvent,
		Label = activeEvent == "" and permanent.Name or (permanent.Name .. " + " .. halloween.Name),
	})
end

return table.freeze(Catalog)
