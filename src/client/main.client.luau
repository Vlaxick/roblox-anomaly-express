--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)

local gui = Instance.new("ScreenGui")
gui.Name = "AnomalyHUD"
gui.DisplayOrder = 10
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local function frame(parent: Instance, name: string, size: UDim2, position: UDim2, color: Color3): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Size = size
	f.Position = position
	f.BackgroundColor3 = color
	f.BackgroundTransparency = 0.04
	f.BorderSizePixel = 0
	f.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = f
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Slate
	stroke.Thickness = 1
	stroke.Transparency = 0.15
	stroke.Parent = f
	return f
end

local function text(parent: Instance, name: string, content: string, pos: UDim2, size: UDim2, pointSize: number, color: Color3, font: Enum.Font): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.BackgroundTransparency = 1
	t.Position = pos
	t.Size = size
	t.Font = font
	t.Text = content
	t.TextSize = pointSize
	t.TextColor3 = color
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Center
	t.Parent = parent
	return t
end

local function progress(parent: Instance, name: string, position: UDim2, width: number, color: Color3): Frame
	local track = frame(parent, name .. "Track", UDim2.fromOffset(width, 7), position, Theme.Steel)
	track.BackgroundTransparency = 0
	track:FindFirstChildOfClass("UIStroke"):Destroy()
	local fill = frame(track, name .. "Fill", UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), color)
	fill.BackgroundTransparency = 0
	fill:FindFirstChildOfClass("UIStroke"):Destroy()
	return fill
end

local status = frame(gui, "BaseStatus", UDim2.fromOffset(286, 190), UDim2.fromOffset(14, 14), Theme.Ink)
local statusScale = Instance.new("UIScale")
statusScale.Parent = status
frame(status, "Accent", UDim2.fromOffset(4, 172), UDim2.fromOffset(0, 9), Theme.Mint)
local sectorText = text(status, "Sector", "ТВОЯ БАЗА / СЕКТОР --", UDim2.fromOffset(18, 9), UDim2.fromOffset(250, 22), 12, Theme.Mint, Enum.Font.Code)
text(status, "Title", "ANOMALY EXPRESS", UDim2.fromOffset(18, 33), UDim2.fromOffset(250, 30), 20, Theme.Paper, Enum.Font.GothamBlack)
local levelText = text(status, "Level", "РІВЕНЬ 01", UDim2.fromOffset(18, 75), UDim2.fromOffset(132, 26), 17, Theme.Paper, Enum.Font.GothamBold)
local xpText = text(status, "XP", "0 / 100 XP", UDim2.fromOffset(155, 77), UDim2.fromOffset(112, 22), 12, Theme.Muted, Enum.Font.Code)
xpText.TextXAlignment = Enum.TextXAlignment.Right
local xpFill = progress(status, "XP", UDim2.fromOffset(18, 108), 250, Theme.Mint)
text(status, "WalletLabel", "У ТЕБЕ", UDim2.fromOffset(18, 128), UDim2.fromOffset(115, 20), 12, Theme.Muted, Enum.Font.Code)
text(status, "StoredLabel", "У КОЛЕКТОРІ", UDim2.fromOffset(148, 128), UDim2.fromOffset(120, 20), 12, Theme.Muted, Enum.Font.Code)
local energyText = text(status, "Wallet", "0", UDim2.fromOffset(18, 148), UDim2.fromOffset(118, 32), 25, Theme.Amber, Enum.Font.GothamBlack)
local storedText = text(status, "Stored", "0 / 100", UDim2.fromOffset(148, 148), UDim2.fromOffset(120, 32), 21, Theme.Paper, Enum.Font.GothamBold)

local objective = frame(gui, "CurrentGoal", UDim2.fromOffset(338, 198), UDim2.new(1, -352, 0, 264), Theme.Ink)
local objectiveScale = Instance.new("UIScale")
objectiveScale.Parent = objective
frame(objective, "Accent", UDim2.fromOffset(4, 180), UDim2.fromOffset(0, 9), Theme.Amber)
text(objective, "Overline", "ЗАРАЗ ЗРОБИ", UDim2.fromOffset(18, 10), UDim2.fromOffset(220, 20), 13, Theme.Amber, Enum.Font.Code)
local stepText = text(objective, "Step", "КРОК 1 / 3", UDim2.fromOffset(230, 10), UDim2.fromOffset(90, 20), 12, Theme.Muted, Enum.Font.Code)
stepText.TextXAlignment = Enum.TextXAlignment.Right
local goalTitle = text(objective, "GoalTitle", "ЗАБЕРИ ПЕРШИЙ ЗАРЯД", UDim2.fromOffset(18, 40), UDim2.fromOffset(302, 28), 19, Theme.Paper, Enum.Font.GothamBlack)
local goalBody = text(objective, "GoalBody", "Окоцвіт сам наповнює колектор. Підійди до нього й забери енергію.", UDim2.fromOffset(18, 75), UDim2.fromOffset(302, 52), 15, Theme.Paper, Enum.Font.GothamMedium)
goalBody.TextWrapped = true
goalBody.TextYAlignment = Enum.TextYAlignment.Top
local goalFill = progress(objective, "Goal", UDim2.fromOffset(18, 138), 302, Theme.Amber)
local progressText = text(objective, "Progress", "0 / 5 У КОЛЕКТОРІ", UDim2.fromOffset(18, 151), UDim2.fromOffset(302, 19), 12, Theme.Muted, Enum.Font.Code)
local targetText = text(objective, "Target", "ЦІЛЬ: КОЛЕКТОР ПО ЦЕНТРУ БАЗИ", UDim2.fromOffset(18, 176), UDim2.fromOffset(302, 18), 12, Theme.Mint, Enum.Font.GothamBold)

local notice = frame(gui, "Notice", UDim2.fromOffset(328, 48), UDim2.new(0.5, -164, 1, -65), Theme.Panel)
local noticeScale = Instance.new("UIScale")
noticeScale.Parent = notice
local noticeText = text(notice, "Text", "", UDim2.fromOffset(14, 5), UDim2.fromOffset(300, 38), 14, Theme.Paper, Enum.Font.GothamMedium)
noticeText.TextWrapped = true
noticeText.TextXAlignment = Enum.TextXAlignment.Center
notice.Visible = false

local highlight = Instance.new("Highlight")
highlight.Name = "CurrentGoalHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.FillTransparency = 0.82
highlight.OutlineTransparency = 0.05
highlight.FillColor = Theme.Mint
highlight.OutlineColor = Theme.Mint
highlight.Parent = Workspace

local function setTarget(partName: string?, color: Color3)
	highlight.FillColor = color
	highlight.OutlineColor = color
	local index = player:GetAttribute("PlotIndex")
	local plots = Workspace:FindFirstChild("PlayerPlots")
	local plot = index and plots and plots:FindFirstChild("Laboratory_" .. index)
	highlight.Adornee = plot and partName and plot:FindFirstChild(partName) or nil
end

local function update()
	local level = player:GetAttribute("Level") or 1
	local xp = player:GetAttribute("XP") or 0
	local required = math.floor(100 * (level ^ 1.35))
	local energy = player:GetAttribute("Energy") or 0
	local stored = player:GetAttribute("StoredEnergy") or 0
	local capacity = player:GetAttribute("StorageLimit") or Config.EyeFlowerStorageLimit
	local reactorLevel = player:GetAttribute("ProductionLevel") or 1
	local storageLevel = player:GetAttribute("StorageLevel") or 1
	local sector = player:GetAttribute("PlotIndex")

	sectorText.Text = sector and string.format("ТВОЯ БАЗА / СЕКТОР %02d", sector) or "ТВОЯ БАЗА / ОЧІКУВАННЯ"
	levelText.Text = string.format("РІВЕНЬ %02d", level)
	xpText.Text = string.format("%d / %d XP", xp, required)
	xpFill.Size = UDim2.fromScale(math.clamp(xp / required, 0, 1), 1)
	energyText.Text = tostring(energy)
	storedText.Text = string.format("%d / %d", stored, capacity)

	local target: string? = "EnergyCollector"
	local targetColor = Theme.Mint
	if not sector or not player:GetAttribute("CollectedOnce") then
		stepText.Text = "КРОК 1 / 3"
		goalTitle.Text = "ЗАБЕРИ ПЕРШИЙ ЗАРЯД"
		goalBody.Text = "Окоцвіт наповнює колектор кожні 5 секунд. Підійди до центру бази й забери енергію."
		progressText.Text = stored >= Config.EyeFlowerEnergyPerCycle and string.format("КОЛЕКТОР ГОТОВИЙ: %d ЕН. · ЗАБЕРИ", stored) or string.format("ЗАРЯДЖАЄТЬСЯ: %d / %d", stored, Config.EyeFlowerEnergyPerCycle)
		goalFill.Size = UDim2.fromScale(math.clamp(stored / Config.EyeFlowerEnergyPerCycle, 0, 1), 1)
		targetText.Text = "ЦІЛЬ: КОЛЕКТОР ПО ЦЕНТРУ БАЗИ"
	elseif reactorLevel < 2 then
		stepText.Text = "КРОК 2 / 3"
		goalTitle.Text = "ПОКРАЩ РЕАКТОР"
		goalBody.Text = "Збери 80 енергії. Реактор праворуч подвоїть швидкість виробництва."
		progressText.Text = string.format("НА ПОКРАЩЕННЯ: %d / %d ЕН.", energy, Config.ProductionUpgradeCost)
		goalFill.Size = UDim2.fromScale(math.clamp(energy / Config.ProductionUpgradeCost, 0, 1), 1)
		if energy >= Config.ProductionUpgradeCost then
			target = "ProductionPedestal"
			targetColor = Theme.Amber
			targetText.Text = "ГОТОВО: РЕАКТОР ПРАВОРУЧ"
		else
			targetText.Text = "ЦІЛЬ: ЗБИРАЙ ЗАРЯД У КОЛЕКТОРІ"
		end
	elseif storageLevel < 2 then
		stepText.Text = "КРОК 3 / 3"
		goalTitle.Text = "РОЗШИР СХОВИЩЕ"
		goalBody.Text = "Збери 150 енергії. Сховище ліворуч збільшить місткість колектора до 200."
		progressText.Text = string.format("НА ПОКРАЩЕННЯ: %d / %d ЕН.", energy, Config.StorageUpgradeCost)
		goalFill.Size = UDim2.fromScale(math.clamp(energy / Config.StorageUpgradeCost, 0, 1), 1)
		if energy >= Config.StorageUpgradeCost then
			target = "StoragePedestal"
			targetColor = Theme.Amber
			targetText.Text = "ГОТОВО: СХОВИЩЕ ЛІВОРУЧ"
		else
			targetText.Text = "ЦІЛЬ: ЗБИРАЙ ЗАРЯД У КОЛЕКТОРІ"
		end
	else
		stepText.Text = "БАЗА 3 / 3"
		goalTitle.Text = "БАЗА ГОТОВА"
		goalBody.Text = "База готова. Збирай заряд далі; експедиції поїздом додамо наступним етапом."
		progressText.Text = "РЕАКТОР ×2   ·   КОЛЕКТОР 200"
		goalFill.Size = UDim2.fromScale(1, 1)
		targetText.Text = "ПОВЕРТАЙСЯ ДО КОЛЕКТОРА ПО ЗАРЯД"
	end
	setTarget(target, targetColor)
end

for _, attribute in {"Level", "XP", "Energy", "StoredEnergy", "StorageLimit", "PlotIndex", "ProductionLevel", "StorageLevel", "CollectedOnce"} do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end
update()

local noticeVersion = 0
local function showNotice()
	local message = player:GetAttribute("BaseNotice")
	if not message or message == "" then return end
	noticeVersion += 1
	local version = noticeVersion
	noticeText.Text = message
	notice.Visible = true
	task.delay(4, function()
		if noticeVersion == version then notice.Visible = false end
	end)
end
player:GetAttributeChangedSignal("BaseNotice"):Connect(showNotice)
showNotice()

local function resize()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local viewport = camera.ViewportSize
	local mobile = UserInputService.TouchEnabled or viewport.X < 740 or viewport.Y < 600
	local portrait = viewport.X < 600 or viewport.Y > viewport.X
	local scale = mobile and (portrait and (viewport.X < 360 and 0.88 or 0.96) or 0.86) or 1
	statusScale.Scale = scale
	objectiveScale.Scale = scale
	noticeScale.Scale = scale
	if mobile then
		if portrait then
			objective.Position = UDim2.fromOffset(14, 14 + 190 * scale + 14)
			notice.Position = UDim2.fromOffset(14, 14 + 190 * scale + 14 + 198 * scale + 10)
		else
			objective.Position = UDim2.new(1, -(338 * scale + 14), 0, 88)
			notice.Position = UDim2.new(0.5, -(328 * scale) / 2, 1, -(48 * scale + 68))
		end
	else
		objective.Position = UDim2.new(1, -352, 0, 264)
		notice.Position = UDim2.new(0.5, -164, 1, -65)
	end
end

local function watchCamera()
	local camera = Workspace.CurrentCamera
	if camera then camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
	resize()
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()
