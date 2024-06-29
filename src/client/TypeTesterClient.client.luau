local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UI = PlayerGui:WaitForChild("UI")

local TypeTester = require(ReplicatedStorage.Modules.TypeTesterModule)

local new = TypeTester.new(UI)
new:Init()
print(new.currentWords, new.currentLetters, new.currentWordsLength)

