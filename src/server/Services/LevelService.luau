--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameConfig = require(ReplicatedStorage.Shared.Config.GameConfig)

local LevelService = {}

local function xpRequiredForLevel(level: number): number
	return math.floor(100 * (level ^ 1.35))
end

local function applyMovementSpeed(player: Player)
	local level = player:GetAttribute("Level") or 1
	local speedBonus = math.min(
		(level - 1) * GameConfig.SpeedBonusPerLevel,
		GameConfig.MaxSpeedBonus
	)

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = GameConfig.BaseWalkSpeed * (1 + speedBonus)
	end
end

local function updateLevel(player: Player)
	local xp = player:GetAttribute("XP") or 0
	local level = player:GetAttribute("Level") or 1

	while level < GameConfig.MaxPlayerLevel and xp >= xpRequiredForLevel(level) do
		xp -= xpRequiredForLevel(level)
		level += 1
	end

	player:SetAttribute("XP", xp)
	player:SetAttribute("Level", level)
	applyMovementSpeed(player)
end

function LevelService.AddXP(player: Player, amount: number)
	if amount <= 0 then
		return
	end

	player:SetAttribute("XP", (player:GetAttribute("XP") or 0) + amount)
	updateLevel(player)
end

function LevelService.Init()
	Players.PlayerAdded:Connect(function(player)
		player:SetAttribute("Level", 1)
		player:SetAttribute("XP", 0)
		player:SetAttribute("FieldXP", 0)

		player.CharacterAdded:Connect(function()
			applyMovementSpeed(player)
		end)
	end)
end

return LevelService

