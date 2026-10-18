--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local Config = require(ReplicatedStorage.Shared.Config.ObbyConfig)
local Motion = require(ReplicatedStorage.Shared.ObbyMotion)
local Course = {}
local steel = Color3.fromRGB(53, 65, 66)
local brick = Color3.fromRGB(119, 67, 53)
local blue = Color3.fromRGB(92, 143, 159)
local brass = Color3.fromRGB(203, 169, 106)
local cream = Color3.fromRGB(240, 224, 191)
local danger = Color3.fromRGB(183, 70, 51)
local green = Color3.fromRGB(102, 148, 111)
local nodes: {Part} = {}
local hazards: {Part} = {}
local rotors: {{Part: Part, Origin: Vector3, Speed: number}} = {}
local steam: {Part} = {}
local ray = RaycastParams.new()
ray.FilterType = Enum.RaycastFilterType.Include
ray.RespectCanCollide = true

local function part(parent: Instance, name: string, size: Vector3, at: Vector3, color: Color3, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(Config.Origin + at), color, Enum.Material.Metal, collide)
end
local function sign(parent: Instance, at: Vector3, width: number, height: number, title: string, detail: string?): Part
	local anchor = part(parent, "DepotSign", Vector3.new(width, height, 0.3), at, steel)
	Assets.Sign(anchor, title, detail)
	return anchor
end
local function line(parent: Instance, from: Vector3, to: Vector3, width: number, color: Color3)
	local beam = part(parent, "SteelBrace", Vector3.new(width, width, (to - from).Magnitude), (from + to) / 2, color)
	beam.CFrame = CFrame.lookAt(Config.Origin + (from + to) / 2, Config.Origin + to)
end
local function topLabel(anchor: Part, value: string)
	local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Top; gui.PixelsPerStud = 30
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.LightInfluence = 0; gui.Parent = anchor
	local text = Instance.new("TextLabel"); text.Size = UDim2.fromScale(1, 1); text.BackgroundTransparency = 1
	text.Text = value; text.TextColor3 = cream; text.Font = Enum.Font.GothamBold; text.TextScaled = true
	text.Rotation = 90; text.Parent = gui
end
local function striped(anchor: Part)
	local gui = Instance.new("SurfaceGui"); gui.Face = Enum.NormalId.Top; gui.LightInfluence = 0.2; gui.Parent = anchor
	for i = 0, 9 do
		local stripe = Instance.new("Frame"); stripe.Size = UDim2.fromScale(0.05, 1)
		stripe.Position = UDim2.fromScale(i / 10, 0); stripe.BorderSizePixel = 0
		stripe.BackgroundColor3 = brass; stripe.Parent = gui
	end
end
local function hazard(parent: Instance, name: string, at: Vector3, size: Vector3): Part
	local p = part(parent, name, size, at, danger, false)
	p:SetAttribute("HazardActive", true); table.insert(hazards, p); striped(p)
	return p
end
local function room(parent: Instance)
	local shell = Instance.new("Model"); shell.Name = "DepotHall"; shell.Parent = parent
	local floor = part(shell, "ServicePit", Vector3.new(180, 1, 250), Vector3.new(0, 0.7, 0), steel, true)
	floor.Material = Enum.Material.Concrete
	for _, side in {-1, 1} do
		local wall = part(shell, "BrickWall", Vector3.new(3, 72, 250), Vector3.new(side * 90, 37, 0), brick, true)
		wall.Material = Enum.Material.Brick
		part(shell, "WallPlinth", Vector3.new(4, 7, 250), Vector3.new(side * 88.8, 4.5, 0), steel, true)
		for z = -100, 100, 40 do
			part(shell, "IronColumn", Vector3.new(3, 76, 4), Vector3.new(side * 85, 39, z), steel, true)
			local window = part(shell, "HighWindow", Vector3.new(0.4, 25, 22), Vector3.new(side * 88.2, 48, z), blue)
			window.Material = Enum.Material.Glass; window.Transparency = 0.25
			for offset = -8, 8, 8 do part(shell, "WindowMullion", Vector3.new(0.8, 26, 0.7), Vector3.new(side * 87.8, 48, z + offset), brass) end
			local bulb = part(shell, "PendantLamp", Vector3.new(3, 0.8, 3), Vector3.new(side * 47, 66, z), cream)
			part(shell, "PendantCable", Vector3.new(0.2, 12, 0.2), Vector3.new(side * 47, 72, z), steel)
			local light = Instance.new("PointLight"); light.Color = cream; light.Range = 75; light.Brightness = 2; light.Parent = bulb
		end
	end
	local back = part(shell, "BackWall", Vector3.new(180, 72, 3), Vector3.new(0, 37, -125), brick, true)
	back.Material = Enum.Material.Brick
	for _, side in {-1, 1} do
		part(shell, "FrontWing", Vector3.new(66, 72, 3), Vector3.new(side * 57, 37, 125), brick, true).Material = Enum.Material.Brick
	end
	part(shell, "EntranceLintel", Vector3.new(52, 45, 3), Vector3.new(0, 51, 125), brick, true)
	part(shell, "EntranceDock", Vector3.new(46, 1, 28), Vector3.new(0, 1.7, 111), brass, true)
	for step = 1, 4 do part(shell, "EntranceStep", Vector3.new(20, 1.5, 3), Vector3.new(0, 1.6 + step * 1.5, 123 - step * 3), steel, true) end
	for z = -120, 120, 40 do
		part(shell, "RoofTie", Vector3.new(176, 1, 2), Vector3.new(0, 73, z), steel)
		line(shell, Vector3.new(-88, 73, z), Vector3.new(0, 85, z), 1.2, steel)
		line(shell, Vector3.new(0, 85, z), Vector3.new(88, 73, z), 1.2, steel)
		for x = -70, 70, 35 do line(shell, Vector3.new(x, 73, z), Vector3.new(x + 17.5, 82 - math.abs(x) / 12, z), 0.6, steel) end
	end
	for _, side in {-1, 1} do
		local roof = part(shell, "Skylight", Vector3.new(89, 0.6, 254), Vector3.new(side * 44, 79, 0), blue)
		roof.CFrame *= CFrame.Angles(0, 0, -side * math.atan(12 / 88))
		roof.Material = Enum.Material.Glass; roof.Transparency = 0.5
		part(shell, "CraneRail", Vector3.new(2, 2, 232), Vector3.new(side * 65, 59, 0), brass)
	end
	part(shell, "OverheadCrane", Vector3.new(136, 5, 6), Vector3.new(0, 60, -18), brass)
	line(shell, Vector3.new(46, 59, -18), Vector3.new(46, 34, -18), 0.5, steel)
	part(shell, "CraneHook", Vector3.new(4, 4, 1), Vector3.new(46, 33, -18), steel)
	-- The flywheel behind the back glazing is the room's recognisable landmark.
	local wheel = part(shell, "DepotFlywheel", Vector3.new(1.5, 32, 32), Vector3.new(0, 44, -122), brass)
	wheel.Shape = Enum.PartType.Cylinder; wheel.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
	local inner = part(shell, "FlywheelInset", Vector3.new(2, 26, 26), Vector3.new(0, 44, -120.8), steel)
	inner.Shape = Enum.PartType.Cylinder; inner.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
	for i = 1, 12 do
		local angle = i * math.pi / 6
		local spoke = part(shell, "FlywheelSpoke", Vector3.new(1.2, 29, 1), Vector3.new(0, 44, -119.5), brass)
		spoke.CFrame *= CFrame.Angles(0, 0, angle)
	end
	local glass = part(shell, "FlywheelGuard", Vector3.new(42, 42, 0.5), Vector3.new(0, 44, -118), blue)
	glass.Material = Enum.Material.Glass; glass.Transparency = 0.7
	sign(shell, Vector3.new(0, 21, 124), 46, 8, "DEPOT TRIAL", "6 SECTIONS  /  CHECKPOINTS AT 3 & 5")
	sign(shell, Vector3.new(-43, 12, 111), 35, 6, "FOLLOW THE MARKED ROUTE", "STRIPED RED MACHINERY RESETS YOUR RUN")
	-- Service-floor dressing stays below the playable route, never a shortcut.
	for _, side in {-1, 1} do
		for z = -105, 65, 34 do
			part(shell, "ServiceCabinet", Vector3.new(7, 7, 6), Vector3.new(side * 75, 4.8, z), blue, true)
			part(shell, "CabinetHandle", Vector3.new(0.3, 2, 0.3), Vector3.new(side * 75 + 1.8, 4.8, z + 3.2), brass)
		end
		part(shell, "PitRail", Vector3.new(1, 0.5, 220), Vector3.new(side * 8, 1.5, 0), brass)
	end
end

function Course.Build(parent: Instance): (Model, Part)
	nodes = {}; hazards = {}; rotors = {}; steam = {}
	local model = Instance.new("Model"); model.Name = "Obby"; model.Parent = parent
	room(model)
	local route = Instance.new("Folder"); route.Name = "CourseNodes"; route.Parent = model
	for i, definition in Config.Nodes do
		local color = Config.Checkpoints[i] and green or (definition.Section == 1 and brass or blue)
		local node = part(route, "Node_" .. i, definition.Size, definition.At, color, true)
		node:SetAttribute("RouteIndex", i); node:SetAttribute("Section", definition.Section)
		table.insert(nodes, node)
		if Config.Checkpoints[i] then topLabel(node, i == 1 and "START" or "CHECKPOINT") end
		if i == 28 then topLabel(node, "FINISH") end
		if i == 1 or Config.Nodes[i - 1].Section ~= definition.Section then
			local labelAt = definition.At + Vector3.new(-13, 6, 1)
			sign(model, labelAt, 19, 4, string.format("%02d  %s", definition.Section, string.upper(Config.Sections[definition.Section].Name)))
		end
		if i == 5 or Config.Checkpoints[i] or i == 12 or i == 23 or i == 28 then
			part(model, "RouteSupport", Vector3.new(1.2, definition.At.Y - 1, 1.2), Vector3.new(definition.At.X, definition.At.Y / 2, definition.At.Z), steel)
		end
	end
	ray.FilterDescendantsInstances = {route}
	for i = 1, 3 do
		local at = Config.Nodes[i + 5].At
		local size = i == 1 and Vector3.new(11, 7, 2) or Vector3.new(2, 7, 9)
		local jet = hazard(model, "Steam_" .. i, at + Vector3.new(0, 4.1, 0), size)
		table.insert(steam, jet)
		local nozzle = part(model, "SteamNozzle", Vector3.new(size.X, 0.25, size.Z), at + Vector3.new(0, 0.74, 0), steel)
		striped(nozzle)
		local emitter = Instance.new("ParticleEmitter"); emitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
		emitter.Color = ColorSequence.new(cream); emitter.Rate = 18; emitter.Lifetime = NumberRange.new(0.4, 0.65)
		emitter.Speed = NumberRange.new(6, 10); emitter.SpreadAngle = Vector2.new(20, 20)
		emitter.Size = NumberSequence.new(1.4); emitter.Enabled = false; emitter.Parent = jet
	end
	for i, index in {15, 16, 17} do
		local at = Config.Nodes[index].At + Vector3.new(0, 1.8, 0)
		local arm = hazard(model, "Rotor_" .. i, at, Vector3.new(i == 3 and 16 or 24, 1.1, 1.2))
		arm:SetAttribute("RotorOrigin", arm.Position); arm:SetAttribute("RotorSpeed", i % 2 == 0 and -0.65 or 0.75)
		table.insert(rotors, {Part = arm, Origin = arm.Position, Speed = arm:GetAttribute("RotorSpeed")})
		part(model, "RotorHub", Vector3.new(2, 1.5, 2), at - Vector3.new(0, 0.3, 0), steel)
	end
	for _, index in {24, 25} do
		hazard(model, "RafterHurdle_" .. index, Config.Nodes[index].At + Vector3.new(0, 1.5, 0), Vector3.new(6, 1.5, 1.2))
	end
	for _, mover in Config.Movers do
		nodes[mover.Node]:SetAttribute("MovingDeck", true); topLabel(nodes[mover.Node], "CARGO")
	end
	for _, index in Config.FadeNodes do topLabel(nodes[index], tostring(index - 18)) end
	local finish = Config.Nodes[#Config.Nodes].At
	for _, side in {-1, 1} do
		part(model, "FinishArch", Vector3.new(1.5, 12, 1.5), finish + Vector3.new(side * 8, 6, -6), brass)
		part(model, "BalconyRail", Vector3.new(0.5, 3, 18), finish + Vector3.new(side * 9, 2, 0), steel)
	end
	sign(model, finish + Vector3.new(0, 11, -6), 22, 4, "FINISH", "DEPOT TRIAL")
	local bell = part(model, "FinishBell", Vector3.new(3, 3, 3), finish + Vector3.new(0, 7, -6), brass)
	bell.Shape = Enum.PartType.Ball
	local start = part(model, "StartPad", Vector3.new(18, 0.3, 8), Vector3.new(0, 2.4, 118), green, true)
	topLabel(start, "START")
	return model, start
end

function Course.Spawn(index: number): Vector3
	return Config.Origin + Config.Nodes[index].At + Vector3.new(0, 4, 0)
end

function Course.Update(now: number)
	for _, definition in Config.Movers do nodes[definition.Node].CFrame = Motion.Deck(definition, now) end
	for _, rotor in rotors do rotor.Part.CFrame = CFrame.new(rotor.Origin) * CFrame.Angles(0, Motion.RotorAngle(rotor.Speed, now), 0) end
	for i, jet in steam do
		local phase = Motion.Steam(i, now)
		jet:SetAttribute("HazardActive", phase == "Active")
		jet.Color = phase == "Warning" and brass or danger
		jet.Transparency = phase == "Active" and 0.45 or (phase == "Warning" and 0.72 or 1)
		local emitter = jet:FindFirstChildOfClass("ParticleEmitter")
		if emitter then emitter.Enabled = phase == "Active" end
	end
	for _, index in Config.FadeNodes do
		local phase = Motion.Fade(index, now)
		local node = nodes[index]
		node.CanCollide = phase ~= "Gone"; node.CanQuery = node.CanCollide
		node.Transparency = phase == "Gone" and 0.87 or 0
		node.Color = phase == "Warning" and brass or blue
	end
end

function Course.HitHazard(root: BasePart): boolean
	-- Sweep arms move <0.7 studs per server sample. Three capsule samples cover
	-- the legs/hips/torso without treating a safe overhead jump as a hit.
	for _, obstacle in hazards do
		if obstacle:GetAttribute("HazardActive") ~= true then continue end
		for _, y in {-2.1, -0.6, 0.9} do
			local at = obstacle.CFrame:PointToObjectSpace(root.Position + Vector3.new(0, y, 0))
			local half = obstacle.Size / 2 + Vector3.new(0.65, 0.6, 0.65)
			if math.abs(at.X) <= half.X and math.abs(at.Y) <= half.Y and math.abs(at.Z) <= half.Z then return true end
		end
	end
	return false
end

function Course.Surface(root: BasePart): number?
	if root.AssemblyLinearVelocity.Y > 3 or root.AssemblyLinearVelocity.Y < -8 then return nil end
	local result = Workspace:Raycast(root.Position, Vector3.new(0, -3.9, 0), ray)
	return result and result.Instance:GetAttribute("RouteIndex") or nil
end

return Course
