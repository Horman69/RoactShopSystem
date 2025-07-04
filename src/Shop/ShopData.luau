--!strict
-- src/Shop/ShopData.luau
-- Массив товаров магазина. Только особые способности для покупки!

-- Импортируем типы из централизованного модуля
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("Types"))
type Product = Types.Product

local Products: {Product} = {
	-- ОСОБЫЕ СПОСОБНОСТИ (можно покупать в магазине)
	-- Базовые способности (ускорение, щит, прыжок) доступны сразу и не продаются
	
	{
		id = 200,
		name = "💪 Сила",
		price = 200,
		description = "Увеличивает урон в 2 раза на 10 секунд",
		category = "ability",
		abilityId = "strength_boost",
	},
	{
		id = 201,
		name = "💨 Невидимость",
		price = 300,
		description = "Делает игрока невидимым на 8 секунд",
		category = "ability",
		abilityId = "invisibility",
	},
	{
		id = 202,
		name = "🔥 Огненная аура",
		price = 250,
		description = "Наносит урон всем врагам рядом",
		category = "ability",
		abilityId = "fire_aura",
	},
}

return Products
