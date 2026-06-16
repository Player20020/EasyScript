-- =============================================================================
-- 👑 TITAN AUTO-PATCHER v6.0 (Event-Driven / Zero-Lag)
-- =============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local SelectedSong = ""
local trackedSounds = {}

-- 1. ДВИЖОК ОХОТЫ
local function patchSound(sound)
    if not sound:IsA("Sound") or SelectedSong == "" then return end
    
    -- Фильтр: это музыка?
    local name = sound.Name:lower()
    local keywords = {"music", "theme", "bgm", "song", "soundtrack", "plague", "ambient"}
    local isMusic = false
    for _, k in ipairs(keywords) do if name:match(k) then isMusic = true break end end
    if not isMusic then return end

    local asset = getcustomasset(SelectedSong)
    
    -- Замена, если ID другой
    if sound.SoundId ~= asset then
        sound:Stop()
        sound.SoundId = asset
        sound.Looped = true
        sound:Play()
    end
end

-- 2. СЛУШАТЕЛЬ (Охотится за началом музыки)
local function monitorSound(sound)
    if not sound:IsA("Sound") or trackedSounds[sound] then return end
    trackedSounds[sound] = true

    -- Срабатывает, когда звук начинает играть (например, начался раунд)
    sound:GetPropertyChangedSignal("Playing"):Connect(function()
        if sound.Playing then
            patchSound(sound)
        end
    end)
    
    -- Срабатывает, если игра пытается сменить ID обратно
    sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        if sound.Playing then
            patchSound(sound)
        end
    end)
end

-- Инициализация: мониторим всё, что есть и что будет
for _, obj in pairs(game:GetDescendants()) do monitorSound(obj) end
game.DescendantAdded:Connect(monitorSound)

-- 3. ИНТЕРФЕЙС (Минималистичный, плавающий)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 250)
Frame.Position = UDim2.new(0.8, 0, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.Draggable = true -- Перетаскивай пальцем
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "TITAN AUTO-PATCHER"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold

local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1, -20, 1, -60)
List.Position = UDim2.new(0, 10, 0, 50)
List.BackgroundTransparency = 1
List.ScrollBarThickness = 2
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- Список файлов
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
            -- Если музыка уже играет — меняем её немедленно
            for _, sound in pairs(game:GetDescendants()) do
                if sound:IsA("Sound") and sound.Playing then
                    patchSound(sound)
                end
            end
        end)
    end
end
