--!strict

local Theme = require(script.Parent.Config.Theme)
local Assets = {}

function Assets.Part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function ball(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3): Part
	local p = Assets.Part(parent, name, size, CFrame.new(pos), color)
	p.Shape = Enum.PartType.Ball
	return p
end

local function branch(parent: Instance, from: Vector3, to: Vector3, thickness: number)
	local p = Assets.Part(parent, "Branch", Vector3.new(thickness, thickness, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), Theme.Wood, Enum.Material.Wood)
	return p
end

local function pumpkin(parent: Instance, origin: Vector3, scale: number)
	ball(parent, "PumpkinBody", Vector3.new(4, 3.3, 4) * scale, origin + Vector3.new(0, 1.65, 0) * scale, Theme.Pumpkin)
	for rib = 1, 7 do
		local angle = rib * math.pi * 2 / 7
		local pos = origin + Vector3.new(math.cos(angle) * 1.1, 1.65, math.sin(angle) * 1.1) * scale
		ball(parent, "PumpkinRib", Vector3.new(2.1, 3.25, 2.1) * scale, pos, rib % 2 == 0 and Theme.Pumpkin or Theme.Pumpkin:Lerp(Theme.Harvest, 0.13))
	end
	Assets.Part(parent, "Stem", Vector3.new(0.55, 1.2, 0.55) * scale, CFrame.new(origin + Vector3.new(0, 3.7, 0) * scale) * CFrame.Angles(0, 0, 0.25), Theme.Moss, Enum.Material.Wood)
	local leaf = ball(parent, "Leaf", Vector3.new(2, 0.3, 1) * scale, origin + Vector3.new(1, 3.35, 0.2) * scale, Theme.Green)
	leaf.CFrame *= CFrame.Angles(0, 0.5, 0.2)
end

local function candleLight(anchor: BasePart, brightness: number, range: number)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 187, 101)
	light.Brightness = brightness
	light.Range = range
	light.Parent = anchor
end

local function mimic(parent: Instance)
	Assets.Part(parent, "ChestBody", Vector3.new(5.6, 2.3, 3.5), CFrame.new(0, 1.5, 0), Theme.Wood, Enum.Material.WoodPlanks)
	Assets.Part(parent, "Mouth", Vector3.new(5.3, 1, 0.25), CFrame.new(0, 2.8, 1.8), Theme.Night)
	Assets.Part(parent, "OpenLid", Vector3.new(5.9, 1.15, 3.8), CFrame.new(0, 3.6, -0.2) * CFrame.Angles(-0.2, 0, 0), Theme.WoodLight, Enum.Material.WoodPlanks)
	for _, x in {-2.2, 2.2} do
		Assets.Part(parent, "IronBand", Vector3.new(0.4, 2.5, 3.65), CFrame.new(x, 1.5, 0), Theme.Iron, Enum.Material.Metal)
		Assets.Part(parent, "LidBand", Vector3.new(0.42, 1.2, 3.9), CFrame.new(x, 3.6, -0.2) * CFrame.Angles(-0.2, 0, 0), Theme.Iron, Enum.Material.Metal)
		ball(parent, "ClawFoot", Vector3.new(1.4, 0.8, 1.8), Vector3.new(x, 0.4, 1), Theme.Iron)
	end
	for _, x in {-1.2, 1.2} do
		ball(parent, "MimicEye", Vector3.new(1, 0.75, 0.35), Vector3.new(x, 3.8, 1.83), Theme.Harvest)
		ball(parent, "Pupil", Vector3.new(0.25, 0.5, 0.15), Vector3.new(x, 3.8, 2.03), Theme.Night)
	end
	for x = -1.8, 1.8, 0.72 do
		local tooth = Instance.new("WedgePart")
		tooth.Name = "MimicFang"
		tooth.Size = Vector3.new(0.55, 0.8, 0.4)
		tooth.CFrame = CFrame.new(x, 2.95, 2) * CFrame.Angles(0, math.pi / 2, math.pi)
		tooth.Color = Theme.Paper
		tooth.Material = Enum.Material.SmoothPlastic
		tooth.Anchored = true
		tooth.CanCollide = false
		tooth.Parent = parent
	end
	Assets.Part(parent, "BrassLock", Vector3.new(0.65, 0.8, 0.2), CFrame.new(0, 1.4, 1.88), Theme.Harvest, Enum.Material.Metal)
	ball(parent, "Tongue", Vector3.new(1.6, 0.3, 1.3), Vector3.new(0, 2.2, 2.2), Theme.Barn)

end

local function wanderingLantern(parent: Instance)
	for _, side in {-1, 1} do
		for _, z in {-1, 1} do
			local from = Vector3.new(side * 0.9, 1.7, z * 0.7)
			local to = Vector3.new(side * 2.1, 0.35, z * 1.8)
			Assets.Part(parent, "WalkingLeg", Vector3.new(0.35, 0.35, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), Theme.Iron, Enum.Material.Metal)
			ball(parent, "Foot", Vector3.new(1, 0.4, 1.5), to, Theme.Iron)
		end
	end
	Assets.Part(parent, "LanternBase", Vector3.new(3.3, 0.5, 3), CFrame.new(0, 1.8, 0), Theme.Iron, Enum.Material.Metal)
	for _, x in {-1.2, 1.2} do
		for _, z in {-1, 1} do
			Assets.Part(parent, "LanternFrame", Vector3.new(0.22, 3.2, 0.22), CFrame.new(x, 3.5, z), Theme.Iron, Enum.Material.Metal)
		end
	end
	local glass = Assets.Part(parent, "AmberGlass", Vector3.new(2.35, 2.9, 2), CFrame.new(0, 3.5, 0), Theme.Harvest, Enum.Material.Glass)
	glass.Transparency = 0.6
	local flame = ball(parent, "LivingFlame", Vector3.new(1.25, 2.1, 1.1), Vector3.new(0, 3.3, 0), Theme.Paper)
	ball(parent, "FlameTip", Vector3.new(0.65, 1.25, 0.6), Vector3.new(0.2, 4.3, 0), Theme.Harvest)
	for _, x in {-0.25, 0.25} do
		ball(parent, "FlameEye", Vector3.new(0.18, 0.32, 0.16), Vector3.new(x, 3.6, 0.58), Theme.Night)
	end
	Assets.Part(parent, "LanternRoof", Vector3.new(3.3, 0.55, 3), CFrame.new(0, 5.25, 0), Theme.Iron, Enum.Material.Metal)
	Assets.Part(parent, "RoofCrown", Vector3.new(2.1, 0.6, 1.9), CFrame.new(0, 5.65, 0), Theme.Iron, Enum.Material.Metal)
	for segment = 1, 8 do
		local angle = segment * math.pi / 4
		Assets.Part(parent, "CarryingRing", Vector3.new(0.18, 0.65, 0.18), CFrame.new(math.cos(angle) * 0.65, 6.35 + math.sin(angle) * 0.65, 0) * CFrame.Angles(0, 0, angle), Theme.Iron, Enum.Material.Metal)
	end
	candleLight(flame, 0.8, 10)
end

local function midnightClock(parent: Instance)
	Assets.Part(parent, "ClockFoot", Vector3.new(4.8, 0.7, 3.1), CFrame.new(0, 0.4, 0), Theme.Iron, Enum.Material.Wood)
	Assets.Part(parent, "ClockCabinet", Vector3.new(3.5, 7.3, 2.3), CFrame.new(0, 4.2, 0), Theme.Barn:Lerp(Theme.Iron, 0.5), Enum.Material.WoodPlanks)
	Assets.Part(parent, "PendulumWindow", Vector3.new(2.6, 3.9, 0.15), CFrame.new(0, 3.2, 1.22), Theme.Night)
	Assets.Part(parent, "PendulumRod", Vector3.new(0.14, 2.7, 0.16), CFrame.new(0.45, 3.4, 1.4) * CFrame.Angles(0, 0, 0.2), Theme.Harvest, Enum.Material.Metal)
	ball(parent, "PendulumBob", Vector3.new(1, 1, 0.35), Vector3.new(0.7, 2.1, 1.5), Theme.Harvest)
	for _, x in {-1.6, 1.6} do
		Assets.Part(parent, "CabinetTrim", Vector3.new(0.24, 6.6, 0.25), CFrame.new(x, 4.1, 1.25), Theme.WoodLight)
		ball(parent, "GhostHand", Vector3.new(1.4, 0.65, 0.85), Vector3.new(x * 1.7, 4.8, 0), Theme.Ghost)
		for finger = 1, 3 do
			ball(parent, "GhostFinger", Vector3.new(0.3, 0.8, 0.3), Vector3.new(x * 1.95, 5 + finger * 0.13, -0.5 + finger * 0.3), Theme.Ghost)
		end
	end
	local rim = Assets.Part(parent, "ClockRim", Vector3.new(0.35, 3.9, 3.9), CFrame.new(0, 7.2, 1.2) * CFrame.Angles(0, math.pi / 2, 0), Theme.WoodLight, Enum.Material.Metal)
	rim.Shape = Enum.PartType.Cylinder
	local face = Assets.Part(parent, "MidnightFace", Vector3.new(0.2, 3.35, 3.35), CFrame.new(0, 7.2, 1.43) * CFrame.Angles(0, math.pi / 2, 0), Theme.Paper)
	face.Shape = Enum.PartType.Cylinder
	for tick = 1, 12 do
		local angle = tick * math.pi / 6
		Assets.Part(parent, "HourMark", Vector3.new(0.12, 0.27, 0.08), CFrame.new(math.sin(angle) * 1.38, 7.2 + math.cos(angle) * 1.38, 1.58) * CFrame.Angles(0, 0, -angle), Theme.Iron)
	end
	Assets.Part(parent, "MinuteHand", Vector3.new(0.13, 1.4, 0.12), CFrame.new(0, 7.85, 1.72), Theme.Iron)
	Assets.Part(parent, "HourHand", Vector3.new(0.18, 1, 0.12), CFrame.new(0.1, 7.65, 1.8) * CFrame.Angles(0, 0, -0.2), Theme.Barn)
	ball(parent, "HandPin", Vector3.new(0.3, 0.3, 0.2), Vector3.new(0, 7.2, 1.88), Theme.Harvest)
	Assets.Part(parent, "ClockCrown", Vector3.new(4.1, 0.55, 2.8), CFrame.new(0, 9.3, 0), Theme.Iron, Enum.Material.Wood)
end

function Assets.Crop(id: string, at: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "Crop"
	if id == "MimicChest" then
		mimic(model)
	elseif id == "WanderingLantern" then
		wanderingLantern(model)
	else
		midnightClock(model)
	end
	model.WorldPivot = CFrame.new()
	model:PivotTo(CFrame.new(at))
	return model
end

function Assets.Pumpkins(parent: Instance, at: Vector3)
	local model = Instance.new("Model")
	model.Name = "HalloweenPumpkins"
	model.Parent = parent
	pumpkin(model, at, 0.7)
	pumpkin(model, at + Vector3.new(2.4, 0, 0.5), 0.4)
	for _, x in {-0.6, 0.6} do
		ball(model, "CarvedEye", Vector3.new(0.5, 0.5, 0.12), at + Vector3.new(x, 1.55, 1.46), Theme.Paper)
	end
	local grin = Assets.Part(model, "CarvedGrin", Vector3.new(1.6, 0.3, 0.13), CFrame.new(at + Vector3.new(0, 0.95, 1.5)), Theme.Harvest)
	candleLight(grin, 0.8, 12)
end

function Assets.PathLantern(parent: Instance, at: Vector3)
	Assets.Part(parent, "LanternPost", Vector3.new(0.55, 5.8, 0.55), CFrame.new(at + Vector3.new(0, 2.9, 0)), Theme.Wood, Enum.Material.Wood)
	local bulb = Assets.Part(parent, "CandleGlass", Vector3.new(1.25, 1.8, 1.25), CFrame.new(at + Vector3.new(0, 6, 0)), Color3.fromRGB(255, 215, 144), Enum.Material.SmoothPlastic)
	Assets.Part(parent, "LanternCap", Vector3.new(1.65, 0.4, 1.65), CFrame.new(at + Vector3.new(0, 7.1, 0)), Theme.Iron, Enum.Material.Metal)
	Assets.Part(parent, "LanternBase", Vector3.new(1.65, 0.3, 1.65), CFrame.new(at + Vector3.new(0, 5, 0)), Theme.Iron, Enum.Material.Metal)
	candleLight(bulb, 2.5, 34)
end

function Assets.Cobweb(parent: Instance, at: Vector3, scale: number)
	local previous: Vector3? = nil
	for spoke = 0, 6 do
		local angle = spoke * math.pi / 12
		local edge = at + Vector3.new(math.cos(angle), -math.sin(angle), 0) * scale
		Assets.Part(parent, "CobwebSpoke", Vector3.new(0.035, 0.035, scale), CFrame.lookAt((at + edge) / 2, edge), Theme.Ghost)
		if previous then
			for _, radius in {0.4, 0.7, 1} do
				local from = at:Lerp(previous, radius)
				local to = at:Lerp(edge, radius)
				Assets.Part(parent, "CobwebThread", Vector3.new(0.035, 0.035, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), Theme.Ghost)
			end
		end
		previous = edge
	end
end

function Assets.Tree(parent: Instance, at: Vector3, scale: number, color: Color3)
	local model = Instance.new("Model")
	model.Name = "AutumnMaple"
	model.Parent = parent
	branch(model, at, at + Vector3.new(0, 9, 0) * scale, 1.8 * scale)
	for branchIndex = 1, 5 do
		local angle = branchIndex * math.pi * 2 / 5
		local center = at + Vector3.new(math.cos(angle) * 3.7, 10 + branchIndex % 2 * 2, math.sin(angle) * 3.7) * scale
		branch(model, at + Vector3.new(0, 5, 0) * scale, center, 0.8 * scale)
		ball(model, "AutumnLeaves", Vector3.new(8, 7, 8) * scale, center, color:Lerp(Theme.Harvest, (branchIndex % 3) * 0.12))
	end
end

function Assets.Sign(anchor: BasePart, title: string, detail: string?)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Back
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 35
	surface.LightInfluence = 0.2
	surface.Parent = anchor
	local heading = Instance.new("TextLabel")
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromScale(0.05, 0.1)
	heading.Size = UDim2.fromScale(0.9, detail and 0.5 or 0.8)
	heading.Font = Enum.Font.FredokaOne
	heading.TextScaled = true
	heading.TextColor3 = Theme.Paper
	heading.Text = title
	heading.Parent = surface
	if detail then
		local sub = heading:Clone()
		sub.Position = UDim2.fromScale(0.06, 0.65)
		sub.Size = UDim2.fromScale(0.88, 0.23)
		sub.Font = Enum.Font.GothamMedium
		sub.Text = detail
		sub.Parent = surface
	end
	return heading
end

return Assets
