--!strict
-- src/client/ShopApp.client.luau
-- Запуск магазина через новую архитектуру
-- Этот скрипт заменяет старые Main.client.luau и RoactStarter.client.luau

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Ждём загрузки ModuleLoader
local ModuleLoader = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ModuleLoader"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удаляем старые UI, если они есть
local function cleanupOldUI()
	local oldUIs = {"MainApp", "TestScreenGui", "ShopApp"}
	for _, uiName in ipairs(oldUIs) do
		local oldUI = playerGui:FindFirstChild(uiName)
		if oldUI then
			oldUI:Destroy()
		end
	end
end

-- Безопасный запуск приложения
local function startApp()
	local success, errorMessage = pcall(function()
		-- Загружаем Roact и главный контроллер
		local Roact = ModuleLoader.require("Packages/roact")
		local AppController = ModuleLoader.require("App/AppController")
		
		-- Очищаем старые UI
		cleanupOldUI()
		
		-- Монтируем новое приложение
		Roact.mount(Roact.createElement(AppController), playerGui, "ShopApp")
		
		print("✅ Магазин успешно запущен!")
	end)
	
	if not success then
		warn("❌ Ошибка запуска магазина:", errorMessage)
		
		-- Показываем ошибку пользователю
		local errorGui = Instance.new("ScreenGui")
		errorGui.Name = "ShopError"
		errorGui.Parent = playerGui
		
		local errorFrame = Instance.new("Frame")
		errorFrame.Size = UDim2.new(0, 400, 0, 100)
		errorFrame.Position = UDim2.new(0.5, -200, 0.5, -50)
		errorFrame.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		errorFrame.Parent = errorGui
		
		local errorText = Instance.new("TextLabel")
		errorText.Text = "Ошибка загрузки магазина!\nПроверьте консоль разработчика."
		errorText.Size = UDim2.new(1, 0, 1, 0)
		errorText.BackgroundTransparency = 1
		errorText.TextColor3 = Color3.fromRGB(255, 255, 255)
		errorText.TextSize = 18
		errorText.Font = Enum.Font.Gotham
		errorText.Parent = errorFrame
	end
end

-- Запускаем приложение
startApp()
