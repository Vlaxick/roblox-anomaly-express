--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Finds = require(ReplicatedStorage.Shared.Config.Finds)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local CollectionAssets = require(ReplicatedStorage.Shared.CollectionAssets)
local LevelService = require(script.Parent.LevelService)
local WorldService = require(script.Parent.WorldService)

type Stand = {
	Model: Model, Platform: Part, Prompt: ProximityPrompt, Label: BillboardGui,
	Title: TextLabel, Rarity: TextLabel, Status: TextLabel, Position: Vector3,
	FindId: string?, CharacterId: string?, Display: Model?, ReadyAt: number, NextIncome: number, Notified: boolean,
}
type Base = { Index: number, Model: Model, Owner: Player?, Unlocked: number, Stands: {Stand}, Sign: TextLabel }
local PlotService = {}
local bases: {Base} = {}
local playerBases: {[Player]: Base} = {}
local lastRequest: {[Player]: number} = {}
local random = Random.new()
local openMenu, feedback, showCharacter = Instance.new("RemoteEvent"), Instance.new("RemoteEvent"), Instance.new("RemoteEvent")

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(pos), color, material, collide)
end
local function plaque(anchor: BasePart): (BillboardGui, TextLabel, TextLabel, TextLabel)
	local gui = Instance.new("BillboardGui")
	gui.Name = "StandLabel"; gui.Size = UDim2.fromOffset(170, 74)
	gui.StudsOffset = Vector3.new(0, 1.5, 0); gui.MaxDistance = 28
	gui.AlwaysOnTop = true
	gui.Enabled = false -- Client chooses distant label vs nearby prompt.
	gui.Parent = anchor
	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1); panel.BackgroundColor3 = Theme.UIBackground
	panel.BackgroundTransparency = 0.06; panel.BorderSizePixel = 0; panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7); corner.Parent = panel
	local function line(y: number, height: number, size: number, font: Enum.Font): TextLabel
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1; t.Position = UDim2.fromOffset(5, y)
		t.Size = UDim2.new(1, -10, 0, height); t.TextColor3 = Theme.UIText
		t.Font = font; t.TextSize = size; t.Parent = panel
		return t
	end
	return gui, line(3, 24, 13, Enum.Font.GothamBold), line(27, 19, 12, Enum.Font.GothamMedium), line(49, 23, 13, Enum.Font.GothamBold)
end
local function refreshStand(base: Base, index: number, now: number)
	local s = base.Stands[index]
	local unlocked = index <= base.Unlocked
	s.Model:SetAttribute("Unlocked", unlocked)
	s.Model:SetAttribute("FindId", s.FindId or "")
	s.Model:SetAttribute("CharacterId", s.CharacterId or "")
	s.Model:SetAttribute("ReadyAt", s.ReadyAt)
	s.Platform.Color = unlocked and Theme.Wood or Theme.Stone:Lerp(Theme.Iron, 0.45)
	s.Label:SetAttribute("VisibleAtRest", unlocked or index == base.Unlocked + 1)
	s.Prompt.Enabled = unlocked or index == base.Unlocked + 1
	s.Prompt.ObjectText = "Stand " .. index
	if s.CharacterId then
		local c = Finds.CharacterById[s.CharacterId]
		s.Title.Text = c.Name; s.Rarity.Text = c.Rarity; s.Rarity.TextColor3 = c.Color
		s.Status.Text = "+" .. c.Income .. " coins / " .. Config.IncomeInterval .. " s"
		s.Status.TextColor3 = Theme.Harvest; s.Prompt.ActionText = "Inspect"
		s.Prompt.ObjectText = c.Name .. " · +" .. c.Income .. " / " .. Config.IncomeInterval .. " s"
		s.Model:SetAttribute("State", "Occupied")
	elseif s.FindId then
		local f = Finds.AllById[s.FindId]
		local ready = now >= s.ReadyAt
		s.Title.Text = f.Name; s.Rarity.Text = f.Rarity .. " find"; s.Rarity.TextColor3 = f.Color
		s.Status.Text = ready and "Ready! Open now" or ("Unpacking · " .. math.max(0, math.ceil(s.ReadyAt - now)) .. " s")
		s.Status.TextColor3 = ready and Theme.Harvest or Theme.UISecondary
		s.Prompt.Enabled = ready; s.Prompt.ActionText = "Open"
		s.Prompt.ObjectText = f.Name
		s.Model:SetAttribute("State", ready and "Ready" or "Sealed")
	elseif unlocked then
		s.Title.Text = "Empty stand"; s.Rarity.Text = "Place a find here"
		s.Rarity.TextColor3 = Theme.UISecondary; s.Status.Text = "Choose a find"
		s.Status.TextColor3 = Theme.Harvest; s.Prompt.ActionText = "Choose a find"
		s.Model:SetAttribute("State", "Empty")
	else
		s.Title.Text = "New stand"; s.Rarity.Text = "Room for your collection"
		s.Rarity.TextColor3 = Theme.UISecondary; s.Status.Text = (Config.StandPrices[index] or 0) .. " coins"
		s.Status.TextColor3 = Theme.UIText; s.Prompt.ActionText = "Unlock · " .. (Config.StandPrices[index] or 0) .. " coins"
		s.Model:SetAttribute("State", "Locked")
	end
end
local function refreshStats(base: Base)
	local p = base.Owner
	if not p then return end
	local used, ready, sealed, income, residents = 0, 0, 0, 0, 0
	local now = Workspace:GetServerTimeNow()
	for _, s in base.Stands do
		if s.CharacterId then used += 1; residents += 1; income += Finds.CharacterById[s.CharacterId].Income
		elseif s.FindId then
			used += 1
			if now >= s.ReadyAt then ready += 1 else sealed += 1 end
		end
	end
	base.Model:SetAttribute("UnlockedStands", base.Unlocked)
	p:SetAttribute("BaseSlots", base.Unlocked); p:SetAttribute("UsedStands", used)
	p:SetAttribute("ReadyFinds", ready); p:SetAttribute("SealedFinds", sealed)
	p:SetAttribute("Residents", residents); p:SetAttribute("Income", income)
	p:SetAttribute("NextStandCost", Config.StandPrices[base.Unlocked + 1] or 0)
end
local function onBase(p: Player, base: Base): boolean
	local character = p.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return false end
	local relative = root.Position - WorldService.GetPlotPosition(base.Index)
	return math.abs(relative.X) < 48 and math.abs(relative.Z) < 55 and math.abs(relative.Y) < 35
end
local function allowRequest(p: Player): boolean
	local now = os.clock()
	if now - (lastRequest[p] or -1) < 0.25 then return false end
	lastRequest[p] = now
	return true
end
local function unlock(p: Player, base: Base): (boolean, string, number?)
	if base.Unlocked >= Config.MaxStands then return false, "All stands are already unlocked.", nil end
	local index = base.Unlocked + 1
	local price = Config.StandPrices[index]
	local coins = p:GetAttribute("Coins") or 0
	if coins < price then return false, "You need " .. (price - coins) .. " coins", nil end
	p:SetAttribute("Coins", coins - price); base.Unlocked = index
	refreshStand(base, index, Workspace:GetServerTimeNow())
	if index < Config.MaxStands then refreshStand(base, index + 1, Workspace:GetServerTimeNow()) end
	refreshStats(base)
	return true, "New stand unlocked!", index
end
local function place(p: Player, base: Base, index: number, findId: string): (boolean, string)
	local s, f = base.Stands[index], Finds.ById[findId]
	if not s or index > base.Unlocked then return false, "Unlock this stand first." end
	if s.FindId or s.CharacterId then return false, "This stand is occupied." end
	if not f then return false, "Choose a find from the catalogue." end
	local coins = p:GetAttribute("Coins") or 0
	if coins < f.Price then return false, "You need " .. (f.Price - coins) .. " coins" end
	p:SetAttribute("Coins", coins - f.Price)
	s.FindId = findId; s.ReadyAt = Workspace:GetServerTimeNow() + f.OpenSeconds; s.Notified = false
	local display = CollectionAssets.Container(findId, s.Position)
	display.Parent = s.Model; s.Display = display
	refreshStand(base, index, Workspace:GetServerTimeNow()); refreshStats(base)
	return true, f.Name .. " placed. Open in " .. f.OpenSeconds .. " s."
end
local function open(p: Player, base: Base, index: number): (boolean, string)
	local s = base.Stands[index]
	if not s or index > base.Unlocked or not s.FindId then return false, "There is no sealed find on this stand." end
	if Workspace:GetServerTimeNow() < s.ReadyAt then return false, "This find is still unpacking." end
	local f = Finds.AllById[s.FindId]
	local roll, total = random:NextInteger(1, 100), 0
	local id = f.Drops[#f.Drops].Id
	for _, drop in f.Drops do total += drop.Weight; if roll <= total then id = drop.Id; break end end
	-- No yielding between consuming the find and assigning its single reward.
	s.FindId = nil; s.CharacterId = id; s.ReadyAt = 0
	s.NextIncome = Workspace:GetServerTimeNow() + Config.IncomeInterval
	if s.Display then s.Display:Destroy() end
	local display = CollectionAssets.Character(id, s.Position)
	display.Parent = s.Model; s.Display = display
	refreshStand(base, index, Workspace:GetServerTimeNow()); refreshStats(base)
	LevelService.AddXP(p, Config.OpenXP)
	showCharacter:FireClient(p, id, index, true)
	return true, "Meet your new companion: " .. Finds.CharacterById[id].Name .. "!"
end
local function sell(p: Player, base: Base, index: number): (boolean, string)
	local s = base.Stands[index]
	if not s or index > base.Unlocked or not s.CharacterId then return false, "There is no companion on this stand." end
	local c = Finds.CharacterById[s.CharacterId]
	s.CharacterId = nil; s.NextIncome = 0
	if s.Display then s.Display:Destroy() end
	s.Display = nil
	p:SetAttribute("Coins", (p:GetAttribute("Coins") or 0) + c.SellPrice)
	refreshStand(base, index, Workspace:GetServerTimeNow()); refreshStats(base)
	return true, "Companion sold. +" .. c.SellPrice .. " coins. Stand is now free."
end
local function decorate(base: Model, at: Vector3)
	part(base, "CollectorLawn", Vector3.new(88, 0.5, 100), at + Vector3.new(0, 0.35, 0), Theme.Grass, Enum.Material.Grass, true)
	local plaza = part(base, "CollectionCourtyard", Vector3.new(0.22, 68, 68), at + Vector3.new(0, 0.72, -1), Theme.Stone:Lerp(Theme.Path, 0.5), Enum.Material.Cobblestone, true)
	plaza.Shape = Enum.PartType.Cylinder; plaza.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
	part(base, "EntrancePath", Vector3.new(9, 0.2, 21), at + Vector3.new(0, 0.72, 39), Theme.Path, Enum.Material.Ground, true)
	local shed = at + Vector3.new(-27, 0.6, -39)
	part(base, "CollectorWorkshop", Vector3.new(21, 8, 14), shed + Vector3.new(0, 4, 0), Theme.Barn, Enum.Material.WoodPlanks, true)
	for _, side in {-1, 1} do
		local roof = part(base, "WorkshopRoof", Vector3.new(12.5, 0.8, 17), shed + Vector3.new(side * 5.3, 9.2, 0), Theme.Ink, Enum.Material.WoodPlanks, true)
		roof.CFrame *= CFrame.Angles(0, 0, -side * 0.43)
		part(base, "DoorFrame", Vector3.new(0.5, 7, 0.5), shed + Vector3.new(side * 3.4, 3.7, 7.2), Theme.Panel)
	end
	part(base, "WorkshopDoor", Vector3.new(6.3, 6.8, 0.3), shed + Vector3.new(0, 3.5, 7.1), Theme.Wood, Enum.Material.WoodPlanks)
	local workshopSign = part(base, "WorkshopSign", Vector3.new(13, 2, 0.3), shed + Vector3.new(0, 8, 7.3), Theme.Iron)
	Assets.Sign(workshopSign, "Finders' Workshop")
	Assets.Cobweb(base, shed + Vector3.new(-9.8, 7.8, 7.4), 3.4)
	part(base, "Workbench", Vector3.new(11, 0.65, 4.5), at + Vector3.new(0, 3.2, -27), Theme.WoodLight, Enum.Material.WoodPlanks, true)
	for _, x in {-4.3, 4.3} do part(base, "TableLeg", Vector3.new(0.7, 2.5, 3.5), at + Vector3.new(x, 1.7, -27), Theme.Wood, Enum.Material.Wood, true) end
	part(base, "UnfoldedMap", Vector3.new(4, 0.08, 2.7), at + Vector3.new(-1, 3.6, -27), Theme.Paper)
	for _, x in {2, 3.5} do part(base, "OldBook", Vector3.new(1.3, 0.3, 1.8), at + Vector3.new(x, 3.6, -27), Theme.Barn) end
	local how = part(base, "HowToBoard", Vector3.new(14, 4, 0.5), at + Vector3.new(23, 5, -36), Theme.Wood, Enum.Material.Wood)
	Assets.Sign(how, "Your Collection", "Find → open → companion → coins")
	for _, x in {17, 29} do part(base, "BoardPost", Vector3.new(0.7, 5, 0.7), at + Vector3.new(x, 2.5, -36), Theme.Wood) end
	for _, side in {-1, 1} do
		for z = -48, 48, 12 do part(base, "FencePost", Vector3.new(0.8, 4, 0.8), at + Vector3.new(side * 43, 2.5, z), Theme.WoodLight, Enum.Material.Wood, true) end
		for _, y in {1.8, 3.2} do
			part(base, "FenceRail", Vector3.new(0.45, 0.5, 96), at + Vector3.new(side * 43, y, 0), Theme.WoodLight, Enum.Material.Wood, true)
			for _, z in {-48, 48} do part(base, "GateFence", Vector3.new(35, 0.5, 0.45), at + Vector3.new(side * 25.5, y, z), Theme.WoodLight, Enum.Material.Wood, true) end
		end
	end
	Assets.Tree(base, at + Vector3.new(33, 0.6, -40), 1.15, Theme.Harvest)
	Assets.Pumpkins(base, at + Vector3.new(-37, 0.7, -27)); Assets.Pumpkins(base, at + Vector3.new(12, 0.7, 42))
	for _, pos in {Vector3.new(-30, 0.7, 34), Vector3.new(30, 0.7, 34), Vector3.new(-7, 0.7, -24), Vector3.new(7, 0.7, -24)} do Assets.PathLantern(base, at + pos) end
	local leaves = Random.new(math.floor(math.abs(at.X) + math.abs(at.Z)))
	for _ = 1, 35 do
		local leaf = part(base, "FallenLeaf", Vector3.new(0.7, 0.04, 1.2), at + Vector3.new(leaves:NextNumber(-39, 39), 0.9, leaves:NextNumber(-45, 45)), leaves:NextNumber() > 0.5 and Theme.Rust or Theme.Harvest)
		leaf.CFrame *= CFrame.Angles(0, leaves:NextNumber(0, math.pi), 0)
	end
end
local function createBase(index: number, root: Folder): Base
	local at = WorldService.GetPlotPosition(index)
	local model = Instance.new("Model")
	model.Name = "Base_" .. index; model:SetAttribute("OwnerUserId", 0); model.Parent = root
	decorate(model, at)
	local board = part(model, "BaseName", Vector3.new(14, 2.6, 0.5), at + Vector3.new(-24, 4.3, 42), Theme.Wood, Enum.Material.Wood)
	local base: Base = { Index = index, Model = model, Owner = nil, Unlocked = Config.StartingStands, Stands = {}, Sign = Assets.Sign(board, "Unclaimed Base") }
	local folder = Instance.new("Folder")
	folder.Name = "Stands"; folder.Parent = model
	-- Curved display arrangement, not rectangular planting beds.
	local positions = { Vector3.new(-14, 0, 22), Vector3.new(14, 0, 22), Vector3.new(-24, 0, 9), Vector3.new(24, 0, 9), Vector3.new(-25, 0, -7), Vector3.new(25, 0, -7), Vector3.new(-14, 0, -19), Vector3.new(14, 0, -19) }
	for standIndex, offset in positions do
		local pos = at + offset + Vector3.new(0, 1, 0)
		local m = Instance.new("Model")
		m.Name = "Stand_" .. standIndex; m:SetAttribute("StandIndex", standIndex); m.Parent = folder
		for tier = 1, 2 do
			local disc = part(m, "StonePlinth", Vector3.new(0.6, 10 - tier, 10 - tier), pos + Vector3.new(0, (tier - 1) * 0.6, 0), Theme.Stone, Enum.Material.Slate, true)
			disc.Shape = Enum.PartType.Cylinder; disc.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		end
		local platform = part(m, "DisplayTop", Vector3.new(0.25, 7.7, 7.7), pos + Vector3.new(0, 1.03, 0), Theme.Wood, Enum.Material.WoodPlanks, true)
		platform.Shape = Enum.PartType.Cylinder; platform.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		local anchor = part(m, "PlaquePost", Vector3.new(0.4, 2.7, 0.4), pos + Vector3.new(0, 1, 5.2), Theme.WoodLight, Enum.Material.Wood)
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "StandPrompt"; prompt.MaxActivationDistance = 12; prompt.RequiresLineOfSight = false; prompt.HoldDuration = 0; prompt.Parent = anchor
		local gui, title, rarity, status = plaque(anchor)
		base.Stands[standIndex] = { Model = m, Platform = platform, Prompt = prompt, Label = gui, Title = title, Rarity = rarity, Status = status, Position = pos + Vector3.new(0, 1.2, 0), FindId = nil, CharacterId = nil, Display = nil, ReadyAt = 0, NextIncome = 0, Notified = false }
		prompt.Triggered:Connect(function(p)
			if p ~= base.Owner or not onBase(p, base) then return end
			local rootPart = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
			if not rootPart or not rootPart:IsA("BasePart") or (rootPart.Position - anchor.Position).Magnitude > 14 then return end
			local s = base.Stands[standIndex]
			if standIndex > base.Unlocked + 1 then return end
			if s.CharacterId then showCharacter:FireClient(p, s.CharacterId, standIndex, false)
			elseif standIndex <= base.Unlocked and not s.FindId then openMenu:FireClient(p, standIndex)
			elseif allowRequest(p) then
				local ok, message
				if standIndex == base.Unlocked + 1 then ok, message = unlock(p, base) else ok, message = open(p, base, standIndex) end
				if not ok or not s.CharacterId then feedback:FireClient(p, message, ok) end
			end
		end)
		refreshStand(base, standIndex, 0)
	end
	return base
end
local function moveHome(p: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local base = playerBases[p]
	if root and base and p.Character == character then
		local at = WorldService.GetPlotPosition(base.Index)
		character:PivotTo(CFrame.lookAt(at + Vector3.new(0, 4, 38), at + Vector3.new(0, 3, -5)))
	end
end
local function assign(p: Player)
	if playerBases[p] then return end
	for _, base in bases do
		if base.Owner then continue end
		base.Owner = p; playerBases[p] = base; base.Model:SetAttribute("OwnerUserId", p.UserId)
		base.Sign.Text = "Collection: " .. p.DisplayName
		p:SetAttribute("BaseIndex", base.Index); p:SetAttribute("Coins", Config.StartingCoins)
		refreshStats(base)
		p.CharacterAdded:Connect(function(character) task.defer(moveHome, p, character) end)
		if p.Character then task.defer(moveHome, p, p.Character) end
		return
	end
	warn("No free base for " .. p.Name)
end
local function release(p: Player)
	lastRequest[p] = nil
	local base = playerBases[p]
	if not base then return end
	playerBases[p] = nil; base.Owner = nil; base.Unlocked = Config.StartingStands
	base.Model:SetAttribute("OwnerUserId", 0); base.Model:SetAttribute("UnlockedStands", Config.StartingStands)
	base.Sign.Text = "Unclaimed Base"
	for index, s in base.Stands do
		if s.Display then s.Display:Destroy() end
		s.Display, s.FindId, s.CharacterId = nil, nil, nil
		s.ReadyAt, s.NextIncome, s.Notified = 0, 0, false
		refreshStand(base, index, 0)
	end
end
function PlotService.Init()
	for _, name in {"PlayerPlots", "PlayerFarms", "PlayerBases"} do local old = Workspace:FindFirstChild(name); if old then old:Destroy() end end
	for _, name in {"FarmRemotes", "CollectionRemotes"} do local old = ReplicatedStorage:FindFirstChild(name); if old then old:Destroy() end end
	local remotes = Instance.new("Folder")
	remotes.Name = "CollectionRemotes"; remotes.Parent = ReplicatedStorage
	openMenu.Name = "OpenCatalogue"; openMenu.Parent = remotes
	feedback.Name = "Feedback"; feedback.Parent = remotes
	showCharacter.Name = "ShowCharacter"; showCharacter.Parent = remotes
	local request = Instance.new("RemoteFunction")
	request.Name = "Request"; request.Parent = remotes
	request.OnServerInvoke = function(p: Player, action: any, index: any, findId: any)
		local base = playerBases[p]
		if not base or not onBase(p, base) then return { ok = false, message = "Return to your base." } end
		if not allowRequest(p) then return { ok = false, message = "Please wait a moment." } end
		if action == "Unlock" then local ok, message, standIndex = unlock(p, base); return { ok = ok, message = message, standIndex = standIndex } end
		if typeof(index) ~= "number" or index ~= index or index < 1 or index > Config.MaxStands or index ~= math.floor(index) then return { ok = false, message = "Choose a stand on your base." } end
		local ok, message = false, "Choose an action in the catalogue."
		if action == "Place" and typeof(findId) == "string" then ok, message = place(p, base, index, findId)
		elseif action == "Open" then ok, message = open(p, base, index)
		elseif action == "Sell" then ok, message = sell(p, base, index) end
		return { ok = ok, message = message }
	end
	local root = Instance.new("Folder")
	root.Name = "PlayerBases"; root.Parent = Workspace
	for index = 1, Config.PlotCount do bases[index] = createBase(index, root) end
	Players.PlayerAdded:Connect(assign); Players.PlayerRemoving:Connect(release)
	for _, p in Players:GetPlayers() do assign(p) end
	task.spawn(function()
		while true do
			task.wait(1)
			local now = Workspace:GetServerTimeNow()
			for _, base in bases do
				local owner = base.Owner
				if not owner then continue end
				local earned, changed = 0, false
				for index, s in base.Stands do
					if s.FindId then
						refreshStand(base, index, now)
						if now >= s.ReadyAt and not s.Notified then s.Notified = true; changed = true; feedback:FireClient(owner, "Your find is ready! Use Open at its stand.", true) end
					elseif s.CharacterId and now >= s.NextIncome then
						local periods = math.floor((now - s.NextIncome) / Config.IncomeInterval) + 1
						earned += Finds.CharacterById[s.CharacterId].Income * periods
						s.NextIncome += Config.IncomeInterval * periods
					end
				end
				if earned > 0 then owner:SetAttribute("Coins", (owner:GetAttribute("Coins") or 0) + earned) end
				if changed then refreshStats(base) end
			end
		end
	end)
end
return PlotService
