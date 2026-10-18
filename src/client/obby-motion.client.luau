--!strict

-- Mirror deterministic machinery locally, so network updates do not make a
-- rotating arm stutter. Only the server decides hits, route progress and rewards.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(ReplicatedStorage.Shared.Config.ObbyConfig)
local Motion = require(ReplicatedStorage.Shared.ObbyMotion)
local player = Players.LocalPlayer
local course = Workspace:WaitForChild("StationActivities"):WaitForChild("Obby")
local nodes = course:WaitForChild("CourseNodes")
local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Include
ray.FilterDescendantsInstances = {nodes}; ray.RespectCanCollide = true
local nextIndex: number? = nil
local highlight = Instance.new("Highlight"); highlight.Name = "NextObbyLanding"
highlight.FillTransparency = 1; highlight.OutlineColor = Color3.fromRGB(240, 224, 191)
highlight.DepthMode = Enum.HighlightDepthMode.Occluded; highlight.Enabled = false; highlight.Parent = course
local marker = Instance.new("BillboardGui"); marker.Name = "ObbyRouteMarker"
marker.Size = UDim2.fromOffset(66, 24); marker.StudsOffsetWorldSpace = Vector3.new(0, 3, 0)
marker.MaxDistance = 70; marker.Enabled = false; marker.Parent = player:WaitForChild("PlayerGui")
local markerText = Instance.new("TextLabel"); markerText.Size = UDim2.fromScale(1, 1)
markerText.BackgroundColor3 = Color3.fromRGB(53, 65, 66); markerText.BackgroundTransparency = 0.1
markerText.TextColor3 = Color3.fromRGB(240, 224, 191); markerText.TextSize = 12
markerText.Font = Enum.Font.GothamBold; markerText.Text = "NEXT"; markerText.Parent = marker
ReplicatedStorage:WaitForChild("CityRemotes"):WaitForChild("State").OnClientEvent:Connect(function(data)
	nextIndex = data.Active and data.Id == "Obby" and math.min(data.Progress + 1, #Config.Nodes) or nil
	local target = nextIndex and nodes:FindFirstChild("Node_" .. nextIndex) :: BasePart?
	highlight.Adornee = target; highlight.Enabled = target ~= nil
	marker.Adornee = target; marker.Enabled = target ~= nil
end)

RunService.PreSimulation:Connect(function(dt)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not root or (root.Position - Config.Origin).Magnitude > 210 then return end
	local now = Workspace:GetServerTimeNow()
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local riding: BasePart? = nil
	local groundedState = humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Running or humanoid:GetState() == Enum.HumanoidStateType.Landed)
	if humanoid and groundedState and humanoid.FloorMaterial ~= Enum.Material.Air and root.AssemblyLinearVelocity.Y < 3 and not humanoid.Jump then
		local hit = Workspace:Raycast(root.Position, Vector3.new(0, -4, 0), ray)
		if hit and hit.Instance:GetAttribute("MovingDeck") then riding = hit.Instance end
	end
	for _, definition in Config.Movers do
		local deck = nodes:FindFirstChild("Node_" .. definition.Node) :: BasePart?
		if not deck then continue end
		local cf = Motion.Deck(definition, now)
		if riding == deck and dt < 0.2 and character then
			-- Translational decks carry a standing/walking rider but never pull a
			-- jumping player back down. No client route/reward messages are sent.
			local previous = Motion.Deck(definition, now - dt)
			character:PivotTo(character:GetPivot() + (cf.Position - previous.Position))
		end
		deck.CFrame = cf
	end
	for i = 1, 3 do
		local arm = course:FindFirstChild("Rotor_" .. i) :: BasePart?
		if arm then arm.CFrame = CFrame.new(arm:GetAttribute("RotorOrigin")) * CFrame.Angles(0, Motion.RotorAngle(arm:GetAttribute("RotorSpeed"), now), 0) end
	end
	for _, index in Config.FadeNodes do
		local node = nodes:FindFirstChild("Node_" .. index) :: BasePart?
		if node then
			local phase = Motion.Fade(index, now)
			node.CanCollide = phase ~= "Gone"; node.CanQuery = node.CanCollide
			node.Transparency = phase == "Gone" and 0.87 or 0
			node.Color = phase == "Warning" and Color3.fromRGB(203, 169, 106) or Color3.fromRGB(92, 143, 159)
			if nextIndex == index then markerText.Text = phase == "Solid" and "NEXT" or "WAIT" end
		end
	end
	if nextIndex and not table.find(Config.FadeNodes, nextIndex) then markerText.Text = "NEXT" end
end)
