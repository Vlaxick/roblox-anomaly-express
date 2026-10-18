--!strict

local Base = require(script.Parent.FarmAssets)
local Catalog = require(script.Parent.Config.Finds)
local Assets = {}

-- Expedition materials, deliberately independent of the autumn/Halloween theme.
local ink = Color3.fromRGB(53, 63, 74)
local brass = Color3.fromRGB(203, 169, 106)
local sage = Color3.fromRGB(113, 148, 119)
local blue = Color3.fromRGB(92, 143, 159)
local cream = Color3.fromRGB(232, 228, 217)
local stone = Color3.fromRGB(120, 135, 135)

local function part(m: Instance, name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material?): Part
	return Base.Part(m, name, size, CFrame.new(at), color, material)
end
local function ball(m: Instance, name: string, size: Vector3, at: Vector3, color: Color3, material: Enum.Material?): Part
	local p = part(m, name, size, at, color, material)
	p.Shape = Enum.PartType.Ball
	return p
end
local function rod(m: Instance, name: string, from: Vector3, to: Vector3, width: number, color: Color3)
	return Base.Part(m, name, Vector3.new(width, width, (to - from).Magnitude), CFrame.lookAt((from + to) / 2, to), color, Enum.Material.Metal)
end
local function disc(m: Instance, name: string, radius: number, depth: number, at: Vector3, color: Color3, front: boolean?): Part
	local p = part(m, name, Vector3.new(depth, radius * 2, radius * 2), at, color, Enum.Material.Metal)
	p.Shape = Enum.PartType.Cylinder
	p.CFrame *= front and CFrame.Angles(0, math.pi / 2, 0) or CFrame.Angles(0, 0, math.pi / 2)
	return p
end
local function ring(m: Instance, name: string, at: Vector3, radius: number, width: number, color: Color3, rotation: CFrame?)
	local cf = CFrame.new(at) * (rotation or CFrame.new())
	for i = 1, 16 do
		local a, b = (i - 1) * math.pi / 8, i * math.pi / 8
		rod(m, name, cf:PointToWorldSpace(Vector3.new(math.cos(a), 0, math.sin(a)) * radius), cf:PointToWorldSpace(Vector3.new(math.cos(b), 0, math.sin(b)) * radius), width, color)
	end
end
local function wedge(m: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): WedgePart
	local p = Instance.new("WedgePart")
	p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
	p.Material = Enum.Material.SmoothPlastic; p.Anchored = true; p.CanCollide = false; p.Parent = m
	return p
end
local function crystal(m: Instance, at: Vector3, size: number, color: Color3)
	local facet = Instance.new("CornerWedgePart")
	facet.Name = "CrystalFacet"
	facet.Size = Vector3.new(size, size * 2, size)
	facet.CFrame = CFrame.new(at) * CFrame.Angles(0, math.pi / 4, -0.12)
	facet.Color = color; facet.Material = Enum.Material.SmoothPlastic
	facet.Anchored = true; facet.CanCollide = false; facet.Parent = m
end
local function eyes(m: Instance, at: Vector3, spacing: number)
	for _, side in {-1, 1} do
		ball(m, "EyeWhite", Vector3.new(0.62, 0.75, 0.2), at + Vector3.new(side * spacing, 0, 0), cream)
		ball(m, "Pupil", Vector3.new(0.29, 0.42, 0.14), at + Vector3.new(side * spacing, -0.02, 0.14), ink)
		ball(m, "Catchlight", Vector3.new(0.09, 0.1, 0.07), at + Vector3.new(side * spacing - 0.06, 0.09, 0.22), cream)
	end
end
local function finish(m: Model, id: string, at: Vector3): Model
	m.Name = id; m.WorldPivot = CFrame.new(); m:PivotTo(CFrame.new(at))
	return m
end
local function eventAssets()
	-- Event art remains renderable for already-owned residents, even when new
	-- event finds are unavailable. Never use this to decide acquisition eligibility.
	return require(script.Parent.EventAssets.HalloweenAssets)
end

function Assets.Container(id: string, at: Vector3): Model
	if Catalog.FindCollectionById[id] == "Halloween" then return eventAssets().Container(id, at) end
	local m = Instance.new("Model")
	if id == "TravelCase" then
		ball(m, "CanvasCase", Vector3.new(5.7, 3.7, 3.3), Vector3.new(0, 2, 0), blue)
		ball(m, "LeatherFlap", Vector3.new(5.4, 1.3, 3.35), Vector3.new(0, 3.1, 0.1), ink)
		for _, side in {-1, 1} do
			part(m, "TravelStrap", Vector3.new(0.5, 3.1, 0.16), Vector3.new(side * 1.7, 2, 1.68), brass)
			part(m, "Buckle", Vector3.new(0.78, 0.6, 0.2), Vector3.new(side * 1.7, 2.3, 1.8), cream, Enum.Material.Metal)
		end
		ring(m, "CarryHandle", Vector3.new(0, 4, 0), 0.75, 0.23, ink, CFrame.Angles(math.pi / 2, 0, 0))
		local ticket = part(m, "StationTicket", Vector3.new(1, 1.6, 0.13), Vector3.new(2, 3, 1.76), cream)
		ticket.CFrame *= CFrame.Angles(0, 0, -0.17)
		part(m, "TicketMark", Vector3.new(0.65, 0.18, 0.15), Vector3.new(2, 3, 1.85), blue)
	elseif id == "TrailCapsule" then
		disc(m, "CapsuleFoot", 2.3, 0.45, Vector3.new(0, 0.35, 0), ink)
		ball(m, "EnamelShell", Vector3.new(4.5, 5.7, 4.2), Vector3.new(0, 3.2, 0), sage)
		for _, y in {1.3, 4.8} do ring(m, "ReinforcingBand", Vector3.new(0, y, 0), 1.9, 0.23, brass) end
		disc(m, "RoundHatch", 1.3, 0.25, Vector3.new(0, 3.2, 2.05), ink, true)
		disc(m, "HatchFace", 1, 0.28, Vector3.new(0, 3.2, 2.2), cream, true)
		for _, angle in {0, math.pi / 2} do
			local lock = part(m, "HatchLatch", Vector3.new(1.5, 0.23, 0.2), Vector3.new(0, 3.2, 2.4), brass)
			lock.CFrame *= CFrame.Angles(0, 0, angle)
		end
		ring(m, "CapsuleHandle", Vector3.new(0, 6.2, 0), 0.6, 0.23, ink, CFrame.Angles(math.pi / 2, 0, 0))
	elseif id == "PrismGeode" then
		ball(m, "SealedStone", Vector3.new(5.3, 5.3, 4.8), Vector3.new(0, 2.8, 0), stone, Enum.Material.Slate)
		for i = 1, 6 do
			local a = i * math.pi / 3
			local p = part(m, "RockFacet", Vector3.new(2.6, 2.8, 3.7), Vector3.new(math.cos(a) * 1.3, 2.7 + math.sin(a) * 1.4, 0), stone:Lerp(ink, i % 3 * 0.12), Enum.Material.Slate)
			p.CFrame *= CFrame.Angles(0, 0, a)
		end
		for _, p in {Vector3.new(-1.8, 3.6, 1.5), Vector3.new(0, 4.5, 1.1), Vector3.new(1.6, 2.7, 1.9)} do crystal(m, p, 0.8, blue) end
		ring(m, "GeodeBinding", Vector3.new(0, 2.8, 0), 2.8, 0.26, brass, CFrame.Angles(math.pi / 2, 0, 0))
		disc(m, "SurveySeal", 0.55, 0.2, Vector3.new(0, 2.1, 2.6), brass, true)
	elseif id == "AtlasSphere" then
		for i = 1, 3 do
			local a = i * math.pi * 2 / 3
			rod(m, "TripodLeg", Vector3.new(0, 1.8, 0), Vector3.new(math.cos(a) * 2.5, 0.2, math.sin(a) * 2.5), 0.4, ink)
		end
		ball(m, "SealedGlobe", Vector3.new(4.4, 4.4, 4.4), Vector3.new(0, 4.1, 0), blue)
		for _, r in {CFrame.new(), CFrame.Angles(math.pi / 2, 0, 0), CFrame.Angles(0, 0, math.pi / 3)} do ring(m, "NavigationRing", Vector3.new(0, 4.1, 0), 2.7, 0.23, brass, r) end
		for i = 1, 7 do
			local a = i * math.pi / 4
			ball(m, "ConstellationPoint", Vector3.new(0.28, 0.28, 0.18), Vector3.new(math.cos(a) * 1.4, 4.1 + math.sin(a) * 1.4, 1.8), cream)
		end
		disc(m, "AtlasSeal", 0.55, 0.2, Vector3.new(0, 4.1, 2.25), brass, true)
	else
		error("Unknown container: " .. id)
	end
	return finish(m, id, at)
end

function Assets.Character(id: string, at: Vector3): Model
	if Catalog.CharacterCollectionById[id] == "Halloween" then return eventAssets().Character(id, at) end
	local m = Instance.new("Model")
	if id == "Scrapling" then
		part(m, "ToolBody", Vector3.new(2.4, 2.4, 1.8), Vector3.new(0, 2.3, 0), blue, Enum.Material.Metal)
		part(m, "RobotHead", Vector3.new(2.8, 1.8, 1.8), Vector3.new(0, 4.3, 0), cream, Enum.Material.Metal)
		for _, side in {-1, 1} do
			ball(m, "Joint", Vector3.new(0.7, 0.7, 0.7), Vector3.new(side * 1.5, 3, 0), brass)
			rod(m, "Arm", Vector3.new(side * 1.5, 3, 0), Vector3.new(side * 2.1, 2, 0.3), 0.35, ink)
			part(m, "Hand", Vector3.new(0.7, 0.65, 0.65), Vector3.new(side * 2.1, 2, 0.3), cream)
			part(m, "Boot", Vector3.new(1.1, 0.7, 1.5), Vector3.new(side * 0.75, 0.4, 0.3), ink)
			rod(m, "Shin", Vector3.new(side * 0.75, 0.7, 0), Vector3.new(side * 0.75, 1.3, 0), 0.4, brass)
			disc(m, "GoggleRim", 0.57, 0.2, Vector3.new(side * 0.7, 4.4, 0.95), brass, true)
		end
		eyes(m, Vector3.new(0, 4.4, 1.1), 0.7)
		part(m, "Smile", Vector3.new(0.75, 0.13, 0.13), Vector3.new(0, 3.8, 1), ink)
		rod(m, "Antenna", Vector3.new(0.7, 5.2, 0), Vector3.new(1, 5.8, 0), 0.13, brass)
		ball(m, "AntennaTip", Vector3.new(0.35, 0.35, 0.35), Vector3.new(1, 5.8, 0), blue)
		part(m, "ToolPocket", Vector3.new(1.2, 0.9, 0.2), Vector3.new(0, 2.1, 1), brass)
	elseif id == "Pebble" then
		ball(m, "PebbleBody", Vector3.new(3.7, 3.7, 3.1), Vector3.new(0, 2.5, 0), stone, Enum.Material.Slate)
		for _, side in {-1, 1} do
			ball(m, "StoneFoot", Vector3.new(1.4, 0.9, 1.8), Vector3.new(side * 1, 0.5, 0.4), ink, Enum.Material.Slate)
			ball(m, "StoneHand", Vector3.new(1.1, 1.1, 1), Vector3.new(side * 2, 2.2, 0.3), stone, Enum.Material.Slate)
		end
		eyes(m, Vector3.new(0, 2.8, 1.5), 0.7)
		part(m, "Smile", Vector3.new(0.8, 0.15, 0.14), Vector3.new(0, 2, 1.55), ink)
		for _, x in {-0.8, 0, 0.8} do crystal(m, Vector3.new(x, 4.3 + (x == 0 and 0.3 or 0), 0), 0.4, cream) end
	elseif id == "MossTurtle" then
		ball(m, "Shell", Vector3.new(5.6, 3.3, 4.8), Vector3.new(0, 2.1, -0.4), stone, Enum.Material.Slate)
		ball(m, "ShellRim", Vector3.new(5.8, 0.7, 4.9), Vector3.new(0, 1.25, -0.4), brass)
		for _, side in {-1, 1} do
			for _, z in {-1.6, 1.3} do ball(m, "TurtleLeg", Vector3.new(1.4, 1.2, 1.6), Vector3.new(side * 2.1, 0.7, z), sage) end
		end
		ball(m, "TurtleHead", Vector3.new(2.5, 2, 2.4), Vector3.new(0, 1.7, 2.5), sage)
		eyes(m, Vector3.new(0, 1.9, 3.65), 0.55)
		for i = 1, 6 do
			local a = i * math.pi / 3
			ball(m, "MossPatch", Vector3.new(1.9, 0.4, 1.8), Vector3.new(math.cos(a) * 1.3, 3.4, -0.4 + math.sin(a)), sage)
		end
		ball(m, "MossCrown", Vector3.new(2, 0.5, 2), Vector3.new(0, 3.8, -0.4), sage:Lerp(cream, 0.15))
	elseif id == "CourierBird" then
		ball(m, "BirdBody", Vector3.new(3.1, 3.4, 2.6), Vector3.new(0, 2.6, 0), blue)
		ball(m, "BirdHead", Vector3.new(2.8, 2.5, 2.5), Vector3.new(0, 4.8, 0.2), blue)
		ball(m, "BirdBib", Vector3.new(2.2, 2.4, 0.35), Vector3.new(0, 2.7, 1.18), cream)
		for _, side in {-1, 1} do
			local wing = ball(m, "Wing", Vector3.new(1.25, 2.9, 2.2), Vector3.new(side * 1.5, 2.9, 0), blue:Lerp(ink, 0.25))
			wing.CFrame *= CFrame.Angles(0, 0, side * 0.2)
			rod(m, "BirdLeg", Vector3.new(side * 0.7, 1.1, 0), Vector3.new(side * 0.7, 0.35, 0.3), 0.2, brass)
			ball(m, "BirdFoot", Vector3.new(0.8, 0.3, 1.3), Vector3.new(side * 0.7, 0.2, 0.5), brass)
		end
		eyes(m, Vector3.new(0, 5, 1.4), 0.6)
		ball(m, "Beak", Vector3.new(0.8, 0.55, 1.2), Vector3.new(0, 4.45, 1.55), brass)
		disc(m, "PostCap", 1.5, 0.45, Vector3.new(0, 6, 0.1), ink)
		part(m, "CapVisor", Vector3.new(2.2, 0.2, 1.6), Vector3.new(0, 5.95, 1.1), ink)
		local strap = part(m, "MailStrap", Vector3.new(0.3, 3.7, 0.2), Vector3.new(0, 3.2, 1.5), brass)
		strap.CFrame *= CFrame.Angles(0, 0, -0.6)
		part(m, "MailBag", Vector3.new(1.5, 1.3, 0.6), Vector3.new(1.5, 2.2, 1), brass)
		part(m, "Letter", Vector3.new(0.9, 0.65, 0.1), Vector3.new(1.5, 2.5, 1.35), cream)
	elseif id == "PrismFox" then
		ball(m, "FoxBody", Vector3.new(3.1, 2.5, 3.9), Vector3.new(0, 2.3, -0.3), blue)
		ball(m, "FoxHead", Vector3.new(3, 2.7, 2.6), Vector3.new(0, 4.1, 1), blue:Lerp(cream, 0.15))
		for _, side in {-1, 1} do
			for _, z in {-1.3, 1.2} do part(m, "CrystalPaw", Vector3.new(0.9, 1.4, 1.3), Vector3.new(side, 0.75, z), cream) end
			wedge(m, "FoxEar", Vector3.new(0.8, 1.8, 1.3), CFrame.new(side * 1.05, 5.7, 0.9) * CFrame.Angles(0, side * math.pi / 2, 0), blue)
			crystal(m, Vector3.new(side * 1.4, 2.8, -0.6), 0.65, blue:Lerp(cream, 0.3))
		end
		eyes(m, Vector3.new(0, 4.35, 2.25), 0.65)
		ball(m, "FoxMuzzle", Vector3.new(1.8, 1, 1.2), Vector3.new(0, 3.65, 2.25), cream)
		ball(m, "FoxNose", Vector3.new(0.5, 0.35, 0.3), Vector3.new(0, 3.9, 2.8), ink)
		local tail = part(m, "PrismTail", Vector3.new(1.7, 1.7, 3.7), Vector3.new(1.3, 2.8, -2.7), blue)
		tail.CFrame *= CFrame.Angles(-0.5, -0.35, 0.25)
		crystal(m, Vector3.new(2, 3.7, -3.8), 0.75, cream)
	elseif id == "AtlasGolem" then
		part(m, "AtlasTorso", Vector3.new(3.5, 3.4, 2.4), Vector3.new(0, 3.5, 0), stone, Enum.Material.Slate)
		part(m, "AtlasHead", Vector3.new(2.9, 2.2, 2.2), Vector3.new(0, 6.2, 0), stone, Enum.Material.Slate)
		part(m, "FacePlate", Vector3.new(2.3, 1.4, 0.2), Vector3.new(0, 6.1, 1.2), cream)
		eyes(m, Vector3.new(0, 6.25, 1.35), 0.55)
		for _, side in {-1, 1} do
			ball(m, "ShoulderJoint", Vector3.new(1.2, 1.2, 1.2), Vector3.new(side * 2.2, 4.5, 0), brass)
			local arm = part(m, "AtlasArm", Vector3.new(1.5, 2.9, 1.6), Vector3.new(side * 2.6, 3.3, 0.2), stone, Enum.Material.Slate)
			arm.CFrame *= CFrame.Angles(0, 0, side * 0.15)
			part(m, "AtlasLeg", Vector3.new(1.3, 1.5, 1.5), Vector3.new(side * 1, 1.2, 0), ink, Enum.Material.Slate)
			part(m, "AtlasFoot", Vector3.new(1.6, 0.6, 2.2), Vector3.new(side * 1, 0.35, 0.4), stone, Enum.Material.Slate)
		end
		disc(m, "CompassRim", 1.15, 0.2, Vector3.new(0, 3.6, 1.3), brass, true)
		disc(m, "CompassFace", 0.9, 0.21, Vector3.new(0, 3.6, 1.45), cream, true)
		wedge(m, "CompassNeedle", Vector3.new(0.2, 1.4, 0.55), CFrame.new(0, 3.7, 1.65) * CFrame.Angles(0, math.pi / 2, -0.3), blue)
	elseif id == "StarRay" then
		ball(m, "RayBody", Vector3.new(3.1, 1.9, 4.8), Vector3.new(0, 2.6, 0), blue:Lerp(ink, 0.2))
		for _, side in {-1, 1} do
			-- Rotate the triangular cross-section into the horizontal plane:
			-- a ray's swept wing, not a thick rectangular arm facing the camera.
			wedge(m, "RayWing", Vector3.new(0.35, 5.2, 4.5), CFrame.new(side * 2.4, 2.55, -0.3) * CFrame.Angles(0, side * 0.16, 0) * CFrame.Angles(0, 0, -side * math.pi / 2), blue)
			ball(m, "WingRoot", Vector3.new(2, 0.45, 3.5), Vector3.new(side * 1.5, 2.65, -0.1), blue)
		end
		eyes(m, Vector3.new(0, 2.8, 2.3), 0.65)
		rod(m, "RayTail", Vector3.new(0, 2.6, -2), Vector3.new(0, 2, -5), 0.3, blue)
		rod(m, "RayTailTip", Vector3.new(0, 2, -5), Vector3.new(0.8, 3, -6), 0.23, brass)
		local points = {Vector3.new(-1, 3.5, 0.2), Vector3.new(0.3, 3.55, -0.7), Vector3.new(1, 3.3, 0.8)}
		for i, p in points do
			ball(m, "StarSpot", Vector3.new(0.3, 0.15, 0.3), p, brass)
			if i > 1 then rod(m, "ConstellationLine", points[i - 1], p, 0.07, cream) end
		end
	elseif id == "CloudWhale" then
		ball(m, "WhaleBody", Vector3.new(5.8, 3.9, 5.1), Vector3.new(0, 3.1, 0), blue:Lerp(cream, 0.35))
		ball(m, "WhaleBelly", Vector3.new(5.5, 1.6, 4.9), Vector3.new(0, 2.1, 0.1), cream)
		for _, side in {-1, 1} do
			local fin = ball(m, "WhaleFin", Vector3.new(2.5, 0.6, 2.1), Vector3.new(side * 3.2, 2.6, 0), blue)
			fin.CFrame *= CFrame.Angles(0, 0, side * 0.3)
			local tail = ball(m, "WhaleFluke", Vector3.new(2.8, 0.65, 1.6), Vector3.new(side * 1.1, 3.5, -3.6), blue)
			tail.CFrame *= CFrame.Angles(0, side * 0.4, 0)
		end
		ball(m, "WhaleTail", Vector3.new(2.3, 1.7, 2.6), Vector3.new(0, 3.1, -2.8), blue)
		eyes(m, Vector3.new(0, 3.4, 2.45), 1)
		part(m, "WhaleSmile", Vector3.new(1.2, 0.13, 0.1), Vector3.new(0, 2.65, 2.55), ink)
		for _, offset in {Vector3.new(0, 5.4, 0), Vector3.new(-0.55, 6.1, 0), Vector3.new(0.55, 6.2, 0)} do ball(m, "CloudSpout", Vector3.new(1.2, 1, 1.1), offset, cream) end
		ring(m, "NavigatorBand", Vector3.new(0, 3.1, 0), 2.7, 0.18, brass, CFrame.Angles(math.pi / 2, 0, 0))
	else
		error("Unknown character: " .. id)
	end
	return finish(m, id, at)
end

return Assets
