-- =============================================================================
-- 👑 TITAN MUSIC MANAGER v4.0 (Premium Mobile Edition)
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local TitanConfig = {
    Enabled = false, 
    CurrentSong = "",
    VolumeMultiplier = 1.0,
    LoopSong = true
}

local activeCustomAssets = {}
local trackedSounds = {}

-- Проверка эксплоита
if not getcustomasset or not listfiles then
    warn("💥 [TITAN]: Твой инжектор не поддерживает listfiles или getcustomasset!")
    return
end

-- Фильтр MP3 файлов
local function getMp3Files()
    local files = pcall(listfiles, "") and listfiles("") or {}
    local mp3s = {}
    for _, path in ipairs(files) do
        if path:lower():match("%.mp3$") then 
            table.insert(mp3s, path) 
        end
    end
    return mp3s
end

-- Проверка, музыка ли это
local function isGameMusic(sound)
    if not sound:IsA("Sound") then return false end
    local name = sound.Name:lower()
    local keywords = {"music", "theme", "bgm", "song", "soundtrack", "ambient", "faith", "plague"}
    for _, k in ipairs(keywords) do if name:match(k) then return true end end
    return false
end

-- Жесткая подмена звука
local function forcePatch(sound)
    if not TitanConfig.Enabled or TitanConfig.CurrentSong == "" then return end
    if not isGameMusic(sound) then return end

    -- Если ассет еще не создан, создаем один раз
    if not activeCustomAssets[TitanConfig.CurrentSong] then
        local success, asset = pcall(function() return getcustomasset(TitanConfig.CurrentSong) end)
        if success then activeCustomAssets[TitanConfig.CurrentSong] = asset end
    end

    local myAsset = activeCustomAssets[TitanConfig.CurrentSong]
    if myAsset and sound.SoundId ~= myAsset then
        sound:Stop()
        sound.SoundId = myAsset
        sound.Looped = TitanConfig.LoopSong
        sound.Volume = sound.Volume * TitanConfig.VolumeMultiplier
        sound:Play() -- Принудительный старт!
        
        -- Защита от попыток игры вернуть старый трек
        if not trackedSounds[sound] then
            trackedSounds[sound] = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
                if TitanConfig.Enabled and sound.SoundId ~= myAsset then
                    sound:Stop()
                    sound.SoundId = myAsset
                    sound:Play()
                end
            end)
        end
    end
end

-- Сканирование только при включении (без лагающих циклов)
local function scanAllActiveSounds()
    local services = {game:GetService("SoundService"), workspace, LocalPlayer:FindFirstChild("PlayerGui")}
    for _, service in ipairs(services) do
        if service then
            for _, desc in ipairs(service:GetDescendants()) do
                pcall(forcePatch, desc)
            end
        end
    end
end

-- Отключение мода
local function disableTitan()
    TitanConfig.Enabled = false
    for sound, connection in pairs(trackedSounds) do
        if connection then connection:Disconnect() end
        if sound and sound:IsA("Sound") then
            pcall(function() sound:Stop() end)
        end
    end
    trackedSounds = {}
end

-- Слушатель новых звуков (ивентовый метод — 0% нагрузки на ЦП)
game.DescendantAdded:Connect(function(desc)
    if TitanConfig.Enabled then
        task.wait(0.1) -- Даем движку время инициализировать свойства звука
        pcall(forcePatch, desc)
    end
end)


-- =============================================================================
-- UI ИНТЕРФЕЙС (Красивый, современный, адаптивный)
-- =============================================================================

local targetContainer = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if targetContainer:FindFirstChild("TitanMusicSystem") then targetContainer.TitanMusicSystem:Destroy() end

local ScreenGui = Instance.new("ScreenGui", targetContainer)
ScreenGui.Name = "TitanMusicSystem"
ScreenGui.ResetOnSpawn = false

-- 🎵 Идеально круглая плавающая кнопка
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleGuiBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
ToggleGuiBtn.Text = "🎵"
ToggleGuiBtn.TextSize = 20
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleGuiBtn.Font = Enum.Font.GothamBold
ToggleGuiBtn.BorderSizePixel = 0
ToggleGuiBtn.ZIndex = 10

local ButtonCorner = Instance.new("UICorner", ToggleGuiBtn)
ButtonCorner.CornerRadius = UDim.new(1, 0) -- Делает круглым

local ButtonStroke = Instance.new("UIStroke", ToggleGuiBtn)
ButtonStroke.Color = Color3.fromRGB(80, 80, 90)
ButtonStroke.Width = 2

-- Скрипт перетаскивания кнопки (Поддерживает пальцы на телефоне)
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    ToggleGuiBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

ToggleGuiBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleGuiBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
ToggleGuiBtn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)


-- Главное красивое меню
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 340)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 50)
MainStroke.Width = 1

-- Логика скрытия/открытия панели
ToggleGuiBtn.MouseButton1Click:Connect(function()
    if not dragging then -- Защита от открытия при перетаскивании
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Заголовок меню
local Header = Instance.new("TextLabel", MainFrame)
Header.Size = UDim2.new(1, 0, 0, 40)
Header.Text = "TITAN AUDIO RULER"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 14
Header.BackgroundTransparency = 1

-- Кнопка ПИТАНИЯ (ВКЛ / ВЫКЛ)
local PowerBtn = Instance.new("TextButton", MainFrame)
PowerBtn.Size = UDim2.new(1, -30, 0, 40)
PowerBtn.Position = UDim2.new(0, 15, 0, 50)
PowerBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
PowerBtn.Text = "СИСТЕМА: ВЫКЛЕНА"
PowerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerBtn.Font = Enum.Font.GothamBold
PowerBtn.TextSize = 12
Instance.new("UICorner", PowerBtn).CornerRadius = UDim.new(0, 8)

-- Список треков
local ListTitle = Instance.new("TextLabel", MainFrame)
ListTitle.Size = UDim2.new(1, -30, 0, 20)
ListTitle.Position = UDim2.new(0, 15, 0, 105)
ListTitle.Text = "Выбери свой MP3 трек:"
ListTitle.TextColor3 = Color3.fromRGB(150, 150, 155)
ListTitle.Font = Enum.Font.GothamMedium
ListTitle.TextSize = 11
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.BackgroundTransparency = 1

local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(1, -30, 0, 180)
ScrollList.Position = UDim2.new(0, 15, 0, 130)
ScrollList.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 2
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", ScrollList).CornerRadius = UDim.new(0, 6)

local UIListLayout = Instance.new("UIListLayout", ScrollList)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Обновление списка MP3
local function refreshUiList()
    for _, child in ipairs(ScrollList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local files = getMp3Files()
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, #files * 35)
    
    for _, file in ipairs(files) do
        local SongBtn = Instance.new("TextButton", ScrollList)
        SongBtn.Size = UDim2.new(1, -4, 0, 30)
        SongBtn.BackgroundColor3 = (TitanConfig.CurrentSong == file) and Color3.fromRGB(52, 152, 219) or Color3.fromRGB(25, 25, 30)
        SongBtn.Text = "  " .. file:sub(1, 30) -- Обрезка длинных имен
        SongBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
        SongBtn.Font = Enum.Font.Gotham
        SongBtn.TextSize = 11
        SongBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", SongBtn).CornerRadius = UDim.new(0, 4)
        
        SongBtn.MouseButton1Click:Connect(function()
            TitanConfig.CurrentSong = file
            refreshUiList()
            if TitanConfig.Enabled then
                scanAllActiveSounds() -- Сразу пушим новый трек, если мод активен
            end
        end)
    end
end

-- Работа кнопки питания
PowerBtn.MouseButton1Click:Connect(function()
    if not TitanConfig.Enabled then
        if TitanConfig.CurrentSong == "" then
            PowerBtn.Text = "СНАЧАЛА ВЫБЕРИ ТРЕК!"
            task.wait(1)
            PowerBtn.Text = "СИСТЕМА: ВЫКЛЕНА"
            return
        end
        TitanConfig.Enabled = true
        PowerBtn.Text = "СИСТЕМА: АКТИВНА"
        PowerBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        scanAllActiveSounds() -- Моментальный форсированный старт музыки
    else
        disableTitan()
        PowerBtn.Text = "СИСТЕМА: ВЫКЛЕНА"
        PowerBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
    end
end)

refreshUiList()
