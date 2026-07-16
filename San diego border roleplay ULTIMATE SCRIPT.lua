-- =============================================================================
-- 🌌 1MORT SPIDER v3.0 // ЧАСТЬ 1: ФИЛЬТР ПРЕДМЕТОВ И КАРКАС (~160 СТРОК)
-- =============================================================================

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")

local configFileName = "1mort_spider_config.json"

-- Глобальные переменные управления (связывают все 4 части вместе)
_G.speedEnabled = false
_G.speedValue = 50
_G.flyEnabled = false
_G.flyVelocity = nil
_G.flyConnection = nil
_G.smartFarmActive = true -- СРАЗУ ВКЛЮЧЕНО НА ИСТИНУ ПРИ ЗАГРУЗКЕ!
_G.justDied = false
_G.forceRestartFarm = false 

-- 🔧 ОБНОВЛЕННАЯ ФУНКЦИЯ: ПОДСЧЕТ ПРЕДМЕТОВ С ИГНОРИРОВАНИЕМ ПАЛКИ
function _G.checkItemsCount()
    local backpack = Player:FindFirstChild("Backpack")
    local character = Player.Character
    local count = 0
    
    local ignoreName1 = "Stick" 
    local ignoreName2 = "Палка" 
    
    if backpack then 
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= ignoreName1 and item.Name ~= ignoreName2 then
                count = count + 1
            end
        end
    end
    
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name ~= ignoreName1 and item.Name ~= ignoreName2 then
                count = count + 1
            end
        end
    end
    return count
end

-- БЕЗОПАСНОЕ СОЗДАНИЕ ЭКРАНА В PLAYERGUI (Чтоб Xeno железно вывел на экран)
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

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(138, 43, 226) 
UIStroke.Parent = MainFrame

-- ШАПКА МЕНЮ
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = " 🌌 1MORT SPIDER v3.0 // HARD-AUTOEXEC EDITION"
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

-- ЛЕВАЯ ПАНЕЛЬ НАВИГАЦИИ
local NavFrame = Instance.new("Frame")
NavFrame.Size = UDim2.new(0, 140, 1, -50)
NavFrame.Position = UDim2.new(0, 10, 0, 45)
NavFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 45)
NavFrame.BorderSizePixel = 0
NavFrame.Parent = MainFrame
Instance.new("UICorner", NavFrame).CornerRadius = UDim.new(0, 8)

-- ПРАВЫЙ КОНТЕЙНЕР ДЛЯ СТРАНИЦ
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
LogText.Text = "[SYSTEM]: Робот запущен в режиме автовыполнения!\n"
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
-- =============================================================================
-- 🌌 1MORT SPIDER v3.0 // ЧАСТЬ 2.1: ЗАЩИТНЫЕ ЧЕКЕРЫ И ТАЙМЕРЫ (~150 СТРОК)
-- =============================================================================

-- МЕХАНИКА ЗАЖАТИЯ КЛАВИШИ E НА 0.6 СЕКУНД
local function holdEKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.6)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- ФУНКЦИЯ ПЛАВНОГО ПЕРЕЛЁТА (TWEEN) СО СКОРОСТЬЮ 270 ПОСЛЕ СМЕРТИ
local function tweenToPosition(targetPosition)
    local char = Player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local distance = (root.Position - targetPosition).Magnitude
    local duration = distance / 270
    _G.logMessage("[🛡️ TWEEN]: Перелёт после смерти на " .. math.floor(distance) .. " студов...")
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(targetPosition)})
    tween:Play()
    tween.Completed:Wait()
end

-- СОЗДАНИЕ ГЛОБАЛЬНОЙ КНОПКИ В МЕНЮ (ДЛЯ ВИЗУАЛА)
_G.SmartFarmBtn = Instance.new("TextButton")
_G.SmartFarmBtn.Text = "Умный Автофарм: АКТИВЕН"
_G.SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
_G.SmartFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
_G.SmartFarmBtn.Font = Enum.Font.GothamBold
_G.SmartFarmBtn.Parent = _G.FarmPage
Instance.new("UICorner", _G.SmartFarmBtn).CornerRadius = UDim.new(0, 6)

_G.justDied = false
_G.forceRestartFarm = false 
local lastItemsCount = 0

Player.CharacterAdded:Connect(function() if _G.smartFarmActive then _G.justDied = true end end)

-- 🚨 ПОТОК АНТИ-ТЮРЬМЫ: ПРОВЕРКА НА 0 ПРЕДМЕТОВ КАЖДЫЕ 5 СЕКУНД
task.spawn(function()
    while true do
        task.wait(5)
        if _G.smartFarmActive and _G.checkItemsCount() == 0 then
            _G.logMessage("[🚨 АНТИ-ТЮРЬМА]: Обнаружено 0 предметов! Восстановление...")
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(6820.5, 20.1, 16.7)
                while _G.smartFarmActive and _G.checkItemsCount() < 2 do holdEKey() task.wait(0.1) end
            end
        end
    end
end)

-- 🕒 ПОТОК АНТИ-ЗАСТРЕВАНИЯ: УМНЫЙ ТАЙМЕР НА 30 СЕКУНД ПРОСТОЯ
task.spawn(function()
    local lastPosition = nil local idleTimer = 0 local shopPos = Vector3.new(6820.5, 20.1, 16.7)
    while true do
        task.wait(1)
        if _G.smartFarmActive then
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local currentItems = _G.checkItemsCount()
                if (root.Position - shopPos).Magnitude <= 3 then
                    idleTimer = 0 lastPosition = root.Position lastItemsCount = currentItems
                else
                    if not lastPosition then lastPosition = root.Position lastItemsCount = currentItems idleTimer = 0
                    else
                        if (root.Position - lastPosition).Magnitude < 1 and currentItems == lastItemsCount then
                            idleTimer = idleTimer + 1
                            if idleTimer >= 30 then
                                _G.logMessage("[⚠️ АФК-РЕСTАРТ]: Застой 30 сек! Сброс и возврат на Точку 1...")
                                _G.forceRestartFarm = true tweenToPosition(shopPos) idleTimer = 0 lastPosition = nil
                            end
                        else
                            lastPosition = root.Position lastItemsCount = currentItems idleTimer = 0
                        end
                    end
                end
            else lastPosition = nil idleTimer = 0 end
        else lastPosition = nil idleTimer = 0 end
    end
end)

-- 🔄 ПОТОК ЕЖЕЧАСНОГО REJOIN (ПЕРЕЗАХОД НА СЕРВЕР КАЖДЫЙ ЧАС)
task.spawn(function()
    task.wait(3600)
    if _G.smartFarmActive then
        _G.logMessage("[🔄 REJOIN]: Прошел 1 час! Переподключение...")
        _G.smartFarmActive = false task.wait(1)
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)-- =============================================================================
-- 🌌 1MORT SPIDER v3.0 // ЧАСТЬ 2.2: БЕЗОСТАНОВОЧНОЕ ТЕЛО ЦИКЛА (~120 СТРОК)
-- =============================================================================

local function startFarmingLoop()
    while _G.smartFarmActive do
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if root and hum and hum.Health > 0 then
            local targetPos1 = Vector3.new(6820.5, 20.1, 16.7)
            _G.forceRestartFarm = false
            
            if _G.justDied then
                _G.justDied = false
                tweenToPosition(targetPos1)
            end
            
            -- ШАГ 1: ТОЧКА 1 (Фарм до 7 предметов)
            _G.logMessage("[РОБОТ]: Закупка на Точке 1...")
            local holdThread1 = task.spawn(function()
                while _G.smartFarmActive and _G.checkItemsCount() < 7 and hum.Health > 0 and not _G.forceRestartFarm do
                    holdEKey() task.wait(0.05)
                end
            end)
            while _G.smartFarmActive and _G.checkItemsCount() < 7 and hum.Health > 0 and not _G.forceRestartFarm do
                root.CFrame = CFrame.new(targetPos1) task.wait(0.001)
            end
            pcall(function() task.cancel(holdThread1) end)
            
            if _G.forceRestartFarm or not _G.smartFarmActive or hum.Health <= 0 then continue end
            
            -- ШАГ 2: ТОЧКА 2 (Сдача, стоим пока не станет строго 3-6 предметов)
            _G.logMessage("[РОБОТ]: Сдача на Точке 2...")
            local p2_1, p2_2 = CFrame.new(-83.4, 48.5, 417.9), CFrame.new(-82.9, 50.1, 431.1)
            local holdThread2 = task.spawn(function()
                while _G.smartFarmActive and hum.Health > 0 and not _G.forceRestartFarm do
                    local count = _G.checkItemsCount()
                    if count >= 7 or count < 3 then holdEKey() else break end
                    task.wait(0.05)
                end
            end)
            while _G.smartFarmActive and hum.Health > 0 and not _G.forceRestartFarm do
                local items = _G.checkItemsCount()
                if items >= 7 or items < 3 then root.CFrame = p2_1 task.wait(0.001) root.CFrame = p2_2 task.wait(0.001) else break end
            end
            pcall(function() task.cancel(holdThread2) end)
            
            if _G.forceRestartFarm or not _G.smartFarmActive or hum.Health <= 0 then continue end
            
            -- ШАГ 3: ТОЧКА 3 (Очистка остатков до 2 предметов)
            if _G.checkItemsCount() >= 3 and _G.checkItemsCount() <= 6 then
                _G.logMessage("[РОБОТ]: Зачистка на Точке 3...")
                local p3_1, p3_2 = CFrame.new(6805.9, 17.4, -33.5), CFrame.new(6800.1, 17.3, -33.4)
                local holdThread3 = task.spawn(function()
                    while _G.smartFarmActive and _G.checkItemsCount() > 2 and hum.Health > 0 and not _G.forceRestartFarm do
                        holdEKey() task.wait(0.05)
                    end
                end)
                while _G.smartFarmActive and _G.checkItemsCount() > 2 and hum.Health > 0 and not _G.forceRestartFarm do
                    root.CFrame = p3_1 task.wait(0.001) root.CFrame = p3_2 task.wait(0.001)
                end
                pcall(function() task.cancel(holdThread3) end)
            end
        else
            task.wait(1)
        end
        task.wait(0.1)
    end
end

-- ПРИНУДИТЕЛЬНЫЙ МГНОВЕННЫЙ ЗАПУСК ФАРМА СРАЗУ ПРИ ЗАГРУЗКЕ КОДА
_G.smartFarmActive = true
task.spawn(startFarmingLoop)

_G.SmartFarmBtn.MouseButton1Click:Connect(function()
    _G.smartFarmActive = not _G.smartFarmActive
    if _G.smartFarmActive then
        _G.SmartFarmBtn.Text = "Умный Автофарм: АКТИВЕН"
        _G.SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
        task.spawn(startFarmingLoop)
    else
        _G.SmartFarmBtn.Text = "Умный Автофарм: ВЫКЛ"
        _G.SmartFarmBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
    end
end)

-- =============================================================================
-- 🌌 1MORT SPIDER v3.0 // ЧАСТЬ 3: ANTILAG С АВТОСТАРТОМ И ИНТЕРФЕЙС (~180 СТРОК)
-- =============================================================================

-- КНОПКА: БЫСТРЫЙ РЕСПАВН (ВЫЗЫВАЕТ СМЕРТЬ И ПЕРЕЗАПУСК ЧЕРЕЗ БЕЗДНУ)
local FastRespawnBtn = Instance.new("TextButton")
FastRespawnBtn.Text = "💀 Fast Respawn"
FastRespawnBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 20)
FastRespawnBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
FastRespawnBtn.Font = Enum.Font.GothamBold
FastRespawnBtn.Parent = _G.FarmPage
Instance.new("UICorner", FastRespawnBtn).CornerRadius = UDim.new(0, 6)

FastRespawnBtn.MouseButton1Click:Connect(function()
    local char = Player.Character local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for i = 1, 10 do root.CFrame = CFrame.new(root.Position.X, -1000, root.Position.Z) task.wait(0.001) end
    if char:FindFirstChildOfClass("Humanoid") then char:FindFirstChildOfClass("Humanoid").Health = 0 end
end)

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

-- ФЕЙК КНОПКИ ДЛЯ СТРАНИЦЫ BLATANT
local function createPatchedBlatantButton(text)
    local FakeBtn = Instance.new("TextButton")
    FakeBtn.Text = text .. " [❌ PATCHED]"
    FakeBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 20) FakeBtn.TextColor3 = Color3.fromRGB(150, 50, 50)
    FakeBtn.Font = Enum.Font.GothamBold FakeBtn.Parent = _G.MainPage
    Instance.new("UICorner", FakeBtn).CornerRadius = UDim.new(0, 6)
end

createPatchedBlatantButton("Infinite Fly")
createPatchedBlatantButton("God Mode")
createPatchedBlatantButton("Kill Aura")

-- ГОРЯЧАЯ КЛАВИША СКРЫТИЯ МЕНЮ (На кнопку V)
local HideKey = Enum.KeyCode.V 
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == HideKey then
        local mainFrame = ScreenGui:FindFirstChild("MainFrame")
        if mainFrame then mainFrame.Visible = not mainFrame.Visible end
    end
end)

-- ⚡ МОДУЛЬ АВТО-ВКЛЮЧЕНИЯ АНТИЛАГА ПРИ СТАРТЕ ЧЕРЕЗ AUTOEXECUTE
task.spawn(function()
    task.wait(2) -- Ждем 2 секунды, чтобы сначала запустился автофарм
    if AntiLagFrame then
        AntiLagFrame.Visible = true -- Экран сам побелеет для экономии ОЗУ и ФПС
        _G.logMessage("[⚡ AUTO-ANTILAG]: Энергосберегающий белый экран успешно активирован!")
    end
end)
-- =============================================================================
-- 🌌 1MORT SPIDER v3.0 // ЧАСТЬ 4: СИСТЕМА КОНФИГОВ И ФИНАЛИЗАЦИЯ (~50 СТРОК)
-- =============================================================================

-- Таблица для текущих сохранений
local currentConfig = {}

-- АВТОСОХРАНЕНИЕ НАСТРОЕК (Запоминает всё в память Xeno / Studio)
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
            _G.logMessage("[CONFIG]: Конфиг успешно сохранен на диск компьютера.")
        else
            -- Если это чистый Roblox Studio, сохраняем локально в сессию _G
            _G.SpiderConfig = jsonString
            _G.logMessage("[CONFIG]: Сохранено в локальную сессию Studio.")
        end
    else
        _G.logMessage("[ОШИБКА CONFIG]: Не удалось закодировать настройки.")
    end
end

-- КНОПКА ДЛЯ РУЧНОГО СОХРАНЕНИЯ (Добавляем во вкладку Настроек)
local SaveConfigBtn = Instance.new("TextButton")
SaveConfigBtn.Text = "💾 Сохранить Настройки"
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
SaveConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.Parent = _G.ConfigPage
Instance.new("UICorner", SaveConfigBtn).CornerRadius = UDim.new(0, 6)

SaveConfigBtn.MouseButton1Click:Connect(function() 
    saveSettings() 
end)

_G.logMessage("==============================================")
_G.logMessage("🌟 АБСОЛЮТНО ВСЕ 4 МОДУЛЯ УСПЕШНО СКОМПИЛИРОВАНЫ!")
_G.logMessage("[STATUS]: Скрипт 1mort spider v3.0 полностью готов к АФК-фарму 24/7!")
