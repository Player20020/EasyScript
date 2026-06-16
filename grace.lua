-- =============================================================================
-- 👑 TITAN MUSIC MANAGER - FULL VERSION (Mobile Optimized)
-- =============================================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Настройки по умолчанию
local TitanConfig = {
    Enabled = false, 
    CurrentSong = "",
    VolumeMultiplier = 1,
    LoopSong = true,
    ScanInterval = 1.0
}

local activeCustomAssets = {}
local processedSounds = {} -- Хранит ссылки на звуки, которые мы подменили

-- --- ФУНКЦИИ ЯДРА ---

local function getMp3Files()
    if not listfiles then return {} end
    local files = listfiles("")
    local mp3s = {}
    for _, path in ipairs(files) do
        -- Ищем файлы, заканчивающиеся строго на .mp3
        if path:lower():match("%.mp3$") then 
            table.insert(mp3s, path) 
        end
    end
    return mp3s
end

-- Останавливает всю музыку, которую мы подменили
local function stopAllManagedSounds()
    for sound, _ in pairs(processedSounds) do
        if sound and sound:IsA("Sound") then
            pcall(function()
                sound:Stop()
                sound.TimePosition = 0
            end)
        end
    end
    processedSounds = {} 
end

local function patchSound(sound)
    if not TitanConfig.Enabled or not sound.Playing then return end
    if TitanConfig.CurrentSong == "" then return end
    
    -- Проверка: это музыка?
    local name = sound.Name:lower()
    local keywords = {"music", "theme", "bgm", "song", "soundtrack", "ultersonic", "faith", "plague"}
    local isMusic = false
    for _, k in ipairs(keywords) do if name:match(k) then isMusic = true break end end
    if not isMusic then return end

    -- Если звук уже наш — просто правим громкость, не лезем в ID
    if processedSounds[sound] == TitanConfig.CurrentSong then 
        sound.Volume = sound.Volume * TitanConfig.VolumeMultiplier
        return 
    end
    
    processedSounds[sound] = TitanConfig.CurrentSong
    
    local success, asset = pcall(function() return getcustomasset(TitanConfig.CurrentSong) end)
    if success and asset then
        sound:Stop()
        sound.SoundId = asset
        sound.Looped = TitanConfig.LoopSong
        sound.Volume = sound.Volume * TitanConfig.VolumeMultiplier
        sound:Play()
    end
end

-- Фоновый поток-сканер
task.spawn(function()
    while true do
        if TitanConfig.Enabled then
            for _, obj in pairs(game:GetDescendants()) do
                pcall(patchSound, obj)
            end
        end
        task.wait(TitanConfig.ScanInterval)
    end
end)

-- --- ИНТЕРФЕЙС (GUI) ---

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TitanMusicMenu"

-- Кнопка для скрытия/открытия
local ToggleGuiBtn = Instance.new("TextButton", ScreenGui)
ToggleGuiBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleGuiBtn.Position = UDim2.new(0, 10, 0.5, -25)
ToggleGuiBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ToggleGuiBtn.Text = "🎵"
ToggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Меню
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Заголовок и статус
local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "TITAN: OFF"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1

-- Кнопка ВКЛ/ВЫКЛ
local PowerBtn = Instance.new("TextButton", MainFrame)
PowerBtn.Size = UDim2.new(0, 200, 0, 40)
PowerBtn.Position = UDim2.new(0.5, -100, 0.2, 0)
PowerBtn.Text = "ВКЛ / ВЫКЛ"
PowerBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
Instance.new("UICorner", PowerBtn).CornerRadius = UDim.new(0, 6)

-- Список песен
local ScrollList = Instance.new("ScrollingFrame", MainFrame)
ScrollList.Size = UDim2.new(0, 220, 0, 120)
ScrollList.Position = UDim2.new(0.5, -110, 0.5, 20)
ScrollList.CanvasSize = UDim2.new(0,0,2,0)

-- Логика переключения меню
ToggleGuiBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Логика кнопки питания
PowerBtn.MouseButton1Click:Connect(function()
    TitanConfig.Enabled = not TitanConfig.Enabled
    if TitanConfig.Enabled then
        Title.Text = "TITAN: ON"
        PowerBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    else
        Title.Text = "TITAN: OFF"
        PowerBtn.BackgroundColor3 = Color3.fromRGB(231, 76, 60)
        stopAllManagedSounds()
    end
end)

-- Обновление списка
local function refresh()
    ScrollList:ClearAllChildren()
    local files = getMp3Files()
    for _, file in ipairs(files) do
        local btn = Instance.new("TextButton", ScrollList)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Text = file
        btn.MouseButton1Click:Connect(function()
            TitanConfig.CurrentSong = file
            stopAllManagedSounds() -- Смена трека = остановка старого
        end)
    end
end
refresh()

print("👑 [TITAN ONLINE]: Меню загружено.")

