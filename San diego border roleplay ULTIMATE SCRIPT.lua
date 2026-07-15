-- =============================================================================
-- 🌌 1MORT SPIDER v2.7 // ЧАСТЬ 1: ФИЛЬТР ПРЕДМЕТОВ И ИНТЕРФЕЙС (~200 СТРОК)
-- =============================================================================

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local configFileName = "1mort_spider_config.json"

-- Глобальные переменные управления
_G.speedEnabled = false
_G.speedValue = 50
_G.flyEnabled = false
_G.flyVelocity = nil
_G.flyConnection = nil
_G.smartFarmActive = false 

-- 🔧 ОБНОВЛЕННАЯ ФУНКЦИЯ: ПОДСЧЕТ ПРЕДМЕТОВ С ИГНОРИРОВАНИЕМ ПАЛКИ
function _G.checkItemsCount()
    local backpack = Player:FindFirstChild("Backpack")
    local character = Player.Character
    local count = 0
    
    -- Сюда впиши точное название бесполезного предмета, который нужно игнорировать
    local ignoreName1 = "Stick" 
    local ignoreName2 = "Палка" 
    
    -- Считаем вещи в рюкзаке
    if backpack then 
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= ignoreName1 and item.Name ~= ignoreName2 then
                count = count + 1
            end
        end
    end
    
    -- Считаем вещи в руках персонажа
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= ignoreName1 and item.Name ~= ignoreName2 then
                count = count + 1
            end
        end
    end
    
    return count
end

-- БЕЗОПАСНОЕ СОЗДАНИЕ ЭКРАНА В PLAYERGUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "1mortSpiderSpace"
ScreenGui.ResetOnSpawn = false 
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-- ГЛАВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 30) 
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(138, 43, 226) 
UIStroke.Parent = MainFrame

-- ШАПКА МЕНЮ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " 🌌 1MORT SPIDER v2.7 // SMART FILTER EDITION"
Title.TextColor3 = Color3.fromRGB(0, 255, 255) 
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- КНОПКА ЗАКРЫТИЯ (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ПАНЕЛЬ НАВИГАЦИИ
local NavFrame = Instance.new("Frame")
NavFrame.Size = UDim2.new(0, 140, 1, -50)
NavFrame.Position = UDim2.new(0, 10, 0, 45)
NavFrame.BackgroundColor3 = Color3.fromRGB(255, 20, 45)
NavFrame.BorderSizePixel = 0
NavFrame.Parent = MainFrame
Instance.new("UICorner", NavFrame).CornerRadius = UDim.new(0, 8)

-- КОНТЕЙНЕР СТРАНИЦ
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -170, 1, -50)
Container.Position = UDim2.new(0, 160, 0, 45)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = NavFrame

-- СОЗДАНИЕ СТРАНИЦ
_G.MainPage = Instance.new("Frame")
_G.MainPage.Size = UDim2.new(1, 0, 1, 0)
_G.MainPage.BackgroundTransparency = 1
_G.MainPage.Visible = true
_G.MainPage.Parent = Container

_G.FarmPage = Instance.new("Frame")
_G.FarmPage.Size = UDim2.new(1, 0, 1, 0)
_G.FarmPage.BackgroundTransparency = 1
_G.FarmPage.Visible = false
_G.FarmPage.Parent = Container

_G.ConfigPage = Instance.new("Frame")
_G.ConfigPage.Size = UDim2.new(1, 0, 1, 0)
_G.ConfigPage.BackgroundTransparency = 1
_G.ConfigPage.Visible = false
_G.ConfigPage.Parent = Container

_G.LogPage = Instance.new("ScrollingFrame")
_G.LogPage.Size = UDim2.new(1, 0, 1, 0)
_G.LogPage.BackgroundTransparency = 1
_G.LogPage.CanvasSize = UDim2.new(0, 0, 5, 0) 
_G.LogPage.Visible = false
_G.LogPage.Parent = Container

-- СКРОЛЛ ЛОГОВ
local LogText = Instance.new("TextLabel")
LogText.Size = UDim2.new(1, 0, 1, 0)
LogText.BackgroundTransparency = 1
LogText.Text = "[SYSTEM]: 1mort Spider v2.7 успешно запущен.\n"
LogText.TextColor3 = Color3.fromRGB(0, 255, 150) 
LogText.TextSize = 13
LogText.Font = Enum.Font.Code
LogText.TextXAlignment = Enum.TextXAlignment.Left
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.Parent = _G.LogPage

function _G.logMessage(msg)
    local t = os.date("%X")
    LogText.Text = LogText.Text .. "[" .. t .. "] " .. tostring(msg) .. "\n"
end

local function createTabButton(name, targetPage)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 120, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 30, 65)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200, 200, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = NavFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    Btn.MouseButton1Click:Connect(function()
        _G.MainPage.Visible = false
        _G.FarmPage.Visible = false
        _G.ConfigPage.Visible = false
        _G.LogPage.Visible = false
        targetPage.Visible = true
    end)
end

createTabButton("⚔️ Blatant", _G.MainPage)
createTabButton("💵 Автофарм", _G.FarmPage)
createTabButton("👁️ Visuals (ESP)", _G.ConfigPage)
createTabButton("📜 System Logs", _G.LogPage)

function _G.applyGrid(page)
    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0, 170, 0, 40)
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.Parent = page
end

_G.applyGrid(_G.MainPage)
_G.applyGrid(_G.FarmPage)
_G.applyGrid(_G.ConfigPage)

_G.logMessage("Интерфейс v2.7 с фильтром рюкзака успешно запущен.")
-- =============================================================================
-- 🌌 1MORT SPIDER v2.9 // ЧАСТЬ 2.1: УМНЫЙ ЧЕКЕР ЗАСТРЕВАНИЯ (~130 СТРОК)
-- =============================================================================

local TweenService = game:GetService("TweenService")

-- МЕХАНИКА: Зажимаем и ДЕРЖИМ клавишу E ровно 0.6 секунд
local function holdEKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.6)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ФУНКЦИЯ ПЛАВНОГО ПЕРЕЛЁТА (TWEEN) СО СКОРОСТЬЮ 270
local function tweenToPosition(targetPosition)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local distance = (root.Position - targetPosition).Magnitude
    local duration = distance / 270
    
    _G.logMessage("[🛡️ TWEEN]: Скорость 270. Перелёт на " .. math.floor(distance) .. " студов...")
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    
    tween:Play()
    tween.Completed:Wait()
    _G.logMessage("[🛡️ TWEEN]: Долетели.")
end

-- СОЗДАНИЕ КНОПКИ АВТОФАРМА
local SmartFarmBtn = Instance.new("TextButton")
SmartFarmBtn.Text = "Умный Автофарм: ВЫКЛ"
SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
SmartFarmBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
SmartFarmBtn.Font = Enum.Font.GothamBold
SmartFarmBtn.Parent = _G.FarmPage
Instance.new("UICorner", SmartFarmBtn).CornerRadius = UDim.new(0, 6)

_G.justDied = false
Player.CharacterAdded:Connect(function(newCharacter)
    if _G.smartFarmActive then _G.justDied = true end
end)

-- 🚨 ПОТОК 1: ПРОВЕРКА НА ТЮРЬМУ (0 ПРЕДМЕТОВ) КАЖДЫЕ 5 СЕКУНД
task.spawn(function()
    while true do
        task.wait(5)
        if _G.smartFarmActive then
            if _G.checkItemsCount() == 0 then
                _G.logMessage("[🚨 АНТИ-ТЮРЬМА]: Обнаружено 0 предметов! Восстановление...")
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = CFrame.new(6820.5, 20.1, 16.7)
                    while _G.smartFarmActive and _G.checkItemsCount() < 2 do holdEKey() task.wait(0.1) end
                    _G.logMessage("[🚨 АНТИ-ТЮРЬМА]: Стартовые вещи созданы.")
                end
            end
        end
    end
end)

-- 🕒 ПОТОК 2: УМНОЕ АНТИ-ЗАСТРЕВАНИЕ (ИГНОРИРУЕТ ЗОНУ ЗАКУПКИ)
task.spawn(function()
    local lastPosition = nil
    local stuckTimer = 0
    local shopPos = Vector3.new(6820.5, 20.1, 16.7) -- Координаты Точки 1
    
    while true do
        task.wait(1) -- Сканируем позицию каждую секунду
        if _G.smartFarmActive then
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                -- Высчитываем расстояние до Точки 1 (Зоны закупки)
                local distanceToShop = (root.Position - shopPos).Magnitude
                
                -- 🛑 ЕСЛИ МЫ НА ТОЧКЕ 1 ИЛИ В РАДИУСЕ 3 СТУДОВ — СБРАСЫВАЕМ ТАЙМЕР (НЕ УБИВАЕМ)
                if distanceToShop <= 3 then
                    stuckTimer = 0
                    lastPosition = root.Position
                else
                    -- Если мы ВНЕ зоны закупки, проверяем на застревание
                    if not lastPosition then
                        lastPosition = root.Position
                        stuckTimer = 0
                    else
                        local movedDistance = (root.Position - lastPosition).Magnitude
                        if movedDistance < 1 then
                            stuckTimer = stuckTimer + 1 -- Стоим на месте вне магазина
                            
                            if stuckTimer >= 6 then
                                _G.logMessage("[⚠️ АНТИ-ЗАСТРЕВАНИЕ]: Зависание вне магазина! Сброс в бездну...")
                                for i = 1, 10 do root.CFrame = CFrame.new(root.Position.X, -1000, root.Position.Z) task.wait(0.001) end
                                hum.Health = 0
                                stuckTimer = 0
                                lastPosition = nil
                            end
                        else
                            -- Мы двигаемся, всё ок
                            lastPosition = root.Position
                            stuckTimer = 0
                        end
                    end
                end
            else
                lastPosition = nil stuckTimer = 0
            end
        else
            lastPosition = nil stuckTimer = 0
        end
    end
end)
-- =============================================================================
-- 🌌 1MORT SPIDER v2.9 // ЧАСТЬ 2.2: ТЕЛО ЦИКЛА АВТОФАРМА (~130 СТРОК)
-- =============================================================================

SmartFarmBtn.MouseButton1Click:Connect(function()
    _G.smartFarmActive = not _G.smartFarmActive
    
    if _G.smartFarmActive then
        SmartFarmBtn.Text = "Умный Автофарм: АКТИВЕН"
        SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        SmartFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        _G.logMessage("Запуск робота v2.9 (Цикл активен)...")
        
        task.spawn(function()
            while _G.smartFarmActive do
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and hum.Health > 0 then
                    local targetPos1 = Vector3.new(6820.5, 20.1, 16.7)
                    
                    if _G.justDied then
                        _G.justDied = false
                        _G.logMessage("[⚠️ ЗАЩИТА]: Плавный возврат по Tween 270...")
                        tweenToPosition(targetPos1)
                    end
                    
                    -- ШАГ 1: ТОЧКА 1 (Фарм до 7 предметов)
                    _G.logMessage("[РОБОТ]: Закупка на Точке 1...")
                    local holdThread1 = task.spawn(function()
                        while _G.smartFarmActive and _G.checkItemsCount() < 7 and hum.Health > 0 do
                            holdEKey() task.wait(0.05)
                        end
                    end)
                    while _G.smartFarmActive and _G.checkItemsCount() < 7 and hum.Health > 0 do
                        root.CFrame = CFrame.new(targetPos1) task.wait(0.001)
                    end
                    pcall(function() task.cancel(holdThread1) end)
                    
                    if not _G.smartFarmActive or hum.Health <= 0 then continue end
                    
                    -- ШАГ 2: ТОЧКА 2 (Сдача, стоим пока не станет строго 3-6 предметов)
                    _G.logMessage("[РОБОТ]: Сдача на Точке 2...")
                    local p2_1 = CFrame.new(-83.4, 48.5, 417.9)
                    local p2_2 = CFrame.new(-82.9, 50.1, 431.1)
                    
                    local holdThread2 = task.spawn(function()
                        while _G.smartFarmActive and hum.Health > 0 do
                            local count = _G.checkItemsCount()
                            if count >= 7 or count < 3 then holdEKey() else break end
                            task.wait(0.05)
                        end
                    end)
                    while _G.smartFarmActive and hum.Health > 0 do
                        local items = _G.checkItemsCount()
                        if items >= 7 or items < 3 then
                            root.CFrame = p2_1 task.wait(0.001)
                            root.CFrame = p2_2 task.wait(0.001)
                        else
                            break
                        end
                    end
                    pcall(function() task.cancel(holdThread2) end)
                    
                    if not _G.smartFarmActive or hum.Health <= 0 then continue end
                    
                    -- ШАГ 3: ТОЧКА 3 (Очистка остатков до 2 предметов)
                    local itemsNow = _G.checkItemsCount()
                    if itemsNow >= 3 and itemsNow <= 6 then
                        _G.logMessage("[РОБОТ]: Зачистка на Точке 3...")
                        local p3_1 = CFrame.new(6805.9, 17.4, -33.5)
                        local p3_2 = CFrame.new(6800.1, 17.3, -33.4)
                        
                        local holdThread3 = task.spawn(function()
                            while _G.smartFarmActive and _G.checkItemsCount() > 2 and hum.Health > 0 do
                                holdEKey() task.wait(0.05)
                            end
                        end)
                        while _G.smartFarmActive and _G.checkItemsCount() > 2 and hum.Health > 0 do
                            root.CFrame = p3_1 task.wait(0.001)
                            root.CFrame = p3_2 task.wait(0.001)
                        end
                        pcall(function() task.cancel(holdThread3) end)
                    end
                else
                    task.wait(1)
                end
                task.wait(0.1)
            end
        end)
    else
        SmartFarmBtn.Text = "Умный Автофарм: ВЫКЛ"
        SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
        SmartFarmBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
        _G.logMessage("Умный автофарм остановлен.")
    end
end)

-- КНОПКА: БЫСТРЫЙ РЕСПАВН
local FastRespawnBtn = Instance.new("TextButton")
FastRespawnBtn.Text = "💀 Fast Respawn"
FastRespawnBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 20)
FastRespawnBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
FastRespawnBtn.Font = Enum.Font.GothamBold
FastRespawnBtn.Parent = _G.FarmPage
Instance.new("UICorner", FastRespawnBtn).CornerRadius = UDim.new(0, 6)

FastRespawnBtn.MouseButton1Click:Connect(function()
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for i = 1, 10 do root.CFrame = CFrame.new(root.Position.X, -1000, root.Position.Z) task.wait(0.001) end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end)
-- =============================================================================
-- 🌌 1MORT SPIDER v2.9 // ЧАСТЬ 3: ANTILAG, PATCHED-КНОПКИ И КОНФИГИ (~200 СТРОК)
-- =============================================================================

-- СОЗДАНИЕ ПАНЕЛИ АНТИЛАГА (Белая заливка экрана для буста ФПС)
local AntiLagFrame = Instance.new("Frame")
AntiLagFrame.Name = "AntiLagScreen"
AntiLagFrame.Size = UDim2.new(1, 0, 1, 0)
AntiLagFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
AntiLagFrame.BorderSizePixel = 0
AntiLagFrame.Visible = false
AntiLagFrame.ZIndex = -1 
AntiLagFrame.Parent = MainFrame.Parent 

-- ФУНКЦИЯ СОЗДАНИЯ ТУМБЛЕРОВ РАБОЧИХ ВИЗУАЛОВ
local function createVisualToggle(text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Text = text .. ": ВЫКЛ"
    Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    Btn.TextColor3 = Color3.fromRGB(0, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = _G.ConfigPage
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    
    local enabled = false
    Btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Btn.Text = text .. ": ВКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(0, 120, 150)
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Btn.Text = text .. ": ВЫКЛ"
            Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
            Btn.TextColor3 = Color3.fromRGB(0, 255, 255)
        end
        callback(enabled)
    end)
end

-- Функция создания фейковых заблокированных кнопок [PATCHED] для вкладки Visuals
local function createPatchedVisualButton(text)
    local FakeBtn = Instance.new("TextButton")
    FakeBtn.Text = text .. " [❌ PATCHED]"
    FakeBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 20) 
    FakeBtn.TextColor3 = Color3.fromRGB(150, 50, 50) 
    FakeBtn.Font = Enum.Font.GothamBold
    FakeBtn.Parent = _G.ConfigPage
    Instance.new("UICorner", FakeBtn).CornerRadius = UDim.new(0, 6)
    
    FakeBtn.MouseButton1Click:Connect(function()
        _G.logMessage("[⚠️ ERROR]: Визуальный модуль '" .. text .. "' временно отключен разработчиком софта из-за обхода античита!")
    end)
end

-- РАБОЧИЙ АНТИЛАГ (Заливает экран белым, отключая 3D рендер для ФПС)
createVisualToggle("⚡ AntiLag (Белый экран)", function(val)
    AntiLagFrame.Visible = val
    _G.logMessage("[ANTILAG]: Статус изменен на " .. tostring(val))
end)

-- ДОБАВЛЯЕМ ФЕЙК-ПАТЧИ ДЛЯ ОТВОДА ГЛАЗ (Чтоб софт выглядел дорого)
createPatchedVisualButton("Player ESP Boxes")
createPatchedVisualButton("Player ESP Names")
createPatchedVisualButton("Player ESP Health")
createPatchedVisualButton("Chams / Wallhack")
createPatchedVisualButton("Bullet Tracers")

-- ГОРЯЧАЯ КЛАВИША СКРЫТИЯ МЕНЮ (На кнопку V)
local HideKey = Enum.KeyCode.V 

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == HideKey then
        local mainFrame = ScreenGui:FindFirstChild("MainFrame")
        if mainFrame then
            mainFrame.Visible = not mainFrame.Visible
            _G.logMessage("[SYSTEM]: Видимость изменена клавишей " .. tostring(HideKey.Name))
        end
    end
end)

local HintLabel = Instance.new("TextLabel")
HintLabel.Size = UDim2.new(1, -20, 0, 20)
HintLabel.Position = UDim2.new(0, 10, 1, -25)
HintLabel.BackgroundTransparency = 1
HintLabel.Text = "Нажми [ V ] на клавиатуре, чтобы скрыть/открыть меню"
HintLabel.TextColor3 = Color3.fromRGB(100, 100, 150)
HintLabel.TextSize = 11
HintLabel.Font = Enum.Font.GothamItalic
HintLabel.TextXAlignment = Enum.TextXAlignment.Right
HintLabel.Parent = MainFrame

-- АВТОСОХРАНЕНИЕ Настроек
local currentConfig = {}
local function saveSettings()
    currentConfig.WalkSpeed = _G.speedValue
    currentConfig.ESP_Boxes = _G.ESP_Boxes
    currentConfig.ESP_Names = _G.ESP_Names
    currentConfig.ESP_Health = _G.ESP_Health
    currentConfig.ESP_Trackers = _G.ESP_Trackers

    local success, jsonString = pcall(function() return HttpService:JSONEncode(currentConfig) end)
    if success then
        if writefile then
            writefile(configFileName, jsonString)
            _G.logMessage("[CONFIG]: Настройки успешно сохранены.")
        else
            _G.SpiderConfig = jsonString
        end
    end
end

local SaveConfigBtn = Instance.new("TextButton")
SaveConfigBtn.Text = "💾 Сохранить Настройки"
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.Parent = _G.ConfigPage
Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 6)
SaveConfigBtn.MouseButton1Click:Connect(function() saveSettings() end)

_G.logMessage("==============================================")
_G.logMessage("🌟 ОБНОВЛЕНИЕ 1MORT SPIDER СКОМПИЛИРОВАНА УСПЕШНО!")
_G.logMessage("[STATUS]: Система анти-застревания и AntiLag готовы к работе.")


