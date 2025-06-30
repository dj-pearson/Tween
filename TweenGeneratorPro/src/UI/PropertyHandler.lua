-- PropertyHandler.lua
-- Handles property detection and validation for different Roblox object types

local PropertyHandler = {}

-- Define tweenable properties for different object types
local PART_PROPERTIES = {
    Position = {type = "Vector3", default = Vector3.new(0, 0, 0)},
    Size = {type = "Vector3", default = Vector3.new(1, 1, 1)},
    Rotation = {type = "Vector3", default = Vector3.new(0, 0, 0)},
    Transparency = {type = "number", default = 0, min = 0, max = 1},
    Color = {type = "Color3", default = Color3.fromRGB(163, 162, 165)},
    Reflectance = {type = "number", default = 0, min = 0, max = 1},
}

local MODEL_PROPERTIES = {
    -- Models can be positioned via PrimaryPart
    -- We'll handle this specially in the tween generation
}

local UI_PROPERTIES = {
    Position = {type = "UDim2", default = UDim2.new(0, 0, 0, 0)},
    Size = {type = "UDim2", default = UDim2.new(0, 100, 0, 100)},
    Rotation = {type = "number", default = 0},
    BackgroundTransparency = {type = "number", default = 0, min = 0, max = 1},
    BackgroundColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    BorderSizePixel = {type = "number", default = 1, min = 0},
}

local TEXTLABEL_PROPERTIES = {
    Position = {type = "UDim2", default = UDim2.new(0, 0, 0, 0)},
    Size = {type = "UDim2", default = UDim2.new(0, 100, 0, 100)},
    Rotation = {type = "number", default = 0},
    BackgroundTransparency = {type = "number", default = 0, min = 0, max = 1},
    BackgroundColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    TextTransparency = {type = "number", default = 0, min = 0, max = 1},
    TextColor3 = {type = "Color3", default = Color3.fromRGB(0, 0, 0)},
    TextStrokeTransparency = {type = "number", default = 1, min = 0, max = 1},
    TextStrokeColor3 = {type = "Color3", default = Color3.fromRGB(0, 0, 0)},
}

local IMAGELABEL_PROPERTIES = {
    Position = {type = "UDim2", default = UDim2.new(0, 0, 0, 0)},
    Size = {type = "UDim2", default = UDim2.new(0, 100, 0, 100)},
    Rotation = {type = "number", default = 0},
    BackgroundTransparency = {type = "number", default = 0, min = 0, max = 1},
    BackgroundColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    ImageTransparency = {type = "number", default = 0, min = 0, max = 1},
    ImageColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
}

local FRAME_PROPERTIES = {
    Position = {type = "UDim2", default = UDim2.new(0, 0, 0, 0)},
    Size = {type = "UDim2", default = UDim2.new(0, 100, 0, 100)},
    Rotation = {type = "number", default = 0},
    BackgroundTransparency = {type = "number", default = 0, min = 0, max = 1},
    BackgroundColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    BorderSizePixel = {type = "number", default = 1, min = 0},
}

-- Function to get tweenable properties for a specific object
function PropertyHandler.GetTweenableProperties(object)
    if not object then return {} end
    
    local className = object.ClassName
    
    -- Part-like objects
    if className == "Part" or className == "WedgePart" or className == "CornerWedgePart" or 
       className == "TrussPart" or className == "UnionOperation" or className == "NegateOperation" or
       className == "MeshPart" then
        return PART_PROPERTIES
    end
    
    -- Model objects
    if className == "Model" then
        return MODEL_PROPERTIES
    end
    
    -- UI Objects
    if className == "Frame" or className == "ScrollingFrame" then
        return FRAME_PROPERTIES
    end
    
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        return TEXTLABEL_PROPERTIES
    end
    
    if className == "ImageLabel" or className == "ImageButton" then
        return IMAGELABEL_PROPERTIES
    end
    
    -- Generic UI element (catch-all for other GUI objects)
    if object:IsA("GuiObject") then
        return UI_PROPERTIES
    end
    
    -- Default to part properties for other BasePart objects
    if object:IsA("BasePart") then
        return PART_PROPERTIES
    end
    
    return {}
end

-- Function to get the current value of a property from an object
function PropertyHandler.GetPropertyValue(object, propertyName)
    if not object or not propertyName then return nil end
    
    local success, value = pcall(function()
        return object[propertyName]
    end)
    
    if success then
        return value
    else
        warn("Could not get property " .. propertyName .. " from " .. object.ClassName)
        return nil
    end
end

-- Function to set a property value safely
function PropertyHandler.SetPropertyValue(object, propertyName, value)
    if not object or not propertyName or value == nil then return false end
    
    local success = pcall(function()
        object[propertyName] = value
    end)
    
    if not success then
        warn("Could not set property " .. propertyName .. " on " .. object.ClassName)
    end
    
    return success
end

-- Function to validate a property value
function PropertyHandler.ValidatePropertyValue(propertyInfo, value)
    if not propertyInfo or value == nil then return false end
    
    local valueType = typeof(value)
    
    -- Check type matching
    if propertyInfo.type == "Vector3" and valueType ~= "Vector3" then
        return false
    elseif propertyInfo.type == "UDim2" and valueType ~= "UDim2" then
        return false
    elseif propertyInfo.type == "Color3" and valueType ~= "Color3" then
        return false
    elseif propertyInfo.type == "number" and valueType ~= "number" then
        return false
    end
    
    -- Check numerical bounds if specified
    if propertyInfo.type == "number" and valueType == "number" then
        if propertyInfo.min and value < propertyInfo.min then
            return false
        end
        if propertyInfo.max and value > propertyInfo.max then
            return false
        end
    end
    
    return true
end

-- Function to convert a property value to a tween-compatible format
function PropertyHandler.PrepareValueForTween(object, propertyName, value)
    if not object or not propertyName or value == nil then return nil end
    
    local properties = PropertyHandler.GetTweenableProperties(object)
    local propertyInfo = properties[propertyName]
    
    if not propertyInfo then return nil end
    
    -- Handle special cases
    if propertyName == "Rotation" and object:IsA("BasePart") then
        -- Convert Vector3 rotation to CFrame for parts
        if typeof(value) == "Vector3" then
            return CFrame.Angles(math.rad(value.X), math.rad(value.Y), math.rad(value.Z))
        end
    end
    
    -- Validate the value
    if PropertyHandler.ValidatePropertyValue(propertyInfo, value) then
        return value
    else
        warn("Invalid value for property " .. propertyName .. ": " .. tostring(value))
        return nil
    end
end

-- Function to get default values for all properties of an object
function PropertyHandler.GetDefaultProperties(object)
    if not object then return {} end
    
    local properties = PropertyHandler.GetTweenableProperties(object)
    local defaults = {}
    
    for propertyName, propertyInfo in pairs(properties) do
        local currentValue = PropertyHandler.GetPropertyValue(object, propertyName)
        if currentValue then
            defaults[propertyName] = currentValue
        else
            defaults[propertyName] = propertyInfo.default
        end
    end
    
    return defaults
end

-- Function to check if a property is tweenable for TweenService
function PropertyHandler.IsPropertyTweenable(object, propertyName)
    if not object or not propertyName then return false end
    
    local properties = PropertyHandler.GetTweenableProperties(object)
    return properties[propertyName] ~= nil
end

return PropertyHandler 