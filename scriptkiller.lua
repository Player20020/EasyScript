-- =============================================================================
-- 🛑 TITAN SCRIPT KILLER (Standalone)
-- =============================================================================

local ScriptContext = game:GetService("ScriptContext")
local errorCounts = {}

ScriptContext.Error:Connect(function(message, stackTrace, scriptObj)
    -- Проверяем, существует ли объект и является ли он скриптом
    if scriptObj and scriptObj:IsA("LuaSourceContainer") then
        
        -- Считаем количество ошибок
        errorCounts[scriptObj] = (errorCounts[scriptObj] or 0) + 1
        
        -- Если ошибок 2 или больше — убиваем его
        if errorCounts[scriptObj] >= 2 then
            pcall(function()
                -- Выключаем перед удалением
                if scriptObj:IsA("LocalScript") then
                    scriptObj.Disabled = true
                end
                
                -- Удаляем из игры навсегда
                scriptObj:Destroy()
                
                -- Чистим счетчик
                errorCounts[scriptObj] = nil
            end)
        end
    end
end)

print("🛑 [TITAN KILLER]: Активен. Лимит ошибок: 2.")

