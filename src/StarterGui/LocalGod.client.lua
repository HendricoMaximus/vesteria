-- GUI initialization framework by berezaa
-- Will automatically scan and require ModuleScripts in the parented GUI object.
-- Any module with module.init(Modules) defined will be initialization

local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui

repeat wait() until playerGui:FindFirstChild("gameUI")

local ui = playerGui.gameUI
ui.Enabled = false

local Modules = {}
local currentProcess = "setup"

-- wait(0.1)

--[[
local replicatedStorage = game:GetService("ReplicatedStorage")
local modules = require(replicatedStorage.modules)
]]

--game.StarterGui:SetCore("TopbarEnabled", false)
playerGui:SetTopbarTransparency(1)

local replicatedStorage = game:GetService("ReplicatedStorage")
local mods = require(replicatedStorage.modules)

local Libs = {
	"network", "utilities","levels","tween","ability_utilities", "mapping",
	"placeSetup", "projectile", "configuration", "economy", "events", "enchantment",
	"localization"
}

local Ignore = {}
local currentModule

local function AddModule(Ins)
	local Success, Error = pcall(function()
		Modules[Ins.Name] = require(Ins)
	end)
end

local function scan(Ins)
	if Ins:IsA("ModuleScript") then
		currentModule = Ins.Name
		AddModule(Ins)
	end
	for i,Child in pairs(Ins:GetChildren()) do
		scan(Child)
	end
end

local function Init()
	currentProcess = "requiring"
	Modules.HasFinished = false
	scan(script.Parent)

	for _, lib in pairs(Libs) do
		Modules[lib] = mods.load(lib)
		Ignore[lib] = true
	end

	local postInits = {}

	for Name,Module in pairs(Modules) do
		if Module and Ignore[Name] == nil and Module["init"] then
			currentProcess = "init"
			currentModule = Name
			Module.init(Modules)
		end
		if Module and Ignore[Name] == nil and Module["postInit"] then
			postInits[Name] = Module["postInit"]
		end
	end

	for moduleName,postInit in pairs(postInits) do
		currentProcess = "postinit"
		currentModule = moduleName
		postInit(Modules)
	end

	Modules.HasFinished = true

	print("------------------------------------------------------------")
	print("If you see any errors BELOW THIS POINT, please report them to the dev.")
	print("-----------------------------------------------------------")
end

local startTime = tick()

spawn(Init)

repeat wait() until Modules.HasFinished or tick() - startTime > 10
if not Modules.HasFinished then
	error("Module loading got stuck on ".. (currentModule or "???") .. " ".. currentProcess or "???")
end

ui.Enabled = true

wait(1)
