-- =============================================================================
-- 🛡️ TITAN ULTRA-SAFE KILLER (Движение в полной безопасности)
-- =============================================================================

local ScriptContext = game:GetService("ScriptContext")
local errorCounts = {}

-- БЕЛЫЙ СПИСОК: Эти ключевые слова скрипт НЕ ТРОНЕТ НАХЕР НИКОГДА
local movementWhitelist = {"sprint", "crouch", "jump", "slide", "move", "control", "main"}

-- ЧЕРНЫЙ СПИСОК: Только подтвержденный мусор, который лагает
local trashBlacklist = {"cosmetics", "sparkslinger", "clientoutreach"}

ScriptContext.Error:Connect(function(message, stackTrace, scriptObj)
    if scriptObj and scriptObj:IsA("LuaSourceContainer") then
        local scriptPath = scriptObj:GetFullName():lower()
        
        -- 1. ПРОВЕРКА БЕЗОПАСНОСТИ: Если это функция движения — игнорируем ошибку
        local isMovementScript = false
        for _, word in ipairs(movementWhitelist) do
            if string.find(scriptPath, word) then
                -- Исключение: если это "slide" внутри папки кастомизации, то это эффект, а не сам подкат
                if word == "slide" and string.find(scriptPath, "cosmetics") then
                    isMovementScript = false
                else
                    isMovementScript = true
                    break
                end
            end
        end
        
        -- Если скрипт отвечает за прыжок/подкат/присед/бег — выходим, спасаем его
        if isMovementScript then return end
        
        -- 2. ПРОВЕРКА НА МУСОР: Уничтожаем только то, что в черном списке
        local isTargetTrash = false
        for _, word in ipairs(trashBlacklist) do
            if string.find(scriptPath, word) then
                isTargetTrash = true
                break
            end
        end
        
        -- Если это подтвержденный лагающий мусор — удаляем после 2 ошибок
        if isTargetTrash then
            errorCounts[scriptObj] = (errorCounts[scriptObj] or 0) + 1
            
            if errorCounts[scriptObj] >= 2 then
                pcall(function()
                    if scriptObj:IsA("LocalScript") then
                        scriptObj.Disabled = true
                    end
                    scriptObj:Destroy()
                    errorCounts[scriptObj] = nil
                end)
            end
        end
    end
end)

print("🛡️ [TITAN ULTRA-SAFE]: Защита включена. Прыжки, приседания и слайды защищены железно!")
