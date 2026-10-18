--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local City = require(ReplicatedStorage.Shared.Config.CityConfig)
local WorldService = {}

local brick = Color3.fromRGB(119, 67, 53)
local limestone = Color3.fromRGB(198, 182, 153)
local steel = Color3.fromRGB(53, 65, 66)
local blue = Color3.fromRGB(92, 143, 159)
local gold = Color3.fromRGB(203, 169, 106)

function WorldService.GetPlotPosition(index: number): Vector3
	return City.BasePositions[index]
end
local function part(parent: Instance, name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material?, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(at), color, material, collide)
end
local function sign(parent: Instance, name: string, at: Vector3, width: number, height: number, title: string, detail: string?, color: Color3?): Part
	local p = part(parent, name, Vector3.new(width, height, 0.5), at, color or steel)
	Assets.Sign(p, title, detail)
	return p
end
local function lamp(parent: Instance, at: Vector3, height: number, range: number)
	part(parent, "LampColumn", Vector3.new(0.6, height, 0.6), at + Vector3.new(0, height / 2, 0), steel, Enum.Material.Metal, true)
	local bulb = part(parent, "WarmLamp", Vector3.new(2.3, 1.4, 2.3), at + Vector3.new(0, height, 0), Theme.Paper)
	part(parent, "LampCap", Vector3.new(3, 0.35, 3), bulb.Position + Vector3.new(0, 0.9, 0), steel)
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255, 213, 156); light.Brightness = 2; light.Range = range; light.Parent = bulb
end
local function bench(parent: Instance, at: Vector3, angle: number?)
	local cf = CFrame.new(at) * CFrame.Angles(0, angle or 0, 0)
	for _, x in {-4, 4} do Assets.Part(parent, "BenchLeg", Vector3.new(0.6, 2.5, 2.8), cf * CFrame.new(x, 1.25, 0), steel, Enum.Material.Metal, true) end
	Assets.Part(parent, "BenchSeat", Vector3.new(10, 0.5, 3.3), cf * CFrame.new(0, 2.6, 0), Theme.Wood, Enum.Material.WoodPlanks, true)
	Assets.Part(parent, "BenchBack", Vector3.new(10, 2.3, 0.5), cf * CFrame.new(0, 3.9, -1.4), Theme.Wood, Enum.Material.WoodPlanks, true)
end
local function clock(parent: Instance, at: Vector3)
	local face = part(parent, "StationClock", Vector3.new(0.5, 20, 20), at, Theme.Paper)
	face.Shape = Enum.PartType.Cylinder; face.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
	for i = 1, 12 do
		local a = i * math.pi / 6
		local tick = part(parent, "ClockTick", Vector3.new(0.5, 1.4, 0.2), at + Vector3.new(math.sin(a) * 8.2, math.cos(a) * 8.2, 0.4), steel)
		tick.CFrame *= CFrame.Angles(0, 0, -a)
	end
	part(parent, "ClockMinuteHand", Vector3.new(0.45, 7, 0.3), at + Vector3.new(0, 3.2, 0.7), steel)
	local hand = part(parent, "ClockHourHand", Vector3.new(0.6, 5, 0.3), at + Vector3.new(1.7, 1.7, 0.8), steel)
	hand.CFrame *= CFrame.Angles(0, 0, -0.8)
end
local function parkedTrain(parent: Instance)
	local train = Instance.new("Model"); train.Name = "ParkedTrain"; train.Parent = parent
	for _, x in {-116, -50, 16, 82} do
		part(train, "Carriage", Vector3.new(60, 10, 15), Vector3.new(x, 7, -391), brick, Enum.Material.Metal, true)
		part(train, "CarriageRoof", Vector3.new(61, 1.8, 16), Vector3.new(x, 12.8, -391), steel, Enum.Material.Metal, true)
		part(train, "BrassStripe", Vector3.new(60.2, 0.8, 15.2), Vector3.new(x, 4.4, -391), gold)
		for windowX = x - 23, x + 23, 9.2 do
			for _, side in {-1, 1} do
				local window = part(train, "CarriageWindow", Vector3.new(5, 4, 0.2), Vector3.new(windowX, 8.4, -391 + side * 7.6), blue:Lerp(Theme.Paper, 0.35), Enum.Material.Glass)
				window.Transparency = 0.12
			end
		end
		for _, axle in {-20, 20} do
			for _, side in {-1, 1} do
				local wheel = part(train, "TrainWheel", Vector3.new(1.2, 4.5, 4.5), Vector3.new(x + axle, 2.7, -391 + side * 6), steel, Enum.Material.Metal)
				wheel.Shape = Enum.PartType.Cylinder; wheel.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
			end
		end
	end
end
local function station(root: Instance)
	local model = Instance.new("Model"); model.Name = "GrandStation"; model.Parent = root
	part(model, "ConcourseFloor", Vector3.new(330, 1.2, 280), Vector3.new(0, 0.8, -200), limestone, Enum.Material.Marble, true)
	part(model, "CentralRunner", Vector3.new(26, 0.12, 260), Vector3.new(0, 1.46, -200), steel, Enum.Material.Slate)
	for _, side in {-1, 1} do
		part(model, "StationSideWall", Vector3.new(3, 26, 280), Vector3.new(side * 165, 14, -200), brick, Enum.Material.Brick, true)
		part(model, "StationCornice", Vector3.new(5, 2, 284), Vector3.new(side * 165, 28, -200), limestone, Enum.Material.Marble)
		part(model, "EntranceWing", Vector3.new(130, 25, 4), Vector3.new(side * 100, 13.7, -60), brick, Enum.Material.Brick, true)
		for z = -320, -80, 48 do
			part(model, "ConcourseColumn", Vector3.new(3.5, 31, 3.5), Vector3.new(side * 145, 17, z), limestone, Enum.Material.Marble, true)
			part(model, "ColumnFoot", Vector3.new(6, 2, 6), Vector3.new(side * 145, 2, z), steel)
			part(model, "WindowFrame", Vector3.new(0.5, 13, 23), Vector3.new(side * 163, 19, z), gold)
			local window = part(model, "StationWindow", Vector3.new(0.6, 11.5, 21.5), Vector3.new(side * 162.6, 19, z), blue, Enum.Material.Glass)
			window.Transparency = 0.25
			bench(model, Vector3.new(side * 113, 1.45, z + 9), side * math.pi / 2)
		end
		for x = 55, 145, 45 do
			part(model, "FacadePilaster", Vector3.new(3, 28, 5), Vector3.new(side * x, 15, -57), limestone, Enum.Material.Marble)
			local glass = part(model, "FacadeWindow", Vector3.new(23, 12, 0.5), Vector3.new(side * x, 17, -57), blue, Enum.Material.Glass)
			glass.Transparency = 0.2
		end
	end
	-- Broad barrel-vaulted glass roof, with visible iron ribs and a clear entry.
	for segment = 1, 12 do
		local a, b = (segment - 1) * math.pi / 12, segment * math.pi / 12
		local from = Vector3.new(math.cos(a) * 168, 30 + math.sin(a) * 31, -200)
		local to = Vector3.new(math.cos(b) * 168, 30 + math.sin(b) * 31, -200)
		local angle = math.atan2(to.Y - from.Y, to.X - from.X)
		local cf = CFrame.new((from + to) / 2) * CFrame.Angles(0, 0, angle)
		local glass = Assets.Part(model, "VaultGlass", Vector3.new((to - from).Magnitude, 0.45, 284), cf, blue:Lerp(Theme.Paper, 0.3), Enum.Material.Glass)
		glass.Transparency = 0.48
		for z = -340, -60, 40 do
			Assets.Part(model, "VaultRib", Vector3.new((to - from).Magnitude + 0.5, 0.7, 0.8), cf + Vector3.new(0, 0.35, z + 200), steel, Enum.Material.Metal)
		end
	end
	sign(model, "StationName", Vector3.new(0, 27, -56.5), 110, 7, "CENTRAL STATION", "ANOMALY EXPRESS", steel)
	part(model, "ClockSurround", Vector3.new(28, 27, 4), Vector3.new(0, 49, -61), brick, Enum.Material.Brick)
	clock(model, Vector3.new(0, 49, -58.6))
	sign(model, "DepartureBoard", Vector3.new(0, 23, -266), 112, 15, "EXPEDITION EXPRESS", "TRAIN ROUTES IN DEVELOPMENT  /  LOBBY GAMES OPEN", steel)
	sign(model, "ConcourseDirectory", Vector3.new(0, 10, -183), 70, 8, "PLAY BEFORE YOUR JOURNEY", "01 OBBY  /  02 CIRCUIT  /  03 MEMORY  /  04 PLATFORM", steel)
	for _, x in {-8, 8} do part(model, "DirectoryPost", Vector3.new(0.8, 9, 0.8), Vector3.new(x, 5, -183), steel, Enum.Material.Metal) end
	local gates = Instance.new("Folder"); gates.Name = "Gates"; gates.Parent = model
	local names = {"DEPOT TRIAL", "CIRCUIT RUN", "MEMORY ROOM", "PLATFORM 1"}
	local ids = {"Obby", "Circuit", "Memory", "Platform"}
	for i = 1, 4 do
		local x = -108 + (i - 1) * 72
		local gate = Instance.new("Model"); gate.Name = "Gate_" .. i; gate:SetAttribute("Destination", ids[i]); gate.Parent = gates
		for _, side in {-1, 1} do part(gate, "GatePillar", Vector3.new(2.5, 18, 3), Vector3.new(x + side * 24, 10, -292), steel, Enum.Material.Metal, true) end
		part(gate, "GateHeader", Vector3.new(51, 2, 4), Vector3.new(x, 20, -292), gold, Enum.Material.Metal)
		sign(gate, "GateSign", Vector3.new(x, 15, -289.5), 43, 6, string.format("GATE %02d", i), names[i], steel)
		part(gate, "GateMat", Vector3.new(44, 0.2, 12), Vector3.new(x, 1.55, -286), blue, Enum.Material.Slate)
		local anchor = part(gate, "GateControl", Vector3.new(2, 3.2, 2), Vector3.new(x, 3.1, -279), gold, Enum.Material.Metal, true)
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "GatePrompt"; prompt.ActionText = "Enter"; prompt.ObjectText = names[i]
		prompt.MaxActivationDistance = 12; prompt.RequiresLineOfSight = false; prompt.Parent = anchor
	end
	for _, x in {-180, 180} do
		part(model, "PlatformCanopyPost", Vector3.new(2, 17, 2), Vector3.new(x, 9, -355), steel, Enum.Material.Metal, true)
	end
	part(model, "Platform", Vector3.new(390, 1.4, 35), Vector3.new(0, 0.9, -357), limestone, Enum.Material.Concrete, true)
	part(model, "PlatformSafetyLine", Vector3.new(390, 0.08, 1.5), Vector3.new(0, 1.65, -372), gold)
	part(model, "PlatformCanopy", Vector3.new(398, 1.2, 32), Vector3.new(0, 18, -353), steel, Enum.Material.Metal)
	sign(model, "PlatformSign", Vector3.new(95, 12, -350), 36, 5, "PLATFORM 1", "EXPEDITION SERVICE IN DEVELOPMENT")
	for _, z in {-385, -397} do part(root, "MainRail", Vector3.new(1120, 0.5, 0.6), Vector3.new(0, 0.7, z), steel, Enum.Material.Metal, true) end
	for x = -550, 550, 9 do part(root, "RailSleeper", Vector3.new(1.5, 0.4, 17), Vector3.new(x, 0.4, -391), Theme.Wood, Enum.Material.Wood) end
	parkedTrain(root)
	for _, x in {-90, 90} do for _, z in {-105, -220, -325} do lamp(model, Vector3.new(x, 1.45, z), 14, 58) end end
	for _, x in {-140, 0, 140} do lamp(model, Vector3.new(x, 1.6, -353), 12, 48) end
	-- Ticket counters and waiting areas frame, rather than block, the central route.
	for _, side in {-1, 1} do
		part(model, "TicketCounter", Vector3.new(38, 5, 7), Vector3.new(side * 105, 4, -130), Theme.Wood, Enum.Material.WoodPlanks, true)
		sign(model, "TicketSign", Vector3.new(side * 105, 12, -129), 36, 4, "TICKETS & INFORMATION", "LOBBY ACTIVITIES ARE FREE")
	end
end
local function town(root: Instance)
	part(root, "StationSquare", Vector3.new(220, 0.35, 160), Vector3.new(0, 0.45, 20), limestone:Lerp(Theme.Stone, 0.45), Enum.Material.Cobblestone, true)
	part(root, "TownAvenue", Vector3.new(24, 0.3, 510), Vector3.new(0, 0.35, 285), Theme.Path, Enum.Material.Cobblestone, true)
	for _, at in City.BasePositions do
		local gate = at + Vector3.new(0, 0.45, 50)
		part(root, "HomeLane", Vector3.new(math.abs(gate.X), 0.25, 10), Vector3.new(gate.X / 2, 0.45, gate.Z), Theme.Path, Enum.Material.Cobblestone, true)
	end
	for _, side in {-1, 1} do
		for _, z in {25, 90} do
			local at = Vector3.new(side * 72, 0.6, z)
			part(root, "TownShop", Vector3.new(31, 16, 22), at + Vector3.new(0, 8, 0), side == 1 and brick or blue, Enum.Material.Brick, true)
			part(root, "ShopRoof", Vector3.new(34, 2, 25), at + Vector3.new(0, 17, 0), steel, Enum.Material.Slate)
			part(root, "ShopDoor", Vector3.new(6, 10, 0.3), at + Vector3.new(0, 5.2, 11.2), Theme.Wood)
			for _, x in {-10, 10} do part(root, "ShopWindow", Vector3.new(7, 7, 0.35), at + Vector3.new(x, 7, 11.2), Theme.Paper, Enum.Material.Glass) end
			sign(root, "ShopName", at + Vector3.new(0, 13.4, 11.5), 28, 3, z == 25 and (side == 1 and "STATION CAFE" or "TRAVEL GOODS") or (side == 1 and "CITY ARCHIVE" or "CLOCKMAKER"))
		end
		for z = 15, 525, 75 do lamp(root, Vector3.new(side * 18, 0.6, z), 9, 38) end
		bench(root, Vector3.new(side * 45, 0.6, -18), side * math.pi / 2)
	end
	sign(root, "TownWayfinding", Vector3.new(0, 6, 63), 27, 5, "CENTRAL STATION", "NORTH  /  HOMES SOUTH")
	part(root, "WayfindingPost", Vector3.new(0.7, 5, 0.7), Vector3.new(0, 2.6, 63), steel)
end
function WorldService.Init()
	local previous = Workspace:FindFirstChild("AnomalyWorld")
	if previous then previous:Destroy() end
	local root = Instance.new("Folder"); root.Name = "AnomalyWorld"; root.Parent = Workspace
	local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
	if oldSpawn and oldSpawn:IsA("SpawnLocation") then oldSpawn.Transparency = 1; oldSpawn.CanCollide = false; oldSpawn.Enabled = false end
	part(root, "TownGround", Vector3.new(1300, 1, 1400), Vector3.new(0, -0.3, 40), Theme.Ground, Enum.Material.Grass, true)
	station(root)
	town(root)
	local random = Random.new(42)
	local colors = {Theme.Harvest, Theme.Rust, Theme.Moss, Theme.Green}
	for x = -580, 580, 60 do
		for _, z in {-520, 630} do Assets.Tree(root, Vector3.new(x, 0.2, z), random:NextNumber(1.1, 1.7), colors[random:NextInteger(1, #colors)]) end
	end
	for _, at in City.BasePositions do
		for _, side in {-1, 1} do Assets.Tree(root, at + Vector3.new(side * 57, 0.2, -29), 1.1, Theme.Harvest) end
	end
	for z = -420, 500, 100 do
		for _, x in {-490, 490} do Assets.Tree(root, Vector3.new(x, 0.2, z), 1.4, Theme.Moss) end
	end
	Lighting.ClockTime = 19.2; Lighting.Brightness = 2.5; Lighting.ExposureCompensation = 0.35
	Lighting.Ambient = Color3.fromRGB(104, 101, 118); Lighting.OutdoorAmbient = Color3.fromRGB(111, 112, 125); Lighting.ShadowSoftness = 0.7
	for _, name in {"AnomalyAtmosphere", "AutumnColor"} do local old = Lighting:FindFirstChild(name); if old then old:Destroy() end end
	local air = Instance.new("Atmosphere")
	air.Name = "AnomalyAtmosphere"; air.Density = 0.18; air.Haze = 0.9
	air.Color = Color3.fromRGB(166, 160, 171); air.Decay = Color3.fromRGB(78, 75, 91); air.Parent = Lighting
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "AutumnColor"; grade.TintColor = Color3.fromRGB(246, 239, 255); grade.Saturation = -0.06; grade.Contrast = 0.03; grade.Parent = Lighting
end

return WorldService
