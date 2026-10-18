--!strict

local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Presentation = {}
local labels: {[BillboardGui]: {RBXScriptConnection}} = {}
local shown: {[ProximityPrompt]: boolean} = {}
local modalOpen = false
local previousPromptEnabled = true
local previousPlayerListEnabled: boolean? = nil
local initialized = false

local function refresh(label: BillboardGui)
	local anchor = label.Parent
	local prompt = anchor and anchor:FindFirstChild("StandPrompt")
	local hasPrompt = prompt ~= nil and prompt:IsA("ProximityPrompt") and shown[prompt] == true
	-- Distant information OR a nearby action, never both in the same screen space.
	label.Enabled = label:GetAttribute("VisibleAtRest") == true and not modalOpen and not hasPrompt
end
local function refreshAll()
	for label in labels do refresh(label) end
end
local function register(instance: Instance)
	if not instance:IsA("BillboardGui") or instance.Name ~= "StandLabel" or labels[instance] then return end
	local connections = {}
	labels[instance] = connections
	table.insert(connections, instance:GetAttributeChangedSignal("VisibleAtRest"):Connect(function() refresh(instance) end))
	table.insert(connections, instance.Destroying:Connect(function()
		for _, connection in connections do connection:Disconnect() end
		labels[instance] = nil
	end))
	refresh(instance)
end
local function promptVisibility(prompt: ProximityPrompt, visible: boolean)
	if prompt.Name ~= "StandPrompt" then return end
	if visible then shown[prompt] = true else shown[prompt] = nil end
	local anchor = prompt.Parent
	local label = anchor and anchor:FindFirstChild("StandLabel")
	if label and label:IsA("BillboardGui") then refresh(label) end
end

function Presentation.SetModalOpen(open: boolean)
	if modalOpen == open then return end
	modalOpen = open
	if open then
		previousPromptEnabled = ProximityPromptService.Enabled
		ProximityPromptService.Enabled = false
		-- Roblox's floating player list can cover the catalogue's close control
		-- in narrow landscape viewports. Restore the player's prior state on exit.
		pcall(function()
			previousPlayerListEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end)
	else
		ProximityPromptService.Enabled = previousPromptEnabled
		local enabled = previousPlayerListEnabled
		if enabled ~= nil then
			pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, enabled) end)
		end
		previousPlayerListEnabled = nil
	end
	refreshAll()
end

function Presentation.Init()
	if initialized then return end
	initialized = true
	ProximityPromptService.PromptShown:Connect(function(prompt) promptVisibility(prompt, true) end)
	ProximityPromptService.PromptHidden:Connect(function(prompt) promptVisibility(prompt, false) end)
	Workspace.DescendantAdded:Connect(register)
	Workspace.DescendantRemoving:Connect(function(instance)
		if instance:IsA("ProximityPrompt") and shown[instance] then
			promptVisibility(instance, false)
		end
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function()
		table.clear(shown)
		refreshAll()
	end)
	for _, instance in Workspace:GetDescendants() do register(instance) end
end

return Presentation
