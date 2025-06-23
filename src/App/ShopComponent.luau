--!strict
-- src/App/ShopComponent.luau
-- Компонент Roact для отображения магазина и покупки товаров
-- Обновлён для работы с новой сервисной архитектурой

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Импортируем через ModuleLoader
local ModuleLoader = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ModuleLoader"))
local Roact = ModuleLoader.require("Packages/roact")
local ShopService = ModuleLoader.require("services/ShopService")

-- Типы
local Types = ModuleLoader.require("shared/Types")
type Product = Types.Product
type ShopComponentProps = Types.ShopComponentProps

--[=[
	ShopComponent
	Пропсы:
	- onPurchase (function): функция, вызываемая после попытки покупки
	- currentCoins (number): текущее количество монет для отображения
]=]
local ShopComponent = Roact.Component:extend("ShopComponent")

function ShopComponent:init()
	-- Создаём экземпляр сервиса магазина
	self.shopService = ShopService.new()
	
	-- Получаем доступные товары
	local availableProducts = self.shopService:getAvailableProducts()
	self:setState({
		products = availableProducts
	})
end

function ShopComponent:render()
	local products = self.state.products or {}
	local productElements = {}
	
	for i, product in ipairs(products) do
		productElements["Product" .. i] = Roact.createElement("Frame", {
			Size = UDim2.new(0, 350, 0, 80),
			Position = UDim2.new(0, 20, 0, 80 * (i - 1)),
			BackgroundColor3 = Color3.fromRGB(40, 44, 52),
			BorderSizePixel = 0,
		}, {
			UICorner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			
			-- Информация о товаре
			ProductInfo = Roact.createElement("Frame", {
				Size = UDim2.new(0, 220, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Name = Roact.createElement("TextLabel", {
					Text = product.name,
					Size = UDim2.new(1, 0, 0, 25),
					Position = UDim2.new(0, 10, 0, 5),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 20,
					Font = Enum.Font.GothamBold,
					TextColor3 = Color3.fromRGB(255, 255, 255),
				}),
				Price = Roact.createElement("TextLabel", {
					Text = "💰 " .. product.price .. " монет",
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 10, 0, 30),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 16,
					Font = Enum.Font.Gotham,
					TextColor3 = Color3.fromRGB(255, 215, 0),
				}),
				Description = Roact.createElement("TextLabel", {
					Text = product.description,
					Size = UDim2.new(1, 0, 0, 20),
					Position = UDim2.new(0, 10, 0, 50),
					BackgroundTransparency = 1,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextSize = 14,
					Font = Enum.Font.Gotham,
					TextColor3 = Color3.fromRGB(180, 180, 180),
					TextWrapped = true,
				}),
			}),
			
			-- Кнопка покупки
			BuyButton = Roact.createElement("TextButton", {
				Text = "Купить",
				Size = UDim2.new(0, 100, 0, 40),
				Position = UDim2.new(0, 230, 0, 20),
				BackgroundColor3 = Color3.fromRGB(0, 170, 255),
				TextSize = 18,
				Font = Enum.Font.GothamBlack,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				AutoButtonColor = true,
				[Roact.Event.MouseButton1Click] = function()
					-- Вызываем колбэк родительского компонента
					if self.props.onPurchase then
						self.props.onPurchase(product)
					end
				end,
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 8),
				}),
			}),
		})
	end

	return Roact.createElement("ScrollingFrame", {
		Size = UDim2.new(0, 380, 0, math.min(400, 80 * #products + 20)),
		Position = UDim2.new(0, 0, 0, 120),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 80 * #products + 20),
		ScrollBarThickness = 8,
		ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
	}, productElements)
end

return ShopComponent
