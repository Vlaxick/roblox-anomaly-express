--!strict

local LevelService = require(script.Parent.Services.LevelService)
local WorldService = require(script.Parent.Services.WorldService)
local PlotService = require(script.Parent.Services.PlotService)
local CityService = require(script.Parent.Services.CityService)

LevelService.Init()
WorldService.Init()
PlotService.Init()
CityService.Init()

print("Anomaly Express server started")

