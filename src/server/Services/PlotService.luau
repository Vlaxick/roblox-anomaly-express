--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local LevelService = require(script.Parent.LevelService)
local WorldService = require(script.Parent.WorldService)

local PlotService = {}
local owners: {[number]: Player} = {}
local slots: {[Player]: number} = {}
local stored: {[number]: number} = {}
local production: {[number]: boolean} = {}
local storage: {[number]: boolean} = {}
local signs: {[number]: TextLabel} = {}
local meters: {[number]: TextLabel} = {}
local upgradeLabels: {[number]: {[string]: TextLabel}} = {}
local upgradePrompts: {[number]: {[string]: ProximityPrompt}} = {}
local upgradeLights: {[number]: {[string]: Part}} = {}

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material
	p.Anchored = true
	p.CanCollide = collide ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function label(anchor: BasePart, width: number, offset: Vector3, maxDistance: number?): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(width, 38)
	gui.StudsOffset = offset
	gui.AlwaysOnTop = false
	gui.MaxDistance = maxDistance or 44
	gui.Parent = anchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Theme.Ink
	text.BackgroundTransparency = 0.08
	text.TextColor3 = Theme.Paper
	text.TextSize = 15
	text.TextTruncate = Enum.TextTruncate.AtEnd
	text.Font = Enum.Font.GothamBold
	text.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = text
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Slate
	stroke.Parent = text
	return text
end

local function zoneSign(plot: Model, name: string, at: Vector3, width: number, accent: Color3, title: string, detail: string): TextLabel
	local board = part(plot, name, Vector3.new(width, 2.8, 0.55), at, Theme.Ink, Enum.Material.Metal, false)
	part(plot, name .. "Accent", Vector3.new(width, 0.22, 0.62), at + Vector3.new(0, 1.4, 0), accent, Enum.Material.Neon, false)
	local surface = Instance.new("SurfaceGui")
	surface.Name = "ReadableSign"
	surface.Face = Enum.NormalId.Back
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 35
	surface.LightInfluence = 0
	surface.Parent = board
	local heading = Instance.new("TextLabel")
	heading.Name = "Heading"
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromScale(0.045, 0.08)
	heading.Size = UDim2.fromScale(0.91, 0.43)
	heading.Font = Enum.Font.GothamBlack
	heading.Text = title
	heading.TextScaled = true
	heading.TextXAlignment = Enum.TextXAlignment.Left
	heading.TextColor3 = Theme.Paper
	heading.Parent = surface
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Detail"
	subtitle.BackgroundTransparency = 1
	subtitle.Position = UDim2.fromScale(0.045, 0.55)
	subtitle.Size = UDim2.fromScale(0.91, 0.3)
	subtitle.Font = Enum.Font.GothamMedium
	subtitle.Text = detail
	subtitle.TextScaled = true
	subtitle.TextXAlignment = Enum.TextXAlignment.Left
	subtitle.TextColor3 = Theme.Muted
	subtitle.Parent = surface
	return subtitle
end

local function energyConduit(plot: Model, name: string, from: Vector3, to: Vector3, color: Color3)
	local direction = to - from
	local distance = direction.Magnitude
	local segments = math.floor(distance / 3)
	for segment = 1, segments do
		local center = from + direction * ((segment - 0.5) / segments)
		local strip = part(plot, name, Vector3.new(0.36, 0.08, distance / segments - 0.7), center, color, Enum.Material.Neon, false)
		strip.CFrame = CFrame.lookAt(center, to)
	end
end

local function plant(parent: Instance, at: Vector3, scale: number)
	local stem = part(parent, "AnomalyStem", Vector3.new(0.8, 4, 0.8) * scale, at + Vector3.new(0, 2.1 * scale, 0), Theme.Moss, Enum.Material.Grass, false)
	stem.Shape = Enum.PartType.Cylinder
	local bloom = part(parent, "EyeFlower", Vector3.new(4, 4, 4) * scale, at + Vector3.new(0, 4.5 * scale, 0), Theme.Coral, Enum.Material.SmoothPlastic, false)
	bloom.Shape = Enum.PartType.Ball
	local eye = part(parent, "Eye", Vector3.new(2, 2, 0.5) * scale, at + Vector3.new(0, 4.5 * scale, -1.87 * scale), Theme.Paper, Enum.Material.SmoothPlastic, false)
	eye.Shape = Enum.PartType.Ball
	local pupil = part(parent, "Pupil", Vector3.new(0.8, 0.8, 0.28) * scale, at + Vector3.new(0, 4.5 * scale, -2.15 * scale), Theme.Ink, Enum.Material.SmoothPlastic, false)
	pupil.Shape = Enum.PartType.Ball
	for _, side in {-1, 1} do
		local leaf = part(parent, "GlowLeaf", Vector3.new(2.8, 0.4, 1.3) * scale, at + Vector3.new(side * 1.3 * scale, 2.4 * scale, 0), Theme.Mint, Enum.Material.Neon, false)
		leaf.Shape = Enum.PartType.Ball
	end
end

local function limit(index: number): number
	return Config.EyeFlowerStorageLimit * (storage[index] and Config.StorageUpgradeMultiplier or 1)
end

local function refreshEnergy(index: number)
	meters[index].Text = string.format("%d / %d · ПІДІЙДИ Й ЗАБЕРИ", stored[index], limit(index))
	local owner = owners[index]
	if owner then
		owner:SetAttribute("StoredEnergy", stored[index])
		owner:SetAttribute("StorageLimit", limit(index))
	end
end

local function refreshUpgrades(index: number)
	local reactorOn = production[index]
	local storageOn = storage[index]
	upgradeLabels[index].Production.Text = reactorOn and "АКТИВНО · ВИРОБНИЦТВО ×2" or (Config.ProductionUpgradeCost .. " ЕН. → ВИРОБНИЦТВО ×2")
	upgradeLabels[index].Storage.Text = storageOn and "АКТИВНО · ЛІМІТ 200" or (Config.StorageUpgradeCost .. " ЕН. → ЛІМІТ 200")
	upgradeLights[index].Production.Color = reactorOn and Theme.Mint or Theme.Amber
	upgradeLights[index].Storage.Color = storageOn and Theme.Mint or Theme.Amber
	upgradePrompts[index].Production.Enabled = not reactorOn
	upgradePrompts[index].Storage.Enabled = not storageOn
	local owner = owners[index]
	if owner then
		owner:SetAttribute("ProductionLevel", reactorOn and 2 or 1)
		owner:SetAttribute("StorageLevel", storageOn and 2 or 1)
	end
end

local function buy(index: number, player: Player, kind: string, cost: number)
	if owners[index] ~= player or (kind == "Production" and production[index]) or (kind == "Storage" and storage[index]) then
		return
	end
	local balance = player:GetAttribute("Energy") or 0
	if balance < cost then
		player:SetAttribute("BaseNotice", "Потрібно ще " .. (cost - balance) .. " енергії")
		return
	end
	player:SetAttribute("Energy", balance - cost)
	if kind == "Production" then
		production[index] = true
		player:SetAttribute("BaseNotice", "Реактор запущено: +100% виробництва")
	else
		storage[index] = true
		player:SetAttribute("BaseNotice", "Сховище розширено: +100% місткості")
	end
	refreshUpgrades(index)
	refreshEnergy(index)
end

local function console(plot: Model, at: Vector3, kind: string, index: number, title: string, cost: number)
	part(plot, kind .. "Pedestal", Vector3.new(7, 2, 5), at + Vector3.new(0, 2, 0), Theme.Steel, Enum.Material.Metal)
	local light = part(plot, kind .. "Indicator", Vector3.new(5.5, 0.24, 0.4), at + Vector3.new(0, 3.12, -2.3), Theme.Amber, Enum.Material.Neon, false)
	upgradeLights[index][kind] = light
	upgradeLabels[index][kind] = zoneSign(plot, kind .. "Sign", at + Vector3.new(0, 9.5, -3.8), 16, Theme.Amber, title, "")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Покращити за " .. cost .. " енергії"
	prompt.ObjectText = title
	prompt.HoldDuration = 0.35
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Parent = light
	upgradePrompts[index][kind] = prompt
	prompt.Triggered:Connect(function(player)
		buy(index, player, kind, cost)
	end)
end

local function createPlot(index: number, root: Folder)
	local at = WorldService.GetPlotPosition(index)
	local plot = Instance.new("Model")
	plot.Name = "Laboratory_" .. index
	plot.Parent = root
	stored[index], production[index], storage[index] = 0, false, false
	upgradeLabels[index], upgradePrompts[index], upgradeLights[index] = {}, {}, {}

	part(plot, "Foundation", Vector3.new(80, 1.5, 76), at + Vector3.new(0, 0.8, 0), Theme.Ink, Enum.Material.Metal)
	part(plot, "MainDeck", Vector3.new(75, 0.25, 71), at + Vector3.new(0, 1.7, 0), Theme.Slate, Enum.Material.Concrete)
	for _, x in {-38.5, 38.5} do
		part(plot, "DeckEdge", Vector3.new(0.6, 0.22, 74), at + Vector3.new(x, 1.97, 0), Theme.Mint, Enum.Material.Neon, false)
	end
	for _, z in {-36.5, 36.5} do
		part(plot, "DeckEdge", Vector3.new(77, 0.22, 0.6), at + Vector3.new(0, 1.97, z), Theme.Mint, Enum.Material.Neon, false)
	end
	for x = -30, 30, 15 do
		part(plot, "FloorGrid", Vector3.new(0.2, 0.05, 68), at + Vector3.new(x, 1.85, 0), Theme.Steel, Enum.Material.Metal, false)
	end
	for z = -30, 30, 15 do
		part(plot, "FloorGrid", Vector3.new(72, 0.05, 0.2), at + Vector3.new(0, 1.85, z), Theme.Steel, Enum.Material.Metal, false)
	end

	-- Open lab pavilion, visible from the player's spawn point.
	part(plot, "LabFloor", Vector3.new(28, 0.4, 24), at + Vector3.new(-20, 2.05, -13), Theme.Ink, Enum.Material.Metal)
	for _, x in {-32, -8} do
		for _, z in {-23, -3} do
			part(plot, "LabColumn", Vector3.new(1.2, 10, 1.2), at + Vector3.new(x, 7.2, z), Theme.Slate, Enum.Material.Metal)
		end
	end
	part(plot, "LabRoof", Vector3.new(29, 1, 25), at + Vector3.new(-20, 12.65, -13), Theme.Ink, Enum.Material.Metal)
	part(plot, "RoofLight", Vector3.new(27, 0.4, 0.5), at + Vector3.new(-20, 12.3, -25.7), Theme.Amber, Enum.Material.Neon, false)
	part(plot, "ResearchDesk", Vector3.new(12, 2.3, 4), at + Vector3.new(-20, 3.4, -16), Theme.Slate, Enum.Material.Metal)
	part(plot, "ResearchScreen", Vector3.new(6, 3.5, 0.35), at + Vector3.new(-20, 6.1, -17.8), Theme.Mint, Enum.Material.Glass, false).Transparency = 0.28
	for _, x in {-29, -23, -17} do
		part(plot, "SpecimenJar", Vector3.new(2, 3, 2), at + Vector3.new(x, 4.05, -8), Theme.Coral, Enum.Material.Glass, false).Transparency = 0.28
	end

	part(plot, "GreenhouseBed", Vector3.new(28, 0.55, 24), at + Vector3.new(16, 2.15, -13), Theme.Moss, Enum.Material.Grass)
	for _, x in {3, 29} do
		for _, z in {-24, -2} do
			part(plot, "GlassFrame", Vector3.new(0.7, 10, 0.7), at + Vector3.new(x, 7, z), Theme.Mint, Enum.Material.Metal)
		end
	end
	for _, z in {-24, -2} do
		part(plot, "GlassBeam", Vector3.new(27, 0.7, 0.7), at + Vector3.new(16, 12, z), Theme.Mint, Enum.Material.Metal)
	end
	part(plot, "GreenhouseCanopy", Vector3.new(28, 0.45, 24), at + Vector3.new(16, 12.5, -13), Theme.Mint, Enum.Material.Glass, false).Transparency = 0.6
	plant(plot, at + Vector3.new(10, 2.45, -15), 1.15)
	plant(plot, at + Vector3.new(20, 2.45, -18), 0.75)
	plant(plot, at + Vector3.new(20, 2.45, -8), 0.9)
	zoneSign(plot, "GreenhouseSign", at + Vector3.new(16, 12.4, 0), 18, Theme.Mint, "01  ОКОЦВІТ", "АВТО: +5 ЕН. / 5 СЕК")
	zoneSign(plot, "WorkshopSign", at + Vector3.new(-20, 12.4, 0), 18, Theme.Slate, "МАЙСТЕРНЯ", "ДОСЛІДЖЕННЯ · СКОРО")
	energyConduit(plot, "GreenhouseEnergyConduit", at + Vector3.new(16, 1.96, 1), at + Vector3.new(4.5, 1.96, 10), Theme.Mint)

	part(plot, "CollectorPlinth", Vector3.new(11, 0.65, 11), at + Vector3.new(0, 2.1, 11), Theme.Ink, Enum.Material.Metal)
	local collector = part(plot, "EnergyCollector", Vector3.new(5, 5.5, 5), at + Vector3.new(0, 5.15, 11), Theme.Mint, Enum.Material.Glass)
	collector.Transparency = 0.25
	part(plot, "CollectorCore", Vector3.new(2.5, 2.5, 2.5), at + Vector3.new(0, 5.2, 11), Theme.Mint, Enum.Material.Neon, false).Shape = Enum.PartType.Ball
	meters[index] = zoneSign(plot, "CollectorSign", at + Vector3.new(0, 14.2, 10.5), 16, Theme.Mint, "02  ЗБЕРИ ЗАРЯД", "")
	energyConduit(plot, "CollectorGuide", at + Vector3.new(0, 1.96, 27), at + Vector3.new(0, 1.96, 17), Theme.Mint)
	local collect = Instance.new("ProximityPrompt")
	collect.ActionText = "Зібрати заряд"
	collect.ObjectText = "Колектор бази"
	collect.HoldDuration = 0.2
	collect.MaxActivationDistance = 12
	collect.RequiresLineOfSight = false
	collect.Parent = collector
	collect.Triggered:Connect(function(player)
		if owners[index] ~= player then return end
		local amount = stored[index]
		if amount <= 0 then
			player:SetAttribute("BaseNotice", "Колектор ще заряджається")
			return
		end
		stored[index] = 0
		player:SetAttribute("Energy", (player:GetAttribute("Energy") or 0) + amount)
		player:SetAttribute("CollectedOnce", true)
		player:SetAttribute("BaseNotice", "+" .. amount .. " енергії · +" .. Config.EyeFlowerCollectionXP .. " XP")
		refreshEnergy(index)
		LevelService.AddXP(player, Config.EyeFlowerCollectionXP)
	end)

	part(plot, "ReactorFloor", Vector3.new(22, 0.5, 23), at + Vector3.new(18, 2.12, 20), Theme.Ink, Enum.Material.Metal)
	for _, x in {11, 24} do
		part(plot, "ReactorChamber", Vector3.new(4, 9, 4), at + Vector3.new(x, 6.9, 16), Theme.Slate, Enum.Material.Glass).Transparency = 0.35
		part(plot, "ReactorCore", Vector3.new(2, 5, 2), at + Vector3.new(x, 6.7, 16), Theme.Amber, Enum.Material.Neon, false)
	end
	console(plot, at + Vector3.new(18, 1.8, 27), "Production", index, "Реактор", Config.ProductionUpgradeCost)
	part(plot, "StorageFloor", Vector3.new(23, 0.5, 22), at + Vector3.new(-19, 2.12, 20), Theme.Ink, Enum.Material.Metal)
	for _, x in {-28, -20, -12} do
		part(plot, "SpecimenTank", Vector3.new(5, 7, 5), at + Vector3.new(x, 5.7, 14), Theme.Mint, Enum.Material.Glass).Transparency = 0.48
		part(plot, "TankCap", Vector3.new(5.5, 0.7, 5.5), at + Vector3.new(x, 9.6, 14), Theme.Slate, Enum.Material.Metal)
	end
	console(plot, at + Vector3.new(-19, 1.8, 27), "Storage", index, "Сховище", Config.StorageUpgradeCost)

	local ownerSign = part(plot, "OwnerSign", Vector3.new(13, 2.5, 0.6), at + Vector3.new(-18, 5.5, 34), Theme.Ink, Enum.Material.Metal, false)
	signs[index] = label(ownerSign, 200, Vector3.new(0, 1.4, 0))
	signs[index].Text = string.format("СЕКТОР %02d · ВІЛЬНО", index)
	for _, x in {-30, 30} do
		part(plot, "BaseBeacon", Vector3.new(0.8, 8, 0.8), at + Vector3.new(x, 5.8, 32), Theme.Slate, Enum.Material.Metal)
		local beacon = part(plot, "BeaconHead", Vector3.new(2, 1.5, 2), at + Vector3.new(x, 10.4, 32), Theme.Amber, Enum.Material.Neon, false)
		local point = Instance.new("PointLight")
		point.Color, point.Range, point.Brightness = Theme.Amber, 18, 0.8
		point.Parent = beacon
	end
	refreshUpgrades(index)
	refreshEnergy(index)
end

local function moveToPlot(player: Player, character: Model)
	local index = slots[player]
	if not index then return end
	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root and root:IsA("BasePart") and slots[player] == index then
		local at = WorldService.GetPlotPosition(index)
		character:PivotTo(CFrame.lookAt(at + Vector3.new(0, 5.5, 29), at + Vector3.new(0, 5, 10)))
	end
end

local function assign(player: Player)
	local free: number? = nil
	for index = 1, Config.PlotCount do
		if not owners[index] then free = index; break end
	end
	if not free then warn("No free plot for " .. player.Name); return end
	owners[free], slots[player], stored[free] = player, free, 0
	player:SetAttribute("PlotIndex", free)
	player:SetAttribute("Energy", 0)
	player:SetAttribute("CollectedOnce", false)
	player:SetAttribute("BaseNotice", "Твоя база готова. Почни з колектора по центру.")
	signs[free].Text = string.format("СЕКТОР %02d · %s", free, player.DisplayName)
	refreshUpgrades(free)
	refreshEnergy(free)
	player.CharacterAdded:Connect(function(character)
		task.defer(moveToPlot, player, character)
	end)
	if player.Character then task.defer(moveToPlot, player, player.Character) end
end

local function release(player: Player)
	local index = slots[player]
	if not index then return end
	owners[index], slots[player], stored[index] = nil, nil, 0
	production[index], storage[index] = false, false
	signs[index].Text = string.format("СЕКТОР %02d · ВІЛЬНО", index)
	refreshUpgrades(index)
	refreshEnergy(index)
end

function PlotService.Init()
	local previous = Workspace:FindFirstChild("PlayerPlots")
	if previous then previous:Destroy() end
	local root = Instance.new("Folder")
	root.Name = "PlayerPlots"
	root.Parent = Workspace
	for index = 1, Config.PlotCount do createPlot(index, root) end
	Players.PlayerAdded:Connect(assign)
	Players.PlayerRemoving:Connect(release)
	for _, player in Players:GetPlayers() do assign(player) end
	task.spawn(function()
		while true do
			task.wait(Config.EyeFlowerProductionSeconds)
			for index = 1, Config.PlotCount do
				if owners[index] then
					local multiplier = production[index] and Config.ProductionUpgradeMultiplier or 1
					stored[index] = math.min(stored[index] + Config.EyeFlowerEnergyPerCycle * multiplier, limit(index))
					refreshEnergy(index)
				end
			end
		end
	end)
end

return PlotService
