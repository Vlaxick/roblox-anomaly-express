--!strict

-- Archived event art. Only requested for explicitly identified Halloween items.
local Base = require(script.Parent.Parent.FarmAssets)
local Theme = require(script.Parent.Parent.Config.Theme)
local Assets = {}
local cream = Theme.Paper
local gold = Theme.Harvest
local iron = Theme.Iron
local plum = Color3.fromRGB(110, 82, 119)

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?): Part
	return Base.Part(parent, name, size, CFrame.new(pos), color, material)
end
local function ball(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3): Part
	local p = part(parent, name, size, pos, color)
	p.Shape = Enum.PartType.Ball
	return p
end
local function rod(parent: Instance, name: string, from: Vector3, to: Vector3, width: number, color: Color3)
	return Base.Part(parent, name, Vector3.new(width, width, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), color, Enum.Material.Metal)
end
local function disc(parent: Instance, name: string, radius: number, height: number, pos: Vector3, color: Color3): Part
	local p = Base.Part(parent, name, Vector3.new(height, radius * 2, radius * 2), CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), color, Enum.Material.Metal)
	p.Shape = Enum.PartType.Cylinder
	return p
end
local function ring(parent: Instance, name: string, center: Vector3, radius: number, width: number, color: Color3, vertical: boolean?)
	for i = 1, 20 do
		local a, b = (i - 1) * math.pi / 10, i * math.pi / 10
		local function point(t: number): Vector3
			return center + (vertical and Vector3.new(math.cos(t), math.sin(t), 0) or Vector3.new(math.cos(t), 0, math.sin(t))) * radius
		end
		rod(parent, name, point(a), point(b), width, color)
	end
end
local function eyes(parent: Instance, at: Vector3, spacing: number, color: Color3?)
	for _, side in {-1, 1} do
		ball(parent, "Eye", Vector3.new(0.35, 0.5, 0.2), at + Vector3.new(side * spacing, 0, 0), color or iron)
	end
end
local function finish(model: Model, id: string, at: Vector3): Model
	model.Name = id
	model.WorldPivot = CFrame.new()
	model:PivotTo(CFrame.new(at))
	return model
end

function Assets.Container(id: string, at: Vector3): Model
	local m = Instance.new("Model")
	if id == "LostSatchel" then
		-- A soft, bulging station bag, with straps, ticket and a loop handle.
		ball(m, "CanvasBag", Vector3.new(5.8, 3.6, 3.3), Vector3.new(0, 2, 0), Theme.Wood)
		ball(m, "LeatherFlap", Vector3.new(5.3, 1.8, 3.5), Vector3.new(0, 3, 0.1), Theme.Barn)
		for _, x in {-1.7, 1.7} do
			part(m, "LeatherStrap", Vector3.new(0.5, 3.3, 0.17), Vector3.new(x, 2.2, 1.66), iron)
			part(m, "Buckle", Vector3.new(0.8, 0.65, 0.22), Vector3.new(x, 2.1, 1.8), gold, Enum.Material.Metal)
		end
		ring(m, "BagHandle", Vector3.new(0, 4, 0), 0.8, 0.24, iron, true)
		local tag = part(m, "StationTicket", Vector3.new(1, 1.55, 0.12), Vector3.new(2.2, 3.2, 1.65), cream)
		tag.CFrame *= CFrame.Angles(0, 0, -0.25)
		part(m, "TicketStripe", Vector3.new(0.72, 0.15, 0.14), Vector3.new(2.2, 3.25, 1.74), Theme.Rust)
	elseif id == "WhisperCage" then
		disc(m, "CageFoot", 2.6, 0.5, Vector3.new(0, 0.4, 0), iron)
		for i = 1, 12 do
			local a = i * math.pi / 6
			local p = Vector3.new(math.cos(a) * 2.3, 0.6, math.sin(a) * 2.3)
			rod(m, "CageBar", p, p + Vector3.new(0, 4.5, 0), 0.15, iron)
			rod(m, "DomedBar", p + Vector3.new(0, 4.5, 0), Vector3.new(0, 6.1, 0), 0.16, iron)
		end
		for _, y in {0.8, 4.9} do ring(m, "CageHoop", Vector3.new(0, y, 0), 2.3, 0.2, gold) end
		ring(m, "HangingLoop", Vector3.new(0, 6.65, 0), 0.6, 0.18, gold, true)
		ball(m, "WrappedWhisper", Vector3.new(2.1, 2.5, 2), Vector3.new(0, 2.3, 0), Theme.Ghost)
		part(m, "WaxSeal", Vector3.new(0.9, 1.2, 0.25), Vector3.new(0, 2.9, 2.5), Theme.Barn)
	elseif id == "ThornCocoon" then
		ball(m, "SilkCocoon", Vector3.new(4.6, 6.8, 4.5), Vector3.new(0, 3.7, 0), plum)
		for i = 1, 7 do
			local y = 0.8 + i * 0.77
			local radius = math.sqrt(math.max(0.15, 1 - ((y - 3.7) / 3.6)^2)) * 2.35
			ring(m, "SilkBinding", Vector3.new(0, y, 0), radius, 0.13, Theme.Ghost)
		end
		for _, side in {-1, 1} do
			rod(m, "ThornStem", Vector3.new(side * 2.9, 0.2, 0), Vector3.new(side * 1.1, 6.6, 0), 0.45, Theme.Wood)
			for y = 1, 4 do
				rod(m, "Thorn", Vector3.new(side * (2.9 - y * 0.25), y, 0), Vector3.new(side * (4 - y * 0.2), y + 0.8, 0), 0.23, iron)
			end
		end
		ball(m, "CocoonSeal", Vector3.new(1.3, 1.3, 0.25), Vector3.new(0, 3.6, 2.4), Theme.Barn)
	elseif id == "MoonSeal" then
		disc(m, "RelicFoot", 2.6, 0.5, Vector3.new(0, 0.4, 0), iron)
		rod(m, "RelicStem", Vector3.new(0, 0.5, 0), Vector3.new(0, 1.9, 0), 0.55, gold)
		-- Open crescent silhouette: intentionally not a rectangular treasure chest.
		for i = 1, 18 do
			local a = math.rad(55 + (i - 1) * 250 / 18)
			local b = math.rad(55 + i * 250 / 18)
			rod(m, "MoonCrescent", Vector3.new(math.cos(a) * 2.8, 4.7 + math.sin(a) * 2.8, 0), Vector3.new(math.cos(b) * 2.8, 4.7 + math.sin(b) * 2.8, 0), 0.62, gold)
		end
		rod(m, "Suspension", Vector3.new(0, 7.4, 0), Vector3.new(0, 5.7, 0), 0.1, gold)
		ball(m, "SealedPearl", Vector3.new(2.7, 3.3, 2.7), Vector3.new(0, 4.3, 0), cream)
		ring(m, "PearlSeal", Vector3.new(0, 4.3, 0), 1.5, 0.22, plum)
		ball(m, "WaxMoon", Vector3.new(0.8, 0.8, 0.2), Vector3.new(0, 4.4, 1.42), Theme.Barn)
	else
		error("Unknown container: " .. id)
	end
	return finish(m, id, at)
end

function Assets.Character(id: string, at: Vector3): Model
	if id == "WanderingLantern" or id == "MidnightClock" then return Base.Character(id, at) end
	local m = Instance.new("Model")
	if id == "Buttonling" then
		ball(m, "SackBody", Vector3.new(2.5, 2.7, 1.9), Vector3.new(0, 2.1, 0), Theme.WoodLight)
		ball(m, "SackHead", Vector3.new(2.8, 2.6, 2.1), Vector3.new(0, 4.5, 0), Theme.Panel)
		for _, side in {-1, 1} do
			ball(m, "Boot", Vector3.new(1.1, 0.8, 1.6), Vector3.new(side * 0.8, 0.5, 0.3), Theme.Barn)
			ball(m, "Mitten", Vector3.new(0.85, 1.1, 0.9), Vector3.new(side * 1.7, 2.6, 0), Theme.WoodLight)
			ball(m, "ButtonEye", Vector3.new(0.65, 0.65, 0.2), Vector3.new(side * 0.65, 4.8, 1), iron)
			for _, dy in {-0.1, 0.1} do ball(m, "ButtonHole", Vector3.new(0.1, 0.1, 0.1), Vector3.new(side * 0.65, 4.8 + dy, 1.12), cream) end
		end
		for x = -0.6, 0.6, 0.3 do rod(m, "MouthStitch", Vector3.new(x, 3.9, 1), Vector3.new(x + 0.12, 4.13, 1), 0.07, iron) end
		part(m, "Patch", Vector3.new(0.85, 0.9, 0.15), Vector3.new(0.4, 2.2, 1), Theme.Barn)
	elseif id == "SockGhost" then
		ball(m, "SockBody", Vector3.new(3, 4.2, 2.5), Vector3.new(0, 2.9, 0), cream)
		ball(m, "CurledToe", Vector3.new(3.5, 1.4, 2.8), Vector3.new(0.8, 1.1, 0.25), cream)
		for i = 1, 3 do ring(m, "SockStripe", Vector3.new(0, 3.85 + i * 0.26, 0), 1.38 - i * 0.13, 0.17, Theme.Barn) end
		eyes(m, Vector3.new(0, 2.9, 1.2), 0.55)
		ball(m, "LittleMouth", Vector3.new(0.4, 0.55, 0.13), Vector3.new(0, 2.1, 1.25), iron)
		for _, side in {-1, 1} do ball(m, "WavingArm", Vector3.new(1.8, 0.75, 0.8), Vector3.new(side * 1.75, 2.8, 0), cream) end
	elseif id == "RavenGuard" then
		ball(m, "RavenBody", Vector3.new(3.4, 3.5, 2.8), Vector3.new(0, 2.8, 0), iron)
		ball(m, "RavenHead", Vector3.new(2.9, 2.8, 2.7), Vector3.new(0, 5.1, 0.25), iron)
		for _, side in {-1, 1} do
			local wing = ball(m, "FoldedWing", Vector3.new(1.3, 3.4, 2.7), Vector3.new(side * 1.6, 3, -0.2), plum)
			wing.CFrame *= CFrame.Angles(0, 0, side * 0.2)
			for z = 0, 2 do rod(m, "BirdClaw", Vector3.new(side * 0.8, 0.7, 0), Vector3.new(side * 0.8 + (z - 1) * 0.3, 0.3, 1.1), 0.16, gold) end
		end
		eyes(m, Vector3.new(0, 5.35, 1.53), 0.63, gold)
		ball(m, "RavenBeak", Vector3.new(0.9, 0.65, 1.5), Vector3.new(0, 4.8, 1.75), gold)
		part(m, "GuardScarf", Vector3.new(3.1, 0.65, 2.8), Vector3.new(0, 4.1, 0.2), Theme.Barn)
		part(m, "ScarfTail", Vector3.new(0.9, 2, 0.3), Vector3.new(1, 3.1, 1.5), Theme.Barn)
	elseif id == "DuskMoth" then
		for _, side in {-1, 1} do
			local wing = ball(m, "UpperWing", Vector3.new(4.5, 4.6, 0.55), Vector3.new(side * 2.3, 4.4, -0.2), plum)
			wing.CFrame *= CFrame.Angles(0, 0, -side * 0.35)
			ball(m, "LowerWing", Vector3.new(3.4, 3, 0.5), Vector3.new(side * 2, 1.9, -0.1), Theme.Barn)
			ball(m, "WingEye", Vector3.new(1.55, 1.8, 0.15), Vector3.new(side * 2.5, 4.6, 0.15), gold)
			ball(m, "WingPupil", Vector3.new(0.75, 1, 0.16), Vector3.new(side * 2.5, 4.6, 0.25), iron)
			rod(m, "Antenna", Vector3.new(side * 0.3, 5.1, 0), Vector3.new(side * 1.2, 6.6, 0), 0.16, iron)
			ball(m, "AntennaTip", Vector3.new(0.4, 0.5, 0.4), Vector3.new(side * 1.2, 6.6, 0), gold)
		end
		ball(m, "FurryBody", Vector3.new(1.7, 4.2, 1.8), Vector3.new(0, 3.1, 0.4), Theme.Panel)
		eyes(m, Vector3.new(0, 4.5, 1.25), 0.36)
	elseif id == "MoonCat" then
		ball(m, "CatBody", Vector3.new(3.5, 3.9, 2.8), Vector3.new(0, 2.5, 0), Theme.Ghost)
		ball(m, "CatHead", Vector3.new(3.8, 3.1, 2.9), Vector3.new(0, 5.1, 0.2), Theme.Ghost)
		for _, side in {-1, 1} do
			local ear = Instance.new("WedgePart")
			ear.Name = "PointedEar"; ear.Size = Vector3.new(1.1, 1.6, 1.5)
			ear.CFrame = CFrame.new(side * 1.25, 6.6, 0) * CFrame.Angles(0, side * math.pi / 2, 0)
			ear.Color = Theme.Ghost; ear.Material = Enum.Material.SmoothPlastic
			ear.Anchored = true; ear.CanCollide = false; ear.Parent = m
			ball(m, "InnerEar", Vector3.new(0.45, 0.75, 0.13), Vector3.new(side * 1.4, 6.65, 0.57), plum)
			ball(m, "Paw", Vector3.new(1.3, 0.8, 1.6), Vector3.new(side * 1, 0.5, 0.6), cream)
		end
		eyes(m, Vector3.new(0, 5.3, 1.6), 0.75, gold)
		ball(m, "Nose", Vector3.new(0.4, 0.3, 0.15), Vector3.new(0, 4.7, 1.68), Theme.Barn)
		for i = 1, 16 do
			local a = math.rad(-100 + (i - 1) * 260 / 16)
			local b = math.rad(-100 + i * 260 / 16)
			rod(m, "CrescentTail", Vector3.new(2.7 + math.cos(a) * 1.9, 3 + math.sin(a) * 1.9, -0.6), Vector3.new(2.7 + math.cos(b) * 1.9, 3 + math.sin(b) * 1.9, -0.6), 0.5, gold)
		end
		ball(m, "MoonMark", Vector3.new(0.5, 0.65, 0.12), Vector3.new(0, 5.9, 1.55), gold)
	elseif id == "PumpkinKing" then
		ball(m, "RoyalCoat", Vector3.new(3.4, 3.6, 2.5), Vector3.new(0, 2.5, 0), plum)
		ball(m, "PumpkinHead", Vector3.new(4.4, 3.8, 3.5), Vector3.new(0, 5.6, 0), Theme.Pumpkin)
		for _, side in {-1, 1} do
			ball(m, "PumpkinLobe", Vector3.new(2.4, 3.7, 3.4), Vector3.new(side * 1.2, 5.6, 0), Theme.Pumpkin)
			ball(m, "RoyalBoot", Vector3.new(1.3, 0.8, 1.8), Vector3.new(side * 0.9, 0.5, 0.6), iron)
			ball(m, "RoyalGlove", Vector3.new(1, 1.1, 1), Vector3.new(side * 2.2, 3.6, 0), cream)
		end
		eyes(m, Vector3.new(0, 5.9, 1.77), 0.85, cream)
		part(m, "CarvedSmile", Vector3.new(1.8, 0.3, 0.12), Vector3.new(0, 4.9, 1.78), iron)
		ring(m, "CrownBand", Vector3.new(0, 7.3, 0), 1.45, 0.35, gold)
		for i = 1, 5 do
			local a = i * math.pi * 2 / 5
			rod(m, "CrownPoint", Vector3.new(math.cos(a) * 1.45, 7.3, math.sin(a) * 1.45), Vector3.new(math.cos(a) * 1.45, 8.4, math.sin(a) * 1.45), 0.32, gold)
		end
		rod(m, "RoyalStaff", Vector3.new(2.8, 0.3, 0), Vector3.new(2.8, 6, 0), 0.25, gold)
		ball(m, "StaffPearl", Vector3.new(0.8, 0.9, 0.8), Vector3.new(2.8, 6.3, 0), cream)
	else
		error("Unknown character: " .. id)
	end
	return finish(m, id, at)
end

return Assets
