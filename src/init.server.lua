-- Tween Generator Pro Plugin for Roblox Studio
-- Bundled version for Argon/Rojo sync
-- All functionality included in single file

-- Plugin variable is provided by Roblox Studio when script runs as Plugin
local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Plugin Info
local pluginName = "Tween Generator Pro"
local pluginDescription = "Visual tween animation creator for Roblox Studio"

-- ========================================
-- PROPERTY HANDLER MODULE (bundled)
-- ========================================

local PropertyHandler = {}

-- Define tweenable properties for different object types
local PART_PROPERTIES = {
    Position = {type = "Vector3", default = Vector3.new(0, 0, 0)},
    Size = {type = "Vector3", default = Vector3.new(1, 1, 1)},
    Rotation = {type = "Vector3", default = Vector3.new(0, 0, 0)},
    Orientation = {type = "Vector3", default = Vector3.new(0, 0, 0)},
    Transparency = {type = "number", default = 0, min = 0, max = 1},
    Color = {type = "Color3", default = Color3.fromRGB(163, 162, 165)},
    Reflectance = {type = "number", default = 0, min = 0, max = 1},
    Material = {type = "string", default = "Plastic", warning = "Limited tween support"},
}

local UI_PROPERTIES = {
    Position = {type = "UDim2", default = UDim2.new(0, 0, 0, 0)},
    Size = {type = "UDim2", default = UDim2.new(0, 100, 0, 100)},
    Rotation = {type = "number", default = 0},
    BackgroundTransparency = {type = "number", default = 0, min = 0, max = 1},
    BackgroundColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    BorderSizePixel = {type = "number", default = 1, min = 0},
    ImageTransparency = {type = "number", default = 0, min = 0, max = 1},
    ImageColor3 = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
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
    TextSize = {type = "number", default = 14, min = 1, max = 100},
}

-- New property sets for lighting and effects
local LIGHT_PROPERTIES = {
    Brightness = {type = "number", default = 1, min = 0, max = 5},
    Range = {type = "number", default = 8, min = 0, max = 60},
    Color = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
}

local POINTLIGHT_PROPERTIES = {
    Brightness = {type = "number", default = 1, min = 0, max = 5},
    Range = {type = "number", default = 8, min = 0, max = 60},
    Color = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
}

local SPOTLIGHT_PROPERTIES = {
    Brightness = {type = "number", default = 1, min = 0, max = 5},
    Range = {type = "number", default = 8, min = 0, max = 60},
    Color = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
    Angle = {type = "number", default = 90, min = 0, max = 180},
}

local BLOOM_PROPERTIES = {
    Intensity = {type = "number", default = 0.4, min = 0, max = 5},
    Size = {type = "number", default = 24, min = 0, max = 100},
    Threshold = {type = "number", default = 0.95, min = 0, max = 5},
}

local BLUR_PROPERTIES = {
    Size = {type = "number", default = 5, min = 0, max = 100},
}

local COLORCORRECTION_PROPERTIES = {
    Brightness = {type = "number", default = 0, min = -1, max = 1},
    Contrast = {type = "number", default = 0, min = -1, max = 1},
    Saturation = {type = "number", default = 0, min = -1, max = 1},
    TintColor = {type = "Color3", default = Color3.fromRGB(255, 255, 255)},
}

local SOUND_PROPERTIES = {
    Volume = {type = "number", default = 0.5, min = 0, max = 1},
    PlaybackSpeed = {type = "number", default = 1, min = 0.1, max = 20},
    Pitch = {type = "number", default = 1, min = 0.1, max = 20},
}

function PropertyHandler.GetTweenableProperties(object)
    if not object then return {} end
    
    local className = object.ClassName
    
    -- Model objects - use PrimaryPart or first BasePart
    if className == "Model" then
        local targetPart = object.PrimaryPart
        if not targetPart then
            -- Find first BasePart in the model
            for _, child in pairs(object:GetChildren()) do
                if child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end
        
        if targetPart then
            return PART_PROPERTIES
        else
            return {} -- No parts found in model
        end
    end
    
    -- Part-like objects
    if className == "Part" or className == "WedgePart" or className == "MeshPart" or object:IsA("BasePart") then
        return PART_PROPERTIES
    end
    
    -- 💡 LIGHTING OBJECTS
    if className == "PointLight" then
        return POINTLIGHT_PROPERTIES
    elseif className == "SpotLight" then
        return SPOTLIGHT_PROPERTIES
    elseif className == "SurfaceLight" or object:IsA("Light") then
        return LIGHT_PROPERTIES
    end
    
    -- 🎨 POST-PROCESSING EFFECTS
    if className == "BloomEffect" then
        return BLOOM_PROPERTIES
    elseif className == "BlurEffect" then
        return BLUR_PROPERTIES
    elseif className == "ColorCorrectionEffect" then
        return COLORCORRECTION_PROPERTIES
    end
    
    -- 🔊 SOUND OBJECTS
    if className == "Sound" then
        return SOUND_PROPERTIES
    end
    
    -- 🎛 UI OBJECTS (Enhanced Detection)
    if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
        return TEXTLABEL_PROPERTIES
    elseif className == "ImageLabel" or className == "ImageButton" then
        -- Combine UI and Image properties
        local imageProperties = {}
        for k, v in pairs(UI_PROPERTIES) do
            imageProperties[k] = v
        end
        return imageProperties
    elseif className == "Frame" or className == "ScrollingFrame" then
        return UI_PROPERTIES
    elseif object:IsA("GuiObject") then
        return UI_PROPERTIES -- Generic UI element fallback
    end
    
    return {}
end

-- ========================================
-- CODE EXPORTER MODULE (bundled)
-- ========================================

local CodeExporter = {}

function CodeExporter.GenerateCode(targetObject, duration, easingStyle, easingDirection, repeatCount, reverses, delay, goalProperties)
    if not targetObject or not goalProperties or not next(goalProperties) then
        return "-- No valid object or properties specified"
    end
    
    local lines = {}
    
    -- Add header comment
    table.insert(lines, "-- Generated by Tween Generator Pro")
    table.insert(lines, "-- Object: " .. targetObject.Name .. " (" .. targetObject.ClassName .. ")")
    table.insert(lines, "")
    
    -- Add required services
    table.insert(lines, "local TweenService = game:GetService(\"TweenService\")")
    table.insert(lines, "")
    
    -- Add object reference
    local objectPath = CodeExporter.GenerateObjectPath(targetObject)
    table.insert(lines, "-- Reference to the object to tween")
    table.insert(lines, "local targetObject = " .. objectPath)
    table.insert(lines, "")
    
    -- Add TweenInfo creation
    table.insert(lines, "-- Create TweenInfo")
    table.insert(lines, "local tweenInfo = TweenInfo.new(")
    table.insert(lines, "    " .. duration .. ", -- Duration")
    table.insert(lines, "    Enum.EasingStyle." .. easingStyle.Name .. ", -- EasingStyle")
    table.insert(lines, "    Enum.EasingDirection." .. easingDirection.Name .. ", -- EasingDirection")
    table.insert(lines, "    " .. repeatCount .. ", -- RepeatCount")
    table.insert(lines, "    " .. tostring(reverses) .. ", -- Reverses")
    table.insert(lines, "    " .. delay .. " -- DelayTime")
    table.insert(lines, ")")
    table.insert(lines, "")
    
    -- Add goal properties
    table.insert(lines, "-- Goal properties")
    table.insert(lines, "local goals = {")
    
    for propertyName, value in pairs(goalProperties) do
        local valueString = CodeExporter.ValueToString(value)
        table.insert(lines, "    " .. propertyName .. " = " .. valueString .. ",")
    end
    
    table.insert(lines, "}")
    table.insert(lines, "")
    
    -- Add tween creation and play
    table.insert(lines, "-- Create and play the tween")
    table.insert(lines, "local tween = TweenService:Create(targetObject, tweenInfo, goals)")
    table.insert(lines, "tween:Play()")
    
    return table.concat(lines, "\n")
end

function CodeExporter.GenerateObjectPath(object)
    if not object then return "nil" end
    
    local workspace = game:GetService("Workspace")
    local starterGui = game:GetService("StarterGui")
    
    -- Check if object is in Workspace
    if object:IsDescendantOf(workspace) then
        return "game.Workspace." .. object.Name
    end
    
    -- Check if object is in StarterGui
    if object:IsDescendantOf(starterGui) then
        return "game:GetService(\"StarterGui\")." .. object.Name
    end
    
    -- Default to script.Parent assumption
    return "script.Parent -- Adjust this path to your object"
end

function CodeExporter.ValueToString(value)
    local valueType = typeof(value)
    
    if valueType == "Vector3" then
        return string.format("Vector3.new(%.3f, %.3f, %.3f)", value.X, value.Y, value.Z)
    elseif valueType == "UDim2" then
        return string.format("UDim2.new(%.3f, %d, %.3f, %d)", 
            value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset)
    elseif valueType == "Color3" then
        local r = math.floor(value.R * 255 + 0.5)
        local g = math.floor(value.G * 255 + 0.5)
        local b = math.floor(value.B * 255 + 0.5)
        return string.format("Color3.fromRGB(%d, %d, %d)", r, g, b)
    elseif valueType == "number" then
        return tostring(value)
    elseif valueType == "boolean" then
        return tostring(value)
    else
        return "nil -- Unsupported type: " .. valueType
    end
end

-- ========================================
-- PRESET MANAGER MODULE (bundled)
-- ========================================

local PresetManager = {}
local PRESETS_KEY = "TweenGeneratorPro_Presets"

function PresetManager.SavePreset(plugin, presetName, presetData)
    if not plugin or not presetName or not presetData then
        return false
    end
    
    local presets = PresetManager.GetAllPresets(plugin)
    presets[presetName] = presetData
    
    local success = pcall(function()
        local serializedPresets = HttpService:JSONEncode(presets)
        plugin:SetSetting(PRESETS_KEY, serializedPresets)
    end)
    
    return success
end

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
    
    return (success2 and type(presets) == "table") and presets or {}
end

-- ========================================
-- MAIN UI MODULE (bundled)
-- ========================================

local TweenGeneratorUI = {}
TweenGeneratorUI.__index = TweenGeneratorUI

function TweenGeneratorUI.new(widget, plugin)
    local self = setmetatable({}, TweenGeneratorUI)
    
    self.widget = widget
    self.plugin = plugin
    self.selectedObject = nil
    self.currentTween = nil
    self.originalProperties = {}
    
    -- Tween settings
    self.duration = 1
    self.delay = 0
    self.repeatCount = 0
    self.reverses = false
    self.easingStyle = Enum.EasingStyle.Sine
    self.easingDirection = Enum.EasingDirection.Out
    
    -- Property values
    self.startProperties = {}
    self.endProperties = {}
    
    self:CreateUI()
    self:ConnectEvents()
    
    return self
end

function TweenGeneratorUI:CreateUI()
    -- Main frame with blue/neon gradient background
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.widget
    
    -- Add blue gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 18, 35)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 12, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 25, 45))
    }
    gradient.Rotation = 135
    gradient.Parent = mainFrame
    
    -- Add corner radius
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Header with blue/neon styling
    local headerFrame = Instance.new("Frame")
    headerFrame.Name = "Header"
    headerFrame.Size = UDim2.new(1, 0, 0, 60)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = headerFrame
    
    local headerGradient = Instance.new("UIGradient")
    headerGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 35, 65)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 25, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 40, 70))
    }
    headerGradient.Rotation = 90
    headerGradient.Parent = headerFrame
    
    -- Add neon border to header
    local headerStroke = Instance.new("UIStroke")
    headerStroke.Color = Color3.fromRGB(0, 150, 255)
    headerStroke.Thickness = 2
    headerStroke.Transparency = 0.6
    headerStroke.Parent = headerFrame
    
    -- Title with neon glow
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -30, 1, 0)
    titleLabel.Position = UDim2.new(0, 25, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "TWEEN GENERATOR PRO"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = headerFrame
    
    -- Add neon glow to title
    local titleGlow = Instance.new("UIStroke")
    titleGlow.Color = Color3.fromRGB(0, 200, 255)
    titleGlow.Thickness = 1
    titleGlow.Transparency = 0.3
    titleGlow.Parent = titleLabel
    
    -- Create modern scroll frame with proper positioning
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -80)
    scrollFrame.Position = UDim2.new(0, 10, 0, 70)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1300)
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
    scrollFrame.Parent = mainFrame
    
    -- Create sections
    self:CreateObjectSelectionSection(scrollFrame)
    self:CreatePropertySection(scrollFrame)
    self:CreateTweenControlsSection(scrollFrame)
    self:CreatePreviewSection(scrollFrame)
    self:CreateExportSection(scrollFrame)
    self:CreatePresetSection(scrollFrame)
    
    self.mainFrame = mainFrame
    self.scrollFrame = scrollFrame
end

function TweenGeneratorUI:CreateObjectSelectionSection(parent)
    local section = self:CreateSection("Object Selection", parent, 0)
    
    -- Object info label
    -- Modern object info display
    local infoContainer = Instance.new("Frame")
    infoContainer.Size = UDim2.new(1, -150, 0, 35)
    infoContainer.Position = UDim2.new(0, 15, 0, 27.5)
    infoContainer.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
    infoContainer.BorderSizePixel = 0
    infoContainer.Parent = section
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = infoContainer
    
    local infoStroke = Instance.new("UIStroke")
    infoStroke.Color = Color3.fromRGB(80, 120, 200)
    infoStroke.Thickness = 1
    infoStroke.Transparency = 0.8
    infoStroke.Parent = infoContainer
    
    self.objectInfoLabel = Instance.new("TextLabel")
    self.objectInfoLabel.Size = UDim2.new(1, -20, 1, 0)
    self.objectInfoLabel.Position = UDim2.new(0, 10, 0, 0)
    self.objectInfoLabel.BackgroundTransparency = 1
    self.objectInfoLabel.Text = "No object selected"
    self.objectInfoLabel.TextColor3 = Color3.fromRGB(180, 200, 255)
    self.objectInfoLabel.TextSize = 12
    self.objectInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.objectInfoLabel.Font = Enum.Font.GothamMedium
    self.objectInfoLabel.Parent = infoContainer
    
    -- Modern Refresh button
    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.new(0, 120, 0, 35)
    refreshButton.Position = UDim2.new(1, -130, 0, 27.5)
    refreshButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    refreshButton.BorderSizePixel = 0
    refreshButton.Text = "🔄 REFRESH"
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.TextSize = 12
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.Parent = section
    
    -- Modern styling
    local refreshCorner = Instance.new("UICorner")
    refreshCorner.CornerRadius = UDim.new(0, 8)
    refreshCorner.Parent = refreshButton
    
    local refreshGradient = Instance.new("UIGradient")
    refreshGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
    }
    refreshGradient.Rotation = 90
    refreshGradient.Parent = refreshButton
    
    local refreshGlow = Instance.new("UIStroke")
    refreshGlow.Color = Color3.fromRGB(100, 180, 255)
    refreshGlow.Thickness = 1.5
    refreshGlow.Transparency = 0.7
    refreshGlow.Parent = refreshButton
    
    -- Hover effects
    refreshButton.MouseEnter:Connect(function()
        refreshGlow.Transparency = 0.4
        refreshButton.Size = UDim2.new(0, 125, 0, 38)
        refreshButton.Position = UDim2.new(1, -132.5, 0, 26)
    end)
    
    refreshButton.MouseLeave:Connect(function()
        refreshGlow.Transparency = 0.7
        refreshButton.Size = UDim2.new(0, 120, 0, 35)
        refreshButton.Position = UDim2.new(1, -130, 0, 27.5)
    end)
    
    refreshButton.MouseButton1Click:Connect(function()
        -- Visual feedback on click
        refreshButton.BackgroundColor3 = Color3.fromRGB(0, 130, 235)
        task.wait(0.1)
        refreshButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        
        self:RefreshSelectedObject()
    end)
    
    -- Blue/neon info button
    local infoButton = Instance.new("TextButton")
    infoButton.Size = UDim2.new(0, 35, 0, 35)
    infoButton.Position = UDim2.new(1, -45, 0, 65)
    infoButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    infoButton.BorderSizePixel = 0
    infoButton.Text = "ℹ️"
    infoButton.TextSize = 18
    infoButton.Parent = section
    
    -- Add gradient background
    local infoGradient = Instance.new("UIGradient")
    infoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 220))
    }
    infoGradient.Rotation = 90
    infoGradient.Parent = infoButton
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 17)
    infoCorner.Parent = infoButton
    
    -- Add neon glow
    local infoGlow = Instance.new("UIStroke")
    infoGlow.Color = Color3.fromRGB(0, 200, 255)
    infoGlow.Thickness = 2
    infoGlow.Transparency = 0.4
    infoGlow.Parent = infoButton
    
    -- Blue/neon info tooltip
    local infoTooltip = Instance.new("Frame")
    infoTooltip.Size = UDim2.new(0, 340, 0, 220)
    infoTooltip.Position = UDim2.new(1, -350, 0, 0)
    infoTooltip.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    infoTooltip.BorderSizePixel = 0
    infoTooltip.Visible = false
    infoTooltip.Parent = infoButton
    
    -- Add gradient background to tooltip
    local tooltipGradient = Instance.new("UIGradient")
    tooltipGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 60)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 25, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
    }
    tooltipGradient.Rotation = 90
    tooltipGradient.Parent = infoTooltip
    
    local tooltipCorner = Instance.new("UICorner")
    tooltipCorner.CornerRadius = UDim.new(0, 12)
    tooltipCorner.Parent = infoTooltip
    
    local tooltipStroke = Instance.new("UIStroke")
    tooltipStroke.Color = Color3.fromRGB(0, 180, 255)
    tooltipStroke.Thickness = 3
    tooltipStroke.Transparency = 0.4
    tooltipStroke.Parent = infoTooltip
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -25, 1, -25)
    infoText.Position = UDim2.new(0, 12, 0, 12)
    infoText.BackgroundTransparency = 1
    infoText.Text = [[✨ SUPPORTED OBJECTS ✨

🧱 PARTS & MODELS
• Position, Size, Orientation, Transparency
• Color, Reflectance, Material

🎛️ UI ELEMENTS  
• Position, Size, Rotation
• All Transparency & Color properties
• TextSize, BackgroundColor3, TextColor3

💡 LIGHTING & EFFECTS
• PointLight, SpotLight: Brightness, Range, Color
• BloomEffect: Intensity, Size, Threshold  
• BlurEffect: Size
• ColorCorrection: Brightness, Contrast, etc.

🔊 SOUNDS
• Volume, PlaybackSpeed, Pitch

⚠️ Smart warnings detect common issues!]]
    infoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.GothamMedium
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoTooltip
    
    -- Add subtle glow to text
    local textGlow = Instance.new("UIStroke")
    textGlow.Color = Color3.fromRGB(0, 150, 255)
    textGlow.Thickness = 0.5
    textGlow.Transparency = 0.8
    textGlow.Parent = infoText
    
    infoButton.MouseEnter:Connect(function()
        infoTooltip.Visible = true
    end)
    
    infoButton.MouseLeave:Connect(function()
        infoTooltip.Visible = false
    end)
    
    section.Size = UDim2.new(1, -40, 0, 180)
end

function TweenGeneratorUI:CreatePropertySection(parent)
    local section = self:CreateSection("Properties", parent, 200)
    
    self.propertyFrame = Instance.new("Frame")
    self.propertyFrame.Size = UDim2.new(1, -40, 0, 320)
    self.propertyFrame.Position = UDim2.new(0, 20, 0, 60)
    self.propertyFrame.BackgroundTransparency = 1
    self.propertyFrame.Parent = section
    
    section.Size = UDim2.new(1, -40, 0, 390)
end

function TweenGeneratorUI:CreateTweenControlsSection(parent)
    local section = self:CreateSection("Tween Settings", parent, 620)
    
    local yPos = 40
    
    -- Duration
    yPos = self:CreateNumberInput(section, "Duration", self.duration, function(value)
        self.duration = value
    end, yPos)
    
    -- Delay
    yPos = self:CreateNumberInput(section, "Delay", self.delay, function(value)
        self.delay = value
    end, yPos)
    
    -- Repeat Count
    yPos = self:CreateNumberInput(section, "Repeat Count", self.repeatCount, function(value)
        self.repeatCount = math.max(0, math.floor(value))
    end, yPos)
    
    -- Reverses toggle
    local reversesLabel = Instance.new("TextLabel")
    reversesLabel.Size = UDim2.new(0.5, -10, 0, 25)
    reversesLabel.Position = UDim2.new(0, 10, 0, yPos)
    reversesLabel.BackgroundTransparency = 1
    reversesLabel.Text = "Reverses:"
    reversesLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    reversesLabel.TextXAlignment = Enum.TextXAlignment.Left
    reversesLabel.Parent = section
    
    local reversesToggle = Instance.new("TextButton")
    reversesToggle.Size = UDim2.new(0.5, -15, 0, 30)
    reversesToggle.Position = UDim2.new(0.5, 5, 0, yPos)
    reversesToggle.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    reversesToggle.BorderSizePixel = 0
    reversesToggle.Text = "false"
    reversesToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    reversesToggle.Parent = section
    
    -- Add blue/neon styling to toggle
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = reversesToggle
    
    local toggleGradient = Instance.new("UIGradient")
    toggleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
    }
    toggleGradient.Rotation = 90
    toggleGradient.Parent = reversesToggle
    
    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(0, 150, 255)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 0.6
    toggleStroke.Parent = reversesToggle
    
    reversesToggle.MouseButton1Click:Connect(function()
        self.reverses = not self.reverses
        reversesToggle.Text = tostring(self.reverses)
        reversesToggle.BackgroundColor3 = self.reverses and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(15, 25, 50)
        toggleStroke.Transparency = self.reverses and 0.3 or 0.6
    end)
    
    yPos = yPos + 35
    
    -- Easing Style dropdown (simplified)
    local easingLabel = Instance.new("TextLabel")
    easingLabel.Size = UDim2.new(0.5, -10, 0, 25)
    easingLabel.Position = UDim2.new(0, 10, 0, yPos)
    easingLabel.BackgroundTransparency = 1
    easingLabel.Text = "Easing Style:"
    easingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    easingLabel.TextXAlignment = Enum.TextXAlignment.Left
    easingLabel.Parent = section
    
    local easingDropdown = Instance.new("TextButton")
    easingDropdown.Size = UDim2.new(0.5, -15, 0, 30)
    easingDropdown.Position = UDim2.new(0.5, 5, 0, yPos)
    easingDropdown.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    easingDropdown.BorderSizePixel = 0
    easingDropdown.Text = "Sine"
    easingDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    easingDropdown.Parent = section
    
    -- Add blue/neon styling to dropdown
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = easingDropdown
    
    local dropdownGradient = Instance.new("UIGradient")
    dropdownGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
    }
    dropdownGradient.Rotation = 90
    dropdownGradient.Parent = easingDropdown
    
    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = Color3.fromRGB(0, 150, 255)
    dropdownStroke.Thickness = 1
    dropdownStroke.Transparency = 0.6
    dropdownStroke.Parent = easingDropdown
    
    local easingStyles = {"Linear", "Sine", "Back", "Bounce", "Elastic", "Exponential", "Quad"}
    local currentEasingIndex = 2
    
    easingDropdown.MouseButton1Click:Connect(function()
        currentEasingIndex = currentEasingIndex + 1
        if currentEasingIndex > #easingStyles then
            currentEasingIndex = 1
        end
        local selectedStyle = easingStyles[currentEasingIndex]
        easingDropdown.Text = selectedStyle
        self.easingStyle = Enum.EasingStyle[selectedStyle]
    end)
    
    section.Size = UDim2.new(1, -40, 0, yPos + 60)
end

function TweenGeneratorUI:CreatePreviewSection(parent)
    local section = self:CreateSection("Preview", parent, 850)
    
    -- Blue/neon Preview button
    local previewButton = Instance.new("TextButton")
    previewButton.Size = UDim2.new(0, 170, 0, 50)
    previewButton.Position = UDim2.new(0, 20, 0, 50)
    previewButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    previewButton.BorderSizePixel = 0
    previewButton.Text = "▶ PREVIEW TWEEN"
    previewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewButton.TextSize = 15
    previewButton.Font = Enum.Font.GothamBold
    previewButton.Parent = section
    
    -- Blue/neon button styling
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 12)
    previewCorner.Parent = previewButton
    
    local previewGradient = Instance.new("UIGradient")
    previewGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 220))
    }
    previewGradient.Rotation = 90
    previewGradient.Parent = previewButton
    
    local previewGlow = Instance.new("UIStroke")
    previewGlow.Color = Color3.fromRGB(0, 220, 255)
    previewGlow.Thickness = 3
    previewGlow.Transparency = 0.5
    previewGlow.Parent = previewButton
    
    -- Blue/neon Stop button with red accent
    local stopButton = Instance.new("TextButton")
    stopButton.Size = UDim2.new(0, 130, 0, 50)
    stopButton.Position = UDim2.new(0, 200, 0, 50)
    stopButton.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
    stopButton.BorderSizePixel = 0
    stopButton.Text = "⏹ STOP"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextSize = 15
    stopButton.Font = Enum.Font.GothamBold
    stopButton.Parent = section
    
    local stopCorner = Instance.new("UICorner")
    stopCorner.CornerRadius = UDim.new(0, 12)
    stopCorner.Parent = stopButton
    
    local stopGradient = Instance.new("UIGradient")
    stopGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 140)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 80, 120)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 60, 100))
    }
    stopGradient.Rotation = 90
    stopGradient.Parent = stopButton
    
    local stopGlow = Instance.new("UIStroke")
    stopGlow.Color = Color3.fromRGB(255, 150, 180)
    stopGlow.Thickness = 3
    stopGlow.Transparency = 0.5
    stopGlow.Parent = stopButton
    
    -- Enhanced hover effects for Preview button
    previewButton.MouseEnter:Connect(function()
        previewGlow.Transparency = 0.2
        previewButton.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        previewButton.Size = UDim2.new(0, 175, 0, 53)
        previewButton.Position = UDim2.new(0, 17.5, 0, 48.5)
    end)
    
    previewButton.MouseLeave:Connect(function()
        previewGlow.Transparency = 0.5
        previewButton.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        previewButton.Size = UDim2.new(0, 170, 0, 50)
        previewButton.Position = UDim2.new(0, 20, 0, 50)
    end)
    
    -- Enhanced hover effects for Stop button
    stopButton.MouseEnter:Connect(function()
        stopGlow.Transparency = 0.2
        stopButton.BackgroundColor3 = Color3.fromRGB(255, 100, 140)
        stopButton.Size = UDim2.new(0, 135, 0, 53)
        stopButton.Position = UDim2.new(0, 197.5, 0, 48.5)
    end)
    
    stopButton.MouseLeave:Connect(function()
        stopGlow.Transparency = 0.5
        stopButton.BackgroundColor3 = Color3.fromRGB(255, 80, 120)
        stopButton.Size = UDim2.new(0, 130, 0, 50)
        stopButton.Position = UDim2.new(0, 200, 0, 50)
    end)
    
    previewButton.MouseButton1Click:Connect(function()
        self:PreviewTween()
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        self:StopPreview()
    end)
    
    section.Size = UDim2.new(1, -30, 0, 160)
end

function TweenGeneratorUI:CreateExportSection(parent)
    local section = self:CreateSection("Export Code", parent, 1080)
    
    -- Blue/neon Export button
    local exportButton = Instance.new("TextButton")
    exportButton.Size = UDim2.new(1, -40, 0, 55)
    exportButton.Position = UDim2.new(0, 20, 0, 50)
    exportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    exportButton.BorderSizePixel = 0
    exportButton.Text = "📋 EXPORT CODE TO CLIPBOARD"
    exportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportButton.TextSize = 16
    exportButton.Font = Enum.Font.GothamBold
    exportButton.Parent = section
    
    -- Blue/neon styling with orange accent
    local exportCorner = Instance.new("UICorner")
    exportCorner.CornerRadius = UDim.new(0, 15)
    exportCorner.Parent = exportButton
    
    local exportGradient = Instance.new("UIGradient")
    exportGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 20)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 130, 0))
    }
    exportGradient.Rotation = 90
    exportGradient.Parent = exportButton
    
    local exportGlow = Instance.new("UIStroke")
    exportGlow.Color = Color3.fromRGB(255, 200, 100)
    exportGlow.Thickness = 3
    exportGlow.Transparency = 0.5
    exportGlow.Parent = exportButton
    
    -- Enhanced neon hover effects
    exportButton.MouseEnter:Connect(function()
        exportGlow.Transparency = 0.2
        exportButton.Size = UDim2.new(1, -35, 0, 60)
        exportButton.Position = UDim2.new(0, 17.5, 0, 47.5)
        exportButton.BackgroundColor3 = Color3.fromRGB(255, 170, 20)
        
        -- Add pulsing neon effect
        local pulseStart = tick()
        local pulseConnection
        pulseConnection = game:GetService("RunService").Heartbeat:Connect(function()
            local elapsed = tick() - pulseStart
            local alpha = (math.sin(elapsed * 6) + 1) / 2
            exportGlow.Transparency = 0.2 + (alpha * 0.3)
        end)
        
        exportButton.AncestryChanged:Connect(function()
            if pulseConnection then
                pulseConnection:Disconnect()
            end
        end)
    end)
    
    exportButton.MouseLeave:Connect(function()
        exportGlow.Transparency = 0.5
        exportButton.Size = UDim2.new(1, -40, 0, 55)
        exportButton.Position = UDim2.new(0, 20, 0, 50)
        exportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    end)
    
    exportButton.MouseButton1Click:Connect(function()
        -- Enhanced visual feedback on click
        exportButton.BackgroundColor3 = Color3.fromRGB(230, 130, 0)
        exportGlow.Transparency = 0.1
        task.wait(0.1)
        exportButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
        exportGlow.Transparency = 0.5
        
        self:ExportCode()
    end)
    
    section.Size = UDim2.new(1, -30, 0, 160)
end

function TweenGeneratorUI:CreatePresetSection(parent)
    local section = self:CreateSection("Presets", parent, 690)
    
    -- Preset name input
    local presetNameInput = Instance.new("TextBox")
    presetNameInput.Size = UDim2.new(1, -120, 0, 30)
    presetNameInput.Position = UDim2.new(0, 10, 0, 30)
    presetNameInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    presetNameInput.BorderSizePixel = 0
    presetNameInput.Text = "New Preset"
    presetNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    presetNameInput.Parent = section
    
    -- Save preset button
    local savePresetButton = Instance.new("TextButton")
    savePresetButton.Size = UDim2.new(0, 100, 0, 30)
    savePresetButton.Position = UDim2.new(1, -110, 0, 30)
    savePresetButton.BackgroundColor3 = Color3.fromRGB(103, 58, 183)
    savePresetButton.BorderSizePixel = 0
    savePresetButton.Text = "Save"
    savePresetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    savePresetButton.Parent = section
    
    savePresetButton.MouseButton1Click:Connect(function()
        local presetName = presetNameInput.Text
        if presetName and presetName ~= "" then
            self:SavePreset(presetName)
        end
    end)
    
    section.Size = UDim2.new(1, -20, 0, 80)
end

function TweenGeneratorUI:CreateSection(title, parent, yOffset)
    local section = Instance.new("Frame")
    section.Name = title .. "Section"
    section.Size = UDim2.new(1, -40, 0, 180)
    section.Position = UDim2.new(0, 20, 0, yOffset)
    section.BackgroundColor3 = Color3.fromRGB(18, 28, 45)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Simplified background for better performance
    section.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    
    -- Add corner radius and neon border
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = section
    
    -- Neon border effect
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 2
    stroke.Transparency = 0.5
    stroke.Parent = section
    
    -- Modern title with better contrast
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -25, 0, 40)
    titleLabel.Position = UDim2.new(0, 25, 0, 15)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title:upper()
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = section
    
    -- Add subtle text shadow for better readability
    local titleShadow = Instance.new("TextLabel")
    titleShadow.Size = titleLabel.Size
    titleShadow.Position = UDim2.new(0, 26, 0, 16)
    titleShadow.BackgroundTransparency = 1
    titleShadow.Text = titleLabel.Text
    titleShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    titleShadow.TextSize = titleLabel.TextSize
    titleShadow.TextXAlignment = titleLabel.TextXAlignment
    titleShadow.Font = titleLabel.Font
    titleShadow.ZIndex = titleLabel.ZIndex - 1
    titleShadow.Parent = section
    
    return section
end

function TweenGeneratorUI:CreateNumberInput(parent, labelText, defaultValue, callback, yPos, minValue, maxValue)
    minValue = minValue or 0
    maxValue = maxValue or (labelText == "Duration" and 10 or (labelText == "Delay" and 5 or 10))
    
    -- Modern label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText:upper()
    label.TextColor3 = Color3.fromRGB(160, 180, 220)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.Parent = parent
    
    -- Container for controls
    local controlFrame = Instance.new("Frame")
    controlFrame.Size = UDim2.new(1, -20, 0, 35)
    controlFrame.Position = UDim2.new(0, 15, 0, yPos + 25)
    controlFrame.BackgroundTransparency = 1
    controlFrame.Parent = parent
    
    -- Blue/neon slider track
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(0.6, -10, 0, 8)
    sliderTrack.Position = UDim2.new(0, 0, 0.5, -4)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = controlFrame
    
    -- Add gradient to track
    local trackGradient = Instance.new("UIGradient")
    trackGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
    }
    trackGradient.Rotation = 90
    trackGradient.Parent = sliderTrack
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = sliderTrack
    
    -- Add neon border to track
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Color3.fromRGB(0, 150, 255)
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.7
    trackStroke.Parent = sliderTrack
    
    -- Slider fill (progress indicator) with neon glow
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    -- Add neon glow to fill
    local fillGlow = Instance.new("UIStroke")
    fillGlow.Color = Color3.fromRGB(0, 220, 255)
    fillGlow.Thickness = 2
    fillGlow.Transparency = 0.3
    fillGlow.Parent = sliderFill
    
    -- Slider handle with blue/neon styling
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 18, 0, 18)
    sliderHandle.Position = UDim2.new((defaultValue - minValue) / (maxValue - minValue), -9, 0.5, -9)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    sliderHandle.Parent = controlFrame
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 9)
    handleCorner.Parent = sliderHandle
    
    local handleGlow = Instance.new("UIStroke")
    handleGlow.Color = Color3.fromRGB(0, 200, 255)
    handleGlow.Thickness = 3
    handleGlow.Transparency = 0.2
    handleGlow.Parent = sliderHandle
    
    -- Value display with blue/neon styling
    local valueDisplay = Instance.new("TextLabel")
    valueDisplay.Size = UDim2.new(0, 65, 0, 32)
    valueDisplay.Position = UDim2.new(0.6, 5, 0, 1.5)
    valueDisplay.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
    valueDisplay.BorderSizePixel = 0
    valueDisplay.Text = string.format("%.2f", defaultValue)
    valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueDisplay.TextSize = 14
    valueDisplay.Font = Enum.Font.GothamMedium
    valueDisplay.Parent = controlFrame
    
    -- Add gradient to value display
    local displayGradient = Instance.new("UIGradient")
    displayGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 30, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
    }
    displayGradient.Rotation = 90
    displayGradient.Parent = valueDisplay
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 8)
    displayCorner.Parent = valueDisplay
    
    -- Add neon border to value display
    local displayStroke = Instance.new("UIStroke")
    displayStroke.Color = Color3.fromRGB(0, 150, 255)
    displayStroke.Thickness = 1
    displayStroke.Transparency = 0.6
    displayStroke.Parent = valueDisplay
    
    -- Preset buttons for common values
    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(0.35, -10, 0, 20)
    presetFrame.Position = UDim2.new(0.65, 10, 0, 40)
    presetFrame.BackgroundTransparency = 1
    presetFrame.Parent = controlFrame
    
    local presets = {}
    if labelText == "Duration" then
        presets = {0.5, 1, 2, 5}
    elseif labelText == "Delay" then
        presets = {0, 0.5, 1, 2}
    else
        presets = {0, 1, 5, 10}
    end
    
    for i, presetValue in ipairs(presets) do
        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(0.23, -1, 1, 0)
        presetBtn.Position = UDim2.new((i-1) * 0.25, 1, 0, 0)
        presetBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
        presetBtn.BorderSizePixel = 0
        presetBtn.Text = tostring(presetValue)
        presetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        presetBtn.TextSize = 10
        presetBtn.Font = Enum.Font.Gotham
        presetBtn.Parent = presetFrame
        
        -- Add gradient background
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 35, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
        }
        btnGradient.Rotation = 90
        btnGradient.Parent = presetBtn
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = presetBtn
        
        -- Add neon border
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(0, 150, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.6
        btnStroke.Parent = presetBtn
        
        presetBtn.MouseButton1Click:Connect(function()
            callback(presetValue)
            self:UpdateSlider(sliderHandle, sliderFill, valueDisplay, presetValue, minValue, maxValue)
        end)
        
        -- Enhanced hover effects
        presetBtn.MouseEnter:Connect(function()
            presetBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
            btnStroke.Transparency = 0.3
        end)
        
        presetBtn.MouseLeave:Connect(function()
            presetBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
            btnStroke.Transparency = 0.6
        end)
    end
    
    -- Slider functionality
    local dragging = false
    local function updateValue(inputObject)
        if not dragging then return end
        
        local relativeX = (inputObject.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
        relativeX = math.clamp(relativeX, 0, 1)
        
        local newValue = minValue + (maxValue - minValue) * relativeX
        newValue = math.round(newValue * 100) / 100 -- Round to 2 decimal places
        
        callback(newValue)
        self:UpdateSlider(sliderHandle, sliderFill, valueDisplay, newValue, minValue, maxValue)
    end
    
    sliderHandle.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(updateValue)
    
    game:GetService("UserInputService").InputEnded:Connect(function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return yPos + 95
end

function TweenGeneratorUI:UpdateSlider(handle, fill, display, value, minValue, maxValue)
    local percent = (value - minValue) / (maxValue - minValue)
    
    handle.Position = UDim2.new(percent, -9, 0.5, -9)
    fill.Size = UDim2.new(percent, 0, 1, 0)
    display.Text = string.format("%.2f", value)
end

function TweenGeneratorUI:CheckPropertyWarnings(targetObject, propertyName)
    if not targetObject then return nil end
    
    local className = targetObject.ClassName
    
    -- Part anchoring warnings
    if targetObject:IsA("BasePart") and (propertyName == "Position" or propertyName == "Size" or propertyName == "Orientation") then
        if not targetObject.Anchored then
            return "⚠️ Part is not anchored! Tweening may not work as expected. Consider setting Anchored = true."
        end
    end
    
    -- CanCollide warnings for moving parts
    if targetObject:IsA("BasePart") and propertyName == "Position" then
        if targetObject.CanCollide then
            return "💡 Part has CanCollide enabled. Consider disabling during movement to prevent physics conflicts."
        end
    end
    
    -- Sound warnings
    if className == "Sound" and propertyName == "Volume" then
        if not targetObject.IsPlaying then
            return "🔊 Sound is not playing. Start the sound before tweening volume for best results."
        end
    end
    
    -- Transparency warnings
    if propertyName:find("Transparency") and targetObject[propertyName] == 1 then
        return "👁️ Object is fully transparent. Tween may not be visible unless changing to lower transparency."
    end
    
    -- Lighting warnings
    if targetObject:IsA("Light") and propertyName == "Brightness" then
        if targetObject.Brightness == 0 then
            return "💡 Light brightness is 0. Increase brightness to see lighting effects."
        end
    end
    
    return nil -- No warnings
end

function TweenGeneratorUI:ConnectEvents()
    -- Auto-refresh selection
    Selection.SelectionChanged:Connect(function()
        self:RefreshSelectedObject()
    end)
end

function TweenGeneratorUI:GetTargetObject()
    if not self.selectedObject then return nil end
    
    if self.selectedObject.ClassName == "Model" then
        local targetPart = self.selectedObject.PrimaryPart
        if not targetPart then
            -- Find first BasePart in the model
            for _, child in pairs(self.selectedObject:GetChildren()) do
                if child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end
        return targetPart
    else
        return self.selectedObject
    end
end

function TweenGeneratorUI:RefreshSelectedObject()
    local selection = Selection:Get()
    
    if #selection > 0 then
        self.selectedObject = selection[1]
        local targetObject = self:GetTargetObject()
        
        if self.selectedObject.ClassName == "Model" then
            if targetObject then
                self.objectInfoLabel.Text = "Selected: " .. self.selectedObject.Name .. " (Model) → " .. targetObject.Name .. " (" .. targetObject.ClassName .. ")"
            else
                self.objectInfoLabel.Text = "Selected: " .. self.selectedObject.Name .. " (Model) → No parts found!"
            end
        else
            self.objectInfoLabel.Text = "Selected: " .. self.selectedObject.Name .. " (" .. self.selectedObject.ClassName .. ")"
        end
        
        self:RefreshPropertyEditor()
    else
        self.selectedObject = nil
        self.objectInfoLabel.Text = "No object selected"
        self:ClearPropertyEditor()
    end
end

function TweenGeneratorUI:RefreshPropertyEditor()
    self:ClearPropertyEditor()
    
    if not self.selectedObject then return end
    
    local properties = PropertyHandler.GetTweenableProperties(self.selectedObject)
    local yPos = 0
    
    for propertyName, propertyInfo in pairs(properties) do
        yPos = self:CreatePropertyEditor(propertyName, propertyInfo, yPos)
    end
    
    -- Update frame size
    self.propertyFrame.Size = UDim2.new(1, -20, 0, yPos)
end

function TweenGeneratorUI:ClearPropertyEditor()
    for _, child in pairs(self.propertyFrame:GetChildren()) do
        child:Destroy()
    end
    self.endProperties = {}
end

function TweenGeneratorUI:CreatePropertyEditor(propertyName, propertyInfo, yPos)
    local propertyType = propertyInfo.type
    local targetObject = self:GetTargetObject()
    
    if not targetObject then
        return yPos -- Skip if no valid target object
    end
    
    local currentValue = targetObject[propertyName]
    
    -- Property label with better readability
    local propertyLabel = Instance.new("TextLabel")
    propertyLabel.Size = UDim2.new(0.25, -10, 0, 30)
    propertyLabel.Position = UDim2.new(0, 15, 0, yPos)
    propertyLabel.BackgroundTransparency = 1
    propertyLabel.Text = propertyName:upper() .. ":"
    propertyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    propertyLabel.TextSize = 16
    propertyLabel.TextXAlignment = Enum.TextXAlignment.Left
    propertyLabel.Font = Enum.Font.GothamBold
    propertyLabel.Parent = self.propertyFrame
    
    -- Add text shadow for better readability
    local labelShadow = Instance.new("TextLabel")
    labelShadow.Size = propertyLabel.Size
    labelShadow.Position = UDim2.new(0, 16, 0, yPos + 1)
    labelShadow.BackgroundTransparency = 1
    labelShadow.Text = propertyLabel.Text
    labelShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    labelShadow.TextSize = propertyLabel.TextSize
    labelShadow.TextXAlignment = propertyLabel.TextXAlignment
    labelShadow.Font = propertyLabel.Font
    labelShadow.ZIndex = propertyLabel.ZIndex - 1
    labelShadow.Parent = self.propertyFrame
    
    -- Add warning indicators for important properties
    local warning = self:CheckPropertyWarnings(targetObject, propertyName)
    if warning then
        local warningIcon = Instance.new("TextLabel")
        warningIcon.Size = UDim2.new(0, 20, 0, 25)
        warningIcon.Position = UDim2.new(0.28, 0, 0, yPos)
        warningIcon.BackgroundTransparency = 1
        warningIcon.Text = "⚠️"
        warningIcon.TextSize = 12
        warningIcon.Parent = self.propertyFrame
        
        -- Tooltip for warning
        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 200, 0, 30)
        tooltip.Position = UDim2.new(0, 50, 0, 0)
        tooltip.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        tooltip.BorderSizePixel = 0
        tooltip.Text = warning
        tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
        tooltip.TextSize = 10
        tooltip.Font = Enum.Font.Gotham
        tooltip.TextWrapped = true
        tooltip.Visible = false
        tooltip.Parent = warningIcon
        
        local tooltipCorner = Instance.new("UICorner")
        tooltipCorner.CornerRadius = UDim.new(0, 6)
        tooltipCorner.Parent = tooltip
        
        warningIcon.MouseEnter:Connect(function()
            tooltip.Visible = true
        end)
        
        warningIcon.MouseLeave:Connect(function()
            tooltip.Visible = false
        end)
    end
    
    -- Modern status indicator
    local statusIndicator = Instance.new("TextLabel")
    statusIndicator.Name = propertyName .. "Status"
    statusIndicator.Size = UDim2.new(0, 25, 0, 25)
    statusIndicator.Position = UDim2.new(0.3, -10, 0, yPos)
    statusIndicator.BackgroundTransparency = 1
    statusIndicator.Text = "○"
    statusIndicator.TextColor3 = Color3.fromRGB(120, 140, 180)
    statusIndicator.TextSize = 16
    statusIndicator.Font = Enum.Font.GothamBold
    statusIndicator.Parent = self.propertyFrame
    
    if propertyType == "Vector3" then
        yPos = self:CreateVector3Editor(propertyName, currentValue, yPos)
    elseif propertyType == "UDim2" then
        yPos = self:CreateUDim2Editor(propertyName, currentValue, yPos)
    elseif propertyType == "Color3" then
        yPos = self:CreateColor3Editor(propertyName, currentValue, yPos)
    elseif propertyType == "number" then
        yPos = self:CreateNumberEditor(propertyName, currentValue, propertyInfo, yPos)
    end
    
    return yPos + 10 -- Extra spacing between properties
end

function TweenGeneratorUI:CreateVector3Editor(propertyName, currentValue, yPos)
    local inputs = {"X", "Y", "Z"}
    local values = {currentValue.X, currentValue.Y, currentValue.Z}
    local colors = {
        Color3.fromRGB(255, 80, 120), -- Neon Red for X
        Color3.fromRGB(80, 255, 120), -- Neon Green for Y  
        Color3.fromRGB(80, 150, 255)  -- Neon Blue for Z
    }
    
    -- Create input fields with blue/neon styling and better spacing
    for i, component in ipairs(inputs) do
        -- Component label with better spacing
        local componentLabel = Instance.new("TextLabel")
        componentLabel.Size = UDim2.new(0.16, -5, 0, 20)
        componentLabel.Position = UDim2.new(0.28 + (i-1) * 0.24, 0, 0, yPos - 25)
        componentLabel.BackgroundTransparency = 1
        componentLabel.Text = component
        componentLabel.TextColor3 = colors[i]
        componentLabel.TextSize = 16
        componentLabel.TextXAlignment = Enum.TextXAlignment.Center
        componentLabel.Font = Enum.Font.GothamBold
        componentLabel.Parent = self.propertyFrame
        
        -- Add shadow to component label
        local compShadow = Instance.new("TextLabel")
        compShadow.Size = componentLabel.Size
        compShadow.Position = UDim2.new(0.28 + (i-1) * 0.24, 1, 0, yPos - 24)
        compShadow.BackgroundTransparency = 1
        compShadow.Text = componentLabel.Text
        compShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
        compShadow.TextSize = componentLabel.TextSize
        compShadow.TextXAlignment = componentLabel.TextXAlignment
        compShadow.Font = componentLabel.Font
        compShadow.ZIndex = componentLabel.ZIndex - 1
        compShadow.Parent = self.propertyFrame
        
        -- Modern input field with better spacing
        local input = Instance.new("TextBox")
        input.Name = propertyName .. component
        input.Size = UDim2.new(0.16, -5, 0, 32)
        input.Position = UDim2.new(0.28 + (i-1) * 0.24, 0, 0, yPos)
        input.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
        input.BorderSizePixel = 0
        input.Text = string.format("%.2f", values[i])
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.TextSize = 15
        input.Font = Enum.Font.GothamMedium
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.Parent = self.propertyFrame
        
        -- Simplified input styling for better performance
        
        -- Modern styling with neon borders
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 8)
        inputCorner.Parent = input
        
        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = colors[i]
        inputStroke.Thickness = 2
        inputStroke.Transparency = 0.6
        inputStroke.Parent = input
        
        -- Enhanced focus effects
        input.Focused:Connect(function()
            inputStroke.Transparency = 0.2
            input.BackgroundColor3 = Color3.fromRGB(25, 35, 65)
        end)
        
        input.FocusLost:Connect(function()
            inputStroke.Transparency = 0.6
            input.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
            self:UpdatePropertyValue(propertyName, "Vector3")
        end)
    end
    
    -- Add preset buttons with better spacing
    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(0.72, -10, 0, 30)
    presetFrame.Position = UDim2.new(0.28, 0, 0, yPos + 40)
    presetFrame.BackgroundTransparency = 1
    presetFrame.Parent = self.propertyFrame
    
    local presets = {}
    if propertyName == "Position" then
        presets = {
            {name = "Origin", value = Vector3.new(0, 0, 0)},
            {name = "Up", value = Vector3.new(0, 10, 0)},
            {name = "Forward", value = Vector3.new(0, 0, 10)},
            {name = "Right", value = Vector3.new(10, 0, 0)}
        }
    elseif propertyName == "Size" then
        presets = {
            {name = "Small", value = Vector3.new(1, 1, 1)},
            {name = "Medium", value = Vector3.new(4, 4, 4)},
            {name = "Large", value = Vector3.new(8, 8, 8)},
            {name = "Huge", value = Vector3.new(16, 16, 16)}
        }
    else -- Rotation
        presets = {
            {name = "0°", value = Vector3.new(0, 0, 0)},
            {name = "90°", value = Vector3.new(0, 90, 0)},
            {name = "180°", value = Vector3.new(0, 180, 0)},
            {name = "270°", value = Vector3.new(0, 270, 0)}
        }
    end
    
    for i, preset in ipairs(presets) do
        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(0.22, -2, 1, 0)
        presetBtn.Position = UDim2.new((i-1) * 0.25, 1, 0, 0)
        presetBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
        presetBtn.BorderSizePixel = 0
        presetBtn.Text = preset.name
        presetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        presetBtn.TextSize = 10
        presetBtn.Font = Enum.Font.Gotham
        presetBtn.Parent = presetFrame
        
        -- Add gradient background
        local btnGradient = Instance.new("UIGradient")
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 35, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 20, 40))
        }
        btnGradient.Rotation = 90
        btnGradient.Parent = presetBtn
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = presetBtn
        
        -- Add neon border
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(0, 150, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.6
        btnStroke.Parent = presetBtn
        
        presetBtn.MouseButton1Click:Connect(function()
            -- Update input fields properly
            local xInput = self.propertyFrame:FindFirstChild(propertyName .. "X")
            local yInput = self.propertyFrame:FindFirstChild(propertyName .. "Y")
            local zInput = self.propertyFrame:FindFirstChild(propertyName .. "Z")
            
            if xInput then xInput.Text = string.format("%.2f", preset.value.X) end
            if yInput then yInput.Text = string.format("%.2f", preset.value.Y) end
            if zInput then zInput.Text = string.format("%.2f", preset.value.Z) end
            
            -- Update the property value
            self.endProperties[propertyName] = preset.value
            self:UpdatePropertyStatus(propertyName, true)
        end)
        
        -- Enhanced hover effects
        presetBtn.MouseEnter:Connect(function()
            presetBtn.BackgroundColor3 = Color3.fromRGB(25, 40, 70)
            btnStroke.Transparency = 0.3
        end)
        
        presetBtn.MouseLeave:Connect(function()
            presetBtn.BackgroundColor3 = Color3.fromRGB(15, 25, 50)
            btnStroke.Transparency = 0.6
        end)
    end
    
    return yPos + 110
end

function TweenGeneratorUI:CreateUDim2Editor(propertyName, currentValue, yPos)
    local inputs = {"ScaleX", "OffsetX", "ScaleY", "OffsetY"}
    local values = {currentValue.X.Scale, currentValue.X.Offset, currentValue.Y.Scale, currentValue.Y.Offset}
    
    for i, component in ipairs(inputs) do
        local input = Instance.new("TextBox")
        input.Name = propertyName .. component
        input.Size = UDim2.new(0.15, -5, 0, 25)
        input.Position = UDim2.new(0.3 + (i-1) * 0.17, 0, 0, yPos)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        input.BorderSizePixel = 0
        input.Text = tostring(values[i])
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Parent = self.propertyFrame
        
        input.FocusLost:Connect(function()
            self:UpdatePropertyValue(propertyName, "UDim2")
        end)
    end
    
    return yPos + 30
end

function TweenGeneratorUI:CreateColor3Editor(propertyName, currentValue, yPos)
    local inputs = {"R", "G", "B"}
    local values = {
        math.floor(currentValue.R * 255 + 0.5),
        math.floor(currentValue.G * 255 + 0.5),
        math.floor(currentValue.B * 255 + 0.5)
    }
    local colors = {
        Color3.fromRGB(255, 100, 100), -- Red for R
        Color3.fromRGB(100, 255, 100), -- Green for G  
        Color3.fromRGB(100, 150, 255)  -- Blue for B
    }
    
    -- Color preview
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.new(0, 40, 0, 40)
    colorPreview.Position = UDim2.new(0, 10, 0, yPos - 10)
    colorPreview.BackgroundColor3 = currentValue
    colorPreview.BorderSizePixel = 0
    colorPreview.Parent = self.propertyFrame
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 8)
    previewCorner.Parent = colorPreview
    
    local previewStroke = Instance.new("UIStroke")
    previewStroke.Color = Color3.fromRGB(100, 150, 255)
    previewStroke.Thickness = 2
    previewStroke.Transparency = 0.6
    previewStroke.Parent = colorPreview
    
    -- Create RGB input fields with modern styling
    for i, component in ipairs(inputs) do
        -- Component label
        local componentLabel = Instance.new("TextLabel")
        componentLabel.Size = UDim2.new(0.2, -5, 0, 12)
        componentLabel.Position = UDim2.new(0.3 + (i-1) * 0.23, 0, 0, yPos - 15)
        componentLabel.BackgroundTransparency = 1
        componentLabel.Text = component
        componentLabel.TextColor3 = colors[i]
        componentLabel.TextSize = 11
        componentLabel.TextXAlignment = Enum.TextXAlignment.Center
        componentLabel.Font = Enum.Font.GothamBold
        componentLabel.Parent = self.propertyFrame
        
        -- Modern input field
        local input = Instance.new("TextBox")
        input.Name = propertyName .. component
        input.Size = UDim2.new(0.2, -5, 0, 25)
        input.Position = UDim2.new(0.3 + (i-1) * 0.23, 0, 0, yPos)
        input.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
        input.BorderSizePixel = 0
        input.Text = tostring(values[i])
        input.TextColor3 = Color3.fromRGB(200, 220, 255)
        input.TextSize = 12
        input.Font = Enum.Font.GothamMedium
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.Parent = self.propertyFrame
        
        -- Modern styling
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 6)
        inputCorner.Parent = input
        
        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = colors[i]
        inputStroke.Thickness = 1
        inputStroke.Transparency = 0.8
        inputStroke.Parent = input
        
        -- Focus effects
        input.Focused:Connect(function()
            inputStroke.Transparency = 0.4
            input.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
        end)
        
        input.FocusLost:Connect(function()
            inputStroke.Transparency = 0.8
            input.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            self:UpdatePropertyValue(propertyName, "Color3")
            
            -- Update color preview
            local rInput = self.propertyFrame:FindFirstChild(propertyName .. "R")
            local gInput = self.propertyFrame:FindFirstChild(propertyName .. "G")
            local bInput = self.propertyFrame:FindFirstChild(propertyName .. "B")
            
            local r = tonumber(rInput and rInput.Text) or 0
            local g = tonumber(gInput and gInput.Text) or 0
            local b = tonumber(bInput and bInput.Text) or 0
            
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            
            colorPreview.BackgroundColor3 = Color3.fromRGB(r, g, b)
        end)
    end
    
    -- Add color preset buttons
    local presetFrame = Instance.new("Frame")
    presetFrame.Size = UDim2.new(0.6, -10, 0, 40)
    presetFrame.Position = UDim2.new(0.3, 0, 0, yPos + 30)
    presetFrame.BackgroundTransparency = 1
    presetFrame.Parent = self.propertyFrame
    
    local colorPresets = {
        {name = "Red", color = Color3.fromRGB(255, 0, 0)},
        {name = "Green", color = Color3.fromRGB(0, 255, 0)},
        {name = "Blue", color = Color3.fromRGB(0, 100, 255)},
        {name = "Yellow", color = Color3.fromRGB(255, 255, 0)},
        {name = "Purple", color = Color3.fromRGB(255, 0, 255)},
        {name = "Cyan", color = Color3.fromRGB(0, 255, 255)},
        {name = "White", color = Color3.fromRGB(255, 255, 255)},
        {name = "Black", color = Color3.fromRGB(0, 0, 0)}
    }
    
    for i, preset in ipairs(colorPresets) do
        local row = math.floor((i-1) / 4)
        local col = (i-1) % 4
        
        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(0.23, 0, 0.45, 0)
        presetBtn.Position = UDim2.new(col * 0.25, 0, row * 0.5, 0)
        presetBtn.BackgroundColor3 = preset.color
        presetBtn.BorderSizePixel = 0
        presetBtn.Text = ""
        presetBtn.Parent = presetFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = presetBtn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = Color3.fromRGB(150, 180, 255)
        btnStroke.Thickness = 1
        btnStroke.Transparency = 0.8
        btnStroke.Parent = presetBtn
        
        -- Tooltip
        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 50, 0, 15)
        tooltip.Position = UDim2.new(0.5, -25, 1, 2)
        tooltip.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
        tooltip.BorderSizePixel = 0
        tooltip.Text = preset.name
        tooltip.TextColor3 = Color3.fromRGB(200, 220, 255)
        tooltip.TextSize = 8
        tooltip.Font = Enum.Font.Gotham
        tooltip.TextXAlignment = Enum.TextXAlignment.Center
        tooltip.Visible = false
        tooltip.Parent = presetBtn
        
        local tooltipCorner = Instance.new("UICorner")
        tooltipCorner.CornerRadius = UDim.new(0, 3)
        tooltipCorner.Parent = tooltip
        
        presetBtn.MouseButton1Click:Connect(function()
            -- Update input fields
            local r = math.floor(preset.color.R * 255 + 0.5)
            local g = math.floor(preset.color.G * 255 + 0.5)
            local b = math.floor(preset.color.B * 255 + 0.5)
            
            local rInput = self.propertyFrame:FindFirstChild(propertyName .. "R")
            local gInput = self.propertyFrame:FindFirstChild(propertyName .. "G")
            local bInput = self.propertyFrame:FindFirstChild(propertyName .. "B")
            
            if rInput then rInput.Text = tostring(r) end
            if gInput then gInput.Text = tostring(g) end
            if bInput then bInput.Text = tostring(b) end
            
            -- Update color preview
            colorPreview.BackgroundColor3 = preset.color
            
            -- Update the property value
            self.endProperties[propertyName] = preset.color
            self:UpdatePropertyStatus(propertyName, true)
        end)
        
        -- Hover effects
        presetBtn.MouseEnter:Connect(function()
            btnStroke.Transparency = 0.4
            tooltip.Visible = true
        end)
        
        presetBtn.MouseLeave:Connect(function()
            btnStroke.Transparency = 0.8
            tooltip.Visible = false
        end)
    end
    
    return yPos + 95
end

function TweenGeneratorUI:CreateNumberEditor(propertyName, currentValue, propertyInfo, yPos)
    local minValue = propertyInfo.min or 0
    local maxValue = propertyInfo.max or (currentValue * 2 > 10 and currentValue * 2 or 10)
    local hasRange = propertyInfo.min and propertyInfo.max
    
    -- Create container for the property
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -40, 0, hasRange and 75 or 40)
    container.Position = UDim2.new(0, 30, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = self.propertyFrame
    
    if hasRange then
        -- Use slider control for properties with defined ranges
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = string.format("%s (%.2f - %.2f)", propertyName:upper(), minValue, maxValue)
        label.TextColor3 = Color3.fromRGB(160, 180, 220)
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = container
        
        -- Slider track
        local sliderTrack = Instance.new("Frame")
        sliderTrack.Size = UDim2.new(0.7, -10, 0, 6)
        sliderTrack.Position = UDim2.new(0, 10, 0, 30)
        sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
        sliderTrack.BorderSizePixel = 0
        sliderTrack.Parent = container
        
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(0, 3)
        trackCorner.Parent = sliderTrack
        
        -- Slider fill
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((currentValue - minValue) / (maxValue - minValue), 0, 1, 0)
        sliderFill.Position = UDim2.new(0, 0, 0, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        sliderFill.BorderSizePixel = 0
        sliderFill.Parent = sliderTrack
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = sliderFill
        
        -- Slider handle
        local sliderHandle = Instance.new("TextButton")
        sliderHandle.Size = UDim2.new(0, 16, 0, 16)
        sliderHandle.Position = UDim2.new((currentValue - minValue) / (maxValue - minValue), -8, 0, -5)
        sliderHandle.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
        sliderHandle.BorderSizePixel = 0
        sliderHandle.Text = ""
        sliderHandle.Parent = sliderTrack
        
        local handleCorner = Instance.new("UICorner")
        handleCorner.CornerRadius = UDim.new(0, 8)
        handleCorner.Parent = sliderHandle
        
        -- Value display
        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Name = propertyName .. "Value"
        valueDisplay.Size = UDim2.new(0, 80, 0, 30)
        valueDisplay.Position = UDim2.new(0.7, 5, 0, 22.5)
        valueDisplay.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
        valueDisplay.BorderSizePixel = 0
        valueDisplay.Text = string.format("%.3f", currentValue)
        valueDisplay.TextColor3 = Color3.fromRGB(200, 220, 255)
        valueDisplay.TextSize = 12
        valueDisplay.Font = Enum.Font.GothamMedium
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Center
        valueDisplay.Parent = container
        
        local displayCorner = Instance.new("UICorner")
        displayCorner.CornerRadius = UDim.new(0, 6)
        displayCorner.Parent = valueDisplay
        
        -- Slider functionality
        local dragging = false
        local function updateSliderValue(inputObject)
            if not dragging then return end
            
            local relativeX = (inputObject.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            
            local newValue = minValue + (maxValue - minValue) * relativeX
            newValue = math.round(newValue * 1000) / 1000 -- Round to 3 decimal places
            
            -- Update display and slider
            valueDisplay.Text = string.format("%.3f", newValue)
            sliderHandle.Position = UDim2.new(relativeX, -8, 0, -5)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            
            -- Update property
            self.endProperties[propertyName] = newValue
            self:UpdatePropertyStatus(propertyName, true)
        end
        
        sliderHandle.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        game:GetService("UserInputService").InputChanged:Connect(updateSliderValue)
        
        game:GetService("UserInputService").InputEnded:Connect(function(inputObject)
            if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        return yPos + 85
    else
        -- Use text input for properties without defined ranges
        local input = Instance.new("TextBox")
        input.Name = propertyName .. "Value"
        input.Size = UDim2.new(0.7, -10, 0, 30)
        input.Position = UDim2.new(0, 10, 0, 5)
        input.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
        input.BorderSizePixel = 0
        input.Text = string.format("%.3f", currentValue)
        input.TextColor3 = Color3.fromRGB(200, 220, 255)
        input.TextSize = 14
        input.Font = Enum.Font.GothamMedium
        input.TextXAlignment = Enum.TextXAlignment.Center
        input.Parent = container
        
        -- Modern styling
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 8)
        inputCorner.Parent = input
        
        local inputStroke = Instance.new("UIStroke")
        inputStroke.Color = Color3.fromRGB(100, 150, 255)
        inputStroke.Thickness = 1
        inputStroke.Transparency = 0.8
        inputStroke.Parent = input
        
        -- Focus effects
        input.Focused:Connect(function()
            inputStroke.Transparency = 0.4
            input.BackgroundColor3 = Color3.fromRGB(40, 45, 65)
        end)
        
        input.FocusLost:Connect(function()
            inputStroke.Transparency = 0.8
            input.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
            self:UpdatePropertyValue(propertyName, "number")
        end)
        
        return yPos + 50
    end
end

function TweenGeneratorUI:UpdatePropertyValue(propertyName, valueType)
    local value
    
    if valueType == "Vector3" then
        local xInput = self.propertyFrame:FindFirstChild(propertyName .. "X")
        local yInput = self.propertyFrame:FindFirstChild(propertyName .. "Y")
        local zInput = self.propertyFrame:FindFirstChild(propertyName .. "Z")
        
        local x = tonumber(xInput and xInput.Text)
        local y = tonumber(yInput and yInput.Text)
        local z = tonumber(zInput and zInput.Text)
        
        if x and y and z then
            value = Vector3.new(x, y, z)
        else
            return
        end
    elseif valueType == "UDim2" then
        local scaleXInput = self.propertyFrame:FindFirstChild(propertyName .. "ScaleX")
        local offsetXInput = self.propertyFrame:FindFirstChild(propertyName .. "OffsetX")
        local scaleYInput = self.propertyFrame:FindFirstChild(propertyName .. "ScaleY")
        local offsetYInput = self.propertyFrame:FindFirstChild(propertyName .. "OffsetY")
        
        local scaleX = tonumber(scaleXInput and scaleXInput.Text)
        local offsetX = tonumber(offsetXInput and offsetXInput.Text)
        local scaleY = tonumber(scaleYInput and scaleYInput.Text)
        local offsetY = tonumber(offsetYInput and offsetYInput.Text)
        
        if scaleX and offsetX and scaleY and offsetY then
            value = UDim2.new(scaleX, offsetX, scaleY, offsetY)
        else
            return
        end
    elseif valueType == "Color3" then
        local rInput = self.propertyFrame:FindFirstChild(propertyName .. "R")
        local gInput = self.propertyFrame:FindFirstChild(propertyName .. "G")
        local bInput = self.propertyFrame:FindFirstChild(propertyName .. "B")
        
        local r = tonumber(rInput and rInput.Text)
        local g = tonumber(gInput and gInput.Text)
        local b = tonumber(bInput and bInput.Text)
        
        if r and g and b then
            -- Clamp values to 0-255 range
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            value = Color3.fromRGB(r, g, b)
        else
            return
        end
    elseif valueType == "number" then
        local valueInput = self.propertyFrame:FindFirstChild(propertyName .. "Value")
        local numValue = tonumber(valueInput and valueInput.Text)
        
        if numValue then
            value = numValue
        else
            return
        end
    end
    
    if value then
        self.endProperties[propertyName] = value
        self:UpdatePropertyStatus(propertyName, true)
    end
end

function TweenGeneratorUI:PreviewTween()
    if not self.selectedObject then
        warn("No object selected for preview")
        return
    end
    
    local targetObject = self:GetTargetObject()
    if not targetObject then
        warn("No valid part found to tween in the selected object")
        return
    end
    
    self:StopPreview()
    self:SaveOriginalProperties()
    
    local tweenInfo = TweenInfo.new(
        self.duration,
        self.easingStyle,
        self.easingDirection,
        self.repeatCount,
        self.reverses,
        self.delay
    )
    
    local goals = {}
    for propertyName, value in pairs(self.endProperties) do
        goals[propertyName] = value
    end
    
    if next(goals) then
        self.currentTween = TweenService:Create(targetObject, tweenInfo, goals)
        self.currentTween:Play()
        
        -- Auto-reset after completion
        self.currentTween.Completed:Connect(function()
            task.wait(0.1)
            self:ResetToOriginal()
        end)
    end
end

function TweenGeneratorUI:StopPreview()
    if self.currentTween then
        self.currentTween:Cancel()
        self.currentTween = nil
        self:ResetToOriginal()
    end
end

function TweenGeneratorUI:SaveOriginalProperties()
    local targetObject = self:GetTargetObject()
    if not targetObject then return end
    
    self.originalProperties = {}
    for propertyName, _ in pairs(self.endProperties) do
        -- Only save properties that actually exist on the target object
        if targetObject[propertyName] ~= nil then
            local success, value = pcall(function()
                return targetObject[propertyName]
            end)
            if success then
                self.originalProperties[propertyName] = value
            end
        end
    end
end

function TweenGeneratorUI:ResetToOriginal()
    local targetObject = self:GetTargetObject()
    if not targetObject or not self.originalProperties then return end
    
    for propertyName, value in pairs(self.originalProperties) do
        -- Only reset properties that actually exist on the target object
        if targetObject[propertyName] ~= nil then
            targetObject[propertyName] = value
        end
    end
end

function TweenGeneratorUI:ExportCode()
    if not self.selectedObject then
        warn("No object selected for export")
        return
    end
    
    local targetObject = self:GetTargetObject()
    if not targetObject then
        warn("No valid part found to tween in the selected object")
        return
    end
    
    if not self.endProperties or not next(self.endProperties) then
        warn("No properties configured for tweening. Please set some target values first.")
        return
    end
    
    local code = CodeExporter.GenerateCode(
        targetObject,
        self.duration,
        self.easingStyle,
        self.easingDirection,
        self.repeatCount,
        self.reverses,
        self.delay,
        self.endProperties
    )
    
    -- Try to copy to clipboard (if Studio allows it)
    local success = pcall(function()
        game:GetService("GuiService"):SetClipboard(code)
    end)
    
    if success then
        print("✅ Tween code copied to clipboard!")
    else
        print("=== TWEEN CODE (Copy manually) ===")
        print(code)
        print("=== END TWEEN CODE ===")
    end
    
    -- Provide user feedback
    if self.selectedObject.ClassName == "Model" then
        print("Generated tween for: " .. self.selectedObject.Name .. " (Model) → " .. targetObject.Name .. " (" .. targetObject.ClassName .. ")")
    else
        print("Generated tween for: " .. self.selectedObject.Name)
    end
    print("Properties tweened: " .. table.concat(self:GetPropertyNames(), ", "))
end

function TweenGeneratorUI:GetPropertyNames()
    local names = {}
    for propertyName, _ in pairs(self.endProperties or {}) do
        table.insert(names, propertyName)
    end
    return names
end

function TweenGeneratorUI:UpdatePropertyStatus(propertyName, isConfigured)
    local statusIndicator = self.propertyFrame:FindFirstChild(propertyName .. "Status")
    if statusIndicator then
        if isConfigured then
            statusIndicator.Text = "●"
            statusIndicator.TextColor3 = Color3.fromRGB(100, 255, 120) -- Bright green
        else
            statusIndicator.Text = "○"
            statusIndicator.TextColor3 = Color3.fromRGB(120, 140, 180) -- Muted blue-gray
        end
    end
end

function TweenGeneratorUI:SavePreset(name)
    local presetData = {
        duration = self.duration,
        delay = self.delay,
        repeatCount = self.repeatCount,
        reverses = self.reverses,
        easingStyle = self.easingStyle.Name,
        easingDirection = self.easingDirection.Name,
        endProperties = self.endProperties
    }
    
    PresetManager.SavePreset(self.plugin, name, presetData)
    print("Preset saved: " .. name)
end

function TweenGeneratorUI:Cleanup()
    self:StopPreview()
    if self.widget then
        self.widget:Destroy()
    end
end

-- ========================================
-- PLUGIN INITIALIZATION
-- ========================================

-- Create toolbar
local toolbar = plugin:CreateToolbar("Tween Generator Pro")

-- Create button
local button = toolbar:CreateButton(
    "Tween Generator",
    "Open Tween Generator Pro",
    "rbxasset://textures/DevConsole/Close.png"
)

-- Create DockWidget with much larger size for better spacing
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false, -- InitialEnabled
    false, -- InitialEnabledShouldOverrideRestore
    550,   -- FloatingXSize (was 400)
    850,   -- FloatingYSize (was 600)
    500,   -- MinWidth (was 300)
    750    -- MinHeight (was 400)
)

local widget = plugin:CreateDockWidgetPluginGui("TweenGeneratorPro", widgetInfo)
widget.Title = pluginName

-- Initialize UI
local tweenGeneratorUI = TweenGeneratorUI.new(widget, plugin)

-- Toggle widget when button is clicked
button.Click:Connect(function()
    widget.Enabled = not widget.Enabled
end)

-- Handle widget close
widget:GetPropertyChangedSignal("Enabled"):Connect(function()
    if not widget.Enabled then
        tweenGeneratorUI:StopPreview()
    end
end)

-- Handle plugin unloading
plugin.Unloading:Connect(function()
    tweenGeneratorUI:Cleanup()
end) 