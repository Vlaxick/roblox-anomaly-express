--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Crops = require(ReplicatedStorage.Shared.Config.Crops)
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local remotes = ReplicatedStorage:WaitForChild("FarmRemotes")
local request = remotes:WaitForChild("Request") :: RemoteFunction
local openMenu = remotes:WaitForChild("OpenPlantMenu") :: RemoteEvent
local feedback = remotes:WaitForChild("Feedback") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "AnomalyHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")
local screen = Instance.new("Frame")
screen.Name = "SafeArea"
screen.Size = UDim2.fromScale(1, 1)
screen.BackgroundTransparency = 1
screen.Parent = gui

local function rounded(object: GuiObject, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = object
end

local function frame(parent: Instance, name: string, color: Color3, radius: number?): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Parent = parent
	if radius then rounded(f, radius) end
	return f
end

local function text(parent: Instance, name: string, value: string, size: number, color: Color3, font: Enum.Font?): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.BackgroundTransparency = 1
	t.Text = value
	t.TextSize = size
	t.TextColor3 = color
	t.Font = font or Enum.Font.GothamMedium
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = parent
	return t
end

local function button(parent: Instance, name: string, value: string): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.BackgroundColor3 = Theme.Green
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.TextColor3 = Theme.Paper
	b.Text = value
	b.AutoButtonColor = true
	b.Parent = parent
	rounded(b, 9)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Theme.Ink
	stroke.Transparency = 0.65
	stroke.Parent = b
	return b
end

local status = frame(screen, "FarmStatus", Theme.Paper, 12)
status.Position = UDim2.fromOffset(14, 12)
status.Size = UDim2.fromOffset(254, 126)
local edge = Instance.new("UIStroke")
edge.Color = Theme.Wood
edge.Thickness = 2
edge.Parent = status
local heading = text(status, "Title", "Моя ферма", 21, Theme.Ink, Enum.Font.FredokaOne)
heading.Position = UDim2.fromOffset(16, 8)
heading.Size = UDim2.fromOffset(220, 28)
local coinLabel = text(status, "CoinLabel", "Монети", 12, Theme.Muted)
coinLabel.Position = UDim2.fromOffset(16, 42)
coinLabel.Size = UDim2.fromOffset(95, 18)
local coinsText = text(status, "Coins", "40", 29, Theme.Ink, Enum.Font.GothamBold)
coinsText.Position = UDim2.fromOffset(16, 61)
coinsText.Size = UDim2.fromOffset(110, 34)
local incomeText = text(status, "Income", "+0 / 5 с", 18, Theme.Green, Enum.Font.GothamBold)
incomeText.Position = UDim2.fromOffset(132, 59)
incomeText.Size = UDim2.fromOffset(112, 29)
local autoText = text(status, "AutoIncome", "автоматично", 11, Theme.Muted)
autoText.Position = UDim2.fromOffset(132, 83)
autoText.Size = UDim2.fromOffset(110, 16)
local farmText = text(status, "Beds", "2 грядки · Рівень 1", 12, Theme.Muted)
farmText.Position = UDim2.fromOffset(16, 103)
farmText.Size = UDim2.fromOffset(230, 18)

local plantButton = button(screen, "PlantButton", "Посадити")
plantButton.AnchorPoint = Vector2.new(0.5, 1)
plantButton.Position = UDim2.new(0.5, 0, 1, -14)
plantButton.Size = UDim2.fromOffset(202, 48)
plantButton.TextSize = 18
local hint = frame(screen, "FarmHint", Theme.Paper, 9)
hint.AnchorPoint = Vector2.new(0.5, 1)
hint.Position = UDim2.new(0.5, 0, 1, -72)
local hintText = text(hint, "Text", "Посади гарбуз — він почне заробляти.", 14, Theme.Ink)
hintText.Size = UDim2.new(1, -20, 1, 0)
hintText.Position = UDim2.fromOffset(10, 0)
hintText.TextXAlignment = Enum.TextXAlignment.Center
hintText.TextWrapped = true

local overlay = frame(screen, "CatalogueOverlay", Theme.Ink)
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundTransparency = 1
overlay.ZIndex = 20
overlay.Visible = false
local backdrop = Instance.new("TextButton")
backdrop.Name = "CloseBackdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Theme.Ink
backdrop.BackgroundTransparency = 0.3
backdrop.Text = ""
backdrop.AutoButtonColor = false
backdrop.BorderSizePixel = 0
backdrop.Modal = true
backdrop.Selectable = false
backdrop.Parent = overlay
local catalogue = frame(overlay, "SeedCatalogue", Theme.Paper, 14)
catalogue.AnchorPoint = Vector2.new(0.5, 0.5)
catalogue.Position = UDim2.fromScale(0.5, 0.5)
catalogue.Active = true
local catalogueBorder = Instance.new("UIStroke")
catalogueBorder.Color = Theme.Wood
catalogueBorder.Thickness = 3
catalogueBorder.Parent = catalogue
local title = text(catalogue, "Title", "Що посадимо?", 27, Theme.Ink, Enum.Font.FredokaOne)
local subtitle = text(catalogue, "Subtitle", "Грядка 1 · У тебе 40 монет", 14, Theme.Muted)
subtitle.TextWrapped = true
local closeButton = button(catalogue, "CloseCatalogue", "×")
closeButton.BackgroundColor3 = Theme.Panel
closeButton.TextColor3 = Theme.Ink
closeButton.TextSize = 26
closeButton.Size = UDim2.fromOffset(44, 44)

local list = Instance.new("ScrollingFrame")
list.Name = "Plants"
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = Theme.Wood
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = catalogue
local footer = frame(catalogue, "Expansion", Theme.Panel, 10)
local bedsText = text(footer, "Beds", "Грядки 2 / 8", 15, Theme.Ink, Enum.Font.GothamBold)
local expansionNote = text(footer, "Description", "Більше місця для рослин", 12, Theme.Muted)
local expandButton = button(footer, "UnlockBed", "Нова грядка · 50")

type Card = { Frame: Frame, Preview: ViewportFrame, Name: TextLabel, Rarity: TextLabel, Stats: TextLabel, Buy: TextButton, Id: string }
local cards: {Card} = {}
for _, crop in Crops.List do
	local row = frame(list, crop.Id, Theme.Panel, 10)
	local preview = Instance.new("ViewportFrame")
	preview.Name = "Preview"
	preview.BackgroundTransparency = 1
	preview.Ambient = Color3.fromRGB(220, 207, 174)
	preview.LightColor = Color3.fromRGB(255, 243, 212)
	preview.LightDirection = Vector3.new(-1, -1, -1)
	preview.Parent = row
	local world = Instance.new("WorldModel")
	world.Parent = preview
	local model = Assets.Crop(crop.Id, Vector3.zero)
	model.Parent = world
	local cf, bounds = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0.7, 0.45, 1).Unit * math.max(bounds.X, bounds.Y, bounds.Z) * 1.7, cf.Position)
	camera.Parent = preview
	preview.CurrentCamera = camera
	local nameLabel = text(row, "PlantName", crop.Name, 18, Theme.Ink, Enum.Font.GothamBold)
	local rarity = text(row, "Rarity", crop.Rarity, 12, crop.Color, Enum.Font.GothamBold)
	local stats = text(row, "Stats", crop.GrowSeconds .. " с росту   ·   +" .. crop.Income .. " мон. / " .. Config.IncomeInterval .. " с", 13, Theme.Muted)
	local buy = button(row, "Plant", "Посадити · " .. crop.Price)
	table.insert(cards, { Frame = row, Preview = preview, Name = nameLabel, Rarity = rarity, Stats = stats, Buy = buy, Id = crop.Id })
end

local toast = frame(screen, "Toast", Theme.Paper, 10)
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 14)
toast.ZIndex = 30
toast.Visible = false
local toastText = text(toast, "Message", "", 15, Theme.Ink, Enum.Font.GothamBold)
toastText.Position = UDim2.fromOffset(12, 6)
toastText.Size = UDim2.new(1, -24, 1, -12)
toastText.TextWrapped = true
toastText.TextXAlignment = Enum.TextXAlignment.Center

local selectedBed: number? = nil
local pending = false
local errorMessage: string? = nil
local refreshShop: () -> ()

local function getFarm(): Model?
	local index = player:GetAttribute("FarmIndex")
	local root = Workspace:FindFirstChild("PlayerFarms")
	return (index and root and root:FindFirstChild("Farm_" .. index)) :: Model?
end

local function emptyBed(preferred: number?): number?
	local farm = getFarm()
	local beds = farm and farm:FindFirstChild("Beds")
	if not beds then return nil end
	local function available(index: number): boolean
		local bed = beds:FindFirstChild("Bed_" .. index)
		return bed ~= nil and bed:GetAttribute("Unlocked") == true and bed:GetAttribute("CropId") == ""
	end
	if preferred and available(preferred) then return preferred end
	for index = 1, player:GetAttribute("FarmSlots") or Config.StartingBeds do
		if available(index) then return index end
	end
	return nil
end

local toastVersion = 0
local function showToast(message: string, ok: boolean?)
	toastVersion += 1
	local version = toastVersion
	toastText.Text = message
	toastText.TextColor3 = ok == false and Theme.Barn or Theme.Ink
	toast.Visible = true
	task.delay(4, function() if toastVersion == version then toast.Visible = false end end)
end

local function closeCatalogue()
	if pending then return end
	overlay.Visible = false
	ContextActionService:UnbindAction("CloseSeedCatalogue")
end

refreshShop = function()
	local coins = player:GetAttribute("Coins") or 0
	local slots = player:GetAttribute("FarmSlots") or Config.StartingBeds
	selectedBed = emptyBed(selectedBed)
	local fullMessage = slots < Config.MaxBeds and "Усі грядки зайняті. Відкрий нову нижче." or "Ферма заповнена. Рослини заробляють самі."
	subtitle.Text = errorMessage or (selectedBed and ("Грядка " .. selectedBed .. " · У тебе " .. coins .. " мон.") or fullMessage)
	subtitle.TextColor3 = errorMessage and Theme.Barn or Theme.Muted
	for _, card in cards do
		local crop = Crops.ById[card.Id]
		local enabled = not pending and selectedBed ~= nil and coins >= crop.Price
		card.Buy.Active = enabled
		card.Buy.Selectable = enabled
		card.Buy.AutoButtonColor = enabled
		card.Buy.BackgroundColor3 = enabled and Theme.Green or Theme.Paper
		card.Buy.TextColor3 = enabled and Theme.Paper or Theme.Muted
		card.Buy.Text = pending and "Зачекай…" or ("Посадити · " .. crop.Price)
	end
	local price = player:GetAttribute("NextBedCost") or 0
	bedsText.Text = "Грядки " .. slots .. " / " .. Config.MaxBeds
	expansionNote.Text = slots < Config.MaxBeds and "Більше місця для рослин" or "Ферму повністю відкрито"
	expandButton.Text = slots < Config.MaxBeds and ("Нова грядка · " .. price) or "Усі грядки відкрито"
	local enabled = not pending and slots < Config.MaxBeds and coins >= price
	expandButton.Active = enabled
	expandButton.Selectable = enabled
	expandButton.AutoButtonColor = enabled
	expandButton.BackgroundColor3 = enabled and Theme.Green or Theme.Paper
	expandButton.TextColor3 = enabled and Theme.Paper or Theme.Muted
end

local function openCatalogue(index: number?)
	if not player:GetAttribute("FarmIndex") then return end
	selectedBed = emptyBed(index)
	errorMessage = nil
	overlay.Visible = true
	refreshShop()
	ContextActionService:BindActionAtPriority("CloseSeedCatalogue", function(_, state)
		if state == Enum.UserInputState.Begin then closeCatalogue() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
end

local function sendAction(action: string, cropId: string?)
	if pending then return end
	if action == "Plant" then
		selectedBed = emptyBed(selectedBed)
		local crop = cropId and Crops.ById[cropId]
		if not selectedBed or not crop or (player:GetAttribute("Coins") or 0) < crop.Price then return end
	elseif (player:GetAttribute("FarmSlots") or 0) >= Config.MaxBeds or (player:GetAttribute("Coins") or 0) < (player:GetAttribute("NextBedCost") or 0) then
		return
	end
	pending = true
	errorMessage = nil
	refreshShop()
	local success, result = pcall(function() return request:InvokeServer(action, selectedBed, cropId) end)
	pending = false
	if success and typeof(result) == "table" and result.ok then
		if action == "Plant" then closeCatalogue() else selectedBed = result.bedIndex end
		showToast(result.message, true)
	else
		errorMessage = success and result.message or "Не вдалося посадити. Спробуй ще раз."
		showToast(errorMessage or "Спробуй ще раз.", false)
	end
	refreshShop()
end

for _, card in cards do card.Buy.Activated:Connect(function() sendAction("Plant", card.Id) end) end
expandButton.Activated:Connect(function() sendAction("Unlock", nil) end)
plantButton.Activated:Connect(function() openCatalogue(nil) end)
closeButton.Activated:Connect(closeCatalogue)
backdrop.Activated:Connect(closeCatalogue)
openMenu.OnClientEvent:Connect(openCatalogue)
feedback.OnClientEvent:Connect(showToast)

local function update()
	local coins = player:GetAttribute("Coins") or 0
	local slots = player:GetAttribute("FarmSlots") or Config.StartingBeds
	local used = player:GetAttribute("UsedBeds") or 0
	local mature = player:GetAttribute("MatureBeds") or 0
	coinsText.Text = tostring(coins)
	incomeText.Text = "+" .. (player:GetAttribute("Income") or 0) .. " / " .. Config.IncomeInterval .. " с"
	farmText.Text = string.format("Грядки %d / %d · Рівень %d", used, slots, player:GetAttribute("Level") or 1)
	plantButton.Text = used < slots and "Посадити" or (slots < Config.MaxBeds and "Розширити ферму" or "Моя ферма")
	if used == 0 then
		hintText.Text = "Посади гарбуз — він почне заробляти."
	elseif mature == 0 then
		hintText.Text = "Рослини ростуть. Монети надходитимуть самі."
	else
		hintText.Text = "Дохід надходить сам. Сади ще й розвивай ферму."
	end
	if overlay.Visible then refreshShop() end
end
for _, attribute in {"Coins", "FarmIndex", "FarmSlots", "UsedBeds", "GrowingBeds", "MatureBeds", "Income", "NextBedCost", "Level"} do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end
update()

local function resize()
	local view = screen.AbsoluteSize
	if view.X <= 0 or view.Y <= 0 then return end
	local portrait = view.X < 620
	local compact = not portrait and view.Y < 550
	status.Size = UDim2.fromOffset(portrait and math.min(254, view.X - 28) or 254, 126)
	hint.Size = UDim2.fromOffset(math.min(470, view.X - 28), 38)
	toast.Size = UDim2.fromOffset(math.min(430, view.X - 28), 56)
	toast.Position = UDim2.new(0.5, 0, 0, portrait and 150 or (compact and 146 or 14))
	local width = math.min(portrait and 430 or 680, view.X - 24)
	local desiredHeight = portrait and 560 or (compact and 332 or 420)
	local height = math.min(desiredHeight, view.Y - 16)
	local headerHeight = portrait and 80 or (compact and 58 or 72)
	local footerHeight = portrait and 82 or (compact and 58 or 70)
	local rowHeight = portrait and 124 or (compact and 68 or 86)
	local gap = compact and 6 or 8
	catalogue.Size = UDim2.fromOffset(width, height)
	title.Position = UDim2.fromOffset(18, compact and 5 or 10)
	title.Size = UDim2.fromOffset(width - 88, compact and 28 or 34)
	title.TextSize = compact and 23 or 27
	subtitle.Position = UDim2.fromOffset(18, compact and 33 or 44)
	subtitle.Size = UDim2.fromOffset(width - 50, portrait and 31 or 22)
	subtitle.TextSize = compact and 13 or 14
	closeButton.Position = UDim2.new(1, -54, 0, compact and 5 or 10)
	list.Position = UDim2.fromOffset(12, headerHeight)
	list.Size = UDim2.fromOffset(width - 24, math.max(40, height - headerHeight - footerHeight))
	list.CanvasSize = UDim2.fromOffset(0, #cards * (rowHeight + gap))
	for index, card in cards do
		local rowWidth = width - 30
		card.Frame.Position = UDim2.fromOffset(0, (index - 1) * (rowHeight + gap))
		card.Frame.Size = UDim2.fromOffset(rowWidth, rowHeight)
		card.Preview.Position = UDim2.fromOffset(5, 4)
		card.Preview.Size = UDim2.fromOffset(portrait and 85 or (compact and 76 or 88), portrait and 110 or rowHeight - 8)
		local contentX = portrait and 96 or (compact and 86 or 100)
		local textWidth = rowWidth - contentX - (portrait and 8 or 140)
		card.Name.Position = UDim2.fromOffset(contentX, compact and 3 or 7)
		card.Name.Size = UDim2.fromOffset(textWidth, 24)
		card.Name.TextSize = compact and 16 or 18
		card.Rarity.Position = UDim2.fromOffset(contentX, compact and 25 or 31)
		card.Rarity.Size = UDim2.fromOffset(textWidth, 17)
		card.Stats.Position = UDim2.fromOffset(contentX, compact and 44 or 51)
		card.Stats.Size = UDim2.fromOffset(portrait and rowWidth - contentX - 6 or textWidth, 19)
		card.Stats.TextSize = compact and 12 or 13
		card.Buy.Position = portrait and UDim2.fromOffset(contentX, 75) or UDim2.new(1, -134, 0.5, -22)
		card.Buy.Size = UDim2.fromOffset(portrait and rowWidth - contentX - 10 or 124, 44)
		card.Buy.TextSize = 14
	end
	footer.Position = UDim2.fromOffset(12, height - footerHeight + 4)
	footer.Size = UDim2.fromOffset(width - 24, footerHeight - 10)
	bedsText.Position = UDim2.fromOffset(10, 3)
	bedsText.Size = UDim2.fromOffset(portrait and 118 or 240, 23)
	expansionNote.Position = UDim2.fromOffset(10, 27)
	expansionNote.Size = UDim2.fromOffset(portrait and 118 or 260, 18)
	expansionNote.Visible = not portrait
	expandButton.Position = UDim2.new(1, portrait and -184 or -224, 0.5, -22)
	expandButton.Size = UDim2.fromOffset(portrait and 174 or 214, 44)
	expandButton.TextSize = portrait and 13 or 14
	refreshShop()
end
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
resize()
