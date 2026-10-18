--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local City = require(ReplicatedStorage.Shared.Config.CityConfig)
local remotes = ReplicatedStorage:WaitForChild("CityRemotes")
local travel = remotes:WaitForChild("Travel") :: RemoteFunction
local activityState = remotes:WaitForChild("State") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "CityHUD"; gui.ResetOnSpawn = false; gui.DisplayOrder = 9
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
local screen = Instance.new("Frame")
screen.Name = "SafeArea"; screen.Size = UDim2.fromScale(1, 1); screen.BackgroundTransparency = 1; screen.Parent = gui
local function round(object: GuiObject)
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = object
end
local function text(parent: Instance, name: string, size: number, color: Color3): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name; t.BackgroundTransparency = 1; t.Font = Enum.Font.GothamMedium
	t.TextSize = size; t.TextColor3 = color; t.TextXAlignment = Enum.TextXAlignment.Left; t.Text = ""; t.Parent = parent
	return t
end
local function button(parent: Instance, name: string, value: string): TextButton
	local b = Instance.new("TextButton")
	b.Name = name; b.Text = value; b.Font = Enum.Font.GothamBold; b.TextSize = 15
	b.TextColor3 = Theme.UIText; b.BackgroundColor3 = Theme.UISurface; b.BorderSizePixel = 0; b.Parent = parent
	round(b)
	local stroke = Instance.new("UIStroke"); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Color = Theme.UIBorder; stroke.Parent = b
	return b
end
local nav = Instance.new("Frame")
nav.Name = "Navigation"; nav.BackgroundTransparency = 1; nav.Size = UDim2.fromOffset(254, 44); nav.Parent = screen
local station = button(nav, "Station", "Station")
station.Size = UDim2.fromOffset(123, 44)
local home = button(nav, "Home", "Home")
home.Size = UDim2.fromOffset(123, 44); home.Position = UDim2.fromOffset(131, 0)
local message = text(screen, "TravelMessage", 13, Theme.UIText)
message.Size = UDim2.fromOffset(254, 38); message.TextWrapped = true; message.Visible = false

local card = Instance.new("Frame")
card.Name = "Activity"; card.BackgroundColor3 = Theme.UIBackground; card.BorderSizePixel = 0
card.Position = UDim2.fromOffset(14, 66); card.Visible = false; card.Parent = screen; round(card)
local stroke = Instance.new("UIStroke"); stroke.Color = Theme.UIBorder; stroke.Thickness = 2; stroke.Parent = card
local title = text(card, "Title", 20, Theme.UIText); title.Font = Enum.Font.FredokaOne
title.Position = UDim2.fromOffset(14, 8); title.Size = UDim2.new(1, -104, 0, 30)
local leave = button(card, "Leave", "Leave")
leave.Position = UDim2.new(1, -84, 0, 8); leave.Size = UDim2.fromOffset(70, 44)
local instruction = text(card, "Instruction", 14, Theme.UIText)
instruction.Position = UDim2.fromOffset(14, 49); instruction.Size = UDim2.new(1, -28, 0, 36); instruction.TextWrapped = true
local progress = text(card, "Progress", 22, Theme.Harvest); progress.Font = Enum.Font.GothamBold
progress.Position = UDim2.fromOffset(14, 88); progress.Size = UDim2.new(1, -28, 0, 30)
local footer = text(card, "Reward", 12, Theme.UISecondary)
footer.Position = UDim2.fromOffset(14, 124); footer.Size = UDim2.new(1, -28, 0, 32); footer.TextWrapped = true

local priorPlayerList: boolean? = nil
card:GetPropertyChangedSignal("Visible"):Connect(function()
	pcall(function()
		if card.Visible then
			priorPlayerList = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		elseif priorPlayerList ~= nil then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, priorPlayerList :: boolean)
			priorPlayerList = nil
		end
	end)
end)

local data: any = nil
local pending = false
local version = 0
local messageVersion = 0
local function notify(value: string)
	messageVersion += 1
	local token = messageVersion
	message.Text = value; message.Visible = true
	task.delay(3, function() if messageVersion == token then message.Visible = false end end)
end
local function go(destination: string)
	if pending then return end
	pending = true; station.Active = false; home.Active = false; leave.Active = false
	local ok, result = pcall(function() return travel:InvokeServer(destination) end)
	pending = false; station.Active = true; home.Active = true; leave.Active = true
	if ok and typeof(result) == "table" then notify(result.message) else notify("Travel is unavailable. Please try again.") end
end
station.Activated:Connect(function() go("Station") end)
home.Activated:Connect(function() go("Home") end)
leave.Activated:Connect(function() go("Station") end)

activityState.OnClientEvent:Connect(function(value)
	if typeof(value) ~= "table" then return end
	version += 1
	local token = version
	data = value
	card.Visible = value.Active == true or value.Message ~= nil
	card:SetAttribute("ActivityId", value.Id or "")
	card:SetAttribute("Phase", value.Phase or "Result")
	card:SetAttribute("Progress", value.Progress or 0)
	if not value.Active then
		title.Text = value.Success and "Activity cleared!" or "Activity ended"
		instruction.Text = value.Name or "Central Station"
		progress.Text = value.Success and (tostring(value.Seconds) .. " s") or "Try another round"
		footer.Text = value.Message or ""
		task.delay(4, function() if version == token then data = nil; card.Visible = false end end)
	end
end)
local function update()
	local view = screen.AbsoluteSize
	card.Size = UDim2.fromOffset(math.min(360, view.X - 28), 166)
	nav.Position = UDim2.fromOffset(14, card.Visible and 12 or 150)
	message.Position = UDim2.fromOffset(14, card.Visible and 240 or 196)
	local baseGui = player.PlayerGui:FindFirstChild("AnomalyHUD")
	local baseScreen = baseGui and baseGui:FindFirstChild("SafeArea")
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local index = player:GetAttribute("BaseIndex")
	local at = index and City.BasePositions[index]
	local onBase = false
	if root and root:IsA("BasePart") and at then
		local relative = root.Position - at
		onBase = math.abs(relative.X) < 48 and math.abs(relative.Z) < 55
	end
	if baseScreen then
		local status = baseScreen:FindFirstChild("BaseStatus") :: GuiObject?
		local actions = baseScreen:FindFirstChild("Actions") :: GuiObject?
		local hint = baseScreen:FindFirstChild("BaseHint") :: GuiObject?
		if status then status.Visible = not card.Visible end
		if actions then actions.Visible = onBase and not card.Visible end
		if hint then hint.Visible = onBase and not card.Visible end
	end
	if not data or not data.Active then return end
	local now = Workspace:GetServerTimeNow()
	title.Text = data.Name
	local seconds = data.Deadline > 0 and math.max(0, math.ceil(data.Deadline - now)) or math.floor(now - data.Started)
	if data.Id == "Obby" then
		instruction.Text = data.Message or "Jump through all stages. Green platforms save your checkpoint."
		progress.Text = "Stage " .. data.Progress .. " / " .. data.Total .. "  ·  " .. seconds .. " s"
	elseif data.Id == "Circuit" then
		instruction.Text = data.Message or "Step on each numbered button. You have 30 seconds."
		progress.Text = data.Progress .. " / " .. data.Total .. " buttons  ·  " .. seconds .. " s"
	elseif data.Phase == "Study" and now < data.StudyUntil then
		instruction.Text = data.Message or "Remember these numbers. Then repeat them on the floor buttons."
		local pattern = {}
		for _, number in data.Pattern or {} do table.insert(pattern, tostring(number)) end
		progress.Text = table.concat(pattern, " > ") .. "  ·  " .. math.max(0, math.ceil(data.StudyUntil - now)) .. " s"
	else
		instruction.Text = "Step on the four numbers in the order you memorized."
		progress.Text = data.Progress .. " / " .. data.Total .. " correct  ·  " .. seconds .. " s"
	end
	local rewardIn = math.max(0, math.ceil((data.RewardReadyAt or 0) - now))
	footer.Text = rewardIn > 0 and ("Practice round · reward cooldown: " .. rewardIn .. " s") or ("Clear reward: " .. data.Coins .. " coins + " .. data.XP .. " XP")
end
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
task.spawn(function() while gui.Parent do update(); task.wait(0.1) end end)
