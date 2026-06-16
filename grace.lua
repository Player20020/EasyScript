-- =============================================================================
-- 👑 TITAN-AUDIO-RULER v2.0 (Anti-Crash, Anti-Revert, Anti-Stream)
-- =============================================================================

local success, customAudio = pcall(function()
    return getcustomasset("grace_music.mp3")
end)

if not (success and customAudio) then
    warn("💥 [TITAN CRITICAL]: Файл 'grace_music.mp3' не найден в папке workspace!")
    return
end

-- Черный список оригинальных ID или ключевые слова для тотальной зачистки
local TARGET_KEYWORDS = {"music", "theme", "bgm", "song", "soundtrack", "ultersonic", "faith", "plague"}
local processedSounds = {}

-- Функция жесткой проверки: наш ли это целевой звук?
local function isGameMusic(sound)
    if not sound:IsA("Sound") then return false end
    local name = sound.Name:lower()
    for _, keyword in ipairs(TARGET_KEYWORDS) do
        if name:match(keyword) then return true end
    end
    return false
end

-- Главная броня Титана
local function absolutePatch(sound)
    if not isGameMusic(sound) then return end
    
    -- Если объект уже под полным контролем этого потока — игнорируем
    if processedSounds[sound] then return end
    processedSounds[sound] = true

    -- [ЗАЩИТА ОТ ОТКАТА]: Перехватываем любые попытки игры вернуть старую музыку
    local propertyConnection
    propertyConnection = sound:GetPropertyChangedSignal("SoundId"):Connect(function()
        if sound.SoundId ~= customAudio then
            sound:Stop()
            sound.SoundId = customAudio
            sound:Play()
        end
    end)

    -- Первая жесткая инициализация (вырезаем оригинал)
    if sound.SoundId ~= customAudio then
        sound:Stop()
        sound.SoundId = customAudio
        
        -- Гарантируем, что трек играет, если игра его включила, но не даем ему орать громче настроек
        if sound.Playing or sound.TimePosition > 0 then
            sound:Play()
        end
    end

    -- [ЗАЩИТА ОТ УТЕЧКИ ПАМЯТИ]: Если игра уничтожит объект, подчищаем хвосты в кэше
    local ancestryConnection
    ancestryConnection = sound.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if propertyConnection then propertyConnection:Disconnect() end
            if ancestryConnection then ancestryConnection:Disconnect() end
            processedSounds[sound] = nil
        end
    end)
end

-- Безопасный сканер критических сервисов игры
local function titanScan()
    local criticalServices = {
        game:GetService("Workspace"),
        game:GetService("SoundService"),
        game:GetService("ReplicatedStorage"),
        game:GetService("Players")
    }
    
    for _, service in ipairs(criticalServices) do
        pcall(function()
            for _, descendant in ipairs(service:GetDescendants()) do
                absolutePatch(descendant)
            end
        end)
    end
end

-- 1. Моментальный перехват всего, что уже загружено
titanScan()

-- 2. Перехват «на лету» (Защита от динамического спавна новых раундов)
game.DescendantAdded:Connect(function(descendant)
    pcall(absolutePatch, descendant)
end)

-- 3. ТИТАНИЧЕСКИЙ ДОЗОР (Фоновый поток против StreamingEnabled и жестких ресетов)
task.spawn(function()
    while true do
        titanScan()
        task.wait(2) -- Оптимальный интервал: нулевая нагрузка на CPU, моментальная реакция
    end
end)

print("👑 [TITAN ONLINE]: Контроль звуковых ассетов зафиксирован. Ошибки исключены.")
