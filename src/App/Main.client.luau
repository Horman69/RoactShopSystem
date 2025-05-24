local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Roact = require(Packages:WaitForChild("roact"))

local SimpleButton = require(script.Parent:WaitForChild("SimpleButton"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

Roact.mount(Roact.createElement(SimpleButton), playerGui, "SimpleButton")
