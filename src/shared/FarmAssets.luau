--!strict

local Theme = require(script.Parent.Config.Theme)
local Assets = {}

function Assets.Part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, collide: boolean?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = collide == true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function ball(parent: Instance, name: string, size: Vector3, pos: Vector3, color: Color3): Part
	local p = Assets.Part(parent, name, size, CFrame.new(pos), color)
	p.Shape = Enum.PartType.Ball
	return p
end

local function branch(parent: Instance, from: Vector3, to: Vector3, thickness: number)
	local p = Assets.Part(parent, "Branch", Vector3.new(thickness, thickness, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), Theme.Wood, Enum.Material.Wood)
	return p
end

local function pumpkin(parent: Instance, origin: Vector3, scale: number)
	ball(parent, "PumpkinBody", Vector3.new(4, 3.3, 4) * scale, origin + Vector3.new(0, 1.65, 0) * scale, Theme.Pumpkin)
	for rib = 1, 7 do
		local angle = rib * math.pi * 2 / 7
		local pos = origin + Vector3.new(math.cos(angle) * 1.1, 1.65, math.sin(angle) * 1.1) * scale
		ball(parent, "PumpkinRib", Vector3.new(2.1, 3.25, 2.1) * scale, pos, rib % 2 == 0 and Theme.Pumpkin or Theme.Pumpkin:Lerp(Theme.Harvest, 0.13))
	end
	Assets.Part(parent, "Stem", Vector3.new(0.55, 1.2, 0.55) * scale, CFrame.new(origin + Vector3.new(0, 3.7, 0) * scale) * CFrame.Angles(0, 0, 0.25), Theme.Moss, Enum.Material.Wood)
	local leaf = ball(parent, "Leaf", Vector3.new(2, 0.3, 1) * scale, origin + Vector3.new(1, 3.35, 0.2) * scale, Theme.Green)
	leaf.CFrame *= CFrame.Angles(0, 0.5, 0.2)
end

local function mushroom(parent: Instance, origin: Vector3, scale: number)
	Assets.Part(parent, "Stalk", Vector3.new(1, 3, 1) * scale, CFrame.new(origin + Vector3.new(0, 1.5, 0) * scale), Theme.Paper)
	ball(parent, "CapUnder", Vector3.new(4.1, 0.65, 4.1) * scale, origin + Vector3.new(0, 2.7, 0) * scale, Theme.Panel)
	ball(parent, "MushroomCap", Vector3.new(4.8, 2, 4.8) * scale, origin + Vector3.new(0, 3.25, 0) * scale, Theme.Barn)
	for dot = 1, 6 do
		local angle = dot * math.pi * 2 / 6
		ball(parent, "CapSpot", Vector3.new(0.6, 0.15, 0.6) * scale, origin + Vector3.new(math.cos(angle) * 1.35, 4.05, math.sin(angle) * 1.35) * scale, Theme.Paper)
	end
	ball(parent, "CapSpot", Vector3.new(0.75, 0.16, 0.75) * scale, origin + Vector3.new(0, 4.25, 0) * scale, Theme.Paper)
end

function Assets.Crop(id: string, at: Vector3): Model
	local model = Instance.new("Model")
	model.Name = "Crop"
	if id == "Pumpkin" then
		pumpkin(model, Vector3.new(-1.9, 0, 0), 1)
		pumpkin(model, Vector3.new(2.6, 0, 1), 0.65)
		ball(model, "Vine", Vector3.new(8, 0.25, 2), Vector3.new(0, 0.2, 1), Theme.Green)
	elseif id == "ForestMushroom" then
		mushroom(model, Vector3.new(-1.5, 0, 0), 1.2)
		mushroom(model, Vector3.new(2.4, 0, 1.5), 0.7)
		mushroom(model, Vector3.new(1.8, 0, -2), 0.5)
	else
		branch(model, Vector3.zero, Vector3.new(0, 6.5, 0), 1.4)
		branch(model, Vector3.new(0, 3.5, 0), Vector3.new(-2.7, 7, 0), 0.65)
		branch(model, Vector3.new(0, 4, 0), Vector3.new(2.8, 7.4, 1), 0.65)
		for _, crown in {Vector3.new(-2.8, 7, 0), Vector3.new(2.5, 7.3, 0.5), Vector3.new(0, 9, -0.6), Vector3.new(0, 7.4, 2)} do
			ball(model, "GoldenLeaves", Vector3.new(5.5, 4.7, 5), crown, Theme.Harvest)
		end
		for fruit = 1, 7 do
			local angle = fruit * math.pi * 2 / 7
			ball(model, "Apple", Vector3.new(0.9, 0.9, 0.9), Vector3.new(math.cos(angle) * 3.9, 6.5 + (fruit % 2), math.sin(angle) * 2.7), Theme.Barn)
		end
	end
	model.WorldPivot = CFrame.new()
	model:PivotTo(CFrame.new(at))
	return model
end

function Assets.Tree(parent: Instance, at: Vector3, scale: number, color: Color3)
	local model = Instance.new("Model")
	model.Name = "AutumnMaple"
	model.Parent = parent
	branch(model, at, at + Vector3.new(0, 9, 0) * scale, 1.8 * scale)
	for branchIndex = 1, 5 do
		local angle = branchIndex * math.pi * 2 / 5
		local center = at + Vector3.new(math.cos(angle) * 3.7, 10 + branchIndex % 2 * 2, math.sin(angle) * 3.7) * scale
		branch(model, at + Vector3.new(0, 5, 0) * scale, center, 0.8 * scale)
		ball(model, "AutumnLeaves", Vector3.new(8, 7, 8) * scale, center, color:Lerp(Theme.Harvest, (branchIndex % 3) * 0.12))
	end
end

function Assets.Sign(anchor: BasePart, title: string, detail: string?)
	local surface = Instance.new("SurfaceGui")
	surface.Face = Enum.NormalId.Back
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 35
	surface.LightInfluence = 0.2
	surface.Parent = anchor
	local heading = Instance.new("TextLabel")
	heading.BackgroundTransparency = 1
	heading.Position = UDim2.fromScale(0.05, 0.1)
	heading.Size = UDim2.fromScale(0.9, detail and 0.5 or 0.8)
	heading.Font = Enum.Font.FredokaOne
	heading.TextScaled = true
	heading.TextColor3 = Theme.Paper
	heading.Text = title
	heading.Parent = surface
	if detail then
		local sub = heading:Clone()
		sub.Position = UDim2.fromScale(0.06, 0.65)
		sub.Size = UDim2.fromScale(0.88, 0.23)
		sub.Font = Enum.Font.GothamMedium
		sub.Text = detail
		sub.Parent = surface
	end
	return heading
end

return Assets
