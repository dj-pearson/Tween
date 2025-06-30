-- PresetManager.lua
-- Manages saving and loading tween presets using plugin settings

local PresetManager = {}

local HttpService = game:GetService("HttpService")

-- Key for storing presets in plugin settings
local PRESETS_KEY = "TweenGeneratorPro_Presets"

-- Function to save a preset
function PresetManager.SavePreset(plugin, presetName, presetData)
    if not plugin or not presetName or not presetData then
        warn("Invalid parameters for saving preset")
        return false
    end
    
    -- Get existing presets
    local presets = PresetManager.GetAllPresets(plugin)
    
    -- Prepare preset data for storage
    local storeData = {
        duration = presetData.duration,
        delay = presetData.delay,
        repeatCount = presetData.repeatCount,
        reverses = presetData.reverses,
        easingStyle = presetData.easingStyle,
        easingDirection = presetData.easingDirection,
        startProperties = PresetManager.SerializeProperties(presetData.startProperties),
        endProperties = PresetManager.SerializeProperties(presetData.endProperties),
        savedAt = os.time()
    }
    
    -- Store the preset
    presets[presetName] = storeData
    
    -- Save back to plugin settings
    local success, err = pcall(function()
        local serializedPresets = HttpService:JSONEncode(presets)
        plugin:SetSetting(PRESETS_KEY, serializedPresets)
    end)
    
    if success then
        print("Preset '" .. presetName .. "' saved successfully")
        return true
    else
        warn("Failed to save preset '" .. presetName .. "': " .. tostring(err))
        return false
    end
end

-- Function to load a preset
function PresetManager.LoadPreset(plugin, presetName)
    if not plugin or not presetName then
        warn("Invalid parameters for loading preset")
        return nil
    end
    
    local presets = PresetManager.GetAllPresets(plugin)
    local presetData = presets[presetName]
    
    if not presetData then
        warn("Preset '" .. presetName .. "' not found")
        return nil
    end
    
    -- Deserialize the preset data
    local loadedPreset = {
        duration = presetData.duration or 1,
        delay = presetData.delay or 0,
        repeatCount = presetData.repeatCount or 0,
        reverses = presetData.reverses or false,
        easingStyle = presetData.easingStyle or "Sine",
        easingDirection = presetData.easingDirection or "Out",
        startProperties = PresetManager.DeserializeProperties(presetData.startProperties),
        endProperties = PresetManager.DeserializeProperties(presetData.endProperties),
        savedAt = presetData.savedAt
    }
    
    return loadedPreset
end

-- Function to delete a preset
function PresetManager.DeletePreset(plugin, presetName)
    if not plugin or not presetName then
        warn("Invalid parameters for deleting preset")
        return false
    end
    
    local presets = PresetManager.GetAllPresets(plugin)
    
    if not presets[presetName] then
        warn("Preset '" .. presetName .. "' not found")
        return false
    end
    
    presets[presetName] = nil
    
    -- Save back to plugin settings
    local success, err = pcall(function()
        local serializedPresets = HttpService:JSONEncode(presets)
        plugin:SetSetting(PRESETS_KEY, serializedPresets)
    end)
    
    if success then
        print("Preset '" .. presetName .. "' deleted successfully")
        return true
    else
        warn("Failed to delete preset '" .. presetName .. "': " .. tostring(err))
        return false
    end
end

-- Function to get all preset names
function PresetManager.GetPresetNames(plugin)
    if not plugin then return {} end
    
    local presets = PresetManager.GetAllPresets(plugin)
    local names = {}
    
    for presetName, _ in pairs(presets) do
        table.insert(names, presetName)
    end
    
    table.sort(names)
    return names
end

-- Function to get all presets
function PresetManager.GetAllPresets(plugin)
    if not plugin then return {} end
    
    local success, presetsJson = pcall(function()
        return plugin:GetSetting(PRESETS_KEY)
    end)
    
    if not success or not presetsJson then
        return {}
    end
    
    local success2, presets = pcall(function()
        return HttpService:JSONDecode(presetsJson)
    end)
    
    if success2 and type(presets) == "table" then
        return presets
    else
        warn("Failed to decode presets from plugin settings")
        return {}
    end
end

-- Function to serialize properties for storage
function PresetManager.SerializeProperties(properties)
    if not properties then return {} end
    
    local serialized = {}
    
    for propertyName, value in pairs(properties) do
        local valueType = typeof(value)
        
        if valueType == "Vector3" then
            serialized[propertyName] = {
                type = "Vector3",
                x = value.X,
                y = value.Y,
                z = value.Z
            }
        elseif valueType == "UDim2" then
            serialized[propertyName] = {
                type = "UDim2",
                scaleX = value.X.Scale,
                offsetX = value.X.Offset,
                scaleY = value.Y.Scale,
                offsetY = value.Y.Offset
            }
        elseif valueType == "Color3" then
            serialized[propertyName] = {
                type = "Color3",
                r = value.R,
                g = value.G,
                b = value.B
            }
        elseif valueType == "CFrame" then
            local x, y, z = value.Position.X, value.Position.Y, value.Position.Z
            local rx, ry, rz = value:ToEulerAnglesXYZ()
            serialized[propertyName] = {
                type = "CFrame",
                x = x, y = y, z = z,
                rx = rx, ry = ry, rz = rz
            }
        elseif valueType == "number" or valueType == "boolean" then
            serialized[propertyName] = {
                type = valueType,
                value = value
            }
        elseif valueType == "string" then
            serialized[propertyName] = {
                type = "string",
                value = value
            }
        else
            warn("Cannot serialize property " .. propertyName .. " of type " .. valueType)
        end
    end
    
    return serialized
end

-- Function to deserialize properties from storage
function PresetManager.DeserializeProperties(serializedProperties)
    if not serializedProperties then return {} end
    
    local properties = {}
    
    for propertyName, data in pairs(serializedProperties) do
        if data.type == "Vector3" then
            properties[propertyName] = Vector3.new(data.x, data.y, data.z)
        elseif data.type == "UDim2" then
            properties[propertyName] = UDim2.new(data.scaleX, data.offsetX, data.scaleY, data.offsetY)
        elseif data.type == "Color3" then
            properties[propertyName] = Color3.new(data.r, data.g, data.b)
        elseif data.type == "CFrame" then
            properties[propertyName] = CFrame.new(data.x, data.y, data.z) * CFrame.Angles(data.rx, data.ry, data.rz)
        elseif data.type == "number" or data.type == "boolean" or data.type == "string" then
            properties[propertyName] = data.value
        else
            warn("Cannot deserialize property " .. propertyName .. " of type " .. data.type)
        end
    end
    
    return properties
end

-- Function to export presets to a file (for backup/sharing)
function PresetManager.ExportPresets(plugin)
    if not plugin then return nil end
    
    local presets = PresetManager.GetAllPresets(plugin)
    
    local success, exportData = pcall(function()
        return HttpService:JSONEncode({
            version = "1.0",
            exported = os.time(),
            presets = presets
        })
    end)
    
    if success then
        return exportData
    else
        warn("Failed to export presets")
        return nil
    end
end

-- Function to import presets from exported data
function PresetManager.ImportPresets(plugin, importData, overwriteExisting)
    if not plugin or not importData then
        warn("Invalid parameters for importing presets")
        return false
    end
    
    overwriteExisting = overwriteExisting or false
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(importData)
    end)
    
    if not success or not data.presets then
        warn("Invalid import data")
        return false
    end
    
    local currentPresets = PresetManager.GetAllPresets(plugin)
    local importedCount = 0
    local skippedCount = 0
    
    for presetName, presetData in pairs(data.presets) do
        if currentPresets[presetName] and not overwriteExisting then
            skippedCount = skippedCount + 1
            print("Skipped existing preset: " .. presetName)
        else
            currentPresets[presetName] = presetData
            importedCount = importedCount + 1
        end
    end
    
    -- Save the updated presets
    local saveSuccess, err = pcall(function()
        local serializedPresets = HttpService:JSONEncode(currentPresets)
        plugin:SetSetting(PRESETS_KEY, serializedPresets)
    end)
    
    if saveSuccess then
        print("Imported " .. importedCount .. " presets, skipped " .. skippedCount .. " existing presets")
        return true
    else
        warn("Failed to save imported presets: " .. tostring(err))
        return false
    end
end

-- Function to clear all presets
function PresetManager.ClearAllPresets(plugin)
    if not plugin then
        warn("Invalid plugin for clearing presets")
        return false
    end
    
    local success, err = pcall(function()
        plugin:SetSetting(PRESETS_KEY, "{}")
    end)
    
    if success then
        print("All presets cleared")
        return true
    else
        warn("Failed to clear presets: " .. tostring(err))
        return false
    end
end

return PresetManager 