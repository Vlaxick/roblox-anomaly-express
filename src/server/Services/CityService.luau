--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Config = require(ReplicatedStorage.Shared.Config.CityConfig)
local Obby = require(ReplicatedStorage.Shared.Config.ObbyConfig)
local Course = require(script.Parent.ObbyCourse)
local Assets = require(ReplicatedStorage.Shared.FarmAssets)
local Theme = require(ReplicatedStorage.Shared.Config.Theme)
local LevelService = require(script.Parent.LevelService)
local CityService = {}

type Session = {
	Id: string, Progress: number, Started: number, Deadline: number,
	StudyUntil: number, Phase: string, Pattern: {number}, Pressed: {[number]: boolean},
	Checkpoint: number, LastTouch: number, LastFall: number, Falls: number,
}
local sessions: {[Player]: Session} = {}
local rewardTimes: {[Player]: {[string]: number}} = {}
local travelTimes: {[Player]: number} = {}
local contacts: {[BasePart]: {[Player]: boolean}} = {}
local random = Random.new()
local state = Instance.new("RemoteEvent")
local steel = Color3.fromRGB(53, 65, 66)
local blue = Color3.fromRGB(92, 143, 159)
local green = Color3.fromRGB(102, 148, 111)
local brick = Color3.fromRGB(119, 67, 53)
local gold = Color3.fromRGB(203, 169, 106)

local function part(parent: Instance, name: string, size: Vector3, at: Vector3, color: Color3, collide: boolean?): Part
	return Assets.Part(parent, name, size, CFrame.new(at), color, Enum.Material.SmoothPlastic, collide)
end
local function sign(parent: Instance, at: Vector3, width: number, height: number, title: string, detail: string?): Part
	local p = part(parent, "ActivitySign", Vector3.new(width, height, 0.4), at, steel)
	Assets.Sign(p, title, detail)
	return p
end
local function rootOf(player: Player): BasePart?
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root or not root:IsA("BasePart") then return nil end
	return root
end
local function teleport(player: Player, at: Vector3)
	local root = rootOf(player)
	if not root or not player.Character then return end
	root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
	player.Character:PivotTo(CFrame.new(at))
end
local function send(player: Player, session: Session, message: string?)
	local definition = Config.Activities[session.Id]
	local now = Workspace:GetServerTimeNow()
	local last = rewardTimes[player] and rewardTimes[player][session.Id]
	local section = session.Id == "Obby" and Obby.Nodes[math.min(session.Progress + 1, #Obby.Nodes)].Section or nil
	state:FireClient(player, {
		Active = true, Id = session.Id, Name = definition.Name,
		Progress = session.Progress, Total = session.Id == "Obby" and #Obby.Nodes or (session.Id == "Circuit" and 6 or 4),
		Section = section, SectionName = section and Obby.Sections[section].Name or nil,
		Hint = section and Obby.Sections[section].Hint or nil, Falls = session.Falls,
		CheckpointSection = session.Id == "Obby" and Obby.Nodes[session.Checkpoint].Section or nil,
		Started = session.Started, Deadline = session.Deadline,
		Phase = session.Phase, StudyUntil = session.StudyUntil,
		Pattern = session.Phase == "Study" and session.Pattern or nil,
		Coins = definition.Coins, XP = definition.XP,
		RewardIn = last and math.max(0, math.ceil(Config.RewardCooldown - (now - last))) or 0,
		RewardReadyAt = last and last + Config.RewardCooldown or 0,
		Message = message,
	})
end
local function cancel(player: Player, message: string?)
	sessions[player] = nil
	player:SetAttribute("CityActivity", "")
	if player.Parent == Players then state:FireClient(player, { Active = false, Message = message }) end
end
local function complete(player: Player, session: Session)
	local now = Workspace:GetServerTimeNow()
	local definition = Config.Activities[session.Id]
	if now - session.Started < definition.MinimumSeconds then
		send(player, session, "Complete the route before claiming the finish.")
		return
	end
	sessions[player] = nil
	player:SetAttribute("CityActivity", "")
	local times = rewardTimes[player] or {}
	rewardTimes[player] = times
	local last = times[session.Id]
	local rewardIn = last and math.max(0, math.ceil(Config.RewardCooldown - (now - last))) or 0
	local message: string
	if rewardIn == 0 then
		times[session.Id] = now
		player:SetAttribute("Coins", (player:GetAttribute("Coins") or 0) + definition.Coins)
		LevelService.AddXP(player, definition.XP)
		message = "+" .. definition.Coins .. " coins  /  +" .. definition.XP .. " XP"
	else
		message = "Practice clear! Next reward in " .. rewardIn .. " s."
	end
	local elapsed = math.floor((now - session.Started) * 10) / 10
	if session.Id == "Obby" then
		local best = player:GetAttribute("ObbyBestSeconds")
		if not best or elapsed < best then player:SetAttribute("ObbyBestSeconds", elapsed) end
	end
	player:SetAttribute("CityWins", (player:GetAttribute("CityWins") or 0) + 1)
	state:FireClient(player, { Active = false, Success = true, Name = definition.Name, Message = message, Seconds = elapsed })
end
local function start(player: Player, id: string)
	if not rootOf(player) then return end
	local now = Workspace:GetServerTimeNow()
	local current = sessions[player]
	if current and current.Id == id then return end
	local pattern: {number} = {}
	if id == "Memory" then
		local choices = {1, 2, 3, 4, 5, 6, 7, 8}
		for _ = 1, 4 do table.insert(pattern, table.remove(choices, random:NextInteger(1, #choices))) end
	end
	local session: Session = {
		Id = id, Progress = id == "Obby" and 1 or 0, Started = now,
		Deadline = id == "Circuit" and now + 30 or (id == "Memory" and now + 50 or 0),
		StudyUntil = id == "Memory" and now + 5 or 0, Phase = id == "Memory" and "Study" or "Play",
		Pattern = pattern, Pressed = {}, Checkpoint = 1, LastTouch = 0, LastFall = 0, Falls = 0,
	}
	sessions[player] = session
	player:SetAttribute("CityActivity", id)
	if id == "Obby" then teleport(player, Course.Spawn(1))
	elseif id == "Circuit" then teleport(player, Config.CircuitCenter + Vector3.new(0, 4, 31))
	else teleport(player, Config.MemoryCenter + Vector3.new(0, 4, 31)) end
	send(player, session)
end
local function travel(player: Player, destination: string): (boolean, string)
	if not rootOf(player) then return false, "Wait for your character to respawn." end
	local now = os.clock()
	if now - (travelTimes[player] or -10) < 1 then return false, "Please wait a moment." end
	local target: Vector3?
	if destination == "Home" then
		local index = player:GetAttribute("BaseIndex")
		local at = index and Config.BasePositions[index]
		if not at then return false, "Your base is not ready yet." end
		target = at + Vector3.new(0, 4, 38)
	elseif destination == "Station" then target = Config.StationArrival
	elseif destination == "Platform" then target = Config.PlatformArrival
	elseif Config.Activities[destination] then
		travelTimes[player] = now
		if sessions[player] then cancel(player) end
		start(player, destination)
		return true, "Entered " .. Config.Activities[destination].Name .. "."
	else return false, "Choose a station destination." end
	travelTimes[player] = now
	cancel(player)
	teleport(player, target :: Vector3)
	return true, destination == "Home" and "Welcome home." or "Welcome to Central Station."
end
local function bindTouch(pad: BasePart, callback: (Player) -> ())
	local occupants: {[Player]: boolean} = {}
	contacts[pad] = occupants
	pad.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player then return end
		local root = rootOf(player)
		if not root then return end
		local relative = pad.CFrame:PointToObjectSpace(root.Position)
		if math.abs(relative.X) > pad.Size.X / 2 + 2 or math.abs(relative.Z) > pad.Size.Z / 2 + 2 then return end
		if relative.Y < 0 or relative.Y > pad.Size.Y / 2 + 5 then return end
		if occupants[player] then return end
		occupants[player] = true
		callback(player)
	end)
end
local function numberOn(pad: BasePart, value: string)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Top; gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 30; gui.LightInfluence = 0.1; gui.Parent = pad
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1
	label.Text = value; label.TextColor3 = Theme.Paper; label.Font = Enum.Font.GothamBold; label.TextScaled = true; label.Parent = gui
end
local function pressurePad(parent: Instance, id: string, index: number, at: Vector3): Part
	part(parent, "ButtonSocket", Vector3.new(10, 0.45, 10), at - Vector3.new(0, 0.3, 0), steel, true)
	local pad = part(parent, "Button_" .. index, Vector3.new(8.4, 0.65, 8.4), at, blue, true)
	pad:SetAttribute("Activity", id); pad:SetAttribute("ButtonIndex", index)
	numberOn(pad, tostring(index))
	local pulsing = false
	bindTouch(pad, function(player)
		local session = sessions[player]
		if not session or session.Id ~= id or session.Phase ~= "Play" then return end
		local now = Workspace:GetServerTimeNow()
		if now - session.LastTouch < 0.35 then return end
		session.LastTouch = now
		if now >= session.Deadline then return end
		if not pulsing then
			pulsing = true
			local tween = TweenService:Create(pad, TweenInfo.new(0.12), {Color = gold, Position = at - Vector3.new(0, 0.18, 0)})
			tween:Play()
			task.delay(0.3, function()
				if pad.Parent then TweenService:Create(pad, TweenInfo.new(0.15), {Color = blue, Position = at}):Play() end
				pulsing = false
			end)
		end
		if id == "Circuit" then
			if session.Pressed[index] then return end
			session.Pressed[index] = true; session.Progress += 1
		elseif session.Pattern[session.Progress + 1] == index then session.Progress += 1
		else
			session.Progress = 0; session.Phase = "Study"; session.StudyUntil = now + 5; session.Deadline = now + 50
			send(player, session, "Wrong button. Watch the pattern again.")
			return
		end
		local total = id == "Circuit" and 6 or 4
		if session.Progress == total then
			if now - session.Started >= Config.Activities[id].MinimumSeconds then complete(player, session)
			else session.Progress -= 1; if id == "Circuit" then session.Pressed[index] = nil end; send(player, session, "Keep moving through the room.") end
		else send(player, session) end
	end)
	return pad
end
local function returnPrompt(parent: Instance, at: Vector3)
	local anchor = sign(parent, at + Vector3.new(0, 3.5, 0), 15, 4, "RETURN TO STATION", "OR USE THE STATION BUTTON")
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Return"; prompt.ObjectText = "Central Station"; prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false; prompt.Parent = anchor
	prompt.Triggered:Connect(function(player)
		local root = rootOf(player)
		if root and (root.Position - anchor.Position).Magnitude <= 14 then travel(player, "Station") end
	end)
end
local function room(root: Instance, id: string, center: Vector3, title: string, rules: string): Model
	local model = Instance.new("Model"); model.Name = id; model.Parent = root
	part(model, "RoomFloor", Vector3.new(90, 1, 90), center + Vector3.new(0, 0.8, 0), Theme.Stone, true)
	for _, side in {-1, 1} do
		part(model, "RoomWall", Vector3.new(2, 18, 90), center + Vector3.new(side * 45, 10, 0), brick, true)
		part(model, "RoomColumn", Vector3.new(4, 21, 4), center + Vector3.new(side * 43, 11, 43), gold, true)
	end
	part(model, "RoomBack", Vector3.new(90, 18, 2), center + Vector3.new(0, 10, -45), brick, true)
	part(model, "RoomHeader", Vector3.new(94, 2, 4), center + Vector3.new(0, 22, 44), steel, true)
	sign(model, center + Vector3.new(0, 17, 43), 66, 7, title, rules)
	sign(model, center + Vector3.new(0, 12, -43.5), 68, 6, "YOUR PROGRESS IS PERSONAL", "REWARDS EVERY 90 SECONDS  /  PRACTICE ANYTIME")
	for _, side in {-1, 1} do
		local lamp = part(model, "ActivityLamp", Vector3.new(3, 1, 3), center + Vector3.new(side * 30, 16, 0), Theme.Paper)
		local light = Instance.new("PointLight"); light.Color = Theme.Paper; light.Brightness = 2; light.Range = 65; light.Parent = lamp
	end
	local startPad = part(model, "StartPad", Vector3.new(14, 0.3, 8), center + Vector3.new(0, 1.5, 36), green, true)
	numberOn(startPad, "START")
	bindTouch(startPad, function(player) start(player, id) end)
	returnPrompt(model, center + Vector3.new(33, 1.5, 32))
	return model
end
local function buildActivities(root: Folder)
	local circuit = room(root, "Circuit", Config.CircuitCenter, "CIRCUIT RUN", "STEP ON ALL 6 BUTTONS IN 30 SECONDS")
	local offsets = {Vector3.new(-28, 0, 20), Vector3.new(28, 0, 20), Vector3.new(-28, 0, -4), Vector3.new(28, 0, -4), Vector3.new(-18, 0, -30), Vector3.new(18, 0, -30)}
	for i, offset in offsets do pressurePad(circuit, "Circuit", i, Config.CircuitCenter + offset + Vector3.new(0, 1.6, 0)) end
	local memory = room(root, "Memory", Config.MemoryCenter, "MEMORY ROOM", "WATCH 4 NUMBERS  /  REPEAT THEM BY STEPPING ON BUTTONS")
	for i = 1, 8 do
		pressurePad(memory, "Memory", i, Config.MemoryCenter + Vector3.new(-27 + ((i - 1) % 4) * 18, 1.6, i <= 4 and -16 or 8))
	end
	local obby, startPad = Course.Build(root)
	bindTouch(startPad, function(player) start(player, "Obby") end)
	returnPrompt(obby, Course.Spawn(#Obby.Nodes) + Vector3.new(0, 0, -12))
end
function CityService.Init()
	local old = Workspace:FindFirstChild("StationActivities"); if old then old:Destroy() end
	local oldRemotes = ReplicatedStorage:FindFirstChild("CityRemotes"); if oldRemotes then oldRemotes:Destroy() end
	local remotes = Instance.new("Folder"); remotes.Name = "CityRemotes"; remotes.Parent = ReplicatedStorage
	state.Name = "State"; state.Parent = remotes
	local request = Instance.new("RemoteFunction"); request.Name = "Travel"; request.Parent = remotes
	request.OnServerInvoke = function(player: Player, destination: any)
		-- HUD travel only goes home/station. Activity entry must use a real gate
		-- or its physical start pad, not a client-supplied challenge teleport.
		if destination ~= "Station" and destination ~= "Home" then return {ok = false, message = "Use a station gate to enter an activity."} end
		local ok, message = travel(player, destination)
		return {ok = ok, message = message}
	end
	local root = Instance.new("Folder"); root.Name = "StationActivities"; root.Parent = Workspace
	buildActivities(root)
	local gates = Workspace.AnomalyWorld.GrandStation.Gates
	for _, gate in gates:GetChildren() do
		local anchor = gate:FindFirstChild("GateControl")
		local prompt = anchor and anchor:FindFirstChild("GatePrompt")
		if not anchor or not anchor:IsA("BasePart") or not prompt or not prompt:IsA("ProximityPrompt") then continue end
		prompt.Triggered:Connect(function(player)
			local rootPart = rootOf(player)
			if rootPart and (rootPart.Position - anchor.Position).Magnitude <= 14 then travel(player, gate:GetAttribute("Destination")) end
		end)
	end
	local function joined(player: Player)
		player:SetAttribute("CityActivity", ""); player:SetAttribute("CityWins", 0)
		player.CharacterRemoving:Connect(function() cancel(player) end)
	end
	Players.PlayerAdded:Connect(joined)
	for _, player in Players:GetPlayers() do joined(player) end
	Players.PlayerRemoving:Connect(function(player) sessions[player] = nil; rewardTimes[player] = nil; travelTimes[player] = nil end)

	local accumulated = 0
	RunService.Heartbeat:Connect(function(dt)
		accumulated += dt
		if accumulated < 0.05 then return end
		accumulated = 0
		local now = Workspace:GetServerTimeNow()
		Course.Update(now)
		for player, session in sessions do
			if session.Id ~= "Obby" then continue end
			local rootPart = rootOf(player)
			if not rootPart then continue end
			local fell = rootPart.Position.Y < math.max(5, Obby.Nodes[session.Progress].At.Y - 7)
			if now - session.LastFall > 0.9 and (fell or Course.HitHazard(rootPart)) then
				session.LastFall = now; session.Falls += 1; session.Progress = session.Checkpoint
				teleport(player, Course.Spawn(session.Checkpoint))
				send(player, session, fell and "Missed the jump. Back to your checkpoint." or "Machinery hit! Back to your checkpoint.")
				continue
			end
			local index = Course.Surface(rootPart)
			if index ~= session.Progress + 1 then continue end
			if index == #Obby.Nodes and now - session.Started < Config.Activities.Obby.MinimumSeconds then continue end
			session.Progress = index
			if Obby.Checkpoints[index] then session.Checkpoint = index end
			if index == #Obby.Nodes then complete(player, session)
			else send(player, session, Obby.Checkpoints[index] and "Checkpoint saved!" or nil) end
		end
	end)
	task.spawn(function()
		while true do
			task.wait(0.25)
			local now = Workspace:GetServerTimeNow()
			-- Touched fires for multiple body parts and again when a button pulses.
			-- Treat a whole visit to a pad as one press; re-arm only after leaving.
			for pad, occupants in contacts do
				if not pad.Parent then contacts[pad] = nil; continue end
				for player in occupants do
					local rootPart = rootOf(player)
					local relative = rootPart and pad.CFrame:PointToObjectSpace(rootPart.Position)
					if not relative or math.abs(relative.X) > pad.Size.X / 2 + 2.5 or math.abs(relative.Z) > pad.Size.Z / 2 + 2.5 or relative.Y < -1 or relative.Y > 7 then
						occupants[player] = nil
					end
				end
			end
			for player, session in sessions do
				local rootPart = rootOf(player)
				if not rootPart then cancel(player); continue end
				local at = rootPart.Position
				local center = session.Id == "Obby" and Obby.Origin or (session.Id == "Circuit" and Config.CircuitCenter or Config.MemoryCenter)
				local size = session.Id == "Obby" and Obby.Bounds or Vector3.new(50, 60, 50)
				local relative = at - center
				if math.abs(relative.X) > size.X or math.abs(relative.Z) > size.Z or at.Y > size.Y then cancel(player, "Activity left. Use a gate to start again."); continue end
				if session.Deadline > 0 and now >= session.Deadline then
					cancel(player, "Time is up. Step on START to try again.")
				elseif session.Id == "Memory" and session.Phase == "Study" and now >= session.StudyUntil then
					session.Phase = "Play"; send(player, session, "Now repeat the pattern!")
				end
			end
		end
	end)
end

return CityService
