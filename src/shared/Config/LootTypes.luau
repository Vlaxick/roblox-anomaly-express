--!strict

export type Character = { Id: string, Name: string, Rarity: string, Income: number, SellPrice: number, Color: Color3 }
export type Drop = { Id: string, Weight: number }
export type Find = { Id: string, Name: string, Rarity: string, Price: number, OpenSeconds: number, Color: Color3, Clue: string, Drops: {Drop} }
export type Collection = { Id: string, Name: string, Finds: {Find}, Characters: {Character} }

return table.freeze({})
