--!strict
-- src/Shop/ShopData.luau
-- Массив товаров магазина. Добавлять новые товары очень просто!

-- Импортируем типы из централизованного модуля
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("Types"))
type Product = Types.Product

local Products: {Product} = {
	{
		id = 1,
		name = "Меч",
		price = 100,
		description = "Обычный меч для начинающих.",
	},
	{
		id = 2,
		name = "Щит",
		price = 150,
		description = "Прочный деревянный щит.",
	},

	{
		id = 3,
		name = "Лук",
		price = 150,
		description = "Легкий деревянный лук.",
	},

	-- Добавляйте новые товары сюда!
}

return Products
