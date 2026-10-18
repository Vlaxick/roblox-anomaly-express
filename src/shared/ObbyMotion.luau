--!strict

local Config = require(script.Parent.Config.ObbyConfig)
local Motion = {}

function Motion.Deck(definition, now: number): CFrame
	local node = Config.Nodes[definition.Node]
	local offset = definition.Axis * (math.sin((now % definition.Period) * math.pi * 2 / definition.Period + definition.Phase) * definition.Amplitude)
	return CFrame.new(Config.Origin + node.At + offset)
end

function Motion.RotorAngle(speed: number, now: number): number
	-- CFrame stores float components: passing an epoch-sized angle destroys
	-- angular precision. Reduce to one revolution before constructing a CFrame.
	return (now % (math.pi * 2 / math.abs(speed))) * speed
end

function Motion.Fade(index: number, now: number): string
	local phase = (now + (index - 19) * 0.32) % Config.FadePeriod
	if phase < 4.8 then return "Solid" end
	if phase < 6 then return "Warning" end
	return "Gone"
end

function Motion.Steam(index: number, now: number): string
	local phase = (now + index * 1.4) % Config.SteamPeriod
	if phase < 2.7 then return "Off" end
	if phase < 3.7 then return "Warning" end
	return "Active"
end

return Motion
