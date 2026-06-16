-- ================================================
-- 🎵 GRACE MUSIC REPLACER v1.0
-- Delta Executor | Меню выбора MP3 из workspace
-- ================================================

local Players      = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer  = Players.LocalPlayer

-- ======== НАСТРОЙКИ ========
local VOLUME           = 0.5
local SCAN_INTERVAL    = 2
local TARGET_KEYWORDS  = {
    "music","theme","bgm","song","soundtrack",
    "ultersonic","faith","plague","ambient","audio"
}

-- ======== ПОИСК MP3 В WORKSPACE ========
local function getMP3Files()
    local files   = {}
    local found   = nil

    for _, tryPath in ipairs({"workspace", ".", ""}) do
        local ok, list = pcall(listfiles, tryPath)
        if ok and list and #list > 0 then
            found = list
            break
        end
    end

    if not found then return files end

    for _, filepath in ipairs(found) do
        if type(filepath) == "string"
           and filepath:lower():match("%.mp3$") then
            local filename    = filepath:match("[^/\\]+$") or filepath
            local displayName = filename:gsub("%.[Mm][Pp]3$", "")
            table.insert(files, {
                display  = displayName,
                filename = filename,
            })
        end
    end
    return files
end

-- ======== ЗВУКОВАЯ ЛОГИКА ========
local selectedAsset  = nil
local isActive       = false
local patchedSounds  = {}

local function isTarget(sound)
    if not sound:IsA("Sound") then return false end
    local n = sound.Name:lower()
    for _, kw in ipairs(TARGET_KEYWORDS) do
        if n:match(kw) then return true end
    end
    return false
end

local function patchSound(sound)
    if not isTarget(sound)        then return end
    if patchedSounds[sound]       then return end
    if not selectedAsset          then return end
    patchedSounds[sound] = true

    sound:Stop()
    sound.SoundId = selectedAsset
    sound.Volume  = VOLUME
    if sound.Playing or sound.TimePosition > 0 then
        sound:Play()
    end

    -- Если игра попробует вернуть оригинал — возвращаем нашу
    sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        if isActive and sound.SoundId ~= selectedAsset then
            sound:Stop()
            sound.SoundId = selectedAsset
            sound:Play()
        end
    end)

    sound.AncestryChanged:Connect(function(_, p)
        if not p then patchedSounds[sound] = nil end
    end)
end

local function scanAll()
    for _, svc in ipairs({
        game:GetService("Workspace"),
        game:GetService("SoundService"),
        game:GetService("ReplicatedStorage"),
    }) do
        pcall(function()
            for _, d in ipairs(svc:GetDescendants()) do
                patchSound(d)
            end
        end)
    end
end

local function startReplacement()
    if not selectedAsset then return end
    isActive      = true
    patchedSounds = {}
    scanAll()

    game.DescendantAdded:Connect(function(d)
        if isActive then pcall(patchSound, d) end
    end)

    task.spawn(function()
        while isActive do
            task.wait(SCAN_INTERVAL)
            if isActive then scanAll() end
        end
    end)
end

local function stopAll()
    isActive      = false
    selectedAsset = nil
    patchedSounds = {}
end

-- ======== GUI ========
if LocalPlayer.PlayerGui:FindFirstChild("GraceReplUI") then
    LocalPlayer.PlayerGui.GraceReplUI:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name            = "GraceReplUI"
gui.ResetOnSpawn    = false
gui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
gui.Parent          = LocalPlayer.PlayerGui

local main = Instance.new("Frame")
main.Size            = UDim2.new(0, 330, 0, 460)
main.Position        = UDim2.new(0.5,-165, 0.5,-230)
main.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
main.BorderSizePixel = 0
main.Parent          = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Заголовок (перетаскивание)
local titleBar = Instance.new("Frame")
titleBar.Size             = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = Color3.fromRGB(70, 0, 160)
titleBar.BorderSizePixel  = 0
titleBar.Parent           = main
local tc = Instance.new("UICorner", titleBar)
tc.CornerRadius = UDim.new(0, 12)
-- Фикс нижних углов шапки
local fix = Instance.new("Frame")
fix.Size             = UDim2.new(1, 0, 0.5, 0)
fix.Position         = UDim2.new(0, 0, 0.5, 0)
fix.BackgroundColor3 = Color3.fromRGB(70, 0, 160)
fix.BorderSizePixel  = 0
fix.Parent           = titleBar

local titleLbl = Instance.new("TextLabel")
titleLbl.Size               = UDim2.new(1,-16, 1, 0)
titleLbl.Position           = UDim2.new(0, 14, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text               = "🎵  Grace Music Replacer"
titleLbl.TextColor3         = Color3.new(1,1,1)
titleLbl.TextSize           = 15
titleLbl.Font               = Enum.Font.GothamBold
titleLbl.TextXAlignment     = Enum.TextXAlignment.Left
titleLbl.Parent             = titleBar

-- Статус
local statusLbl = Instance.new("TextLabel")
statusLbl.Size              = UDim2.new(1,-20, 0, 22)
statusLbl.Position          = UDim2.new(0,10, 0, 54)
statusLbl.BackgroundTransparency = 1
statusLbl.Text              = "📂 Загрузка файлов..."
statusLbl.TextColor3        = Color3.fromRGB(170,170,200)
statusLbl.TextSize          = 11
statusLbl.Font              = Enum.Font.Gotham
statusLbl.TextXAlignment    = Enum.TextXAlignment.Left
statusLbl.Parent            = main

-- Список песен
local scroll = Instance.new("ScrollingFrame")
scroll.Size                  = UDim2.new(1,-20, 1,-178)
scroll.Position              = UDim2.new(0,10, 0, 82)
scroll.BackgroundColor3      = Color3.fromRGB(22, 22, 30)
scroll.BorderSizePixel       = 0
scroll.ScrollBarThickness    = 4
scroll.ScrollBarImageColor3  = Color3.fromRGB(110, 0, 220)
scroll.CanvasSize            = UDim2.new(0,0, 0,0)
scroll.Parent                = main
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)
local ll = Instance.new("UIListLayout", scroll)
ll.Padding = UDim.new(0, 4)
local lp = Instance.new("UIPadding", scroll)
lp.PaddingTop   = UDim.new(0, 6)
lp.PaddingLeft  = UDim.new(0, 6)
lp.PaddingRight = UDim.new(0, 6)

-- Громкость
local volLbl = Instance.new("TextLabel")
volLbl.Size              = UDim2.new(0.55, -10, 0, 28)
volLbl.Position          = UDim2.new(0, 10, 1, -120)
volLbl.BackgroundTransparency = 1
volLbl.Text              = "🔊  Громкость: 50%"
volLbl.TextColor3        = Color3.fromRGB(200,200,220)
volLbl.TextSize          = 12
volLbl.Font              = Enum.Font.Gotham
volLbl.TextXAlignment    = Enum.TextXAlignment.Left
volLbl.Parent            = main

local function makeBtn(text, x, y, w, h, r, g, b)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, w, 0, h)
    btn.Position         = UDim2.new(0, x, 1, y)
    btn.BackgroundColor3 = Color3.fromRGB(r, g, b)
    btn.Text             = text
    btn.TextColor3       = Color3.new(1,1,1)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.Parent           = main
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    return btn
end

local btnVolDown  = makeBtn("−",   210, -118, 32, 26, 45,45,65)
local btnVolUp    = makeBtn("+",   248, -118, 32, 26, 45,45,65)
local btnPlay     = makeBtn("▶ Запустить",    10, -83, 150, 38, 20,120,50)
local btnStop     = makeBtn("⏹ Стоп",        170, -83, 150, 38, 150,20,20)
local btnRefresh  = makeBtn("🔄 Обновить",     10, -35, 150, 28, 35,55,95)
local btnClose    = makeBtn("✕ Закрыть",      170, -35, 150, 28, 60,20,20)

-- ======== ЗАПОЛНЕНИЕ СПИСКА ========
local mp3List      = {}
local selectedBtn  = nil

local function buildList()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    selectedBtn   = nil
    selectedAsset = nil

    mp3List = getMP3Files()

    if #mp3List == 0 then
        statusLbl.Text = "⚠️  MP3 не найдены. Положи файлы в workspace экзекутора"
        local lbl = Instance.new("TextLabel")
        lbl.Size                = UDim2.new(1, 0, 0, 50)
        lbl.BackgroundTransparency = 1
        lbl.Text                = "Папка workspace пуста\nили listfiles недоступен"
        lbl.TextColor3          = Color3.fromRGB(160,160,160)
        lbl.TextSize            = 12
        lbl.Font                = Enum.Font.Gotham
        lbl.Parent              = scroll
        scroll.CanvasSize = UDim2.new(0,0,0,50)
        return
    end

    statusLbl.Text = "📂  Найдено: " .. #mp3List .. " файлов | Выбрано: нет"

    for _, file in ipairs(mp3List) do
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1, -8, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(38, 18, 65)
        btn.Text             = "🎵  " .. file.display
        btn.TextColor3       = Color3.fromRGB(215, 215, 255)
        btn.TextSize         = 12
        btn.Font             = Enum.Font.Gotham
        btn.TextXAlignment   = Enum.TextXAlignment.Left
        btn.TextTruncate     = Enum.TextTruncate.AtEnd
        btn.BorderSizePixel  = 0
        btn.Parent           = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local pad = Instance.new("UIPadding", btn)
        pad.PaddingLeft = UDim.new(0, 10)

        local f = file
        btn.MouseButton1Click:Connect(function()
            if selectedBtn then
                selectedBtn.BackgroundColor3 = Color3.fromRGB(38, 18, 65)
            end
            btn.BackgroundColor3 = Color3.fromRGB(85, 0, 190)
            selectedBtn = btn

            local ok, asset = pcall(getcustomasset, f.filename)
            if ok and asset then
                selectedAsset = asset
                statusLbl.Text = "✅  Выбрано: " .. f.display
            else
                selectedAsset = nil
                statusLbl.Text = "❌  Ошибка загрузки: " .. f.display
            end
        end)
    end

    scroll.CanvasSize = UDim2.new(0, 0, 0, #mp3List * 44 + 12)
end

-- ======== КНОПКИ ========
btnVolDown.MouseButton1Click:Connect(function()
    VOLUME = math.max(0, math.round((VOLUME - 0.1) * 10) / 10)
    volLbl.Text = "🔊  Громкость: " .. math.floor(VOLUME * 100) .. "%"
    for s in pairs(patchedSounds) do
        if s and s.Parent then s.Volume = VOLUME end
    end
end)

btnVolUp.MouseButton1Click:Connect(function()
    VOLUME = math.min(1, math.round((VOLUME + 0.1) * 10) / 10)
    volLbl.Text = "🔊  Громкость: " .. math.floor(VOLUME * 100) .. "%"
    for s in pairs(patchedSounds) do
        if s and s.Parent then s.Volume = VOLUME end
    end
end)

btnPlay.MouseButton1Click:Connect(function()
    if not selectedAsset then
        statusLbl.Text = "⚠️  Сначала выбери песню!"
        return
    end
    startReplacement()
    btnPlay.BackgroundColor3 = Color3.fromRGB(15, 170, 55)
    btnPlay.Text = "▶ Играет..."
end)

btnStop.MouseButton1Click:Connect(function()
    stopAll()
    btnPlay.BackgroundColor3 = Color3.fromRGB(20, 120, 50)
    btnPlay.Text = "▶ Запустить"
    if selectedBtn then
        selectedBtn.BackgroundColor3 = Color3.fromRGB(38, 18, 65)
        selectedBtn = nil
    end
    statusLbl.Text = "⏹  Остановлено. Выбери песню заново"
end)

btnRefresh.MouseButton1Click:Connect(function()
    stopAll()
    buildList()
end)

btnClose.MouseButton1Click:Connect(function()
    stopAll()
    gui:Destroy()
end)

-- ======== DRAG ========
local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = inp.Position
        startPos  = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local d = inp.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false end
end)

-- ======== СТАРТ ========
buildList()
print("🎵 Grace Music Replacer | Файлов найдено: " .. #mp3List)
