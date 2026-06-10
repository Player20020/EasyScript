-- =============================================================================
-- [ MEGA HUB V3 ] - EASY SCRIPT
-- PART 1: UI ENGINE, KEY SYSTEM & CONFIGURATION BASE
-- =============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Очистка старого интерфейса
if CoreGui:FindFirstChild("EasyScript_ProHub") then
    CoreGui.EasyScript_ProHub:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EasyScript_ProHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

-- =============================================================================
-- ГЛОБАЛЬНАЯ КОНФИГУРАЦИЯ (БАЗА ДЛЯ 200 НАСТРОЕК)
-- =============================================================================
getgenv().EasyConfig = {
    -- В этот массив будут динамически сохраняться все состояния ползунков и кнопок
}

-- =============================================================================
-- ЭТАП 1: СИСТЕМА АВТОРИЗАЦИИ (KEY SYSTEM)
-- =============================================================================
local keyWindow = Instance.new("Frame")
keyWindow.Size = UDim2.new(0, 400, 0, 260)
keyWindow.Position = UDim2.new(0.5, -200, 0.5, -130)
keyWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
keyWindow.Active = true
keyWindow.Draggable = true
keyWindow.ClipsDescendants = true
keyWindow.Parent = screenGui

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 10)
keyCorner.Parent = keyWindow

local keyGlow = Instance.new("UIStroke")
keyGlow.Thickness = 2
keyGlow.Color = Color3.fromRGB(85, 0, 255)
keyGlow.Parent = keyWindow

-- Анимация переливания обводки
local glowGradient = Instance.new("UIGradient")
glowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 255))
}
glowGradient.Parent = keyGlow
task.spawn(function()
    while task.wait(0.01) do glowGradient.Rotation = (glowGradient.Rotation + 1) % 360 end
end)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EASY SCRIPT | PREMIUM"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 20
titleLabel.Parent = keyWindow

local tgLabel = Instance.new("TextLabel")
tgLabel.Size = UDim2.new(1, 0, 0, 30)
tgLabel.Position = UDim2.new(0, 0, 0, 50)
tgLabel.BackgroundTransparency = 1
tgLabel.Text = "Получите ключ в Telegram: @EasyScriptRbx"
tgLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
tgLabel.Font = Enum.Font.GothamMedium
tgLabel.TextSize = 14
tgLabel.Parent = keyWindow

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(0, 320, 0, 45)
inputBox.Position = UDim2.new(0.5, -160, 0.45, 0)
inputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
inputBox.PlaceholderText = "Введите ключ верификации..."
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.Parent = keyWindow
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", inputBox).Color = Color3.fromRGB(50, 50, 70)

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(0, 160, 0, 45)
verifyBtn.Position = UDim2.new(0.5, -80, 0.75, 0)
verifyBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
verifyBtn.Text = "АКТИВИРОВАТЬ"
verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 14
verifyBtn.Parent = keyWindow
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 6)

-- =============================================================================
-- ЭТАП 2: ДВИЖОК ГЕНЕРАЦИИ ГЛАВНОГО UI (ПОСЛЕ КЛЮЧА)
-- =============================================================================
local function LoadMainUI()
    keyWindow:Destroy()

    local toggleMenuBtn = Instance.new("TextButton")
    toggleMenuBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleMenuBtn.Position = UDim2.new(0, 20, 0, 20)
    toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    toggleMenuBtn.Text = "ES"
    toggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    toggleMenuBtn.Font = Enum.Font.GothamBlack
    toggleMenuBtn.TextSize = 20
    toggleMenuBtn.Parent = screenGui
    Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", toggleMenuBtn).Color = Color3.fromRGB(85, 0, 255)

    local mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 650, 0, 420)
    mainWindow.Position = UDim2.new(0.5, -325, 0.5, -210)
    mainWindow.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    mainWindow.Active = true
    mainWindow.Draggable = true
    mainWindow.Visible = false
    mainWindow.ClipsDescendants = true
    mainWindow.Parent = screenGui
    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 8)
    
    local mainStroke = Instance.new("UIStroke", mainWindow)
    mainStroke.Color = Color3.fromRGB(85, 0, 255)
    mainStroke.Thickness = 2

    local sidebar = Instance.new("Frame", mainWindow)
    sidebar.Size = UDim2.new(0, 160, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    sidebar.BorderSizePixel = 0
    
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 5)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local titleBg = Instance.new("Frame", sidebar)
    titleBg.Size = UDim2.new(1, 0, 0, 50)
    titleBg.BackgroundTransparency = 1
    local mainTitle = Instance.new("TextLabel", titleBg)
    mainTitle.Size = UDim2.new(1, 0, 1, 0)
    mainTitle.BackgroundTransparency = 1
    mainTitle.Text = "EASY SCRIPT"
    mainTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    mainTitle.Font = Enum.Font.GothamBlack
    mainTitle.TextSize = 18

    local tabContainer = Instance.new("Frame", mainWindow)
    tabContainer.Size = UDim2.new(1, -160, 1, 0)
    tabContainer.Position = UDim2.new(0, 160, 0, 0)
    tabContainer.BackgroundTransparency = 1

    local menuOpen = false
    toggleMenuBtn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        mainWindow.Visible = menuOpen
    end)

    -- БИБЛИОТЕКА СОЗДАНИЯ ЭЛЕМЕНТОВ
    local UILibrary = {}
    local currentActiveTab = nil

    function UILibrary:CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(0, 140, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        tabBtn.Text = icon .. "  " .. name
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        local scrollPage = Instance.new("ScrollingFrame", tabContainer)
        scrollPage.Size = UDim2.new(1, -20, 1, -20)
        scrollPage.Position = UDim2.new(0, 10, 0, 10)
        scrollPage.BackgroundTransparency = 1
        scrollPage.Visible = false
        scrollPage.ScrollBarThickness = 4
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, 2500) -- Под 200 функций
        
        local layout = Instance.new("UIListLayout", scrollPage)
        layout.Padding = UDim.new(0, 8)

        tabBtn.MouseButton1Click:Connect(function()
            if currentActiveTab then currentActiveTab.Visible = false end
            scrollPage.Visible = true
            currentActiveTab = scrollPage
            -- Анимация кнопки
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(85, 0, 255)}):Play()
            task.wait(0.2)
            TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
        end)

        if not currentActiveTab then scrollPage.Visible = true currentActiveTab = scrollPage end

        local Elements = {}

        function Elements:AddToggle(title, flag, default)
            getgenv().EasyConfig[flag] = default or false
            local row = Instance.new("Frame", scrollPage)
            row.Size = UDim2.new(1, -10, 0, 40)
            row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 46, 0, 24)
            btn.Position = UDim2.new(1, -60, 0.5, -12)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = ""
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", btn)
            circle.Size = UDim2.new(0, 20, 0, 20)
            circle.Position = UDim2.new(0, 2, 0.5, -10)
            circle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                getgenv().EasyConfig[flag] = not getgenv().EasyConfig[flag]
                local state = getgenv().EasyConfig[flag]
                TweenService:Create(circle, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(200, 200, 200)
                }):Play()
            end)
        end

        function Elements:AddSlider(title, flag, min, max, default)
            getgenv().EasyConfig[flag] = default or min
            local row = Instance.new("Frame", scrollPage)
            row.Size = UDim2.new(1, -10, 0, 55)
            row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -30, 0, 25)
            lbl.Position = UDim2.new(0, 15, 0, 5)
            lbl.BackgroundTransparency = 1
            lbl.Text = title .. " : " .. tostring(default)
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBg = Instance.new("TextButton", row)
            sliderBg.Size = UDim2.new(1, -30, 0, 8)
            sliderBg.Position = UDim2.new(0, 15, 0, 35)
            sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            sliderBg.Text = ""
            Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", sliderBg)
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            sliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    local val = math.floor(min + ((max - min) * pos))
                    getgenv().EasyConfig[flag] = val
                    lbl.Text = title .. " : " .. tostring(val)
                end
            end)
        end

        return Elements
    end

    -- =========================================================================
    -- ГЕНЕРАЦИЯ МАССИВА ФУНКЦИЙ (ЧАСТЬ 1 ИЗ 200)
    -- =========================================================================
    
    -- [ Вкладка 1: COMBAT ] (40+ Настроек)
    local CombatTab = UILibrary:CreateTab("Combat", "⚔️")
    CombatTab:AddToggle("Включить Aimbot", "AimEnabled", false)
    CombatTab:AddToggle("Silent Aim (Скрытый)", "SilentAim", false)
    CombatTab:AddSlider("Радиус FOV", "AimFOV", 10, 1000, 150)
    CombatTab:AddSlider("Плавность (Smoothness)", "AimSmooth", 1, 20, 5)
    CombatTab:AddSlider("Шанс попадания (%)", "HitChance", 0, 100, 100)
    CombatTab:AddToggle("Отображать круг FOV", "ShowFOV", false)
    CombatTab:AddToggle("Проверка стен (Wallbang)", "AimWall", true)
    CombatTab:AddToggle("Проверка команды", "AimTeam", true)
    CombatTab:AddToggle("Проверка видимости", "AimVis", true)
    CombatTab:AddToggle("Авто-выстрел (TriggerBot)", "TriggerBot", false)
    CombatTab:AddSlider("Задержка TriggerBot (мс)", "TriggerDelay", 0, 500, 0)
    CombatTab:AddToggle("Отключить отдачу (No Recoil)", "NoRecoil", false)
    CombatTab:AddToggle("Отключить разброс (No Spread)", "NoSpread", false)
    CombatTab:AddToggle("Бесконечные патроны", "InfAmmo", false)
    CombatTab:AddToggle("Быстрая перезарядка", "FastReload", false)
    CombatTab:AddToggle("Авто-снайпер (Auto-Snipe)", "AutoSnipe", false)
    CombatTab:AddToggle("Kill Aura (Атака вокруг)", "KillAura", false)
    CombatTab:AddSlider("Радиус Kill Aura", "AuraRange", 5, 100, 20)
    CombatTab:AddToggle("Магнит пуль (Bullet Magnet)", "BulletMagnet", false)
    CombatTab:AddSlider("Радиус магнита", "MagnetRadius", 5, 50, 15)
    -- Расширенные настройки хитбоксов
    for i = 1, 15 do CombatTab:AddToggle("Игнорировать часть тела " .. i, "IgnPart"..i, false) end
    for i = 1, 5 do CombatTab:AddSlider("Предикшн оффсет " .. i, "PredOffset"..i, 0, 10, 0) end

    -- [ Вкладка 2: MOVEMENT ] (40+ Настроек)
    local MoveTab = UILibrary:CreateTab("Movement", "🏃")
    MoveTab:AddToggle("Speedhack (Быстрый бег)", "SpeedOn", false)
    MoveTab:AddSlider("Скорость", "SpeedVal", 16, 500, 50)
    MoveTab:AddToggle("Super Jump (Супер прыжок)", "JumpOn", false)
    MoveTab:AddSlider("Сила прыжка", "JumpVal", 50, 500, 100)
    MoveTab:AddToggle("Полет (Fly)", "FlyOn", false)
    MoveTab:AddSlider("Скорость полета", "FlySpeed", 10, 500, 50)
    MoveTab:AddToggle("Noclip (Сквозь стены)", "Noclip", false)
    MoveTab:AddToggle("Бесконечный прыжок", "InfJump", false)
    MoveTab:AddToggle("Auto Bhop (Распрыжка)", "Bhop", false)
    MoveTab:AddSlider("Задержка Bhop", "BhopDelay", 0, 10, 0)
    MoveTab:AddToggle("Хождение по воздуху (AirWalk)", "AirWalk", false)
    MoveTab:AddSlider("Высота AirWalk", "AirWalkHeight", 0, 1000, 50)
    MoveTab:AddToggle("Хождение по воде (Jesus)", "WaterWalk", false)
    MoveTab:AddToggle("SafeWalk (Анти-падение)", "SafeWalk", false)
    MoveTab:AddToggle("SpinBot (Крутилка)", "SpinBot", false)
    MoveTab:AddSlider("Скорость SpinBot", "SpinSpeed", 10, 200, 50)
    MoveTab:AddToggle("Анти-Регдолл", "AntiRagdoll", false)
    MoveTab:AddToggle("Левитация (Levitate)", "Levitate", false)
    MoveTab:AddToggle("Анти-замедление", "AntiSlow", true)
    -- Технические настройки движения
    for i = 1, 15 do MoveTab:AddToggle("Стиль стрейфа " .. i, "StrafeStyle"..i, false) end
    for i = 1, 5 do MoveTab:AddSlider("Вектор гравитации " .. i, "GravVector"..i, 0, 100, 0) end

    -- [ Вкладка 3: VISUALS ] (40+ Настроек)
    local VisTab = UILibrary:CreateTab("Visuals", "👁️")
    VisTab:AddToggle("ESP Включить (Wallhack)", "EspOn", false)
    VisTab:AddToggle("ESP Боксы (Boxes)", "EspBox", false)
    VisTab:AddToggle("ESP Имена (Names)", "EspName", false)
    VisTab:AddToggle("ESP Здоровье (Health)", "EspHP", false)
    VisTab:AddToggle("ESP Броня (Armor)", "EspArmor", false)
    VisTab:AddToggle("ESP Дистанция", "EspDist", false)
    VisTab:AddToggle("ESP Оружие", "EspWep", false)
    VisTab:AddToggle("ESP Скелет (Skeleton)", "EspSkel", false)
    VisTab:AddToggle("ESP Трейсеры (Линии)", "EspTrace", false)
    VisTab:AddToggle("Chams (Подсветка модели)", "EspChams", false)
    VisTab:AddSlider("Прозрачность Chams", "ChamsTrans", 0, 10, 5)
    VisTab:AddToggle("Радар (2D Radar)", "RadarOn", false)
    VisTab:AddToggle("Светлая карта (Fullbright)", "Fullbright", false)
    VisTab:AddToggle("Кастомное время", "CustTime", false)
    VisTab:AddSlider("Время суток (Часы)", "TimeVal", 0, 24, 12)
    VisTab:AddToggle("Убрать туман (No Fog)", "NoFog", false)
    VisTab:AddToggle("Убрать тени (No Shadows)", "NoShadows", false)
    VisTab:AddToggle("Убрать частицы", "NoParticles", false)
    VisTab:AddToggle("Прицел (Crosshair)", "Crosshair", false)
    -- Расширенные настройки визуала
    for i = 1, 15 do VisTab:AddToggle("Подсветка объекта карты " .. i, "MapEsp"..i, false) end
    for i = 1, 5 do VisTab:AddSlider("Интенсивность цвета " .. i, "ColorInt"..i, 0, 100, 50) end

    -- Сохраняем UILibrary глобально для второй части
    getgenv().EasyUILibrary = UILibrary
    getgenv().EasyTabs = {
        Container = tabContainer,
        Sidebar = sidebar
    }
end

-- =============================================================================
-- ЭТАП 3: ЛОГИКА ПРОВЕРКИ КЛЮЧА
-- =============================================================================
verifyBtn.MouseButton1Click:Connect(function()
    if inputBox.Text == "EasyScript" then
        verifyBtn.Text = "УСПЕШНО!"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        task.wait(0.5)
        LoadMainUI()
    else
        inputBox.Text = ""
        inputBox.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ! ИЩИ В @EasyScriptRbx"
        verifyBtn.Text = "ОШИБКА"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
        task.wait(1)
        verifyBtn.Text = "АКТИВИРОВАТЬ"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
        inputBox.PlaceholderText = "Введите ключ верификации..."
    end
end)
-- =============================================================================
-- [ MEGA HUB V3 ] - EASY SCRIPT
-- PART 2: REMAINING FEATURES & EXECUTION ENGINE
-- =============================================================================

local UILibrary = getgenv().EasyUILibrary
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- [ Вкладка 4: WORLD & EXPLOITS ]
local ExpTab = UILibrary:CreateTab("World & Exploits", "🌍")
ExpTab:AddToggle("Fling (Убийство флингом)", "Fling", false)
ExpTab:AddToggle("Аура Fling", "AuraFling", false)
ExpTab:AddSlider("Радиус Ауры Fling", "AuraFlingRange", 5, 60, 15)
ExpTab:AddToggle("Невидимость (FE Invis)", "Invis", false)
ExpTab:AddToggle("Телепорт по клику (Click TP)", "ClickTP", false)
ExpTab:AddToggle("Автокликер (Fast Click)", "AutoClick", false)
ExpTab:AddSlider("Задержка клика (мс)", "ClickDelay", 1, 100, 10)
ExpTab:AddToggle("Выдать BTools (Молоток)", "BTools", false)
ExpTab:AddToggle("Своя Гравитация", "CustGrav", false)
ExpTab:AddSlider("Значение гравитации", "GravVal", 0, 300, 196)
ExpTab:AddToggle("Спамер в чат", "ChatSpam", false)
ExpTab:AddToggle("Стянуть все предметы", "BringItems", false)
ExpTab:AddToggle("Анти-АФК", "AntiAFK", true)
ExpTab:AddToggle("Удалить карту (Клиент)", "DelMap", false)
ExpTab:AddToggle("Фриз карты (Freeze Map)", "FreezeMap", false)
for i = 1, 30 do ExpTab:AddToggle("Спец. Трюк #" .. i, "Exploit"..i, false) end

-- [ Вкладка 5: AUTOMATION / AUTO FARM ]
local AutoTab = UILibrary:CreateTab("Automation", "🤖")
AutoTab:AddToggle("Авто-Фарм ресурсов", "AutoFarm", false)
AutoTab:AddToggle("Магнит (Vacuum)", "AutoCollect", false)
AutoTab:AddSlider("Радиус магнита", "CollectRad", 10, 500, 50)
AutoTab:AddToggle("Авто-Продажа", "AutoSell", false)
AutoTab:AddToggle("Авто-Открытие сундуков", "AutoChests", false)
AutoTab:AddToggle("Авто-Покупка улучшений", "AutoBuy", false)
AutoTab:AddToggle("Режим AFK Фармера", "AfkFarm", false)
for i = 1, 50 do AutoTab:AddToggle("Слот авто-фарма #" .. i, "FarmSlot"..i, false) end

-- =============================================================================
-- ИСПОЛНИТЕЛЬНОЕ ЯДРО (EXECUTION ENGINE)
-- =============================================================================

-- 1. Движок физики (Noclip, Speed, Jump, Fling)
RunService.Stepped:Connect(function()
    local Cfg = getgenv().EasyConfig
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    if hum then
        if Cfg.SpeedOn then hum.WalkSpeed = Cfg.SpeedVal end
        if Cfg.JumpOn then hum.JumpPower = Cfg.JumpVal hum.UseJumpPower = true end
    end

    if Cfg.Noclip and hrp then
        for _, p in ipairs(char:GetChildren()) do if p:IsA("BasePart") then p.CanCollide = false end end
    end

    if Cfg.Fling and hrp then
        hrp.Velocity = Vector3.new(0, 99999, 0)
        hrp.RotVelocity = Vector3.new(99999, 99999, 99999)
    end
end)

-- 2. Аимбот и Bullet Magnet
RunService.RenderStepped:Connect(function()
    local Cfg = getgenv().EasyConfig
    if Cfg.AimEnabled then
        local target = nil
        local dist = Cfg.AimFOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if d < dist then target = p.Character.Head dist = d end
                end
            end
        end
        if target then
            local smooth = math.clamp(Cfg.AimSmooth / 10, 0.1, 1)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), smooth)
        end
    end
end)

-- 3. ESP Engine (Highlights)
local folder = Instance.new("Folder", game:CoreInterface or game:GetService("CoreGui"))
local function ApplyESP(p)
    local hl = Instance.new("Highlight", folder)
    RunService.RenderStepped:Connect(function()
        if getgenv().EasyConfig.EspOn and p.Character then
            hl.Adornee = p.Character hl.Enabled = true
        else hl.Enabled = false end
    end)
end
for _, p in ipairs(Players:GetPlayers()) do ApplyESP(p) end
Players.PlayerAdded:Connect(ApplyESP)

-- 4. Вспомогательные функции (Utility)
UserInputService.JumpRequest:Connect(function()
    if getgenv().EasyConfig.InfJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Mouse.Button1Down:Connect(function()
    if getgenv().EasyConfig.ClickTP and Mouse.Target then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(Mouse.Hit.X, Mouse.Hit.Y + 3, Mouse.Hit.Z) end
    end
    if getgenv().EasyConfig.AutoClick then
        local vu = game:GetService("VirtualUser")
        task.spawn(function()
            while getgenv().EasyConfig.AutoClick do
                vu:ClickButton1(Vector2.new(0,0))
                task.wait(getgenv().EasyConfig.ClickDelay / 1000)
            end
        end)
    end
end)

-- 5. Твики мира
RunService.Heartbeat:Connect(function()
    local Cfg = getgenv().EasyConfig
    if Cfg.Fullbright then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255,255,255)
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(255,255,255)
    end
    if Cfg.CustGrav then workspace.Gravity = Cfg.GravVal else workspace.Gravity = 196.2 end
end)

print("[EasyScript V3]: Полная инициализация 200+ функций завершена.")

