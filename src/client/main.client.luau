--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Finds = require(ReplicatedStorage.Shared.Config.Finds)
local Assets = require(ReplicatedStorage.Shared.CollectionAssets)
local remotes = ReplicatedStorage:WaitForChild("CollectionRemotes")
local request = remotes:WaitForChild("Request") :: RemoteFunction
local openMenu = remotes:WaitForChild("OpenCatalogue") :: RemoteEvent
local feedback = remotes:WaitForChild("Feedback") :: RemoteEvent
local showCharacter = remotes:WaitForChild("ShowCharacter") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "AnomalyHUD"; gui.ResetOnSpawn = false; gui.DisplayOrder = 10
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.Parent = player:WaitForChild("PlayerGui")
local screen = Instance.new("Frame")
screen.Name = "SafeArea"; screen.Size = UDim2.fromScale(1, 1); screen.BackgroundTransparency = 1; screen.Parent = gui

local function rounded(object: GuiObject, radius: number)
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, radius); corner.Parent = object
end
local function frame(parent: Instance, name: string, color: Color3, radius: number?): Frame
	local f = Instance.new("Frame")
	f.Name = name; f.BackgroundColor3 = color; f.BorderSizePixel = 0; f.Parent = parent
	if radius then rounded(f, radius) end
	return f
end
local function text(parent: Instance, name: string, value: string, size: number, color: Color3, font: Enum.Font?): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name; t.BackgroundTransparency = 1; t.Text = value; t.TextSize = size
	t.TextColor3 = color; t.Font = font or Enum.Font.GothamMedium; t.TextXAlignment = Enum.TextXAlignment.Left; t.Parent = parent
	return t
end
local function button(parent: Instance, name: string, value: string): TextButton
	local b = Instance.new("TextButton")
	b.Name = name; b.BackgroundColor3 = Theme.Action; b.BorderSizePixel = 0; b.Font = Enum.Font.GothamBold
	b.TextSize = 15; b.TextColor3 = Theme.UIText; b.Text = value; b.AutoButtonColor = true; b.Parent = parent
	rounded(b, 9)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Color = Theme.UIBorder; stroke.Transparency = 0.4; stroke.Parent = b
	return b
end
local function place(object: GuiObject, x: number, y: number, w: number, h: number)
	object.Position = UDim2.fromOffset(x, y); object.Size = UDim2.fromOffset(w, h)
end
local function preview(parent: Instance): ViewportFrame
	local v = Instance.new("ViewportFrame")
	v.Name = "Preview"; v.BackgroundTransparency = 1; v.Ambient = Color3.fromRGB(220, 207, 194)
	v.LightColor = Color3.fromRGB(255, 243, 212); v.LightDirection = Vector3.new(-1, -1, -1); v.Parent = parent
	return v
end
local function setPreview(v: ViewportFrame, model: Model)
	v:ClearAllChildren()
	local world = Instance.new("WorldModel"); world.Parent = v; model.Parent = world
	local cf, bounds = model:GetBoundingBox()
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	camera.CFrame = CFrame.lookAt(cf.Position + Vector3.new(0.55, 0.25, 1).Unit * math.max(bounds.X, bounds.Y, bounds.Z) * 1.65, cf.Position)
	camera.Parent = v; v.CurrentCamera = camera
end
local function enable(b: TextButton, enabled: boolean)
	b.Active = enabled; b.Selectable = enabled; b.AutoButtonColor = enabled
	b.BackgroundColor3 = enabled and Theme.Action or Theme.UIBackground
	b.TextColor3 = enabled and Theme.UIText or Theme.UISecondary
end

local status = frame(screen, "BaseStatus", Theme.UIBackground, 12)
place(status, 14, 12, 254, 126)
local edge = Instance.new("UIStroke"); edge.Color = Theme.UIBorder; edge.Thickness = 2; edge.Parent = status
local heading = text(status, "Title", "Моя колекція", 21, Theme.UIText, Enum.Font.FredokaOne)
place(heading, 16, 8, 220, 28)
place(text(status, "CoinLabel", "Монети", 12, Theme.UISecondary), 16, 42, 95, 18)
local coinsText = text(status, "Coins", "40", 29, Theme.UIText, Enum.Font.GothamBold)
place(coinsText, 16, 61, 110, 34)
local incomeText = text(status, "Income", "+0 / 5 с", 18, Theme.Harvest, Enum.Font.GothamBold)
place(incomeText, 132, 59, 112, 29)
place(text(status, "AutoIncome", "від персонажів", 11, Theme.UISecondary), 132, 83, 112, 16)
local baseText = text(status, "Stands", "Підставки 0 / 2 · Рівень 1", 12, Theme.UISecondary)
place(baseText, 16, 103, 232, 18)

local actions = frame(screen, "Actions", Theme.Night)
actions.BackgroundTransparency = 1; actions.AnchorPoint = Vector2.new(0.5, 1); actions.Position = UDim2.new(0.5, 0, 1, -14)
local catalogueButton = button(actions, "FindsButton", "Знахідки")
local readyButton = button(actions, "OpenReady", "Відкрити")
local hint = frame(screen, "BaseHint", Theme.UIBackground, 9)
hint.AnchorPoint = Vector2.new(0.5, 1); hint.Position = UDim2.new(0.5, 0, 1, -72)
local hintText = text(hint, "Text", "Обери знахідку та постав її на підставку.", 14, Theme.UIText)
hintText.Position = UDim2.fromOffset(10, 0); hintText.Size = UDim2.new(1, -20, 1, 0)
hintText.TextXAlignment = Enum.TextXAlignment.Center; hintText.TextWrapped = true

local overlay = frame(screen, "CatalogueOverlay", Theme.Night)
overlay.Size = UDim2.fromScale(1, 1); overlay.BackgroundTransparency = 1; overlay.ZIndex = 20; overlay.Visible = false
local backdrop = Instance.new("TextButton")
backdrop.Name = "CloseBackdrop"; backdrop.Size = UDim2.fromScale(1, 1); backdrop.BackgroundColor3 = Theme.Night
backdrop.BackgroundTransparency = 0.25; backdrop.Text = ""; backdrop.AutoButtonColor = false
backdrop.BorderSizePixel = 0; backdrop.Modal = true; backdrop.Selectable = false; backdrop.Parent = overlay
local catalogue = frame(overlay, "FindCatalogue", Theme.UIBackground, 14)
catalogue.AnchorPoint = Vector2.new(0.5, 0.5); catalogue.Position = UDim2.fromScale(0.5, 0.5); catalogue.Active = true
local border = Instance.new("UIStroke"); border.Color = Theme.UIBorder; border.Thickness = 3; border.Parent = catalogue
local title = text(catalogue, "Title", "Таємничі знахідки", 26, Theme.UIText, Enum.Font.FredokaOne)
local subtitle = text(catalogue, "Subtitle", "", 14, Theme.UISecondary); subtitle.TextWrapped = true
local closeButton = button(catalogue, "CloseCatalogue", "×"); closeButton.TextSize = 26; closeButton.BackgroundColor3 = Theme.UISurface
local list = Instance.new("ScrollingFrame")
list.Name = "Finds"; list.BackgroundTransparency = 1; list.BorderSizePixel = 0
list.ScrollBarThickness = 4; list.ScrollBarImageColor3 = Theme.UIBorder; list.Parent = catalogue
local footer = frame(catalogue, "Expansion", Theme.UISurface, 10)
local standsText = text(footer, "Stands", "", 14, Theme.UIText, Enum.Font.GothamBold)
local expandButton = button(footer, "UnlockStand", "Нове місце · 50")

type Card = { Frame: Frame, Preview: ViewportFrame, Name: TextLabel, Rarity: TextLabel, Stats: TextLabel, Odds: TextLabel, Buy: TextButton, Id: string }
local cards: {Card} = {}
for _, find in Finds.List do
	local row = frame(list, find.Id, Theme.UISurface, 10)
	local v = preview(row); setPreview(v, Assets.Container(find.Id, Vector3.zero))
	local name = text(row, "FindName", find.Name, 18, Theme.UIText, Enum.Font.GothamBold); name.TextWrapped = true
	local rarity = text(row, "Rarity", find.Rarity, 13, find.Color, Enum.Font.GothamBold)
	local stats = text(row, "Stats", "Розпакування: " .. find.OpenSeconds .. " с", 13, Theme.UISecondary)
	local lines = {}
	for _, drop in find.Drops do
		local c = Finds.CharacterById[drop.Id]
		table.insert(lines, c.Name .. " " .. drop.Weight .. "% · +" .. c.Income .. " / " .. Config.IncomeInterval .. " с")
	end
	local odds = text(row, "Odds", table.concat(lines, "\n"), 13, Theme.UIText)
	odds.TextWrapped = true; odds.TextYAlignment = Enum.TextYAlignment.Top
	local buy = button(row, "Place", "Поставити · " .. find.Price)
	table.insert(cards, { Frame = row, Preview = v, Name = name, Rarity = rarity, Stats = stats, Odds = odds, Buy = buy, Id = find.Id })
end

-- One focused reveal, not a roulette animation with misleading near-misses.
local revealOverlay = frame(screen, "CharacterOverlay", Theme.Night)
revealOverlay.Size = UDim2.fromScale(1, 1); revealOverlay.BackgroundTransparency = 1
revealOverlay.ZIndex = 20; revealOverlay.Visible = false
local revealBackdrop = backdrop:Clone(); revealBackdrop.Parent = revealOverlay
local reveal = frame(revealOverlay, "CharacterCard", Theme.UIBackground, 16)
reveal.AnchorPoint = Vector2.new(0.5, 0.5); reveal.Position = UDim2.fromScale(0.5, 0.5)
local revealBorder = border:Clone(); revealBorder.Parent = reveal
local revealTitle = text(reveal, "Title", "Новий мешканець!", 25, Theme.UIText, Enum.Font.FredokaOne)
local revealRarity = text(reveal, "Rarity", "", 14, Theme.Harvest, Enum.Font.GothamBold)
local revealPreview = preview(reveal)
local revealName = text(reveal, "CharacterName", "", 23, Theme.UIText, Enum.Font.GothamBold)
local revealIncome = text(reveal, "Income", "", 16, Theme.Harvest, Enum.Font.GothamBold)
for _, t in {revealTitle, revealRarity, revealName, revealIncome} do t.TextXAlignment = Enum.TextXAlignment.Center end
local keepButton = button(reveal, "Keep", "На базу")
local sellButton = button(reveal, "Sell", "Продати"); sellButton.BackgroundColor3 = Theme.UISurface

local toast = frame(screen, "Toast", Theme.UIBackground, 10)
toast.AnchorPoint = Vector2.new(0.5, 0); toast.ZIndex = 30; toast.Visible = false
local toastText = text(toast, "Message", "", 15, Theme.UIText, Enum.Font.GothamBold)
toastText.Position = UDim2.fromOffset(12, 6); toastText.Size = UDim2.new(1, -24, 1, -12)
toastText.TextWrapped = true; toastText.TextXAlignment = Enum.TextXAlignment.Center
local selectedStand: number? = nil
local inspectedStand: number? = nil
local inspectedId: string? = nil
local pending, confirmSell, inspection = false, false, false
local errorMessage: string? = nil
local toastVersion = 0
local previousSelection: GuiObject? = nil
local refreshShop: () -> ()
local resize: () -> ()

local function getStands(): Folder?
	local index = player:GetAttribute("BaseIndex")
	local root = Workspace:FindFirstChild("PlayerBases")
	local base = index and root and root:FindFirstChild("Base_" .. index)
	return (base and base:FindFirstChild("Stands")) :: Folder?
end
local function findStand(state: string, preferred: number?): number?
	local stands = getStands()
	if not stands then return nil end
	local function matches(i: number): boolean
		local s = stands:FindFirstChild("Stand_" .. i)
		return s ~= nil and s:GetAttribute("Unlocked") == true and s:GetAttribute("State") == state
	end
	if preferred and matches(preferred) then return preferred end
	for i = 1, player:GetAttribute("BaseSlots") or Config.StartingStands do if matches(i) then return i end end
	return nil
end
local function showToast(message: string, ok: boolean?)
	toastVersion += 1
	local version = toastVersion
	toastText.Text = message; toastText.TextColor3 = ok == false and Theme.Error or Theme.UIText; toast.Visible = true
	task.delay(4, function() if toastVersion == version then toast.Visible = false end end)
end
local function closeModals()
	if pending then return end
	overlay.Visible = false; revealOverlay.Visible = false; confirmSell = false
	ContextActionService:UnbindAction("CloseCollection")
	GuiService.SelectedObject = previousSelection and previousSelection.Parent and previousSelection or nil
end
local function bindClose(first: GuiObject)
	if not overlay.Visible and not revealOverlay.Visible then previousSelection = GuiService.SelectedObject end
	ContextActionService:BindActionAtPriority("CloseCollection", function(_, state)
		if state == Enum.UserInputState.Begin then closeModals() end
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Escape, Enum.KeyCode.ButtonB)
	if GuiService.SelectedObject then GuiService.SelectedObject = first end
end
refreshShop = function()
	local coins, slots = player:GetAttribute("Coins") or 0, player:GetAttribute("BaseSlots") or Config.StartingStands
	selectedStand = findStand("Empty", selectedStand)
	subtitle.Text = errorMessage or (selectedStand and ("Підставка " .. selectedStand .. " · У тебе " .. coins .. " мон.") or "Немає місця. Додай підставку або продай персонажа.")
	subtitle.TextColor3 = errorMessage and Theme.Error or Theme.UISecondary
	for _, card in cards do
		local f = Finds.ById[card.Id]
		enable(card.Buy, not pending and selectedStand ~= nil and coins >= f.Price)
		card.Buy.Text = pending and "Зачекай…" or ("Поставити · " .. f.Price)
	end
	standsText.Text = "Підставки " .. slots .. " / " .. Config.MaxStands
	expandButton.Text = slots < Config.MaxStands and ("Нова · " .. (player:GetAttribute("NextStandCost") or 0) .. " мон.") or "Усі відкрито"
	enable(expandButton, not pending and slots < Config.MaxStands and coins >= (player:GetAttribute("NextStandCost") or 0))
end
local function openCatalogue(index: number?)
	if pending or not player:GetAttribute("BaseIndex") then return end
	bindClose(closeButton); selectedStand = findStand("Empty", index); errorMessage = nil
	revealOverlay.Visible = false; overlay.Visible = true; refreshShop()
end
local function invoke(action: string, index: number?, id: string?)
	if pending then return end
	pending = true; errorMessage = nil; refreshShop(); enable(readyButton, false); enable(sellButton, false)
	local success, result = pcall(function() return request:InvokeServer(action, index, id) end)
	pending = false
	if success and typeof(result) == "table" and result.ok then
		if action == "Place" or action == "Sell" then closeModals() end
		if action == "Unlock" then selectedStand = result.standIndex end
		if action ~= "Open" then showToast(result.message, true) end
	else
		errorMessage = success and typeof(result) == "table" and result.message or "Не вдалося виконати дію. Спробуй ще раз."
		showToast(errorMessage or "Спробуй ще раз.", false)
	end
	enable(readyButton, true); enable(sellButton, true); refreshShop()
end
for _, card in cards do
	card.Buy.Activated:Connect(function()
		selectedStand = findStand("Empty", selectedStand)
		if not selectedStand or (player:GetAttribute("Coins") or 0) < Finds.ById[card.Id].Price then return end
		invoke("Place", selectedStand, card.Id)
	end)
end
expandButton.Activated:Connect(function() invoke("Unlock", nil, nil) end)
catalogueButton.Activated:Connect(function() openCatalogue(nil) end)
readyButton.Activated:Connect(function()
	local index = findStand("Ready", nil)
	if index then invoke("Open", index, nil) else showToast("Зачекай завершення розпакування.", false) end
end)
closeButton.Activated:Connect(closeModals); backdrop.Activated:Connect(closeModals)
keepButton.Activated:Connect(closeModals); revealBackdrop.Activated:Connect(closeModals)
sellButton.Activated:Connect(function()
	if pending or not inspectedStand or not inspectedId then return end
	if not confirmSell then
		confirmSell = true; sellButton.Text = "Так, продати"
		revealIncome.Text = "Персонаж зникне, підставка звільниться."
		return
	end
	invoke("Sell", inspectedStand, nil)
end)
openMenu.OnClientEvent:Connect(openCatalogue)
feedback.OnClientEvent:Connect(showToast)
showCharacter.OnClientEvent:Connect(function(id: string, index: number, isNew: boolean)
	local c = Finds.CharacterById[id]
	if not c then return end
	bindClose(keepButton); overlay.Visible = false; revealOverlay.Visible = true; toast.Visible = false
	inspectedStand = index; inspectedId = id; inspection = not isNew; confirmSell = false
	revealTitle.Text = isNew and "Новий мешканець!" or ("Підставка " .. index)
	revealName.Text = c.Name; revealRarity.Text = c.Rarity; revealRarity.TextColor3 = c.Color; revealBorder.Color = c.Color
	revealIncome.Text = "+" .. c.Income .. " монет кожні " .. Config.IncomeInterval .. " с — автоматично"
	sellButton.Text = "Продати · " .. c.SellPrice; sellButton.Visible = inspection
	keepButton.Text = isNew and "На базу" or "Залишити"
	setPreview(revealPreview, Assets.Character(id, Vector3.zero)); resize()
end)
local function update()
	local slots, used = player:GetAttribute("BaseSlots") or Config.StartingStands, player:GetAttribute("UsedStands") or 0
	local ready, residents = player:GetAttribute("ReadyFinds") or 0, player:GetAttribute("Residents") or 0
	coinsText.Text = tostring(player:GetAttribute("Coins") or 0)
	incomeText.Text = "+" .. (player:GetAttribute("Income") or 0) .. " / " .. Config.IncomeInterval .. " с"
	baseText.Text = string.format("Підставки %d / %d · Рівень %d", used, slots, player:GetAttribute("Level") or 1)
	readyButton.Visible = ready > 0; readyButton.Text = "Відкрити · " .. ready
	if ready > 0 then hintText.Text = "Знахідка готова! Відкрий і дізнайся, хто всередині."
	elseif used == 0 then hintText.Text = "Обери знахідку та постав її на підставку."
	elseif (player:GetAttribute("SealedFinds") or 0) > 0 then hintText.Text = "Знахідка розпаковується. Скоро можна буде відкрити."
	elseif residents > 0 then hintText.Text = "Персонажі заробляють самі. Збирай нові знахідки!" end
	if overlay.Visible then refreshShop() end
	local width = actions.AbsoluteSize.X
	if ready > 0 then place(catalogueButton, 0, 0, (width - 8) / 2, 48); place(readyButton, (width + 8) / 2, 0, (width - 8) / 2, 48)
	else place(catalogueButton, (width - 202) / 2, 0, 202, 48) end
end
resize = function()
	local view = screen.AbsoluteSize
	if view.X <= 0 or view.Y <= 0 then return end
	local portrait = view.X < 620
	hint.Size = UDim2.fromOffset(math.min(510, view.X - 28), 38)
	actions.Size = UDim2.fromOffset(math.min(380, view.X - 28), 48)
	toast.Size = UDim2.fromOffset(math.min(430, view.X - 28), 56)
	toast.Position = UDim2.new(0.5, 0, 0, (portrait or view.Y < 550) and 146 or 14)
	local w, h = math.min(portrait and 430 or 730, view.X - 24), math.min(610, view.Y - 16)
	local header, foot, rowH = 84, 64, portrait and 222 or 132
	catalogue.Size = UDim2.fromOffset(w, h)
	place(title, 16, 8, w - 82, 34); title.TextSize = portrait and 22 or 26
	place(subtitle, 16, 43, w - 32, 34); place(closeButton, w - 54, 8, 44, 44)
	place(list, 12, header, w - 24, math.max(40, h - header - foot))
	list.CanvasSize = UDim2.fromOffset(0, #cards * (rowH + 8))
	for i, card in cards do
		local rw = w - 30
		place(card.Frame, 0, (i - 1) * (rowH + 8), rw, rowH)
		if portrait then
			place(card.Preview, 4, 9, 90, 125)
			place(card.Name, 100, 8, rw - 110, 42); card.Name.TextSize = 17
			place(card.Rarity, 100, 52, rw - 110, 18); place(card.Stats, 100, 73, rw - 110, 18)
			place(card.Buy, 100, 99, rw - 110, 44); place(card.Odds, 12, 154, rw - 24, 62)
		else
			place(card.Preview, 4, 4, 112, 124)
			place(card.Name, 124, 5, rw - 286, 28); card.Name.TextSize = 18
			place(card.Rarity, 124, 35, rw - 286, 19); place(card.Stats, 124, 57, rw - 140, 18)
			place(card.Buy, rw - 152, 12, 140, 44); place(card.Odds, 124, 83, rw - 140, 44)
		end
	end
	place(footer, 12, h - foot + 5, w - 24, foot - 10)
	place(standsText, 10, 3, portrait and 118 or 240, 44)
	place(expandButton, w - 190, 5, 156, 44); expandButton.TextSize = 14
	local rW, rH = math.min(500, view.X - 24), math.min(530, view.Y - 16)
	reveal.Size = UDim2.fromOffset(rW, rH)
	place(revealTitle, 12, 12, rW - 24, 32); place(revealRarity, 12, 47, rW - 24, 22)
	place(revealPreview, 12, 72, rW - 24, math.max(70, rH - 230))
	place(revealName, 12, rH - 154, rW - 24, 32); revealName.TextSize = portrait and 20 or 23
	place(revealIncome, 16, rH - 118, rW - 32, 42); revealIncome.TextWrapped = true; revealIncome.TextSize = portrait and 14 or 16
	if inspection then place(keepButton, 16, rH - 62, (rW - 40) / 2, 46); place(sellButton, rW / 2 + 4, rH - 62, (rW - 40) / 2, 46)
	else place(keepButton, (rW - 202) / 2, rH - 62, 202, 46) end
	update(); refreshShop()
end
for _, attribute in {"Coins", "BaseIndex", "BaseSlots", "UsedStands", "ReadyFinds", "SealedFinds", "Residents", "Income", "NextStandCost", "Level"} do player:GetAttributeChangedSignal(attribute):Connect(update) end
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
actions:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
resize()
