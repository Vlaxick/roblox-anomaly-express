--!strict

local LevelService = require(script.Parent.Services.LevelService)
local WorldService = require(script.Parent.Services.WorldService)
local PlotService = require(script.Parent.Services.PlotService)

LevelService.Init()
WorldService.Init()
PlotService.Init()

print("Anomaly Express server started")

