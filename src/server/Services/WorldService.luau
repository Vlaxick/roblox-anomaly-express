--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local WorldService = {}
local positions = {
	Vector3.new(-152, 0, -112), Vector3.new(0, 0, -176), Vector3.new(152, 0, -112),
	Vector3.new(-152, 0, 112), Vector3.new(0, 0, 176), Vector3.new(152, 0, 112),
}

function WorldService.GetPlotPosition(index: number): Vector3
	return positions[index]
end

local function part(parent: Instance, name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material?, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(at), color, material, collide)
end

local function villageStation(root: Instance)
	part(root, "StationPlatform", Vector3.new(74, 1, 22), Vector3.new(0, 0.8, -24), Theme.Wood, Enum.Material.WoodPlanks, true)
	for _, x in {-31, 31} do
		part(root, "ShelterPost", Vector3.new(1.3, 11, 1.3), Vector3.new(x, 6.5, -29), Theme.Ink, Enum.Material.Wood, true)
	end
	part(root, "StationRoof", Vector3.new(72, 1, 15), Vector3.new(0, 12, -28), Theme.Barn, Enum.Material.WoodPlanks, true)
	local sign = part(root, "VillageStationSign", Vector3.new(24, 3, 0.7), Vector3.new(0, 9.8, -20), Theme.Ink, Enum.Material.Wood)
	Assets.Sign(sign, "Anomaly Express")
	for _, z in {-3, 3} do
		part(root, "Rail", Vector3.new(570, 0.35, 0.5), Vector3.new(0, 0.7, z), Theme.Stone, Enum.Material.Metal, true)
	end
	for x = -280, 280, 7 do
		part(root, "RailSleeper", Vector3.new(1.3, 0.3, 9), Vector3.new(x, 0.4, 0), Theme.Wood, Enum.Material.Wood)
	end
	local train = Instance.new("Model")
	train.Name = "ParkedTrain"
	train.Parent = root
	for _, x in {-20, 14} do
		part(train, "Carriage", Vector3.new(29, 6, 11), Vector3.new(x, 5, 0), Theme.Barn, Enum.Material.Metal, true)
		part(train, "CarriageRoof", Vector3.new(30, 1, 12), Vector3.new(x, 8.5, 0), Theme.Ink, Enum.Material.Metal)
		part(train, "CreamStripe", Vector3.new(28, 0.6, 11.1), Vector3.new(x, 3.6, 0), Theme.Panel)
		for windowX = x - 9, x + 9, 6 do
			for _, side in {-1, 1} do
				part(train, "Window", Vector3.new(3.3, 2.8, 0.2), Vector3.new(windowX, 5.8, side * 5.6), Color3.fromRGB(124, 148, 144), Enum.Material.Glass)
			end
		end
		for _, axle in {-9, 9} do
			for _, side in {-1, 1} do
				local wheel = part(train, "Wheel", Vector3.new(1, 3, 3), Vector3.new(x + axle, 1.6, side * 4.8), Theme.Ink, Enum.Material.Metal)
				wheel.Shape = Enum.PartType.Cylinder
			end
		end
	end
end

function WorldService.Init()
	local previous = Workspace:FindFirstChild("AnomalyWorld")
	if previous then previous:Destroy() end
	local root = Instance.new("Folder")
	root.Name = "AnomalyWorld"
	root.Parent = Workspace
	local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
	if oldSpawn and oldSpawn:IsA("SpawnLocation") then
		oldSpawn.Transparency = 1
		oldSpawn.CanCollide = false
		oldSpawn.Enabled = false
	end
	part(root, "AutumnMeadow", Vector3.new(610, 1, 610), Vector3.new(0, -0.3, 0), Theme.Ground, Enum.Material.Grass, true)
	part(root, "VillagePath", Vector3.new(22, 0.25, 400), Vector3.new(0, 0.3, 0), Theme.Path, Enum.Material.Ground, true)
	villageStation(root)
	for _, at in positions do
		local gate = at + Vector3.new(0, 0.34, 50)
		local junction = Vector3.new(0, 0.34, gate.Z)
		local distance = (gate - junction).Magnitude
		if distance > 1 then
			local path = part(root, "FarmLane", Vector3.new(9, 0.25, distance), (gate + junction) / 2, Theme.Path, Enum.Material.Ground, true)
			path.CFrame = CFrame.lookAt(path.Position, junction)
		end
	end

	local random = Random.new(42)
	local colors = {Theme.Harvest, Theme.Pumpkin, Theme.Rust, Theme.Moss, Theme.Barn}
	for x = -275, 275, 25 do
		for _, z in {-272, 272} do
			Assets.Tree(root, Vector3.new(x + random:NextNumber(-5, 5), 0.2, z + random:NextNumber(-8, 8)), random:NextNumber(1, 1.6), colors[random:NextInteger(1, #colors)])
		end
	end
	for z = -225, 225, 28 do
		for _, x in {-275, 275} do
			Assets.Tree(root, Vector3.new(x, 0.2, z), random:NextNumber(1.2, 1.7), colors[random:NextInteger(1, #colors)])
		end
	end
	for _, at in positions do
		for _, side in {-1, 1} do
			Assets.Tree(root, at + Vector3.new(side * 57, 0.2, -29), 1.1, side == 1 and Theme.Harvest or Theme.Rust)
		end
	end
	for _, z in {-290, 290} do
		for _, x in {-200, -75, 75, 200} do
			local hill = part(root, "DistantHill", Vector3.new(150, 65, 100), Vector3.new(x, 6, z + math.sign(z) * 35), Theme.Moss, Enum.Material.Grass)
			hill.Shape = Enum.PartType.Ball
		end
	end

	Lighting.ClockTime = 14.8
	Lighting.Brightness = 2.5
	Lighting.Ambient = Color3.fromRGB(157, 142, 117)
	Lighting.OutdoorAmbient = Color3.fromRGB(158, 150, 126)
	Lighting.ShadowSoftness = 0.45
	local atmosphere = Lighting:FindFirstChild("AnomalyAtmosphere")
	if atmosphere then atmosphere:Destroy() end
	local air = Instance.new("Atmosphere")
	air.Name = "AnomalyAtmosphere"
	air.Density = 0.18
	air.Haze = 1
	air.Color = Color3.fromRGB(238, 219, 181)
	air.Decay = Color3.fromRGB(174, 143, 112)
	air.Parent = Lighting
	local oldGrade = Lighting:FindFirstChild("AutumnColor")
	if oldGrade then oldGrade:Destroy() end
	local grade = Instance.new("ColorCorrectionEffect")
	grade.Name = "AutumnColor"
	grade.TintColor = Color3.fromRGB(255, 247, 231)
	grade.Saturation = 0.04
	grade.Contrast = 0.03
	grade.Parent = Lighting
end

return WorldService
