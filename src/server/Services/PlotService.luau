--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)
local LevelService = require(script.Parent.LevelService)

local PlotService = {}

local PLOT_POSITIONS = {
	Vector3.new(-72, 0, -54),
	Vector3.new(0, 0, -78),
	Vector3.new(72, 0, -54),
	Vector3.new(-72, 0, 54),
	Vector3.new(0, 0, 78),
	Vector3.new(72, 0, 54),
}

local plots: {Model} = {}
local owners: {[number]: Player} = {}
local playerSlots: {[Player]: number} = {}
local storedEnergy: {[number]: number} = {}
local labels: {[number]: TextLabel} = {}
local energyLabels: {[number]: TextLabel} = {}

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	position: Vector3,
	color: Color3,
	material: Enum.Material
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.Parent = parent
	return part
end

local function makeBillboard(parent: BasePart, width: number, height: number): TextLabel
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(width, height)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 60
	billboard.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(18, 28, 35)
	label.BackgroundTransparency = 0.15
	label.TextColor3 = Color3.fromRGB(235, 255, 244)
	label.TextSize = 18
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = label
	return label
end

local function createPlot(index: number, root: Folder)
	local position = PLOT_POSITIONS[index]
	local plot = Instance.new("Model")
	plot.Name = "Plot_" .. index
	plot.Parent = root
	plots[index] = plot
	storedEnergy[index] = 0

	makePart(plot, "Floor", Vector3.new(44, 1, 44), position + Vector3.new(0, 0.5, 0), Color3.fromRGB(39, 57, 63), Enum.Material.Concrete)
	makePart(plot, "LeftBorder", Vector3.new(1, 0.5, 44), position + Vector3.new(-22, 1.25, 0), Color3.fromRGB(64, 218, 177), Enum.Material.Neon)
	makePart(plot, "RightBorder", Vector3.new(1, 0.5, 44), position + Vector3.new(22, 1.25, 0), Color3.fromRGB(64, 218, 177), Enum.Material.Neon)
	makePart(plot, "FrontBorder", Vector3.new(44, 0.5, 1), position + Vector3.new(0, 1.25, 22), Color3.fromRGB(64, 218, 177), Enum.Material.Neon)
	makePart(plot, "BackBorder", Vector3.new(44, 0.5, 1), position + Vector3.new(0, 1.25, -22), Color3.fromRGB(64, 218, 177), Enum.Material.Neon)

	local sign = makePart(plot, "OwnerSign", Vector3.new(8, 4, 1), position + Vector3.new(0, 4, 19), Color3.fromRGB(18, 28, 35), Enum.Material.Metal)
	labels[index] = makeBillboard(sign, 170, 34)
	labels[index].Text = "Вільна ділянка"

	makePart(plot, "GreenhousePad", Vector3.new(16, 0.4, 16), position + Vector3.new(0, 1.2, -6), Color3.fromRGB(66, 102, 78), Enum.Material.Grass)
	local stem = makePart(plot, "EyeFlowerStem", Vector3.new(1.2, 4, 1.2), position + Vector3.new(0, 3.2, -6), Color3.fromRGB(72, 174, 92), Enum.Material.Grass)
	stem.Shape = Enum.PartType.Cylinder
	local flower = makePart(plot, "EyeFlower", Vector3.new(5, 5, 5), position + Vector3.new(0, 6.2, -6), Color3.fromRGB(210, 94, 150), Enum.Material.SmoothPlastic)
	flower.Shape = Enum.PartType.Ball
	local eye = makePart(plot, "Eye", Vector3.new(2, 2, 0.5), position + Vector3.new(0, 6.2, -8.4), Color3.fromRGB(245, 246, 227), Enum.Material.SmoothPlastic)
	eye.Shape = Enum.PartType.Ball
	local pupil = makePart(plot, "Pupil", Vector3.new(0.75, 0.75, 0.3), position + Vector3.new(0, 6.2, -8.7), Color3.fromRGB(18, 25, 30), Enum.Material.SmoothPlastic)
	pupil.Shape = Enum.PartType.Ball

	local collector = makePart(plot, "EnergyCollector", Vector3.new(5, 4, 5), position + Vector3.new(0, 3, 8), Color3.fromRGB(51, 182, 215), Enum.Material.Neon)
	energyLabels[index] = makeBillboard(collector, 170, 34)
	energyLabels[index].Text = "Енергія: 0/100"

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Зібрати енергію"
	prompt.ObjectText = "Окоцвіт"
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Parent = collector
	prompt.Triggered:Connect(function(player)
		if owners[index] ~= player then
			return
		end

		local amount = storedEnergy[index]
		if amount <= 0 then
			return
		end

		storedEnergy[index] = 0
		energyLabels[index].Text = "Енергія: 0/" .. GameConfig.EyeFlowerStorageLimit
		player:SetAttribute("Energy", (player:GetAttribute("Energy") or 0) + amount)
		LevelService.AddXP(player, GameConfig.EyeFlowerCollectionXP)
	end)
end

local function moveCharacterToPlot(player: Player, character: Model)
	local slot = playerSlots[player]
	if not slot then
		return
	end

	local root = character:WaitForChild("HumanoidRootPart", 10)
	if root and root:IsA("BasePart") and playerSlots[player] == slot then
		local spawnPosition = PLOT_POSITIONS[slot] + Vector3.new(-12, 4, 9)
		character:PivotTo(CFrame.lookAt(spawnPosition, PLOT_POSITIONS[slot] + Vector3.new(0, 4, -6)))
	end
end

local function assignPlot(player: Player)
	local freeSlot: number? = nil
	for index = 1, GameConfig.PlotCount do
		if owners[index] == nil then
			freeSlot = index
			break
		end
	end

	if not freeSlot then
		warn("No free plot for " .. player.Name)
		return
	end

	owners[freeSlot] = player
	playerSlots[player] = freeSlot
	storedEnergy[freeSlot] = 0
	player:SetAttribute("PlotIndex", freeSlot)
	player:SetAttribute("Energy", 0)
	labels[freeSlot].Text = player.DisplayName .. " · лабораторія"
	energyLabels[freeSlot].Text = "Енергія: 0/" .. GameConfig.EyeFlowerStorageLimit

	player.CharacterAdded:Connect(function(character)
		task.defer(moveCharacterToPlot, player, character)
	end)
	if player.Character then
		task.defer(moveCharacterToPlot, player, player.Character)
	end
end

local function releasePlot(player: Player)
	local slot = playerSlots[player]
	if not slot then
		return
	end

	owners[slot] = nil
	playerSlots[player] = nil
	storedEnergy[slot] = 0
	labels[slot].Text = "Вільна ділянка"
	energyLabels[slot].Text = "Енергія: 0/" .. GameConfig.EyeFlowerStorageLimit
end

function PlotService.Init()
	local root = Instance.new("Folder")
	root.Name = "PlayerPlots"
	root.Parent = Workspace

	for index = 1, GameConfig.PlotCount do
		createPlot(index, root)
	end

	Players.PlayerAdded:Connect(assignPlot)
	Players.PlayerRemoving:Connect(releasePlot)
	for _, player in Players:GetPlayers() do
		assignPlot(player)
	end

	task.spawn(function()
		while true do
			task.wait(GameConfig.EyeFlowerProductionSeconds)
			for index = 1, GameConfig.PlotCount do
				if owners[index] then
					storedEnergy[index] = math.min(
						storedEnergy[index] + GameConfig.EyeFlowerEnergyPerCycle,
						GameConfig.EyeFlowerStorageLimit
					)
					energyLabels[index].Text = "Енергія: " .. storedEnergy[index] .. "/" .. GameConfig.EyeFlowerStorageLimit
				end
			end
		end
	end)
end

return PlotService
