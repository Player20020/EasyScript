-- =============================================================================
-- 👑 TITAN DIRECT v5.0 (No-Button, Immediate-Menu)
-- =============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local SelectedSong = ""
local activeConnections = {}

-- 1. ДВИЖОК ПОДМЕНЫ
local function patchSound(sound)
    if not sound:IsA("Sound") or SelectedSong == "" then return end
    
    local name = sound.Name:lower()
    local keywords = {"music", "theme", "bgm", "song", "soundtrack", "plague", "ambient"}
    
    local isMusic = false
    for _, k in ipairs(keywords) do if name:match(k) then isMusic = true break end end
    if not isMusic then return end

    local asset = getcustomasset(SelectedSong)
    if sound.SoundId == asset then return end -- Уже наша музыка

    sound:Stop()
    sound.SoundId = asset
    sound.Looped = true
    sound:Play()

    -- Защита от возврата игры
    if not activeConnections[sound] then
        activeConnections[sound] = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
            if sound.SoundId ~= asset then
                sound:Stop()
                sound.SoundId = asset
                sound:Play()
            end
        end)
    end
end

-- 2. ИНТЕРФЕЙС
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 220, 0, 300)
Frame.Position = UDim2.new(0.5, -110, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
Frame.Draggable = true -- Можно двигать по экрану

-- Заголовок
local Title = Instance.new("TextLabel", Frame)
Title.Text = "TITAN DIRECT"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

-- Кнопка стоп
local StopBtn = Instance.new("TextButton", Frame)
StopBtn.Text = "⏹ STOP MUSIC"
StopBtn.Size = UDim2.new(1, -20, 0, 30)
StopBtn.Position = UDim2.new(0, 10, 0, 40)
StopBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
StopBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

StopBtn.MouseButton1Click:Connect(function()
    SelectedSong = ""
    for sound, conn in pairs(activeConnections) do
        conn:Disconnect()
        sound:Stop()
    end
    activeConnections = {}
end)

-- Список песен
local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1, -20, 1, -90)
List.Position = UDim2.new(0, 10, 0, 80)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 2
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- Обновление списка файлов
for _, path in ipairs(listfiles("")) do
    if path:lower():match("%.mp3$") then
        local btn = Instance.new("TextButton", List)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.Text = path:match("[^\\]+$")
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        
        btn.MouseButton1Click:Connect(function()
            SelectedSong = path
            -- Применяем ко всем звукам в игре
            for _, obj in pairs(game:GetDescendants()) do
                pcall(patchSound, obj)
            end
        end)
    end
end

-- Следим за новыми звуками
game.DescendantAdded:Connect(patchSound)

print("👑 Titan Direct Loaded")
