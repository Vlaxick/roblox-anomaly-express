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
	StartingStands = 2,
	MaxStands = 8,
	IncomeInterval = 5,
	OpenXP = 10,
	StandPrices = table.freeze({ 0, 0, 50, 100, 180, 300, 480, 750 }),
}

return table.freeze(GameConfig)

