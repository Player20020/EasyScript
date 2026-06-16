-- =============================================================================
-- 👑 TITAN MINI (Minimalist & Fast)
-- =============================================================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local SelectedSong = ""
local activeConnections = {}

-- Функция подмены
local function patchSound(sound)
    if not sound:IsA("Sound") then return end
    local name = sound.Name:lower()
    local keywords = {"music", "theme", "bgm", "song", "soundtrack", "plague"}
    
    local isMusic = false
    for _, k in ipairs(keywords) do if name:match(k) then isMusic = true break end end
    if not isMusic or SelectedSong == "" then return end

    local asset = getcustomasset(SelectedSong)
    sound:Stop()
    sound.SoundId = asset
    sound.Looped = true
    sound:Play()

    -- Щит от отката
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

-- Инициализация меню
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 200, 0, 250)
Frame.Position = UDim2.new(0.8, 0, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Text = "TITAN MINI"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local List = Instance.new("ScrollingFrame", Frame)
List.Size = UDim2.new(1, -20, 1, -60)
List.Position = UDim2.new(0, 10, 0, 50)
List.BackgroundTransparency = 1
Instance.new("UIListLayout", List).Padding = UDim.new(0, 5)

-- Функция обновления списка
local function refresh()
    List:ClearAllChildren()
    for _, path in ipairs(listfiles("")) do
        if path:lower():match("%.mp3$") then
            local btn = Instance.new("TextButton", List)
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = path:match("[^\\]+$")
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                SelectedSong = path
                -- Принудительно ищем все звуки и меняем их на новую песню
                for _, obj in pairs(game:GetDescendants()) do
                    pcall(patchSound, obj)
                end
            end)
        end
    end
end

-- Следим за новыми звуками
game.DescendantAdded:Connect(patchSound)

refresh()
print("👑 Titan Mini Loaded")
