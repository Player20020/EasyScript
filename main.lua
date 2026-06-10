-- =============================================================================
-- [ MEGA HUB V3 ] - EASY SCRIPT Premium Edition
-- PART 1: CORE UI, ADVANCED TWEEN ENGINE & MODULE LOADER
-- =============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

-- Очистка старых сессий
if CoreGui:FindFirstChild("EasyScript_ProHub") then
    CoreGui.EasyScript_ProHub:Destroy()
end
if Lighting:FindFirstChild("HubBlur") then
    Lighting.HubBlur:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EasyScript_ProHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

getgenv().EasyConfig = {}
getgenv().ModulesLoaded = 0

-- Кастомная библиотека анимаций (Tween Configurations)
local Anim = {
    Intro = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    Outro = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
    Smooth = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Linear)
}

-- Эффект размытия заднего плана (Blur)
local blur = Instance.new("BlurEffect")
blur.Name = "HubBlur"
blur.Size = 0
blur.Enabled = true
blur.Parent = Lighting

-- =============================================================================
-- ОКНО АВТОРИЗАЦИИ С ЭФФЕКТОМ МЯГКОГО ПОЯВЛЕНИЯ
-- =============================================================================
local keyWindow = Instance.new("Frame")
keyWindow.Size = UDim2.new(0, 420, 0, 280)
keyWindow.Position = UDim2.new(0.5, -210, 0.5, -140)
keyWindow.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
keyWindow.BackgroundTransparency = 1 -- Стартует невидимым для анимации
keyWindow.Active = true
keyWindow.Draggable = true
keyWindow.ClipsDescendants = true
keyWindow.Parent = screenGui

Instance.new("UICorner", keyWindow).CornerRadius = UDim.new(0, 12)
local keyGlow = Instance.new("UIStroke", keyWindow)
keyGlow.Thickness = 2
keyGlow.Color = Color3.fromRGB(85, 0, 255)
keyGlow.Transparency = 1

local glowGradient = Instance.new("UIGradient", keyGlow)
glowGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 0, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 0, 255))
}
task.spawn(function()
    while task.wait(0.02) do glowGradient.Rotation = (glowGradient.Rotation + 1) % 360 end
end)

-- Контент окна авторизации
local titleLabel = Instance.new("TextLabel", keyWindow)
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "EASY SCRIPT | PREMIUM"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 22
titleLabel.TextTransparency = 1

local tgLabel = Instance.new("TextLabel", keyWindow)
tgLabel.Size = UDim2.new(1, 0, 0, 30)
tgLabel.Position = UDim2.new(0, 0, 0, 55)
tgLabel.BackgroundTransparency = 1
tgLabel.Text = "Получите доступ в Telegram: @EasyScriptRbx"
tgLabel.TextColor3 = Color3.fromRGB(0, 255, 200)
tgLabel.Font = Enum.Font.GothamMedium
tgLabel.TextSize = 13
tgLabel.TextTransparency = 1

local inputBox = Instance.new("TextBox", keyWindow)
inputBox.Size = UDim2.new(0, 340, 0, 48)
inputBox.Position = UDim2.new(0.5, -170, 0.45, 10)
inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
inputBox.BackgroundTransparency = 1
inputBox.PlaceholderText = "Введите ваш приватный ключ..."
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 8)
local inputStroke = Instance.new("UIStroke", inputBox)
inputStroke.Color = Color3.fromRGB(60, 60, 80)
inputStroke.Transparency = 1

local verifyBtn = Instance.new("TextButton", keyWindow)
verifyBtn.Size = UDim2.new(0, 180, 0, 45)
verifyBtn.Position = UDim2.new(0.5, -90, 0.78, 5)
verifyBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
verifyBtn.BackgroundTransparency = 1
verifyBtn.Text = "АКТИВИРОВАТЬ"
verifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 14
verifyBtn.TextTransparency = 1
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 8)

-- Запуск плавной анимации появления (Intro)
TweenService:Create(blur, Anim.Intro, {Size = 16}):Play()
TweenService:Create(keyWindow, Anim.Intro, {BackgroundTransparency = 0}):Play()
TweenService:Create(keyGlow, Anim.Intro, {Transparency = 0}):Play()
task.wait(0.2)
TweenService:Create(titleLabel, Anim.Smooth, {TextTransparency = 0}):Play()
TweenService:Create(tgLabel, Anim.Smooth, {TextTransparency = 0}):Play()
TweenService:Create(inputBox, Anim.Smooth, {BackgroundTransparency = 0}):Play()
TweenService:Create(inputStroke, Anim.Smooth, {Transparency = 0}):Play()
TweenService:Create(verifyBtn, Anim.Smooth, {BackgroundTransparency = 0, TextTransparency = 0}):Play()

-- =============================================================================
-- ДВИЖОК ГЕНЕРАЦИИ ГЛАВНОГО ИНТЕРФЕЙСА (БИБЛИОТЕКА)
-- =============================================================================
local function LoadMainUI()
    -- Анимация закрытия окна авторизации (Outro)
    TweenService:Create(titleLabel, Anim.Fast, {TextTransparency = 1}):Play()
    TweenService:Create(tgLabel, Anim.Fast, {TextTransparency = 1}):Play()
    TweenService:Create(inputBox, Anim.Fast, {BackgroundTransparency = 1}):Play()
    TweenService:Create(inputStroke, Anim.Fast, {Transparency = 1}):Play()
    TweenService:Create(verifyBtn, Anim.Fast, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    TweenService:Create(keyWindow, Anim.Outro, {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)}):Play()
    task.wait(0.4)
    keyWindow:Destroy()

    -- Кнопка сворачивания меню на экране
    local toggleMenuBtn = Instance.new("TextButton", screenGui)
    toggleMenuBtn.Size = UDim2.new(0, 55, 0, 55)
    toggleMenuBtn.Position = UDim2.new(0, 25, 0, 25)
    toggleMenuBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    toggleMenuBtn.Text = "ES"
    toggleMenuBtn.TextColor3 = Color3.fromRGB(0, 255, 200)
    toggleMenuBtn.Font = Enum.Font.GothamBlack
    toggleMenuBtn.TextSize = 22
    Instance.new("UICorner", toggleMenuBtn).CornerRadius = UDim.new(1, 0)
    local btnStroke = Instance.new("UIStroke", toggleMenuBtn)
    btnStroke.Color = Color3.fromRGB(85, 0, 255)
    btnStroke.Thickness = 2

    local mainWindow = Instance.new("Frame", screenGui)
    mainWindow.Size = UDim2.new(0, 700, 0, 460)
    mainWindow.Position = UDim2.new(0.5, -350, 0.5, -230)
    mainWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    mainWindow.Active = true
    mainWindow.Draggable = true
    mainWindow.Visible = false
    mainWindow.ClipsDescendants = true
    Instance.new("UICorner", mainWindow).CornerRadius = UDim.new(0, 10)
    
    local mainStroke = Instance.new("UIStroke", mainWindow)
    mainStroke.Color = Color3.fromRGB(85, 0, 255)
    mainStroke.Thickness = 2

    local sidebar = Instance.new("Frame", mainWindow)
    sidebar.Size = UDim2.new(0, 175, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    sidebar.BorderSizePixel = 0
    
    local sidebarLayout = Instance.new("UIListLayout", sidebar)
    sidebarLayout.Padding = UDim.new(0, 6)
    sidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local titleBg = Instance.new("Frame", sidebar)
    titleBg.Size = UDim2.new(1, 0, 0, 60)
    titleBg.BackgroundTransparency = 1
    local mainTitle = Instance.new("TextLabel", titleBg)
    mainTitle.Size = UDim2.new(1, 0, 1, 0)
    mainTitle.BackgroundTransparency = 1
    mainTitle.Text = "EASY SCRIPT"
    mainTitle.TextColor3 = Color3.fromRGB(0, 255, 200)
    mainTitle.Font = Enum.Font.GothamBlack
    mainTitle.TextSize = 20

    local tabContainer = Instance.new("Frame", mainWindow)
    tabContainer.Size = UDim2.new(1, -175, 1, 0)
    tabContainer.Position = UDim2.new(0, 175, 0, 0)
    tabContainer.BackgroundTransparency = 1

    -- Анимация развертывания главного меню
    local menuOpen = false
    toggleMenuBtn.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            mainWindow.Visible = true
            mainWindow.Size = UDim2.new(0, 0, 0, 460)
            TweenService:Create(mainWindow, Anim.Intro, {Size = UDim2.new(0, 700, 0, 460)}):Play()
            TweenService:Create(blur, Anim.Smooth, {Size = 16}):Play()
        else
            TweenService:Create(mainWindow, Anim.Outro, {Size = UDim2.new(0, 0, 0, 460)}):Play()
            TweenService:Create(blur, Anim.Smooth, {Size = 0}):Play()
            task.wait(0.4)
            if not menuOpen then mainWindow.Visible = false end
        end
    end)

    local UILibrary = {}
    local currentActiveTab = nil

    function UILibrary:CreateTab(name, icon)
        local tabBtn = Instance.new("TextButton", sidebar)
        tabBtn.Size = UDim2.new(0, 155, 0, 38)
        tabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        tabBtn.Text = icon .. "  " .. name
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

        local scrollPage = Instance.new("ScrollingFrame", tabContainer)
        scrollPage.Size = UDim2.new(1, -20, 1, -20)
        scrollPage.Position = UDim2.new(0, 10, 0, 10)
        scrollPage.BackgroundTransparency = 1
        scrollPage.Visible = false
        scrollPage.ScrollBarThickness = 3
        scrollPage.ScrollBarImageColor3 = Color3.fromRGB(85, 0, 255)
        scrollPage.CanvasSize = UDim2.new(0, 0, 0, 4000) -- Огромный запас под сотни строк
        
        local layout = Instance.new("UIListLayout", scrollPage)
        layout.Padding = UDim.new(0, 6)

        tabBtn.MouseButton1Click:Connect(function()
            if currentActiveTab then currentActiveTab.Visible = false end
            scrollPage.Visible = true
            currentActiveTab = scrollPage
            -- Эффект пульсации кнопки при клике
            TweenService:Create(tabBtn, Anim.Fast, {BackgroundColor3 = Color3.fromRGB(85, 0, 255), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
            task.wait(0.15)
            TweenService:Create(tabBtn, Anim.Smooth, {BackgroundColor3 = Color3.fromRGB(22, 22, 32), TextColor3 = Color3.fromRGB(180, 180, 190)}):Play()
        end)

        if not currentActiveTab then scrollPage.Visible = true currentActiveTab = scrollPage end

        local Elements = {}

        function Elements:AddToggle(title, flag, default)
            getgenv().EasyConfig[flag] = default or false
            local row = Instance.new("Frame", scrollPage)
            row.Size = UDim2.new(1, -10, 0, 42)
            row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(0.7, 0, 1, 0)
            lbl.Position = UDim2.new(0, 15, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = title
            lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(0, 44, 0, 22)
            btn.Position = UDim2.new(1, -55, 0.5, -11)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.Text = ""
            Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame", btn)
            circle.Size = UDim2.new(0, 18, 0, 18)
            circle.Position = UDim2.new(0, 2, 0.5, -9)
            circle.BackgroundColor3 = Color3.fromRGB(160, 160, 170)
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            btn.MouseButton1Click:Connect(function()
                getgenv().EasyConfig[flag] = not getgenv().EasyConfig[flag]
                local state = getgenv().EasyConfig[flag]
                TweenService:Create(circle, Anim.Smooth, {
                    Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    BackgroundColor3 = state and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(160, 160, 170)
                }):Play()
                TweenService:Create(btn, Anim.Fast, {BackgroundColor3 = state and Color3.fromRGB(50, 0, 150) or Color3.fromRGB(35, 35, 45)}):Play()
            end)
        end

        function Elements:AddSlider(title, flag, min, max, default)
            getgenv().EasyConfig[flag] = default or min
            local row = Instance.new("Frame", scrollPage)
            row.Size = UDim2.new(1, -10, 0, 56)
            row.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1, -30, 0, 24)
            lbl.Position = UDim2.new(0, 15, 0, 4)
            lbl.BackgroundTransparency = 1
            lbl.Text = title .. " : " .. tostring(default)
            lbl.TextColor3 = Color3.fromRGB(220, 220, 230)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 13
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local sliderBg = Instance.new("TextButton", row)
            sliderBg.Size = UDim2.new(1, -30, 0, 6)
            sliderBg.Position = UDim2.new(0, 15, 0, 36)
            sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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

    getgenv().EasyUILibrary = UILibrary
    print("[EasyScript Core]: Графическое ядро развернуто. Ожидание модулей функций...")

    -- =============================================================================
    -- АВТОМАТИЧЕСКИЙ ИМПОРТ ДОПОЛНИТЕЛЬНЫХ ПАКЕТОВ РАСШИРЕНИЯ (ЛОАДЕР)
    -- =============================================================================
    task.spawn(function()
        local basePath = "https://raw.githubusercontent.com/Player20020/EasyScript/refs/heads/main/"
        
        local success1, err1 = pcall(function()
            loadstring(game:HttpGet(basePath .. "combat_movement.lua"))()
        end)
        if not success1 then warn("Ошибка сборки боевого модуля: " .. tostring(err1)) end
        
        local success2, err2 = pcall(function()
            loadstring(game:HttpGet(basePath .. "world_automation.lua"))()
        end)
        if not success2 then warn("Ошибка сборки модуля автоматизации: " .. tostring(err2)) end
        
        repeat task.wait(0.1) until getgenv().ModulesLoaded >= 2
        print("[MEGA HUB V3]: Процесс сборки завершен. Более 2000 строк кода успешно инициализированы в рантайме.")
    end)
end

-- Валидация ключа
verifyBtn.MouseButton1Click:Connect(function()
    if inputBox.Text == "EasyScript" then
        verifyBtn.Text = "УСПЕШНО!"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        task.wait(0.4)
        LoadMainUI()
    else
        inputBox.Text = ""
        inputBox.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ! ИЩИ В @EasyScriptRbx"
        verifyBtn.Text = "ОШИБКА"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 50)
        task.wait(1)
        verifyBtn.Text = "АКТИВИРОВАТЬ"
        verifyBtn.BackgroundColor3 = Color3.fromRGB(85, 0, 255)
        inputBox.PlaceholderText = "Введите ваш приватный ключ..."
    end
end)

