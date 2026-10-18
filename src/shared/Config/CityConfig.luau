--!strict

return table.freeze({
	BasePositions = table.freeze({
		Vector3.new(-170, 0, 160), Vector3.new(170, 0, 160),
		Vector3.new(-170, 0, 310), Vector3.new(170, 0, 310),
		Vector3.new(-170, 0, 460), Vector3.new(170, 0, 460),
	}),
	StationArrival = Vector3.new(0, 4, -47),
	Concourse = Vector3.new(0, 4, -150),
	PlatformArrival = Vector3.new(105, 4, -354),
	CircuitCenter = Vector3.new(270, 0, -150),
	MemoryCenter = Vector3.new(270, 0, -280),
	RewardCooldown = 90,
	Activities = table.freeze({
		Obby = table.freeze({ Name = "Depot Trial", Coins = 25, XP = 12, MinimumSeconds = 25 }),
		Circuit = table.freeze({ Name = "Circuit Run", Coins = 15, XP = 8, MinimumSeconds = 6 }),
		Memory = table.freeze({ Name = "Memory Room", Coins = 20, XP = 10, MinimumSeconds = 6 }),
	}),
})
