--!strict
-- src/App/AbilityPanel.luau
-- Главная панель способностей

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Импортируем зависимости
local ModuleLoader = require(ReplicatedStorage:WaitForChild("shared"):WaitForChild("ModuleLoader"))
local Roact = ModuleLoader.require("Packages/roact")
local AbilityService = ModuleLoader.require("services/AbilityService")

local AbilityPanel = Roact.Component:extend("AbilityPanel")

function AbilityPanel:init()
	self.abilityService = AbilityService.new()
	
	self.state = {
		abilities = {},
		cooldowns = {},
		activeEffects = {},
		cooldownTimes = {},
		hoveredAbility = nil,
	}
	
	-- Обновляем состояние каждые 0.1 секунды для плавности
	spawn(function()
		while true do
			wait(0.1)
			self:updateState()
		end
	end)
	
	-- Загружаем способности мгновенно
	spawn(function()
		wait(0.1) -- Минимальная задержка для стабильности
		self:loadAbilities()
	end)
	
	-- Горячие клавиши
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		-- Базовые способности
		if input.KeyCode == Enum.KeyCode.Q then
			self:activateAbilityByIndex(1)
		elseif input.KeyCode == Enum.KeyCode.E then
			self:activateAbilityByIndex(2)
		elseif input.KeyCode == Enum.KeyCode.R then
			self:activateAbilityByIndex(3)
		-- Особые способности
		elseif input.KeyCode == Enum.KeyCode.T then
			self:activateAbilityByIndex(4)
		elseif input.KeyCode == Enum.KeyCode.F then
			self:activateAbilityByIndex(5)
		elseif input.KeyCode == Enum.KeyCode.G then
			self:activateAbilityByIndex(6)
		end
	end)
end

function AbilityPanel:loadAbilities()
	local player = Players.LocalPlayer
	if not player then return end
	
	local abilities = self.abilityService:getPlayerAbilities(player)
	self:setState({ abilities = abilities })
end

function AbilityPanel:updateState()
	local player = Players.LocalPlayer
	if not player then return end
	
	local cooldowns = {}
	local cooldownTimes = {}
	local activeEffects = self.abilityService:getActiveEffects(player)
	
	for _, ability in ipairs(self.state.abilities) do
		local isOnCooldown = self.abilityService:isAbilityOnCooldown(player, ability.id)
		cooldowns[ability.id] = isOnCooldown
		
		if isOnCooldown then
			cooldownTimes[ability.id] = self.abilityService:getCooldownTimeLeft(player, ability.id)
		end
	end
	
	self:setState({
		cooldowns = cooldowns,
		activeEffects = activeEffects,
		cooldownTimes = cooldownTimes,
	})
end

function AbilityPanel:activateAbilityByIndex(index: number)
	local abilities = self.state.abilities
	if abilities[index] then
		self:onAbilityActivate(abilities[index].id)
	end
end

function AbilityPanel:onAbilityActivate(abilityId: string)
	local player = Players.LocalPlayer
	if not player then return end
	
	local result = self.abilityService:activateAbility(player, abilityId)
	
	if result.success then
		print("✅", result.message)
	end
	
	self:updateState()
end

function AbilityPanel:createProButton(ability, index: number)
	local isOnCooldown = self.state.cooldowns[ability.id]
	local isActive = self.state.activeEffects[ability.id] ~= nil
	local cooldownTime = self.state.cooldownTimes[ability.id] or 0
	local cooldownProgress = 0
	
	if isOnCooldown and ability.cooldown > 0 then
		cooldownProgress = 1 - (cooldownTime / ability.cooldown)
	end
	
	-- ПРОФЕССИОНАЛЬНЫЕ ЦВЕТА И ИКОНКИ
	local abilityConfig = {
		speed_boost = {
			-- Современная иконка ускорения
			icon = "⚡",
			color = Color3.fromRGB(0, 174, 255), -- Яркий синий
			glowColor = Color3.fromRGB(100, 200, 255),
			name = "SPEED",
		},
		shield_aura = {
			-- Современная иконка щита
			icon = "🛡",
			color = Color3.fromRGB(255, 149, 0), -- Оранжевый
			glowColor = Color3.fromRGB(255, 200, 100),
			name = "SHIELD",
		},
		jump_boost = {
			-- Современная иконка прыжка
			icon = "🚀",
			color = Color3.fromRGB(52, 199, 89), -- Зеленый
			glowColor = Color3.fromRGB(100, 255, 150),
			name = "JUMP",
		},
		-- Особые способности
		strength_boost = {
			icon = "💪",
			color = Color3.fromRGB(255, 59, 48), -- Красный
			glowColor = Color3.fromRGB(255, 150, 150),
			name = "STRENGTH",
		},
		invisibility = {
			icon = "💨",
			color = Color3.fromRGB(175, 82, 222), -- Фиолетовый
			glowColor = Color3.fromRGB(200, 150, 255),
			name = "INVISIBLE",
		},
		fire_aura = {
			icon = "🔥",
			color = Color3.fromRGB(255, 149, 0), -- Оранжево-красный
			glowColor = Color3.fromRGB(255, 200, 100),
			name = "FIRE",
		},
	}
	
	local config = abilityConfig[ability.id] or {
		icon = "?",
		color = Color3.fromRGB(100, 100, 255),
		glowColor = Color3.fromRGB(150, 150, 255),
		name = "UNKNOWN",
	}
	
	local buttonColor = config.color
	local glowIntensity = 0
	
	if isOnCooldown then
		buttonColor = Color3.fromRGB(45, 45, 45) -- Темно-серый
	elseif isActive then
		buttonColor = Color3.fromRGB(255, 255, 255) -- Белый при активации
		glowIntensity = 0.3
	end
	
	local hotkeys = {"Q", "E", "R", "T", "F", "G"}
	local buttonSize = 64 -- Увеличенный размер для лучшей видимости
	local spacing = 8
	
	return Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, buttonSize, 0, buttonSize),
		Position = UDim2.new(0, (index - 1) * (buttonSize + spacing), 0, 0),
	}, {
		-- ОСНОВНАЯ КНОПКА
		Button = Roact.createElement("TextButton", {
			BackgroundColor3 = buttonColor,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			AutoButtonColor = false,
			[Roact.Event.Activated] = function()
				if not isOnCooldown then
					self:onAbilityActivate(ability.id)
				end
			end,
			[Roact.Event.MouseEnter] = function()
				self:setState({ hoveredAbility = ability.id })
			end,
			[Roact.Event.MouseLeave] = function()
				self:setState({ hoveredAbility = Roact.None })
			end,
		}, {
			-- СОВРЕМЕННОЕ СКРУГЛЕНИЕ
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 12),
			}),
			
			-- ПРОФЕССИОНАЛЬНАЯ ТЕНЬ
			Shadow = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.7,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 4, 1, 4),
				Position = UDim2.new(0, -2, 0, 3),
				ZIndex = -1,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 12),
				}),
			}),
			
			-- СВЕЧЕНИЕ ПРИ АКТИВАЦИИ
			Glow = isActive and Roact.createElement("Frame", {
				BackgroundColor3 = config.glowColor,
				BackgroundTransparency = 1 - glowIntensity,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 8, 1, 8),
				Position = UDim2.new(0, -4, 0, -4),
				ZIndex = -2,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 16),
				}),
			}) or nil,
			
			-- ИКОНКА СПОСОБНОСТИ
			Icon = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0.55, 0, 0.55, 0),
				Position = UDim2.new(0.225, 0, 0.15, 0),
				Text = config.icon,
				TextColor3 = isOnCooldown and Color3.fromRGB(100, 100, 100) or Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
			}),
			
			-- ПРОГРЕСС КУЛДАУНА (КРУГОВОЙ ЭФФЕКТ)
			CooldownOverlay = isOnCooldown and Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1 - cooldownProgress, 0),
				Position = UDim2.new(0, 0, cooldownProgress, 0),
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 12),
				}),
			}) or nil,
			
			-- ГОРЯЧАЯ КЛАВИША
			Hotkey = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.2,
				BorderSizePixel = 0,
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(1, -22, 0, 2),
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
				
				Text = Roact.createElement("TextLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = hotkeys[index] or "",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextScaled = true,
					Font = Enum.Font.GothamBold,
				}),
			}),
			
			-- ТАЙМЕР КУЛДАУНА
			CooldownTimer = isOnCooldown and Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.3, 0),
				Position = UDim2.new(0, 0, 0.65, 0),
				Text = tostring(math.ceil(cooldownTime)),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextStrokeTransparency = 0,
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
			}) or nil,
		}),
		
		-- ТУЛТИП ПРИ НАВЕДЕНИИ (МИНИМАЛЬНЫЙ)
		Tooltip = self.state.hoveredAbility == ability.id and Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BackgroundTransparency = 0.1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 100, 0, 30),
			Position = UDim2.new(0.5, -50, -1, -5),
			ZIndex = 10,
		}, {
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			
			-- Название способности
			Title = Roact.createElement("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -4, 1, -4),
				Position = UDim2.new(0, 2, 0, 2),
				Text = config.name,
				TextColor3 = config.color,
				TextScaled = true,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Center,
			}),
		}) or nil,
	})
end

function AbilityPanel:render()
	local abilities = self.state.abilities
	
	if #abilities == 0 then
		return Roact.createElement("ScreenGui", {
			Name = "AbilityPanel",
			ResetOnSpawn = false,
		})
	end
	
	local buttonSize = 64
	local spacing = 8
	local totalWidth = #abilities * buttonSize + (#abilities - 1) * spacing
	local totalHeight = buttonSize
	
	local abilityButtons = {}
	for i, ability in ipairs(abilities) do
		abilityButtons["Ability" .. i] = self:createProButton(ability, i)
	end
	
	return Roact.createElement("ScreenGui", {
		Name = "AbilityPanel",
		ResetOnSpawn = false,
	}, {
		-- ПРОФЕССИОНАЛЬНАЯ ПАНЕЛЬ
		MainBar = Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromRGB(28, 28, 30), -- Темно-серый Apple style
			BackgroundTransparency = 0.05, -- Почти непрозрачный
			BorderSizePixel = 0,
			Size = UDim2.new(0, totalWidth + 16, 0, totalHeight + 16),
			Position = UDim2.new(0.5, -(totalWidth + 16) / 2, 1, -totalHeight - 32),
		}, {
			-- СОВРЕМЕННОЕ СКРУГЛЕНИЕ
			Corner = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 16),
			}),
			
			-- ПРОФЕССИОНАЛЬНАЯ ТЕНЬ ПАНЕЛИ
			Shadow = Roact.createElement("Frame", {
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.8,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 6, 1, 6),
				Position = UDim2.new(0, -3, 0, 3),
				ZIndex = -1,
			}, {
				Corner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 19),
				}),
			}),
			
			-- ТОНКАЯ РАМКА (ПРОФЕССИОНАЛЬНО)
			Border = Roact.createElement("UIStroke", {
				Color = Color3.fromRGB(60, 60, 60),
				Thickness = 1,
				Transparency = 0.5,
			}),
			
			-- КОНТЕЙНЕР КНОПОК
			ButtonContainer = Roact.createElement("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -16, 1, -16),
				Position = UDim2.new(0, 8, 0, 8),
			}, abilityButtons),
		}),
	})
end

return AbilityPanel
