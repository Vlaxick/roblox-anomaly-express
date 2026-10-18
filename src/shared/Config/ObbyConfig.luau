--!strict

-- Authored route, not a ladder of interchangeable square platforms.
local nodes = {
	{At = Vector3.new(0, 8, 102), Size = Vector3.new(16, 1.2, 16), Section = 1},
	{At = Vector3.new(0, 8, 89), Size = Vector3.new(3, 1.2, 16), Section = 1},
	{At = Vector3.new(-10, 9, 78), Size = Vector3.new(20, 1.2, 3), Section = 1},
	{At = Vector3.new(-20, 10, 65), Size = Vector3.new(3, 1.2, 18), Section = 1},
	{At = Vector3.new(-20, 11, 50), Size = Vector3.new(12, 1.2, 12), Section = 1},
	{At = Vector3.new(-20, 12, 34), Size = Vector3.new(10, 1.2, 18), Section = 2},
	{At = Vector3.new(-10, 13, 20), Size = Vector3.new(20, 1.2, 8), Section = 2},
	{At = Vector3.new(10, 14, 20), Size = Vector3.new(16, 1.2, 8), Section = 2},
	{At = Vector3.new(30, 15, 20), Size = Vector3.new(12, 1.2, 12), Section = 2},
	{At = Vector3.new(30, 17, 4), Size = Vector3.new(12, 1.2, 12), Section = 3},
	{At = Vector3.new(46, 18, -8), Size = Vector3.new(10, 1.2, 10), Section = 3},
	{At = Vector3.new(46, 20, -28), Size = Vector3.new(12, 1.2, 12), Section = 3},
	{At = Vector3.new(28, 22, -38), Size = Vector3.new(10, 1.2, 10), Section = 3},
	{At = Vector3.new(10, 23, -38), Size = Vector3.new(12, 1.2, 12), Section = 3},
	{At = Vector3.new(10, 24, -58), Size = Vector3.new(24, 1.2, 24), Section = 4},
	{At = Vector3.new(-16, 26, -72), Size = Vector3.new(24, 1.2, 24), Section = 4},
	{At = Vector3.new(-42, 28, -72), Size = Vector3.new(16, 1.2, 16), Section = 4},
	{At = Vector3.new(-42, 29, -94), Size = Vector3.new(14, 1.2, 14), Section = 5},
	{At = Vector3.new(-26, 31, -94), Size = Vector3.new(8, 1.2, 8), Section = 5},
	{At = Vector3.new(-12, 33, -94), Size = Vector3.new(8, 1.2, 8), Section = 5},
	{At = Vector3.new(2, 35, -94), Size = Vector3.new(8, 1.2, 8), Section = 5},
	{At = Vector3.new(16, 37, -94), Size = Vector3.new(8, 1.2, 8), Section = 5},
	{At = Vector3.new(32, 38, -94), Size = Vector3.new(14, 1.2, 14), Section = 5},
	{At = Vector3.new(48, 40, -82), Size = Vector3.new(6, 1.2, 18), Section = 6},
	{At = Vector3.new(48, 42, -60), Size = Vector3.new(6, 1.2, 18), Section = 6},
	{At = Vector3.new(38, 44, -45), Size = Vector3.new(20, 1.2, 5), Section = 6},
	{At = Vector3.new(18, 46, -45), Size = Vector3.new(12, 1.2, 5), Section = 6},
	{At = Vector3.new(0, 48, -45), Size = Vector3.new(18, 1.2, 18), Section = 6},
}
for _, node in nodes do table.freeze(node) end

return table.freeze({
	Origin = Vector3.new(-325, 0, -210),
	Bounds = Vector3.new(90, 90, 125),
	Nodes = table.freeze(nodes),
	Checkpoints = table.freeze({[1] = true, [10] = true, [18] = true}),
	Sections = table.freeze({
		table.freeze({Name = "Rail balance", Hint = "Follow the narrow rails. Jump the broken corners."}),
		table.freeze({Name = "Pressure alley", Hint = "Wait for steam to stop. Amber means it is about to fire."}),
		table.freeze({Name = "Cargo lifts", Hint = "Ride the blue cargo decks. Wait until the next landing is close."}),
		table.freeze({Name = "Rotor room", Hint = "Jump over the striped arms. Do not touch the red machinery."}),
		table.freeze({Name = "Fading stairs", Hint = "Amber plates will vanish. Wait for blue, then keep moving."}),
		table.freeze({Name = "Roof run", Hint = "Clear the red hurdles and follow the rafters to the finish bell."}),
	}),
	Movers = table.freeze({
		table.freeze({Node = 11, Axis = Vector3.zAxis, Amplitude = 4, Period = 6, Phase = 0}),
		table.freeze({Node = 13, Axis = Vector3.xAxis, Amplitude = 4, Period = 6, Phase = 1.8}),
	}),
	FadeNodes = table.freeze({19, 20, 21, 22}),
	FadePeriod = 8,
	SteamPeriod = 6,
})
