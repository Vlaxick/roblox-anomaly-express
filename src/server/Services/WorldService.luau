--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local WorldService = {}

local PLOT_POSITIONS = {
	Vector3.new(-152, 0, -112),
	Vector3.new(0, 0, -176),
	Vector3.new(152, 0, -112),
	Vector3.new(-152, 0, 112),
	Vector3.new(0, 0, 176),
	Vector3.new(152, 0, 112),
}

function WorldService.GetPlotPosition(index: number): Vector3
	return PLOT_POSITIONS[index]
end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function lamp(parent: Instance, at: Vector3)
	part(parent, "LampPost", Vector3.new(0.8, 11, 0.8), CFrame.new(at + Vector3.new(0, 5.5, 0)), Theme.Steel, Enum.Material.Metal)
	local head = part(parent, "AmberLantern", Vector3.new(3.2, 1.2, 3.2), CFrame.new(at + Vector3.new(0, 11.4, 0)), Theme.Amber, Enum.Material.Neon, false)
	local light = Instance.new("PointLight")
	light.Color = Theme.Amber
	light.Brightness = 1.4
	light.Range = 26
	light.Parent = head
end

local function tree(parent: Instance, at: Vector3, scale: number)
	local trunk = part(parent, "TwistedTrunk", Vector3.new(2 * scale, 8 * scale, 2 * scale), CFrame.new(at + Vector3.new(0, 4 * scale, 0)), Theme.Steel, Enum.Material.Wood)
	trunk.Shape = Enum.PartType.Cylinder
	for branch = 1, 3 do
		local theta = branch * math.pi * 2 / 3
		local pos = at + Vector3.new(math.cos(theta) * 3 * scale, 9 * scale, math.sin(theta) * 3 * scale)
		local crown = part(parent, "LuminousCanopy", Vector3.new(7, 5, 7) * scale, CFrame.new(pos), Theme.Moss, Enum.Material.Grass, false)
		crown.Shape = Enum.PartType.Ball
		local bud = part(parent, "CanopyBud", Vector3.new(1.3, 1.3, 1.3) * scale, CFrame.new(pos + Vector3.new(0, 2 * scale, 0)), Theme.Mint, Enum.Material.Neon, false)
		bud.Shape = Enum.PartType.Ball
	end
end

local function sign(parent: Instance, anchor: BasePart, title: string, subtitle: string)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "StationSign"
	gui.Face = Enum.NormalId.Front
	gui.PixelsPerStud = 40
	gui.Parent = anchor
	local top = Instance.new("TextLabel")
	top.Name = "Title"
	top.BackgroundTransparency = 1
	top.Position = UDim2.fromScale(0.05, 0.1)
	top.Size = UDim2.fromScale(0.9, 0.55)
	top.Font = Enum.Font.GothamBlack
	top.TextScaled = true
	top.TextColor3 = Theme.Paper
	top.Text = title
	top.Parent = gui
	local bottom = Instance.new("TextLabel")
	bottom.Name = "Subtitle"
	bottom.BackgroundTransparency = 1
	bottom.Position = UDim2.fromScale(0.05, 0.67)
	bottom.Size = UDim2.fromScale(0.9, 0.22)
	bottom.Font = Enum.Font.Code
	bottom.TextScaled = true
	bottom.TextColor3 = Theme.Amber
	bottom.Text = subtitle
	bottom.Parent = gui
end

local function parkedTrain(parent: Instance)
	local train = Instance.new("Model")
	train.Name = "StationDisplayTrain"
	train.Parent = parent
	local function car(x: number, length: number, engine: boolean)
		part(train, engine and "LocomotiveBody" or "PassengerCar", Vector3.new(length, 6, 12), CFrame.new(x, 4.5, 6), engine and Theme.Ink or Theme.Steel, Enum.Material.Metal)
		part(train, "CarRoof", Vector3.new(length + 1, 1, 12.5), CFrame.new(x, 8, 6), Theme.Slate, Enum.Material.Metal)
		part(train, "LowerStripe", Vector3.new(length - 1, 0.55, 0.25), CFrame.new(x, 3.5, -0.13), Theme.Amber, Enum.Material.Neon, false)
		for windowX = x - length / 2 + 5, x + length / 2 - 4, 7 do
			local window = part(train, "LitWindow", Vector3.new(4, 2.8, 0.25), CFrame.new(windowX, 5.5, -0.12), Theme.Mint, Enum.Material.Glass, false)
			window.Transparency = 0.35
		end
		for _, offset in {-length / 2 + 5, length / 2 - 5} do
			for _, side in {-1, 1} do
				local wheel = part(train, "Wheel", Vector3.new(1.2, 3, 3), CFrame.new(x + offset, 1.45, 6 + side * 5.3), Theme.Ink, Enum.Material.Metal, false)
				wheel.Shape = Enum.PartType.Cylinder
			end
		end
	end
	car(-25, 31, true)
	car(12, 32, false)
	part(train, "Pilot", Vector3.new(3, 3, 10), CFrame.new(-42, 2.5, 6), Theme.Slate, Enum.Material.Metal)
	local headlight = part(train, "Headlight", Vector3.new(0.4, 2.2, 2.2), CFrame.new(-43.7, 5.6, 6), Theme.Amber, Enum.Material.Neon, false)
	local beam = Instance.new("PointLight")
	beam.Color = Theme.Amber
	beam.Brightness = 2
	beam.Range = 25
	beam.Parent = headlight
	part(train, "RoofBeacon", Vector3.new(3, 1, 3), CFrame.new(-31, 9, 6), Theme.Coral, Enum.Material.Neon, false)
end

function WorldService.Init()
	local previous = Workspace:FindFirstChild("AnomalyWorld")
	if previous then
		previous:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "AnomalyWorld"
	root.Parent = Workspace

	local oldSpawn = Workspace:FindFirstChild("SpawnLocation")
	if oldSpawn and oldSpawn:IsA("SpawnLocation") then
		oldSpawn.Transparency = 1
		oldSpawn.CanCollide = false
		oldSpawn.Enabled = false
	end

	part(root, "CampusGround", Vector3.new(600, 1, 600), CFrame.new(0, -0.35, 0), Theme.Ground, Enum.Material.Grass)
	part(root, "StationForecourt", Vector3.new(110, 0.4, 102), CFrame.new(0, 0.15, 0), Theme.Steel, Enum.Material.Concrete)
	part(root, "ForecourtInset", Vector3.new(94, 0.12, 86), CFrame.new(0, 0.42, 0), Theme.Ink, Enum.Material.Metal)
	for _, z in {-38, 38} do
		part(root, "Platform", Vector3.new(88, 1.4, 13), CFrame.new(0, 1.05, z), Theme.Slate, Enum.Material.Concrete)
		part(root, "PlatformSafetyLine", Vector3.new(83, 0.12, 0.55), CFrame.new(0, 1.82, z - math.sign(z) * 5.7), Theme.Amber, Enum.Material.Neon, false)
	end
	for _, z in {-6, 6} do
		part(root, "Ballast", Vector3.new(520, 0.3, 9), CFrame.new(0, 0.38, z), Theme.Ink, Enum.Material.Slate)
		for _, railZ in {z - 2.2, z + 2.2} do
			part(root, "Rail", Vector3.new(520, 0.55, 0.7), CFrame.new(0, 0.85, railZ), Theme.Slate, Enum.Material.Metal)
		end
	end
	for x = -250, 250, 8 do
		part(root, "RailSleeper", Vector3.new(1.2, 0.26, 22), CFrame.new(x, 0.61, 0), Theme.Steel, Enum.Material.Wood)
	end
	parkedTrain(root)

	for _, position in PLOT_POSITIONS do
		local start = Vector3.new(position.X * 0.72, 0.46, position.Z * 0.72)
		local finish = Vector3.new(position.X * 0.22, 0.46, position.Z * 0.22)
		local midpoint = (start + finish) / 2
		local distance = (start - finish).Magnitude
		part(root, "PlotPromenade", Vector3.new(9, 0.25, distance), CFrame.lookAt(midpoint, finish), Theme.Slate, Enum.Material.Cobblestone)
		part(root, "PathLightLeft", Vector3.new(0.3, 0.3, distance), CFrame.lookAt(midpoint, finish) * CFrame.new(-4.4, 0.2, 0), Theme.Mint, Enum.Material.Neon, false)
		part(root, "PathLightRight", Vector3.new(0.3, 0.3, distance), CFrame.lookAt(midpoint, finish) * CFrame.new(4.4, 0.2, 0), Theme.Mint, Enum.Material.Neon, false)
	end

	for _, x in {-45, 45} do
		for _, z in {-45, 45} do
			lamp(root, Vector3.new(x, 0.5, z))
		end
	end

	-- A station gate is the visual landmark players can navigate toward from any base.
	for _, x in {-27, 27} do
		part(root, "StationPylon", Vector3.new(4, 23, 4), CFrame.new(x, 12, -25), Theme.Steel, Enum.Material.Metal)
		part(root, "PylonLight", Vector3.new(0.6, 18, 0.6), CFrame.new(x, 12, -27.1), Theme.Amber, Enum.Material.Neon, false)
	end
	part(root, "StationLintel", Vector3.new(59, 4, 5), CFrame.new(0, 24.5, -25), Theme.Ink, Enum.Material.Metal)
	local stationSign = part(root, "StationName", Vector3.new(39, 6, 0.5), CFrame.new(0, 24.5, -27.8), Theme.Ink, Enum.Material.Metal, false)
	sign(root, stationSign, "ANOMALY EXPRESS", "EXPEDITION TERMINAL / SECTOR 01")
	for _, x in {-18, -9, 0, 9, 18} do
		part(root, "SignalLamp", Vector3.new(2.4, 0.7, 2.4), CFrame.new(x, 26.8, -25), Theme.Amber, Enum.Material.Neon, false)
	end

	for _, x in {-260, -220, -180, -100, 100, 180, 220, 260} do
		for _, z in {-255, 255} do
			tree(root, Vector3.new(x, 0.2, z), 1 + math.abs(x % 3) * 0.11)
		end
	end
	for _, z in {-210, -150, 150, 210} do
		for _, x in {-255, 255} do
			tree(root, Vector3.new(x, 0.2, z), 0.9)
		end
	end

	Lighting.ClockTime = 17.6
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(95, 123, 127)
	Lighting.OutdoorAmbient = Color3.fromRGB(87, 111, 112)
	local atmosphere = Lighting:FindFirstChild("AnomalyAtmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Name = "AnomalyAtmosphere"
		atmosphere.Parent = Lighting
	end
	if atmosphere:IsA("Atmosphere") then
		atmosphere.Density = 0.27
		atmosphere.Color = Color3.fromRGB(184, 207, 191)
		atmosphere.Decay = Color3.fromRGB(67, 99, 104)
	end

end

return WorldService
