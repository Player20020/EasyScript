-- ════════════════════════════════════════════════
-- 🎵 GRACE MUSIC REPLACER v2.0
-- ✅ Touch/Mobile | Minimize | Drag | Anti-Revert
-- ════════════════════════════════════════════════

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer

-- ══════ НАСТРОЙКИ ══════
local CFG = {
    volume   = 0.5,
    interval = 2,
    keys     = {
        "music","theme","bgm","song","soundtrack",
        "ultersonic","faith","plague","ambient","audio"
    }
}

-- ══════ ПОИСК MP3 ══════
local function getMP3()
    local files, raw = {}, nil
    for _, p in ipairs({"workspace",".",""}) do
        local ok, r = pcall(listfiles, p)
        if ok and r and #r > 0 then raw = r; break end
    end
    if not raw then return files end
    for _, fp in ipairs(raw) do
        if type(fp)=="string" and fp:lower():match("%.mp3$") then
            local fn = fp:match("[^/\\]+$") or fp
            table.insert(files, {show=fn:gsub("%.[Mm][Pp]3$",""), file=fn})
        end
    end
    return files
end

-- ══════ ЛОГИКА ЗВУКА ══════
local S = { asset=nil, on=false, done={} }

local function isTarget(s)
    if not s:IsA("Sound") then return false end
    local n = s.Name:lower()
    for _, k in ipairs(CFG.keys) do
        if n:find(k,1,true) then return true end
    end
    return false
end

local function patch(s)
    if not S.on or not S.asset then return end
    if not isTarget(s) or S.done[s]  then return end
    S.done[s] = true
    s:Stop(); s.SoundId = S.asset; s.Volume = CFG.volume
    if s.Playing or s.TimePosition > 0 then s:Play() end
    -- Стражник от отката
    s:GetPropertyChangedSignal("SoundId"):Connect(function()
        if S.on and s and s.Parent and s.SoundId ~= S.asset then
            task.defer(function()
                if S.on and s and s.Parent then
                    s:Stop(); s.SoundId = S.asset; s:Play()
                end
            end)
        end
    end)
    s.AncestryChanged:Connect(function(_,p)
        if not p then S.done[s]=nil end
    end)
end

local function scan()
    for _, svc in ipairs({
        workspace,
        game:GetService("SoundService"),
        game:GetService("ReplicatedStorage"),
        game:GetService("Lighting"),
    }) do pcall(function()
        for _, d in ipairs(svc:GetDescendants()) do patch(d) end
    end) end
end

local scanJob = nil
local function startMusic()
    if not S.asset then return end
    S.on=true; S.done={}
    scan()
    game.DescendantAdded:Connect(function(d)
        if S.on then task.defer(function() pcall(patch,d) end) end
    end)
    scanJob = task.spawn(function()
        while S.on do task.wait(CFG.interval); if S.on then scan() end end
    end)
end

local function stopMusic()
    S.on=false; S.asset=nil; S.done={}
    if scanJob then task.cancel(scanJob); scanJob=nil end
end

-- ══════ GUI SETUP ══════
do local o=LP.PlayerGui:FindFirstChild("GMR"); if o then o:Destroy() end end

local G = Instance.new("ScreenGui")
G.Name="GMR"; G.ResetOnSpawn=false
G.DisplayOrder=999; G.IgnoreGuiInset=true
G.ZIndexBehavior=Enum.ZIndexBehavior.Global
G.Parent = LP.PlayerGui

-- ── Пузырь (виден когда свёрнуто) ──
local bubble = Instance.new("TextButton")
bubble.Size             = UDim2.new(0,58,0,58)
bubble.Position         = UDim2.new(0,14,0.65,0)
bubble.BackgroundColor3 = Color3.fromRGB(78,0,175)
bubble.Text="🎵"; bubble.TextSize=26
bubble.Font=Enum.Font.GothamBold
bubble.BorderSizePixel=0; bubble.Visible=false
bubble.ZIndex=999; bubble.Parent=G
Instance.new("UICorner",bubble).CornerRadius=UDim.new(1,0)
local bs=Instance.new("UIStroke",bubble)
bs.Color=Color3.fromRGB(160,80,255); bs.Thickness=2

-- ── Главное окно ──
local W = Instance.new("Frame")
W.Size=UDim2.new(0,340,0,478)
W.Position=UDim2.new(0.5,-170,0.5,-239)
W.BackgroundColor3=Color3.fromRGB(12,12,18)
W.BorderSizePixel=0; W.ZIndex=100; W.Parent=G
Instance.new("UICorner",W).CornerRadius=UDim.new(0,14)
local ws=Instance.new("UIStroke",W)
ws.Color=Color3.fromRGB(78,0,175); ws.Thickness=1.5; ws.Transparency=0.4

-- ── Шапка ──
local TB = Instance.new("Frame")
TB.Size=UDim2.new(1,0,0,52)
TB.BackgroundColor3=Color3.fromRGB(72,0,162)
TB.BorderSizePixel=0; TB.ZIndex=101; TB.Parent=W
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,14)
local tbf=Instance.new("Frame",TB)        -- убираем нижние скругления шапки
tbf.Size=UDim2.new(1,0,0.5,0); tbf.Position=UDim2.new(0,0,0.5,0)
tbf.BackgroundColor3=Color3.fromRGB(72,0,162); tbf.BorderSizePixel=0; tbf.ZIndex=101

local TL=Instance.new("TextLabel",TB)
TL.Size=UDim2.new(1,-94,1,0); TL.Position=UDim2.new(0,14,0,0)
TL.BackgroundTransparency=1; TL.Text="🎵  Grace Music Replacer"
TL.TextColor3=Color3.new(1,1,1); TL.TextSize=15
TL.Font=Enum.Font.GothamBold; TL.TextXAlignment=Enum.TextXAlignment.Left
TL.ZIndex=102

local function hdrBtn(txt,x,r,g,b)
    local b2=Instance.new("TextButton",TB)
    b2.Size=UDim2.new(0,34,0,34); b2.Position=UDim2.new(1,x,0.5,-17)
    b2.BackgroundColor3=Color3.fromRGB(r,g,b); b2.Text=txt
    b2.TextColor3=Color3.new(1,1,1); b2.TextSize=16
    b2.Font=Enum.Font.GothamBold; b2.BorderSizePixel=0; b2.ZIndex=103
    Instance.new("UICorner",b2).CornerRadius=UDim.new(0,8)
    return b2
end
local minBtn   = hdrBtn("−",-80, 45,0,120)
local closeBtn = hdrBtn("✕",-40,155,18,18)

-- ── Статус ──
local SL=Instance.new("TextLabel",W)
SL.Size=UDim2.new(1,-20,0,22); SL.Position=UDim2.new(0,10,0,58)
SL.BackgroundTransparency=1; SL.Text="📂 Загрузка..."
SL.TextColor3=Color3.fromRGB(165,165,195); SL.TextSize=11
SL.Font=Enum.Font.Gotham; SL.TextXAlignment=Enum.TextXAlignment.Left
SL.ZIndex=101

-- ── Список ──
local SCR=Instance.new("ScrollingFrame",W)
SCR.Size=UDim2.new(1,-20,1,-192); SCR.Position=UDim2.new(0,10,0,85)
SCR.BackgroundColor3=Color3.fromRGB(20,18,30)
SCR.BorderSizePixel=0; SCR.ScrollBarThickness=4
SCR.ScrollBarImageColor3=Color3.fromRGB(110,0,220)
SCR.CanvasSize=UDim2.new(0,0,0,0); SCR.ZIndex=101
Instance.new("UICorner",SCR).CornerRadius=UDim.new(0,8)
local ll=Instance.new("UIListLayout",SCR); ll.Padding=UDim.new(0,4)
local lp2=Instance.new("UIPadding",SCR)
lp2.PaddingTop=UDim.new(0,6); lp2.PaddingLeft=UDim.new(0,6)
lp2.PaddingRight=UDim.new(0,6); lp2.PaddingBottom=UDim.new(0,6)

-- ── Громкость ──
local VR=Instance.new("Frame",W)
VR.Size=UDim2.new(1,-20,0,32); VR.Position=UDim2.new(0,10,1,-130)
VR.BackgroundTransparency=1; VR.ZIndex=101
local VL=Instance.new("TextLabel",VR)
VL.Size=UDim2.new(0.62,0,1,0); VL.BackgroundTransparency=1
VL.Text="🔊  Громкость: 50%"; VL.TextColor3=Color3.fromRGB(195,195,220)
VL.TextSize=12; VL.Font=Enum.Font.Gotham
VL.TextXAlignment=Enum.TextXAlignment.Left; VL.ZIndex=102
local function volBtn(t,x)
    local b2=Instance.new("TextButton",VR)
    b2.Size=UDim2.new(0,36,0,30); b2.Position=UDim2.new(0.62,x,0.5,-15)
    b2.BackgroundColor3=Color3.fromRGB(40,40,58); b2.Text=t
    b2.TextColor3=Color3.new(1,1,1); b2.TextSize=20
    b2.Font=Enum.Font.GothamBold; b2.BorderSizePixel=0; b2.ZIndex=102
    Instance.new("UICorner",b2).CornerRadius=UDim.new(0,7)
    return b2
end
local BVD=volBtn("−",4); local BVU=volBtn("+",46)

-- ── Кнопки управления ──
local function ctrlBtn(txt,x,y,w,h,r,g,b)
    local b2=Instance.new("TextButton",W)
    b2.Size=UDim2.new(0,w,0,h); b2.Position=UDim2.new(0,x,1,y)
    b2.BackgroundColor3=Color3.fromRGB(r,g,b); b2.Text=txt
    b2.TextColor3=Color3.new(1,1,1); b2.TextSize=13
    b2.Font=Enum.Font.GothamBold; b2.BorderSizePixel=0; b2.ZIndex=101
    Instance.new("UICorner",b2).CornerRadius=UDim.new(0,9)
    return b2
end
local BPlay    = ctrlBtn("▶  Запустить",  10,-90,152,42, 18,115,48)
local BStop    = ctrlBtn("⏹  Стоп",      178,-90,152,42,148,18,18)
local BRefresh = ctrlBtn("🔄  Обновить",   10,-42,152,34, 32,52,92)

local nowLbl=Instance.new("TextLabel",W)
nowLbl.Size=UDim2.new(0,152,0,34); nowLbl.Position=UDim2.new(0,178,1,-42)
nowLbl.BackgroundColor3=Color3.fromRGB(20,20,30); nowLbl.Text="⏸  Ожидание"
nowLbl.TextColor3=Color3.fromRGB(160,160,195); nowLbl.TextSize=11
nowLbl.Font=Enum.Font.Gotham; nowLbl.BorderSizePixel=0; nowLbl.ZIndex=101
Instance.new("UICorner",nowLbl).CornerRadius=UDim.new(0,8)

-- ══════ СПИСОК ФАЙЛОВ ══════
local mp3s, selBtn, selFile = {}, nil, nil

local function buildList()
    for _, c in ipairs(SCR:GetChildren()) do
        if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
    end
    selBtn=nil; selFile=nil; S.asset=nil
    mp3s = getMP3()

    if #mp3s==0 then
        SL.Text="⚠️ Файлы не найдены — положи .mp3 в workspace Delta"
        local em=Instance.new("TextLabel",SCR)
        em.Size=UDim2.new(1,0,0,52); em.BackgroundTransparency=1
        em.Text="Папка workspace пуста"; em.TextColor3=Color3.fromRGB(130,130,155)
        em.TextSize=12; em.Font=Enum.Font.Gotham
        SCR.CanvasSize=UDim2.new(0,0,0,52); return
    end

    SL.Text="📂  Найдено: "..#mp3s.."  |  Выбрано: нет"

    for _, f in ipairs(mp3s) do
        local btn=Instance.new("TextButton",SCR)
        btn.Size=UDim2.new(1,-8,0,46)
        btn.BackgroundColor3=Color3.fromRGB(34,14,60)
        btn.Text="🎵  "..f.show
        btn.TextColor3=Color3.fromRGB(215,215,255); btn.TextSize=12
        btn.Font=Enum.Font.Gotham; btn.TextXAlignment=Enum.TextXAlignment.Left
        btn.TextTruncate=Enum.TextTruncate.AtEnd
        btn.BorderSizePixel=0; btn.ZIndex=102
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
        local pd=Instance.new("UIPadding",btn); pd.PaddingLeft=UDim.new(0,10)

        local lf=f
        btn.MouseButton1Click:Connect(function()
            if selBtn and selBtn~=btn then
                selBtn.BackgroundColor3=Color3.fromRGB(34,14,60)
            end
            btn.BackgroundColor3=Color3.fromRGB(80,0,182)
            selBtn=btn; selFile=lf.show
            local ok,a=pcall(getcustomasset,lf.file)
            if ok and a then
                S.asset=a; SL.Text="✅  Выбрано: "..lf.show
            else
                S.asset=nil; SL.Text="❌  Ошибка загрузки файла"
            end
        end)
    end
    SCR.CanvasSize=UDim2.new(0,0,0,#mp3s*50+16)
end

-- ══════ ДЕЙСТВИЯ КНОПОК ══════
BVD.MouseButton1Click:Connect(function()
    CFG.volume=math.max(0,math.round((CFG.volume-0.1)*10)/10)
    VL.Text="🔊  Громкость: "..math.floor(CFG.volume*100).."%"
    for s in pairs(S.done) do if s and s.Parent then s.Volume=CFG.volume end end
end)
BVU.MouseButton1Click:Connect(function()
    CFG.volume=math.min(1,math.round((CFG.volume+0.1)*10)/10)
    VL.Text="🔊  Громкость: "..math.floor(CFG.volume*100).."%"
    for s in pairs(S.done) do if s and s.Parent then s.Volume=CFG.volume end end
end)

BPlay.MouseButton1Click:Connect(function()
    if not S.asset then SL.Text="⚠️  Сначала выбери песню!"; return end
    startMusic()
    BPlay.BackgroundColor3=Color3.fromRGB(14,165,50)
    BPlay.Text="▶  Играет..."
    nowLbl.Text="🎵  "..(selFile or "?")
    nowLbl.TextColor3=Color3.fromRGB(90,255,130)
end)

BStop.MouseButton1Click:Connect(function()
    stopMusic()
    BPlay.BackgroundColor3=Color3.fromRGB(18,115,48); BPlay.Text="▶  Запустить"
    nowLbl.Text="⏸  Остановлено"; nowLbl.TextColor3=Color3.fromRGB(160,160,195)
    if selBtn then selBtn.BackgroundColor3=Color3.fromRGB(34,14,60); selBtn=nil end
    SL.Text="⏹  Остановлено — выбери снова"
end)

BRefresh.MouseButton1Click:Connect(function()
    stopMusic(); buildList()
    BPlay.BackgroundColor3=Color3.fromRGB(18,115,48); BPlay.Text="▶  Запустить"
    nowLbl.Text="⏸  Ожидание"; nowLbl.TextColor3=Color3.fromRGB(160,160,195)
end)

minBtn.MouseButton1Click:Connect(function()
    W.Visible=false; bubble.Visible=true
end)
closeBtn.MouseButton1Click:Connect(function()
    stopMusic(); G:Destroy()
end)
bubble.MouseButton1Click:Connect(function()
    bubble.Visible=false; W.Visible=true
end)

-- ══════ DRAG (Touch + Mouse) ══════
local function makeDraggable(handle, target)
    local drag, ds, os = false, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=inp.Position; os=target.Position
            inp.Changed:Connect(function()
                if inp.UserInputState==Enum.UserInputState.End then drag=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if not drag then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement
        and inp.UserInputType~=Enum.UserInputType.Touch then return end
        local d=inp.Position-ds
        target.Position=UDim2.new(
            os.X.Scale, os.X.Offset+d.X,
            os.Y.Scale, os.Y.Offset+d.Y
        )
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1
        or inp.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end

makeDraggable(TB,     W)       -- тащить окно за шапку
makeDraggable(bubble, bubble)  -- тащить пузырь куда угодно

-- ══════ СТАРТ ══════
buildList()
print("🎵 Grace Music Replacer v2.0 | Файлов: "..#mp3s)
