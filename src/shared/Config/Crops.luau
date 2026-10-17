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
	{ Id = "Pumpkin", Name = "Гарбуз", Rarity = "Звичайний", Price = 15, GrowSeconds = 10, Income = 3, Color = Color3.fromRGB(116, 94, 70) },
	{ Id = "ForestMushroom", Name = "Лісовий гриб", Rarity = "Рідкісний", Price = 75, GrowSeconds = 18, Income = 12, Color = Color3.fromRGB(70, 103, 55) },
	{ Id = "GoldenTree", Name = "Золота яблуня", Rarity = "Епічна", Price = 240, GrowSeconds = 30, Income = 42, Color = Color3.fromRGB(151, 91, 24) },
}

local byId: {[string]: CropDefinition} = {}
for _, crop in crops do
	byId[crop.Id] = table.freeze(crop)
end

return table.freeze({ List = table.freeze(crops), ById = table.freeze(byId) })
