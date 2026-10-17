--!strict

export type CropDefinition = {
	Id: string,
	Name: string,
	Rarity: string,
	Price: number,
	GrowSeconds: number,
	Income: number,
	Color: Color3,
}

local crops: {CropDefinition} = {
	{ Id = "MimicChest", Name = "Скриня-мімік", Rarity = "Звичайна", Price = 15, GrowSeconds = 10, Income = 3, Color = Color3.fromRGB(196, 179, 156) },
	{ Id = "WanderingLantern", Name = "Ліхтар-блукач", Rarity = "Рідкісний", Price = 75, GrowSeconds = 18, Income = 12, Color = Color3.fromRGB(164, 195, 154) },
	{ Id = "MidnightClock", Name = "Годинник опівночі", Rarity = "Епічний", Price = 240, GrowSeconds = 30, Income = 42, Color = Color3.fromRGB(227, 175, 105) },
}

local byId: {[string]: CropDefinition} = {}
for _, crop in crops do
	byId[crop.Id] = table.freeze(crop)
end

return table.freeze({ List = table.freeze(crops), ById = table.freeze(byId) })
