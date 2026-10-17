--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage.Shared.Config.GameConfig)
local Crops = require(ReplicatedStorage.Shared.Config.Crops)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local LevelService = require(script.Parent.LevelService)
local WorldService = require(script.Parent.WorldService)

type Bed = {
	Model: Model, Soil: Part, Prompt: ProximityPrompt, Label: BillboardGui,
	Title: TextLabel, Rarity: TextLabel, Status: TextLabel, Position: Vector3,
	CropId: string?, Crop: Model?, ReadyAt: number, NextIncome: number, Stage: number, Mature: boolean,
}
type Farm = { Index: number, Model: Model, Owner: Player?, Unlocked: number, Beds: {Bed}, Sign: TextLabel }

local PlotService = {}
local farms: {Farm} = {}
local playerFarms: {[Player]: Farm} = {}
local lastRequest: {[Player]: number} = {}
local openMenu = Instance.new("RemoteEvent")
local feedback = Instance.new("RemoteEvent")

local function part(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3, material: Enum.Material?, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(pos), color, material, collide)
end

local function bedLabel(anchor: BasePart): (BillboardGui, TextLabel, TextLabel, TextLabel)
	local gui = Instance.new("BillboardGui")
	gui.Name = "PlantLabel"
	gui.Size = UDim2.fromOffset(170, 72)
	gui.StudsOffset = Vector3.new(0, 2.6, 0)
	gui.MaxDistance = 26
	gui.AlwaysOnTop = false
	gui.Parent = anchor
	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(1, 1)
	panel.BackgroundColor3 = Theme.Paper
	panel.BackgroundTransparency = 0.06
	panel.BorderSizePixel = 0
	panel.Parent = gui
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = panel
	local function line(y: number, height: number, size: number, font: Enum.Font): TextLabel
		local t = Instance.new("TextLabel")
		t.BackgroundTransparency = 1
		t.Position = UDim2.fromOffset(6, y)
		t.Size = UDim2.new(1, -12, 0, height)
		t.TextColor3 = Theme.Ink
		t.Font = font
		t.TextSize = size
		t.Parent = panel
		return t
	end
	return gui, line(3, 23, 16, Enum.Font.GothamBold), line(26, 17, 12, Enum.Font.GothamMedium), line(45, 23, 14, Enum.Font.GothamBold)
end

local function refreshBed(farm: Farm, index: number, now: number)
	local bed = farm.Beds[index]
	local unlocked = index <= farm.Unlocked
	bed.Model:SetAttribute("Unlocked", unlocked)
	bed.Model:SetAttribute("CropId", bed.CropId or "")
	bed.Model:SetAttribute("ReadyAt", bed.ReadyAt)
	bed.Model:SetAttribute("Mature", bed.Mature)
	bed.Soil.Color = unlocked and Theme.Soil or Theme.Grass
	bed.Soil.Material = unlocked and Enum.Material.Ground or Enum.Material.Grass
	bed.Label.Enabled = unlocked or index == farm.Unlocked + 1
	bed.Prompt.Enabled = bed.CropId == nil and (unlocked or index == farm.Unlocked + 1)
	bed.Prompt.ObjectText = "Грядка " .. index
	if bed.CropId then
		local crop = Crops.ById[bed.CropId]
		bed.Title.Text = crop.Name
		bed.Rarity.Text = crop.Rarity
		bed.Rarity.TextColor3 = crop.Color
		bed.Status.Text = bed.Mature and ("+" .. crop.Income .. " мон. / " .. Config.IncomeInterval .. " с") or ("Росте · " .. math.max(0, math.ceil(bed.ReadyAt - now)) .. " с")
		bed.Status.TextColor3 = bed.Mature and Theme.Green or Theme.Muted
		bed.Model:SetAttribute("State", bed.Mature and "Mature" or "Growing")
	elseif unlocked then
		bed.Title.Text = "Вільна грядка"
		bed.Rarity.Text = "Місце для рослини"
		bed.Rarity.TextColor3 = Theme.Muted
		bed.Status.Text = "Посадити"
		bed.Status.TextColor3 = Theme.Green
		bed.Prompt.ActionText = "Посадити"
		bed.Model:SetAttribute("State", "Empty")
	else
		bed.Title.Text = "Нова грядка"
		bed.Rarity.Text = "Більше місця для рослин"
		bed.Rarity.TextColor3 = Theme.Muted
		bed.Status.Text = (Config.BedPrices[index] or 0) .. " монет"
		bed.Status.TextColor3 = Theme.Ink
		bed.Prompt.ActionText = "Відкрити · " .. (Config.BedPrices[index] or 0) .. " монет"
		bed.Model:SetAttribute("State", "Locked")
	end
end

local function refreshStats(farm: Farm)
	local player = farm.Owner
	if not player then return end
	local growing, mature, income = 0, 0, 0
	for _, bed in farm.Beds do
		if bed.CropId then
			if bed.Mature then mature += 1; income += Crops.ById[bed.CropId].Income else growing += 1 end
		end
	end
	farm.Model:SetAttribute("UnlockedBeds", farm.Unlocked)
	player:SetAttribute("FarmSlots", farm.Unlocked)
	player:SetAttribute("UsedBeds", growing + mature)
	player:SetAttribute("GrowingBeds", growing)
	player:SetAttribute("MatureBeds", mature)
	player:SetAttribute("Income", income)
	player:SetAttribute("NextBedCost", Config.BedPrices[farm.Unlocked + 1] or 0)
end

local function onFarm(player: Player, farm: Farm): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then return false end
	local relative = root.Position - WorldService.GetPlotPosition(farm.Index)
	return math.abs(relative.X) < 48 and math.abs(relative.Z) < 55 and math.abs(relative.Y) < 35
end

local function unlock(player: Player, farm: Farm): (boolean, string, number?)
	if farm.Unlocked >= Config.MaxBeds then return false, "Усі грядки вже відкриті.", nil end
	local index = farm.Unlocked + 1
	local price = Config.BedPrices[index]
	local coins = player:GetAttribute("Coins") or 0
	if coins < price then return false, "Потрібно ще " .. (price - coins) .. " мон.", nil end
	player:SetAttribute("Coins", coins - price)
	farm.Unlocked = index
	refreshBed(farm, index, Workspace:GetServerTimeNow())
	if index < Config.MaxBeds then refreshBed(farm, index + 1, Workspace:GetServerTimeNow()) end
	refreshStats(farm)
	return true, "Грядку відкрито. Тепер можна посадити рослину.", index
end

local function plant(player: Player, farm: Farm, index: number, cropId: string): (boolean, string)
	local bed = farm.Beds[index]
	local crop = Crops.ById[cropId]
	if not bed or index > farm.Unlocked then return false, "Спочатку відкрий цю грядку." end
	if bed.CropId then return false, "На цій грядці вже росте рослина." end
	if not crop then return false, "Обери рослину з каталогу." end
	local coins = player:GetAttribute("Coins") or 0
	if coins < crop.Price then return false, "Потрібно ще " .. (crop.Price - coins) .. " мон." end
	player:SetAttribute("Coins", coins - crop.Price)
	local now = Workspace:GetServerTimeNow()
	bed.CropId = cropId
	bed.ReadyAt = now + crop.GrowSeconds
	bed.NextIncome = bed.ReadyAt + Config.IncomeInterval
	bed.Stage = 1
	bed.Mature = false
	local model = Assets.Crop(cropId, bed.Position)
	model:ScaleTo(0.25)
	model.Parent = bed.Model
	bed.Crop = model
	refreshBed(farm, index, now)
	refreshStats(farm)
	return true, "Посаджено: " .. crop.Name .. ". Ріст — " .. crop.GrowSeconds .. " с."
end

local function decorate(farm: Model, at: Vector3)
	part(farm, "FarmLawn", Vector3.new(88, 0.5, 100), at + Vector3.new(0, 0.35, 0), Theme.Grass, Enum.Material.Grass, true)
	part(farm, "GardenPath", Vector3.new(8, 0.16, 91), at + Vector3.new(0, 0.67, 3), Theme.Path, Enum.Material.Ground, true)
	for _, side in {-1, 1} do
		for z = -48, 48, 12 do
			part(farm, "FencePost", Vector3.new(0.8, 4, 0.8), at + Vector3.new(side * 43, 2.5, z), Theme.WoodLight, Enum.Material.Wood, true)
		end
		for _, y in {1.8, 3.2} do
			part(farm, "FenceRail", Vector3.new(0.45, 0.5, 96), at + Vector3.new(side * 43, y, 0), Theme.WoodLight, Enum.Material.Wood, true)
		end
		for _, z in {-48, 48} do
			for x = 8, 43, 11.5 do
				part(farm, "FencePost", Vector3.new(0.8, 4, 0.8), at + Vector3.new(side * x, 2.5, z), Theme.WoodLight, Enum.Material.Wood, true)
			end
			for _, y in {1.8, 3.2} do
				part(farm, "GateFence", Vector3.new(35, 0.5, 0.45), at + Vector3.new(side * 25.5, y, z), Theme.WoodLight, Enum.Material.Wood, true)
			end
		end
	end

	local barn = at + Vector3.new(-28, 0.6, -39)
	part(farm, "Barn", Vector3.new(19, 8, 15), barn + Vector3.new(0, 4, 0), Theme.Barn, Enum.Material.WoodPlanks, true)
	for _, side in {-1, 1} do
		local roof = part(farm, "BarnRoof", Vector3.new(11.7, 0.8, 18), barn + Vector3.new(side * 4.9, 9.2, 0), Theme.Ink, Enum.Material.WoodPlanks, true)
		roof.CFrame *= CFrame.Angles(0, 0, -side * 0.43)
		part(farm, "BarnTrim", Vector3.new(0.55, 8, 0.5), barn + Vector3.new(side * 9.1, 4, 7.65), Theme.Paper)
	end
	part(farm, "BarnDoor", Vector3.new(6, 6, 0.3), barn + Vector3.new(0, 3, 7.7), Theme.Wood, Enum.Material.WoodPlanks)
	for _, side in {-1, 1} do
		local brace = part(farm, "DoorBrace", Vector3.new(0.35, 7.8, 0.15), barn + Vector3.new(0, 3, 7.95), Theme.Panel)
		brace.CFrame *= CFrame.Angles(0, 0, side * 0.73)
	end
	part(farm, "BarnWindowTrim", Vector3.new(3, 3, 0.3), barn + Vector3.new(-5.9, 5, 7.7), Theme.Panel)
	part(farm, "BarnWindow", Vector3.new(2.3, 2.3, 0.35), barn + Vector3.new(-5.9, 5, 7.85), Color3.fromRGB(112, 137, 130), Enum.Material.Glass)
	part(farm, "DoorStep", Vector3.new(8, 0.35, 3), barn + Vector3.new(0, 0.15, 9), Theme.Stone, Enum.Material.Cobblestone)
	Assets.Tree(farm, at + Vector3.new(31, 0.6, -39), 1.25, Theme.Harvest)
	for _, pos in {Vector3.new(-35, 1.6, 3), Vector3.new(-35, 1.6, 8), Vector3.new(35, 1.6, -12)} do
		local hay = part(farm, "HayBale", Vector3.new(4, 2.4, 3), at + pos, Theme.Harvest, Enum.Material.Grass)
		for _, band in {-1, 1} do
			part(farm, "HayTwine", Vector3.new(0.22, 2.5, 3.1), hay.Position + Vector3.new(band, 0, 0), Theme.Wood)
		end
	end
	local pumpkins = Assets.Crop("Pumpkin", at + Vector3.new(-37, 0.7, -27))
	pumpkins:ScaleTo(0.7)
	pumpkins.Name = "PorchPumpkins"
	pumpkins.Parent = farm
	part(farm, "MailboxPost", Vector3.new(0.65, 3.2, 0.65), at + Vector3.new(33, 2.1, 38), Theme.Wood, Enum.Material.Wood)
	part(farm, "Mailbox", Vector3.new(2.5, 1.6, 3), at + Vector3.new(33, 4.1, 38), Theme.Barn, Enum.Material.Metal)
	local random = Random.new(math.floor(math.abs(at.X) + math.abs(at.Z)))
	for _ = 1, 35 do
		local x = random:NextNumber(-39, 39)
		local z = random:NextNumber(-45, 45)
		local leaf = part(farm, "FallenLeaf", Vector3.new(0.7, 0.04, 1.2), at + Vector3.new(x, 0.67, z), random:NextNumber() > 0.5 and Theme.Rust or Theme.Harvest)
		leaf.CFrame *= CFrame.Angles(0, random:NextNumber(0, math.pi), 0)
	end
end

local function createFarm(index: number, root: Folder): Farm
	local at = WorldService.GetPlotPosition(index)
	local model = Instance.new("Model")
	model.Name = "Farm_" .. index
	model:SetAttribute("OwnerUserId", 0)
	model.Parent = root
	decorate(model, at)
	local ownerBoard = part(model, "FarmName", Vector3.new(12, 2.6, 0.5), at + Vector3.new(-24, 4.3, 42), Theme.Wood, Enum.Material.Wood)
	local ownerText = Assets.Sign(ownerBoard, "Вільна ферма")
	local farm: Farm = { Index = index, Model = model, Owner = nil, Unlocked = Config.StartingBeds, Beds = {}, Sign = ownerText }
	local bedsFolder = Instance.new("Folder")
	bedsFolder.Name = "Beds"
	bedsFolder.Parent = model
	for bedIndex = 1, Config.MaxBeds do
		local side = bedIndex % 2 == 1 and -1 or 1
		local row = math.ceil(bedIndex / 2)
		local pos = at + Vector3.new(side * 18, 0.85, 24 - (row - 1) * 16)
		local bedModel = Instance.new("Model")
		bedModel.Name = "Bed_" .. bedIndex
		bedModel:SetAttribute("BedIndex", bedIndex)
		bedModel.Parent = bedsFolder
		local soil = part(bedModel, "Soil", Vector3.new(20, 0.35, 12), pos, Theme.Soil, Enum.Material.Ground)
		for _, edge in {-1, 1} do
			part(bedModel, "BedPlank", Vector3.new(20.5, 0.65, 0.45), pos + Vector3.new(0, 0.05, edge * 6), Theme.Wood, Enum.Material.WoodPlanks)
			part(bedModel, "BedPlank", Vector3.new(0.45, 0.65, 12.4), pos + Vector3.new(edge * 10, 0.05, 0), Theme.Wood, Enum.Material.WoodPlanks)
		end
		local anchor = part(bedModel, "PlantStake", Vector3.new(0.4, 2.8, 0.4), pos + Vector3.new(-side * 8, 1.2, 4.7), Theme.WoodLight, Enum.Material.Wood)
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "BedPrompt"
		prompt.MaxActivationDistance = 12
		prompt.RequiresLineOfSight = false
		prompt.HoldDuration = 0
		prompt.Parent = anchor
		local labelGui, title, rarity, status = bedLabel(anchor)
		farm.Beds[bedIndex] = { Model = bedModel, Soil = soil, Prompt = prompt, Label = labelGui, Title = title, Rarity = rarity, Status = status, Position = pos + Vector3.new(0, 0.2, 0), CropId = nil, Crop = nil, ReadyAt = 0, NextIncome = 0, Stage = 0, Mature = false }
		prompt.Triggered:Connect(function(player)
			if player ~= farm.Owner or not onFarm(player, farm) then return end
			if bedIndex <= farm.Unlocked and farm.Beds[bedIndex].CropId == nil then
				openMenu:FireClient(player, bedIndex)
			elseif bedIndex == farm.Unlocked + 1 then
				local ok, message = unlock(player, farm)
				feedback:FireClient(player, message, ok)
			end
		end)
		refreshBed(farm, bedIndex, 0)
	end
	return farm
end

local function moveHome(player: Player, character: Model)
	local root = character:WaitForChild("HumanoidRootPart", 10)
	local farm = playerFarms[player]
	if root and farm and player.Character == character then
		local at = WorldService.GetPlotPosition(farm.Index)
		character:PivotTo(CFrame.lookAt(at + Vector3.new(0, 4, 38), at + Vector3.new(0, 3, -5)))
	end
end

local function assign(player: Player)
	if playerFarms[player] then return end
	for _, farm in farms do
		if not farm.Owner then
			farm.Owner = player
			playerFarms[player] = farm
			farm.Model:SetAttribute("OwnerUserId", player.UserId)
			farm.Sign.Text = "Ферма " .. player.DisplayName
			player:SetAttribute("FarmIndex", farm.Index)
			player:SetAttribute("Coins", Config.StartingCoins)
			refreshStats(farm)
			player.CharacterAdded:Connect(function(character) task.defer(moveHome, player, character) end)
			if player.Character then task.defer(moveHome, player, player.Character) end
			return
		end
	end
	warn("No free farm for " .. player.Name)
end

local function release(player: Player)
	lastRequest[player] = nil
	local farm = playerFarms[player]
	if not farm then return end
	playerFarms[player] = nil
	farm.Owner = nil
	farm.Unlocked = Config.StartingBeds
	farm.Model:SetAttribute("OwnerUserId", 0)
	farm.Model:SetAttribute("UnlockedBeds", Config.StartingBeds)
	farm.Sign.Text = "Вільна ферма"
	for index, bed in farm.Beds do
		if bed.Crop then bed.Crop:Destroy() end
		bed.Crop, bed.CropId = nil, nil
		bed.ReadyAt, bed.NextIncome, bed.Stage, bed.Mature = 0, 0, 0, false
		refreshBed(farm, index, 0)
	end
end

function PlotService.Init()
	for _, name in {"PlayerPlots", "PlayerFarms", "FarmRemotes"} do
		local parent = name == "FarmRemotes" and ReplicatedStorage or Workspace
		local previous = parent:FindFirstChild(name)
		if previous then previous:Destroy() end
	end
	local remotes = Instance.new("Folder")
	remotes.Name = "FarmRemotes"
	remotes.Parent = ReplicatedStorage
	openMenu.Name = "OpenPlantMenu"
	openMenu.Parent = remotes
	feedback.Name = "Feedback"
	feedback.Parent = remotes
	local request = Instance.new("RemoteFunction")
	request.Name = "Request"
	request.Parent = remotes
	request.OnServerInvoke = function(player: Player, action: any, index: any, cropId: any)
		local farm = playerFarms[player]
		if not farm or not onFarm(player, farm) then return { ok = false, message = "Повернися на свою ферму." } end
		local now = os.clock()
		if now - (lastRequest[player] or -1) < 0.25 then return { ok = false, message = "Зачекай мить." } end
		lastRequest[player] = now
		if action == "Plant" and typeof(index) == "number" and index == math.floor(index) and index >= 1 and index <= Config.MaxBeds and typeof(cropId) == "string" then
			local ok, message = plant(player, farm, index, cropId)
			return { ok = ok, message = message }
		elseif action == "Unlock" then
			local ok, message, bedIndex = unlock(player, farm)
			return { ok = ok, message = message, bedIndex = bedIndex }
		end
		return { ok = false, message = "Обери дію в каталозі." }
	end
	local root = Instance.new("Folder")
	root.Name = "PlayerFarms"
	root.Parent = Workspace
	for index = 1, Config.PlotCount do farms[index] = createFarm(index, root) end
	Players.PlayerAdded:Connect(assign)
	Players.PlayerRemoving:Connect(release)
	for _, player in Players:GetPlayers() do assign(player) end
	task.spawn(function()
		while true do
			task.wait(1)
			local now = Workspace:GetServerTimeNow()
			for _, farm in farms do
				local owner = farm.Owner
				if not owner then continue end
				local earned = 0
				local changed = false
				for index, bed in farm.Beds do
					if not bed.CropId then continue end
					local crop = Crops.ById[bed.CropId]
					if not bed.Mature then
						local remaining = bed.ReadyAt - now
						local stage = remaining <= 0 and 3 or (remaining < crop.GrowSeconds / 2 and 2 or 1)
						if stage ~= bed.Stage and bed.Crop then
							bed.Stage = stage
							bed.Crop:ScaleTo(stage == 3 and 1 or 0.6)
						end
						if remaining <= 0 then
							bed.Mature = true
							changed = true
							LevelService.AddXP(owner, Config.GrowXP)
							feedback:FireClient(owner, "Готово: " .. crop.Name .. ". +" .. crop.Income .. " мон. / " .. Config.IncomeInterval .. " с.", true)
						end
						refreshBed(farm, index, now)
					end
					if bed.Mature and now >= bed.NextIncome then
						local periods = math.floor((now - bed.NextIncome) / Config.IncomeInterval) + 1
						earned += crop.Income * periods
						bed.NextIncome += Config.IncomeInterval * periods
					end
				end
				if earned > 0 then owner:SetAttribute("Coins", (owner:GetAttribute("Coins") or 0) + earned) end
				if changed then refreshStats(farm) end
			end
		end
	end)
end

return PlotService
