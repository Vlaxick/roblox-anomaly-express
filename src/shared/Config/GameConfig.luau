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
	EyeFlowerProductionSeconds = 5,
	EyeFlowerEnergyPerCycle = 5,
	EyeFlowerStorageLimit = 100,
	EyeFlowerCollectionXP = 5,
}

return table.freeze(GameConfig)

