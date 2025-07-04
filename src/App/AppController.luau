--!strict
-- src/App/AppController.luau
-- Главный контроллер приложения - правильная архитектура
-- Использует сервисы для бизнес-логики

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Импортируем зависимости через ModuleLoader
local ModuleLoader = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ModuleLoader"))

-- Предзагружаем критически важные модули
ModuleLoader.preloadCriticalModules()

-- Загружаем модули
local Roact = ModuleLoader.require("Packages/roact")
local CurrencyService = ModuleLoader.require("services/CurrencyService")
local ShopService = ModuleLoader.require("services/ShopService")
local AbilityService = ModuleLoader.require("services/AbilityService")
local AbilityConfig = ModuleLoader.require("shared/AbilityConfig")
local WalletComponent = ModuleLoader.require("App/WalletComponent")
local ShopComponent = ModuleLoader.require("App/ShopComponent")
local AbilityPanel = ModuleLoader.require("App/AbilityPanel")

-- Типы
local Types = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("Types"))
type CurrencyState = Types.CurrencyState
type Product = Types.Product
type Ability = Types.Ability

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Контроллер приложения
local AppController = Roact.Component:extend("AppController")

function AppController:init()
	-- Инициализируем сервисы
	self.currencyService = CurrencyService.new()
	self.shopService = ShopService.new()
	
	-- Получаем начальное состояние валюты
	local initialCurrency = self.currencyService:getPlayerCurrency(player)
	
	self:setState({ 
		coins = initialCurrency.coins,
		isLoaded = true,
		showShop = false, -- магазин скрыт по умолчанию
		shopButtonPressed = false, -- состояние нажатия кнопки
	})
	
	-- Подписываемся на изменения валюты
	self.currencyService:onCurrencyChanged(function(changedPlayer: Player, newState: CurrencyState)
		if changedPlayer == player then
			self:setState({ coins = newState.coins })
		end
	end)
end

-- Функция для добавления монет (тестовая)
function AppController:addCoins()
	local success = self.currencyService:addCoins(player, 50)
	if not success then
		warn("Не удалось добавить монеты (возможно, кулдаун)")
	end
end

-- Переключить отображение магазина
function AppController:toggleShop()
	self:setState({
		showShop = not self.state.showShop
	})
end

-- Функция вызывается после покупки товара
function AppController:onPurchase(product: Product)
	-- Покупаем товар через сервис
	local result = self.shopService:purchaseProduct(player, product.id)
	
	if result.success then
		print("✅ Успешная покупка:", result.message)
		
		-- Показываем уведомление об успехе
		game.StarterGui:SetCore("SendNotification", {
			Title = "Покупка успешна!",
			Text = "Куплен товар: " .. product.name,
			Duration = 3,
		})
	else
		warn("❌ Ошибка покупки:", result.message)
		
		-- Показываем уведомление об ошибке
		game.StarterGui:SetCore("SendNotification", {
			Title = "Ошибка покупки",
			Text = result.message,
			Duration = 4,
		})
	end
end

function AppController:render()
	-- Показываем загрузку, пока модули не готовы
	if not self.state.isLoaded then
		return Roact.createElement("ScreenGui", {}, {
			LoadingFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			}, {
				LoadingText = Roact.createElement("TextLabel", {
					Text = "Загрузка магазина...",
					Size = UDim2.new(0, 300, 0, 100),
					Position = UDim2.new(0.5, -150, 0.5, -50),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 24,
					Font = Enum.Font.Gotham,
				})
			})
		})
	end

	-- Основной UI
	return Roact.createElement("ScreenGui", {
		Name = "ShopApp",
		ResetOnSpawn = false,
	}, {
		MainFrame = Roact.createElement("Frame", {
			Size = UDim2.new(0, 420, 0, 500),
			Position = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
		}, {
			-- Компонент кошелька
			Wallet = Roact.createElement(WalletComponent, {
				coins = self.state.coins,
			}),
			
			-- Тестовая кнопка добавления монет
			AddButton = Roact.createElement("TextButton", {
				Text = "+50 монет",
				Size = UDim2.new(0, 140, 0, 44),
				Position = UDim2.new(0, 10, 0, 70),
				BackgroundColor3 = Color3.fromRGB(0, 200, 120),
				TextSize = 22,
				Font = Enum.Font.GothamBlack,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AutoButtonColor = true,
				BorderSizePixel = 0,
				[Roact.Event.MouseButton1Click] = function()
					self:addCoins()
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
			}),
			
			-- Компонент магазина (показывается только если showShop = true)
			Shop = self.state.showShop and Roact.createElement(ShopComponent, {
				onPurchase = function(product)
					self:onPurchase(product)
				end,
			}) or nil,
		}),
		
		-- Кнопка магазина (справа, ближе к центру, за пределами MainFrame)
		ShopButton = Roact.createElement("TextButton", {
			Text = self.state.showShop and "🛒 Закрыть" or "🛒 Магазин",
			Size = UDim2.new(0, 120, 0, 44),
			Position = UDim2.new(1, -140, 0.5, -22),
			BackgroundColor3 = self.state.shopButtonPressed and 
				Color3.fromRGB(150, 75, 0) or -- темнее при нажатии
				(self.state.showShop and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(0, 120, 215)),
			TextSize = 16,
			Font = Enum.Font.GothamBlack,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			AutoButtonColor = false, -- отключаем стандартную анимацию
			BorderSizePixel = 0,
			[Roact.Event.MouseButton1Down] = function()
				-- Мгновенная реакция на нажатие
				self:setState({ shopButtonPressed = true })
			end,
			[Roact.Event.MouseButton1Up] = function()
				-- Сброс состояния и переключение магазина
				self:setState({ shopButtonPressed = false })
				self:toggleShop()
			end,
			[Roact.Event.MouseLeave] = function()
				-- Сброс состояния при уходе курсора
				self:setState({ shopButtonPressed = false })
			end,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
		}),
		
		-- Панель способностей (отдельно от магазина)
		AbilityPanel = Roact.createElement(AbilityPanel),
	})
end

return AppController
