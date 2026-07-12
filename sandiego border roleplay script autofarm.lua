local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ==========================================
-- НАСТРОЙКИ И ОГРАНИЧЕНИЯ (Y >= 16.0)
-- ==========================================
local MIN_Y_LIMIT = 16.0 
local MAX_SPEED = 270 

-- Координаты точек
local POINT_BUY_RING = Vector3.new(6820.6, 20.2, 17.2)       -- Магазин колец
local ROAD_8841 = Vector3.new(6908.36, 17.24, 119.16)     
local ROAD_8844 = Vector3.new(6898.69, 17.24, 103.10)     -- Точка с фото
local ROAD_8842 = Vector3.new(493.00, 17.24, 112.05)      -- Точка 2
local POINT_SELL_RING = Vector3.new(208.53, 17.26, -41.81) -- Продавец контрабанды
local POINT_LAUNDER_MONEY = Vector3.new(6807.17, 17.46, -33.55) -- Прачечная

local guiVisible = true
local needResetLoop = false

local function getSafePos(vec)
	local safeY = math.max(vec.Y, MIN_Y_LIMIT)
	return Vector3.new(vec.X, safeY, vec.Z)
end

-- ==========================================
-- ИНТЕРФЕЙС УПРАВЛЕНИЯ
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SanDiego_Tunnel_V34"
if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end 
ScreenGui.Parent = CoreGui

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 360, 0, 260)
MainPanel.Position = UDim2.new(0.05, 0, 0.35, 0)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "  San Diego Border RP - Tunnel Bot v3.4 (H)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 15
Title.Parent = MainPanel

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.94, 0, 0, 26)
StatusLabel.Position = UDim2.new(0.03, 0, 0.15, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusLabel.Text = "Статус: Запуск v3.4..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 15
StatusLabel.Parent = MainPanel

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(0.94, 0, 0, 155)
LogFrame.Position = UDim2.new(0.03, 0, 0.28, 0)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LogFrame.Parent = MainPanel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = LogFrame

local function logMessage(text, isError)
	local logText = Instance.new("TextLabel")
	logText.Size = UDim2.new(1, -10, 0, 18)
	logText.BackgroundTransparency = 1
	logText.Text = "[" .. os.date("%X") .. "] " .. text
	logText.TextSize = 14
	logText.Font = Enum.Font.SourceSansItalic
	logText.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(150, 255, 150)
	logText.Parent = LogFrame
end

local function updateStatus(text, color)
	StatusLabel.Text = "Статус: " .. text
	StatusLabel.TextColor3 = color or Color3.fromRGB(255, 255, 255)
end

-- ==========================================
-- ВЗАИМОДЕЙСТВИЕ С ИНВЕНТАРЕМ
-- ==========================================
local function holdKeyE()
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	task.wait(0.4) 
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	task.wait(0.2) 
end

local function getTotalInventoryCount()
	local count = 0
	local backpack = player:FindFirstChildOfClass("Backpack")
	local char = player.Character
	if backpack then count = count + #backpack:GetChildren() end
	if char then
		for _, item in ipairs(char:GetChildren()) do if item:IsA("Tool") then count = count + 1 end end
	end
	return count
end

-- ==========================================
-- СИСТЕМА ДВИЖЕНИЯ
11:49
-- ==========================================
local function tweenGoto(targetPos, forcedSpeed)
	if needResetLoop then return end
	targetPos = getSafePos(targetPos) 
	
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum or hum.Health <= 0 then return end

	hum.PlatformStand = true
	local expectedPosition = root.Position

	while (root.Position - targetPos).Magnitude > 5 do
		if needResetLoop or hum.Health <= 0 then break end
		
		if root.Position.Y < MIN_Y_LIMIT then 
			root.CFrame = CFrame.new(root.Position.X, MIN_Y_LIMIT + 1, root.Position.Z) 
		end

		if (root.Position - expectedPosition).Magnitude > 22 then
			updateStatus("Откинуло! Коррекция позиции...", Color3.fromRGB(255, 50, 50))
			root.Velocity = Vector3.new(0, 0, 0)
			task.wait(1.5)
			expectedPosition = root.Position
		end

		local dist = (root.Position - targetPos).Magnitude
		local dir = (targetPos - root.Position).Unit
		local dt = RunService.Heartbeat:Wait()
		
		local step = (forcedSpeed or MAX_SPEED) * dt
		if step > dist then step = dist end
		
		local nextPos = root.Position + dir * step
		if nextPos.Y < MIN_Y_LIMIT then nextPos = Vector3.new(nextPos.X, MIN_Y_LIMIT, nextPos.Z) end
		
		root.CFrame = CFrame.new(nextPos, nextPos + dir)
		expectedPosition = nextPos
	end
	
	if root and hum.Health > 0 then
		root.CFrame = CFrame.new(targetPos)
		root.Velocity = Vector3.new(0,0,0)
	end
	hum.PlatformStand = false
	task.wait(0.1)
end

-- ==========================================
-- ПОЛНОСТЬЮ АВТОНОМНЫЙ ЦИКЛ v3.4
-- ==========================================
task.spawn(function()
	logMessage("Бот v3.4 запущен. Тройной контроль координат активен.")
	while true do
		if needResetLoop then needResetLoop = false task.wait(1.5) end
		
		-- [1] Полет за кольцами + ЖЕСТКИЙ ЯКОРЬ КООРДИНАТ (МАГАЗИН)
		updateStatus("Полет за кольцами...", Color3.fromRGB(170, 255, 255))
		tweenGoto(POINT_BUY_RING)
		
		while getTotalInventoryCount() < 7 and not needResetLoop do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if root then
				-- Если откинуло от магазина во время закупки — летим обратно
				local currentDist = (root.Position - getSafePos(POINT_BUY_RING)).Magnitude
				if currentDist > 6 then
					updateStatus("Сдвиг от магазина! Возврат...", Color3.fromRGB(255, 80, 80))
					tweenGoto(POINT_BUY_RING)
				end
			end
			
			updateStatus("Закупаю кольца (Всего: " .. getTotalInventoryCount() .. "/7)...", Color3.fromRGB(255, 170, 0))
			holdKeyE()
		end

		-- [2] Перелет по цепочке через точку со скриншота
		updateStatus("Лечу на координаты с фото...", Color3.fromRGB(255, 255, 100))
		tweenGoto(ROAD_8844) 
		
		updateStatus("Лечу по безопасной трассе...", Color3.fromRGB(170, 255, 255))
		tweenGoto(ROAD_8841)
		tweenGoto(ROAD_8842) -- Точка 2
		
		-- Прилет к продавцу контрабанды
		updateStatus("Прилетел. Сдаю контрабанду...", Color3.fromRGB(170, 255, 255))
		tweenGoto(POINT_SELL_RING)
		
		-- [3] Сдача контрабанды + ЖЕСТКИЙ ЯКОРЬ КООРДИНАТ (ПРОДАВЕЦ)
		while not needResetLoop do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if root then
				-- Если сместило от продавца — возвращает на точку сдачи
				local currentDist = (root.Position - getSafePos(POINT_SELL_RING)).Magnitude
				if currentDist > 6 then
					updateStatus("Сдвиг от продавца! Возврат...", Color3.fromRGB(255, 80, 80))
					tweenGoto(POINT_SELL_RING)
				end
			end
			
			local count = getTotalInventoryCount()
			if count > 6 then
				holdKeyE() 
			elseif count >= 3 and count <= 6 then
				logMessage("Триггер дозакупки (" .. count .. " шт). Ухожу на трассу.")
				break
			else
				logMessage("Все кольца сданы. Осталось предметов: " .. count)
				break
			end
			task.wait(0.5)
		end
		
		if needResetLoop then continue end
11:49
-- [4] Прямой полет к прачечной через безопасные дорожные точки
		updateStatus("Движение к прачечной...", Color3.fromRGB(150, 255, 150))
		tweenGoto(ROAD_8842) -- Точка 2
		tweenGoto(ROAD_8844) 
		tweenGoto(ROAD_8841) 
		
		-- Прилет к стиралкам
		updateStatus("Прилетел в прачечную. Начинаю отмыв...", Color3.fromRGB(150, 255, 150))
		tweenGoto(POINT_LAUNDER_MONEY) 
		
		-- [5] Отмыв денег + ЖЕСТКИЙ ЯКОРЬ КООРДИНАТ (ПРАЧЕЧНАЯ)
		while not needResetLoop do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			
			if root then
				-- Если унесло от стиралок — возвращает на координаты прачечной
				local currentDist = (root.Position - getSafePos(POINT_LAUNDER_MONEY)).Magnitude
				if currentDist > 6 then
					updateStatus("Сдвиг в прачечной! Возврат...", Color3.fromRGB(255, 80, 80))
					tweenGoto(POINT_LAUNDER_MONEY)
				end
			end
			
			local count = getTotalInventoryCount()
			if count > 2 then
				updateStatus("Стираю деньги (Осталось предметов: " .. count .. ")...", Color3.fromRGB(255, 170, 0))
				holdKeyE()
			else
				logMessage("Деньги полностью отмыты! Круг завершен.")
				break
			end
			task.wait(0.6)
		end
		
		-- Небольшая пауза перед улетом на новый круг закупки
		task.wait(0.1)
	end
end)