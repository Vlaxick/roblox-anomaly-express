--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
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
	f.BackgroundTransparency = 0.06
	f.BorderSizePixel = 0
	f.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 9)
	corner.Parent = f
	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Slate
	stroke.Thickness = 1
	stroke.Transparency = 0.18
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
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.Parent = parent
	return t
end

local left = frame(gui, "FieldRecord", UDim2.fromOffset(302, 214), UDim2.fromOffset(14, 14), Theme.Ink)
local leftScale = Instance.new("UIScale")
leftScale.Parent = left
frame(left, "AccentBar", UDim2.fromOffset(4, 196), UDim2.fromOffset(0, 9), Theme.Mint).BorderSizePixel = 0
text(left, "Overline", "FIELD RECORD  /  AE-01", UDim2.fromOffset(20, 10), UDim2.fromOffset(254, 22), 13, Theme.Mint, Enum.Font.Code)
text(left, "Title", "ANOMALY EXPRESS", UDim2.fromOffset(20, 33), UDim2.fromOffset(265, 29), 21, Theme.Paper, Enum.Font.GothamBlack)
text(left, "Sector", "Лабораторія · сектор --", UDim2.fromOffset(20, 64), UDim2.fromOffset(260, 22), 14, Theme.Muted, Enum.Font.GothamMedium)
local levelText = text(left, "Level", "РІВЕНЬ 01", UDim2.fromOffset(20, 96), UDim2.fromOffset(135, 23), 17, Theme.Paper, Enum.Font.GothamBold)
local xpText = text(left, "XP", "0 / 100 XP", UDim2.fromOffset(171, 98), UDim2.fromOffset(110, 20), 13, Theme.Muted, Enum.Font.Code)
xpText.TextXAlignment = Enum.TextXAlignment.Right
local xpTrack = frame(left, "XPTrack", UDim2.fromOffset(262, 7), UDim2.fromOffset(20, 125), Theme.Steel)
xpTrack.BackgroundTransparency = 0
local xpFill = frame(xpTrack, "XPFill", UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Theme.Mint)
xpFill.BackgroundTransparency = 0
xpFill:FindFirstChildOfClass("UIStroke"):Destroy()
text(left, "WalletLabel", "ЕНЕРГІЯ", UDim2.fromOffset(20, 144), UDim2.fromOffset(105, 20), 12, Theme.Muted, Enum.Font.Code)
text(left, "StoredLabel", "У КОЛЕКТОРІ", UDim2.fromOffset(158, 144), UDim2.fromOffset(126, 20), 12, Theme.Muted, Enum.Font.Code)
local energyText = text(left, "Wallet", "0", UDim2.fromOffset(20, 164), UDim2.fromOffset(118, 31), 24, Theme.Amber, Enum.Font.GothamBlack)
local storedText = text(left, "Stored", "0 / 100", UDim2.fromOffset(158, 164), UDim2.fromOffset(126, 31), 22, Theme.Paper, Enum.Font.GothamBold)

local right = frame(gui, "StationCard", UDim2.fromOffset(246, 151), UDim2.new(1, -260, 0, 136), Theme.Ink)
local rightScale = Instance.new("UIScale")
rightScale.Parent = right
text(right, "Overline", "STATION  01  /  TERMINAL", UDim2.fromOffset(16, 10), UDim2.fromOffset(216, 20), 12, Theme.Amber, Enum.Font.Code)
text(right, "Title", "НАСТУПНИЙ РЕЙС", UDim2.fromOffset(16, 36), UDim2.fromOffset(216, 26), 16, Theme.Paper, Enum.Font.GothamBold)
text(right, "Status", "Маршрут готується", UDim2.fromOffset(16, 70), UDim2.fromOffset(214, 27), 19, Theme.Amber, Enum.Font.GothamBlack)
text(right, "Description", "Поки розбудовуй лабораторію", UDim2.fromOffset(16, 104), UDim2.fromOffset(214, 20), 12, Theme.Muted, Enum.Font.GothamMedium)
local railLine = frame(right, "RailLine", UDim2.fromOffset(214, 3), UDim2.fromOffset(16, 137), Theme.Slate)
railLine.BackgroundTransparency = 0
railLine:FindFirstChildOfClass("UIStroke"):Destroy()
local railSignal = frame(railLine, "RailSignal", UDim2.fromOffset(45, 3), UDim2.fromOffset(0, 0), Theme.Amber)
railSignal.BackgroundTransparency = 0
railSignal:FindFirstChildOfClass("UIStroke"):Destroy()

local base = frame(gui, "BaseStatus", UDim2.fromOffset(302, 72), UDim2.new(0, 14, 1, -86), Theme.Ink)
local baseScale = Instance.new("UIScale")
baseScale.Parent = base
text(base, "Overline", "BASE SYSTEMS", UDim2.fromOffset(16, 8), UDim2.fromOffset(270, 18), 12, Theme.Mint, Enum.Font.Code)
local productionText = text(base, "Production", "Реактор  ·  рівень 1", UDim2.fromOffset(16, 30), UDim2.fromOffset(268, 18), 14, Theme.Paper, Enum.Font.GothamMedium)
local storageText = text(base, "Storage", "Сховище  ·  рівень 1", UDim2.fromOffset(16, 49), UDim2.fromOffset(268, 18), 14, Theme.Muted, Enum.Font.GothamMedium)

local notice = frame(gui, "Notice", UDim2.fromOffset(310, 44), UDim2.new(0.5, -155, 1, -58), Theme.Panel)
local noticeScale = Instance.new("UIScale")
noticeScale.Parent = notice
local noticeText = text(notice, "Text", "Збирай заряд у колекторі бази", UDim2.fromOffset(14, 4), UDim2.fromOffset(282, 36), 13, Theme.Paper, Enum.Font.GothamMedium)
noticeText.TextXAlignment = Enum.TextXAlignment.Center

local function update()
	local level = player:GetAttribute("Level") or 1
	local xp = player:GetAttribute("XP") or 0
	local required = math.floor(100 * (level ^ 1.35))
	levelText.Text = string.format("РІВЕНЬ %02d", level)
	xpText.Text = string.format("%d / %d XP", xp, required)
	xpFill.Size = UDim2.fromScale(math.clamp(xp / required, 0, 1), 1)
	energyText.Text = tostring(player:GetAttribute("Energy") or 0)
	storedText.Text = string.format("%d / %d", player:GetAttribute("StoredEnergy") or 0, player:GetAttribute("StorageLimit") or 100)
	local sector = player:GetAttribute("PlotIndex")
	left.Sector.Text = sector and string.format("Лабораторія · сектор %02d", sector) or "Лабораторія · очікування"
	productionText.Text = "Реактор  ·  рівень " .. (player:GetAttribute("ProductionLevel") or 1)
	storageText.Text = "Сховище  ·  рівень " .. (player:GetAttribute("StorageLevel") or 1)
	noticeText.Text = player:GetAttribute("BaseNotice") or "Збирай заряд у колекторі бази"
end

for _, attribute in {"Level", "XP", "Energy", "StoredEnergy", "StorageLimit", "PlotIndex", "ProductionLevel", "StorageLevel", "BaseNotice"} do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end
update()

local function resize()
	local camera = Workspace.CurrentCamera
	if not camera then return end
	local mobile = UserInputService.TouchEnabled or camera.ViewportSize.X < 740 or camera.ViewportSize.Y < 600
	leftScale.Scale = mobile and 0.9 or 1
	rightScale.Scale = mobile and 0.9 or 1
	baseScale.Scale = mobile and 0.9 or 1
	noticeScale.Scale = mobile and 0.9 or 1
	if mobile then
		right.Visible = false
		if camera.ViewportSize.Y < 500 and camera.ViewportSize.X > 600 then
			base.Position = UDim2.new(1, -286, 0, 14)
		else
			base.Position = UDim2.fromOffset(14, 214)
		end
		notice.Position = UDim2.new(1, -294, 1, -144)
	else
		right.Visible = true
		right.Position = UDim2.new(1, -260, 0, 136)
		base.Position = UDim2.new(0, 14, 1, -86)
		notice.Position = UDim2.new(0.5, -155, 1, -58)
	end
end

local function watchCamera()
	local camera = Workspace.CurrentCamera
	if camera then
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
	end
	resize()
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
watchCamera()
