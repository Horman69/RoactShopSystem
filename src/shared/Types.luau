--!strict
-- src/shared/Types.luau
-- Система типов для магазина и валюты
-- Все интерфейсы и типы данных в одном месте

-- Тип товара в магазине
export type Product = {
	id: number,
	name: string,
	price: number,
	description: string,
	category: string?, -- Опциональная категория (оружие, броня, и т.д.)
	icon: string?, -- Опциональная иконка товара
	maxQuantity: number?, -- Максимальное количество для покупки
	requirements: {[string]: any}?, -- Требования для покупки (уровень, другие товары)
}

-- Массив товаров
export type ProductList = {Product}

-- Интерфейс кошелька
export type WalletInterface = {
	getCoins: (self: WalletInterface) -> number,
	addCoins: (self: WalletInterface, amount: number) -> (),
	spendCoins: (self: WalletInterface, amount: number) -> boolean,
	hasEnoughCoins: (self: WalletInterface, amount: number) -> boolean,
}

-- Результат операции покупки
export type PurchaseResult = {
	success: boolean,
	message: string,
	product: Product?,
	remainingCoins: number?,
}

-- Состояние валюты игрока
export type CurrencyState = {
	coins: number,
	gems: number?, -- Для будущего расширения
	tokens: number?, -- Для будущего расширения
}

-- Пропсы для компонента кошелька
export type WalletComponentProps = {
	coins: number,
	onCoinChange: ((newAmount: number) -> ())?,
}

-- Пропсы для компонента магазина
export type ShopComponentProps = {
	wallet: WalletInterface,
	onPurchase: ((product: Product) -> ())?,
	products: ProductList?,
}

-- Пропсы для компонента товара
export type ProductItemProps = {
	product: Product,
	wallet: WalletInterface,
	onPurchase: (product: Product) -> (),
}

-- События для системы магазина
export type ShopEvents = {
	ProductPurchased: "ProductPurchased",
	InsufficientFunds: "InsufficientFunds",
	CurrencyChanged: "CurrencyChanged",
}

-- Конфигурация магазина
export type ShopConfig = {
	defaultCurrency: number,
	maxCoinsPerSession: number?,
	enableNotifications: boolean,
	notificationDuration: number,
}

return {
	-- Экспортируем типы через module для совместимости
	Product = {} :: Product,
	WalletInterface = {} :: WalletInterface,
	PurchaseResult = {} :: PurchaseResult,
	CurrencyState = {} :: CurrencyState,
}
