--!strict

local GameConfig = {
	MaxPlayerLevel = 50,
	SpeedBonusPerLevel = 0.003,
	MaxSpeedBonus = 0.15,
	BaseWalkSpeed = 16,
	TrainIntervalSeconds = 300,
	TrainBoardingSeconds = 45,
	ExpeditionDurationSeconds = 300,
	FieldXpLossOnFailure = 0.5,
	PlotCount = 6,
	StartingCoins = 40,
	StartingBeds = 2,
	MaxBeds = 8,
	IncomeInterval = 5,
	GrowXP = 10,
	BedPrices = table.freeze({ 0, 0, 50, 100, 180, 300, 480, 750 }),
}

return table.freeze(GameConfig)

