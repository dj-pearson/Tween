-- TweenGeneratorUI.lua
-- Main UI controller for the Tween Generator Pro plugin

local TweenGeneratorUI = {}
TweenGeneratorUI.__index = TweenGeneratorUI

local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local PropertyHandler = require(script.Parent.PropertyHandler)
local CodeExporter = require(script.Parent.CodeExporter)
local PresetManager = require(script.Parent.PresetManager)

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
    -- Main frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = self.widget
    
    -- Create scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -20)
    scrollFrame.Position = UDim2.new(0, 10, 0, 10)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 8
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
    
    -- Update canvas size
    self:UpdateCanvasSize()
end

function TweenGeneratorUI:CreateObjectSelectionSection(parent)
    local section = self:CreateSection("Object Selection", parent, 0)
    
    -- Object info label
    self.objectInfoLabel = Instance.new("TextLabel")
    self.objectInfoLabel.Name = "ObjectInfoLabel"
    self.objectInfoLabel.Size = UDim2.new(1, -20, 0, 30)
    self.objectInfoLabel.Position = UDim2.new(0, 10, 0, 30)
    self.objectInfoLabel.BackgroundTransparency = 1
    self.objectInfoLabel.Text = "No object selected"
    self.objectInfoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.objectInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    self.objectInfoLabel.Parent = section
    
    -- Refresh button
    local refreshButton = Instance.new("TextButton")
    refreshButton.Name = "RefreshButton"
    refreshButton.Size = UDim2.new(0, 100, 0, 30)
    refreshButton.Position = UDim2.new(1, -110, 0, 30)
    refreshButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    refreshButton.BorderSizePixel = 0
    refreshButton.Text = "Refresh"
    refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshButton.Parent = section
    
    refreshButton.MouseButton1Click:Connect(function()
        self:RefreshSelectedObject()
    end)
    
    section.Size = UDim2.new(1, -20, 0, 80)
end

function TweenGeneratorUI:CreatePropertySection(parent)
    local section = self:CreateSection("Properties", parent, 90)
    
    self.propertyFrame = Instance.new("Frame")
    self.propertyFrame.Name = "PropertyFrame"
    self.propertyFrame.Size = UDim2.new(1, -20, 0, 200)
    self.propertyFrame.Position = UDim2.new(0, 10, 0, 30)
    self.propertyFrame.BackgroundTransparency = 1
    self.propertyFrame.Parent = section
    
    section.Size = UDim2.new(1, -20, 0, 250)
end

function TweenGeneratorUI:CreateTweenControlsSection(parent)
    local section = self:CreateSection("Tween Settings", parent, 350)
    
    local yPos = 30
    
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
        self.repeatCount = value
    end, yPos)
    
    -- Reverses checkbox
    yPos = self:CreateCheckbox(section, "Reverses", self.reverses, function(value)
        self.reverses = value
    end, yPos)
    
    -- Easing Style dropdown
    yPos = self:CreateDropdown(section, "Easing Style", {
        "Linear", "Sine", "Back", "Quad", "Quart", "Quint", "Bounce", "Elastic", "Exponential", "Circular"
    }, "Sine", function(value)
        self.easingStyle = Enum.EasingStyle[value]
    end, yPos)
    
    -- Easing Direction dropdown
    yPos = self:CreateDropdown(section, "Easing Direction", {
        "In", "Out", "InOut"
    }, "Out", function(value)
        self.easingDirection = Enum.EasingDirection[value]
    end, yPos)
    
    section.Size = UDim2.new(1, -20, 0, yPos + 10)
end

function TweenGeneratorUI:CreatePreviewSection(parent)
    local sectionYPos = 350 + (self.scrollFrame:FindFirstChild("Tween Settings") and self.scrollFrame:FindFirstChild("Tween Settings").Size.Y.Offset or 200) + 10
    local section = self:CreateSection("Preview", parent, sectionYPos)
    
    -- Preview button
    local previewButton = Instance.new("TextButton")
    previewButton.Name = "PreviewButton"
    previewButton.Size = UDim2.new(0, 150, 0, 40)
    previewButton.Position = UDim2.new(0, 10, 0, 30)
    previewButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    previewButton.BorderSizePixel = 0
    previewButton.Text = "Preview Tween"
    previewButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    previewButton.TextScaled = true
    previewButton.Parent = section
    
    -- Stop button
    local stopButton = Instance.new("TextButton")
    stopButton.Name = "StopButton"
    stopButton.Size = UDim2.new(0, 100, 0, 40)
    stopButton.Position = UDim2.new(0, 170, 0, 30)
    stopButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    stopButton.BorderSizePixel = 0
    stopButton.Text = "Stop"
    stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    stopButton.TextScaled = true
    stopButton.Parent = section
    
    previewButton.MouseButton1Click:Connect(function()
        self:PreviewTween()
    end)
    
    stopButton.MouseButton1Click:Connect(function()
        self:StopPreview()
    end)
    
    section.Size = UDim2.new(1, -20, 0, 90)
end

function TweenGeneratorUI:CreateExportSection(parent)
    local prevSection = self.scrollFrame:FindFirstChild("Preview")
    local sectionYPos = prevSection and (prevSection.Position.Y.Offset + prevSection.Size.Y.Offset + 10) or 500
    local section = self:CreateSection("Export Code", parent, sectionYPos)
    
    -- Export button
    local exportButton = Instance.new("TextButton")
    exportButton.Name = "ExportButton"
    exportButton.Size = UDim2.new(1, -20, 0, 40)
    exportButton.Position = UDim2.new(0, 10, 0, 30)
    exportButton.BackgroundColor3 = Color3.fromRGB(255, 152, 0)
    exportButton.BorderSizePixel = 0
    exportButton.Text = "Copy Code to Clipboard"
    exportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    exportButton.TextScaled = true
    exportButton.Parent = section
    
    exportButton.MouseButton1Click:Connect(function()
        self:ExportCode()
    end)
    
    section.Size = UDim2.new(1, -20, 0, 90)
end

function TweenGeneratorUI:CreatePresetSection(parent)
    local prevSection = self.scrollFrame:FindFirstChild("Export Code")
    local sectionYPos = prevSection and (prevSection.Position.Y.Offset + prevSection.Size.Y.Offset + 10) or 600
    local section = self:CreateSection("Presets", parent, sectionYPos)
    
    -- Preset name input
    local presetNameInput = Instance.new("TextBox")
    presetNameInput.Name = "PresetNameInput"
    presetNameInput.Size = UDim2.new(0.6, -10, 0, 30)
    presetNameInput.Position = UDim2.new(0, 10, 0, 30)
    presetNameInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    presetNameInput.BorderSizePixel = 0
    presetNameInput.Text = "My Preset"
    presetNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    presetNameInput.PlaceholderText = "Preset name..."
    presetNameInput.Parent = section
    
    -- Save preset button
    local savePresetButton = Instance.new("TextButton")
    savePresetButton.Name = "SavePresetButton"
    savePresetButton.Size = UDim2.new(0.4, -15, 0, 30)
    savePresetButton.Position = UDim2.new(0.6, 5, 0, 30)
    savePresetButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    savePresetButton.BorderSizePixel = 0
    savePresetButton.Text = "Save Preset"
    savePresetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    savePresetButton.TextScaled = true
    savePresetButton.Parent = section
    
    savePresetButton.MouseButton1Click:Connect(function()
        if presetNameInput.Text ~= "" then
            self:SavePreset(presetNameInput.Text)
        end
    end)
    
    section.Size = UDim2.new(1, -20, 0, 80)
end

-- Helper function to create a section
function TweenGeneratorUI:CreateSection(title, parent, yPosition)
    local section = Instance.new("Frame")
    section.Name = title
    section.Size = UDim2.new(1, -20, 0, 100) -- Default size, will be updated
    section.Position = UDim2.new(0, 10, 0, yPosition)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    section.BorderSizePixel = 0
    section.Parent = parent
    
    -- Section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -20, 0, 25)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = section
    
    return section
end

-- Helper function to create number input
function TweenGeneratorUI:CreateNumberInput(parent, label, defaultValue, callback, yPos)
    local labelObj = Instance.new("TextLabel")
    labelObj.Name = label .. "Label"
    labelObj.Size = UDim2.new(0.5, -10, 0, 25)
    labelObj.Position = UDim2.new(0, 10, 0, yPos)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label .. ":"
    labelObj.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.Parent = parent
    
    local input = Instance.new("TextBox")
    input.Name = label .. "Input"
    input.Size = UDim2.new(0.5, -15, 0, 25)
    input.Position = UDim2.new(0.5, 5, 0, yPos)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    input.BorderSizePixel = 0
    input.Text = tostring(defaultValue)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Parent = parent
    
    input.FocusLost:Connect(function()
        local value = tonumber(input.Text)
        if value then
            callback(value)
        else
            input.Text = tostring(defaultValue)
        end
    end)
    
    return yPos + 35
end

-- Helper function to create checkbox
function TweenGeneratorUI:CreateCheckbox(parent, label, defaultValue, callback, yPos)
    local labelObj = Instance.new("TextLabel")
    labelObj.Name = label .. "Label"
    labelObj.Size = UDim2.new(0.8, -10, 0, 25)
    labelObj.Position = UDim2.new(0, 10, 0, yPos)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label .. ":"
    labelObj.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.Parent = parent
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = label .. "Checkbox"
    checkbox.Size = UDim2.new(0, 25, 0, 25)
    checkbox.Position = UDim2.new(1, -35, 0, yPos)
    checkbox.BackgroundColor3 = defaultValue and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(25, 25, 25)
    checkbox.BorderSizePixel = 0
    checkbox.Text = defaultValue and "✓" or ""
    checkbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkbox.Parent = parent
    
    checkbox.MouseButton1Click:Connect(function()
        defaultValue = not defaultValue
        checkbox.BackgroundColor3 = defaultValue and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(25, 25, 25)
        checkbox.Text = defaultValue and "✓" or ""
        callback(defaultValue)
    end)
    
    return yPos + 35
end

-- Helper function to create dropdown
function TweenGeneratorUI:CreateDropdown(parent, label, options, defaultOption, callback, yPos)
    local labelObj = Instance.new("TextLabel")
    labelObj.Name = label .. "Label"
    labelObj.Size = UDim2.new(0.5, -10, 0, 25)
    labelObj.Position = UDim2.new(0, 10, 0, yPos)
    labelObj.BackgroundTransparency = 1
    labelObj.Text = label .. ":"
    labelObj.TextColor3 = Color3.fromRGB(255, 255, 255)
    labelObj.TextXAlignment = Enum.TextXAlignment.Left
    labelObj.Parent = parent
    
    local dropdown = Instance.new("TextButton")
    dropdown.Name = label .. "Dropdown"
    dropdown.Size = UDim2.new(0.5, -15, 0, 25)
    dropdown.Position = UDim2.new(0.5, 5, 0, yPos)
    dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    dropdown.BorderSizePixel = 0
    dropdown.Text = defaultOption .. " ▼"
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.Parent = parent
    
    -- Simple dropdown implementation (you might want to enhance this)
    local currentIndex = 1
    for i, option in ipairs(options) do
        if option == defaultOption then
            currentIndex = i
            break
        end
    end
    
    dropdown.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then
            currentIndex = 1
        end
        local selectedOption = options[currentIndex]
        dropdown.Text = selectedOption .. " ▼"
        callback(selectedOption)
    end)
    
    return yPos + 35
end

function TweenGeneratorUI:ConnectEvents()
    -- Selection changed
    Selection.SelectionChanged:Connect(function()
        self:RefreshSelectedObject()
    end)
end

function TweenGeneratorUI:RefreshSelectedObject()
    local selected = Selection:Get()
    if #selected > 0 then
        self.selectedObject = selected[1]
        self.objectInfoLabel.Text = "Selected: " .. self.selectedObject.Name .. " (" .. self.selectedObject.ClassName .. ")"
        self:UpdatePropertyInputs()
    else
        self.selectedObject = nil
        self.objectInfoLabel.Text = "No object selected"
        self:ClearPropertyInputs()
    end
end

function TweenGeneratorUI:UpdatePropertyInputs()
    if not self.selectedObject then return end
    
    -- Clear existing property inputs
    self:ClearPropertyInputs()
    
    -- Get available properties for this object type
    local properties = PropertyHandler.GetTweenableProperties(self.selectedObject)
    
    local yPos = 10
    for propertyName, propertyInfo in pairs(properties) do
        yPos = self:CreatePropertyInput(propertyName, propertyInfo, yPos)
    end
    
    self.propertyFrame.Size = UDim2.new(1, -20, 0, yPos)
    local section = self.propertyFrame.Parent
    section.Size = UDim2.new(1, -20, 0, yPos + 40)
    
    self:UpdateCanvasSize()
end

function TweenGeneratorUI:ClearPropertyInputs()
    for _, child in pairs(self.propertyFrame:GetChildren()) do
        child:Destroy()
    end
end

function TweenGeneratorUI:CreatePropertyInput(propertyName, propertyInfo, yPos)
    -- Property label
    local propertyLabel = Instance.new("TextLabel")
    propertyLabel.Name = propertyName .. "Label"
    propertyLabel.Size = UDim2.new(1, 0, 0, 20)
    propertyLabel.Position = UDim2.new(0, 0, 0, yPos)
    propertyLabel.BackgroundTransparency = 1
    propertyLabel.Text = propertyName
    propertyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    propertyLabel.TextXAlignment = Enum.TextXAlignment.Left
    propertyLabel.Font = Enum.Font.SourceSansBold
    propertyLabel.Parent = self.propertyFrame
    
    yPos = yPos + 25
    
    -- Start and End value inputs based on property type
    if propertyInfo.type == "Vector3" then
        yPos = self:CreateVector3Input(propertyName, "Start", yPos)
        yPos = self:CreateVector3Input(propertyName, "End", yPos)
    elseif propertyInfo.type == "UDim2" then
        yPos = self:CreateUDim2Input(propertyName, "Start", yPos)
        yPos = self:CreateUDim2Input(propertyName, "End", yPos)
    elseif propertyInfo.type == "Color3" then
        yPos = self:CreateColor3Input(propertyName, "Start", yPos)
        yPos = self:CreateColor3Input(propertyName, "End", yPos)
    elseif propertyInfo.type == "number" then
        yPos = self:CreateSingleNumberInput(propertyName, "Start", yPos)
        yPos = self:CreateSingleNumberInput(propertyName, "End", yPos)
    end
    
    return yPos + 10
end

function TweenGeneratorUI:CreateVector3Input(propertyName, prefix, yPos)
    local container = Instance.new("Frame")
    container.Name = propertyName .. prefix .. "Container"
    container.Size = UDim2.new(1, 0, 0, 25)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = self.propertyFrame
    
    local prefixLabel = Instance.new("TextLabel")
    prefixLabel.Size = UDim2.new(0, 40, 1, 0)
    prefixLabel.Position = UDim2.new(0, 0, 0, 0)
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.Text = prefix .. ":"
    prefixLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
    prefixLabel.Parent = container
    
    -- X, Y, Z inputs
    local inputWidth = (1 - 0.15) / 3
    for i, axis in ipairs({"X", "Y", "Z"}) do
        local input = Instance.new("TextBox")
        input.Name = propertyName .. prefix .. axis
        input.Size = UDim2.new(inputWidth, -5, 1, 0)
        input.Position = UDim2.new(0.15 + (i-1) * inputWidth, (i-1) * 5, 0, 0)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        input.BorderSizePixel = 0
        input.Text = "0"
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.PlaceholderText = axis
        input.Parent = container
        
        input.FocusLost:Connect(function()
            self:UpdatePropertyValue(propertyName, prefix)
        end)
    end
    
    return yPos + 30
end

function TweenGeneratorUI:CreateUDim2Input(propertyName, prefix, yPos)
    local container = Instance.new("Frame")
    container.Name = propertyName .. prefix .. "Container"
    container.Size = UDim2.new(1, 0, 0, 25)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = self.propertyFrame
    
    local prefixLabel = Instance.new("TextLabel")
    prefixLabel.Size = UDim2.new(0, 40, 1, 0)
    prefixLabel.Position = UDim2.new(0, 0, 0, 0)
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.Text = prefix .. ":"
    prefixLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
    prefixLabel.Parent = container
    
    -- Scale X, Offset X, Scale Y, Offset Y inputs
    local inputWidth = (1 - 0.15) / 4
    for i, component in ipairs({"ScaleX", "OffsetX", "ScaleY", "OffsetY"}) do
        local input = Instance.new("TextBox")
        input.Name = propertyName .. prefix .. component
        input.Size = UDim2.new(inputWidth, -2, 1, 0)
        input.Position = UDim2.new(0.15 + (i-1) * inputWidth, (i-1) * 2, 0, 0)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        input.BorderSizePixel = 0
        input.Text = "0"
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.PlaceholderText = component
        input.Parent = container
        
        input.FocusLost:Connect(function()
            self:UpdatePropertyValue(propertyName, prefix)
        end)
    end
    
    return yPos + 30
end

function TweenGeneratorUI:CreateColor3Input(propertyName, prefix, yPos)
    local container = Instance.new("Frame")
    container.Name = propertyName .. prefix .. "Container"
    container.Size = UDim2.new(1, 0, 0, 25)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = self.propertyFrame
    
    local prefixLabel = Instance.new("TextLabel")
    prefixLabel.Size = UDim2.new(0, 40, 1, 0)
    prefixLabel.Position = UDim2.new(0, 0, 0, 0)
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.Text = prefix .. ":"
    prefixLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
    prefixLabel.Parent = container
    
    -- R, G, B inputs
    local inputWidth = (1 - 0.15) / 3
    for i, channel in ipairs({"R", "G", "B"}) do
        local input = Instance.new("TextBox")
        input.Name = propertyName .. prefix .. channel
        input.Size = UDim2.new(inputWidth, -5, 1, 0)
        input.Position = UDim2.new(0.15 + (i-1) * inputWidth, (i-1) * 5, 0, 0)
        input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        input.BorderSizePixel = 0
        input.Text = "0"
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.PlaceholderText = channel
        input.Parent = container
        
        input.FocusLost:Connect(function()
            self:UpdatePropertyValue(propertyName, prefix)
        end)
    end
    
    return yPos + 30
end

function TweenGeneratorUI:CreateSingleNumberInput(propertyName, prefix, yPos)
    local container = Instance.new("Frame")
    container.Name = propertyName .. prefix .. "Container"
    container.Size = UDim2.new(1, 0, 0, 25)
    container.Position = UDim2.new(0, 0, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = self.propertyFrame
    
    local prefixLabel = Instance.new("TextLabel")
    prefixLabel.Size = UDim2.new(0, 40, 1, 0)
    prefixLabel.Position = UDim2.new(0, 0, 0, 0)
    prefixLabel.BackgroundTransparency = 1
    prefixLabel.Text = prefix .. ":"
    prefixLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    prefixLabel.TextXAlignment = Enum.TextXAlignment.Left
    prefixLabel.Parent = container
    
    local input = Instance.new("TextBox")
    input.Name = propertyName .. prefix .. "Value"
    input.Size = UDim2.new(0.85, 0, 1, 0)
    input.Position = UDim2.new(0.15, 0, 0, 0)
    input.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    input.BorderSizePixel = 0
    input.Text = "0"
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.PlaceholderText = "Value"
    input.Parent = container
    
    input.FocusLost:Connect(function()
        self:UpdatePropertyValue(propertyName, prefix)
    end)
    
    return yPos + 30
end

function TweenGeneratorUI:UpdatePropertyValue(propertyName, prefix)
    -- This function will be called when property inputs change
    -- Store the values for later use in tween creation
    if not self.startProperties then self.startProperties = {} end
    if not self.endProperties then self.endProperties = {} end
    
    local container = self.propertyFrame:FindFirstChild(propertyName .. prefix .. "Container")
    if not container then return end
    
    local properties = PropertyHandler.GetTweenableProperties(self.selectedObject)
    local propertyInfo = properties[propertyName]
    
    if not propertyInfo then return end
    
    local value
    if propertyInfo.type == "Vector3" then
        local x = tonumber(container:FindFirstChild(propertyName .. prefix .. "X").Text) or 0
        local y = tonumber(container:FindFirstChild(propertyName .. prefix .. "Y").Text) or 0
        local z = tonumber(container:FindFirstChild(propertyName .. prefix .. "Z").Text) or 0
        value = Vector3.new(x, y, z)
    elseif propertyInfo.type == "UDim2" then
        local scaleX = tonumber(container:FindFirstChild(propertyName .. prefix .. "ScaleX").Text) or 0
        local offsetX = tonumber(container:FindFirstChild(propertyName .. prefix .. "OffsetX").Text) or 0
        local scaleY = tonumber(container:FindFirstChild(propertyName .. prefix .. "ScaleY").Text) or 0
        local offsetY = tonumber(container:FindFirstChild(propertyName .. prefix .. "OffsetY").Text) or 0
        value = UDim2.new(scaleX, offsetX, scaleY, offsetY)
    elseif propertyInfo.type == "Color3" then
        local r = tonumber(container:FindFirstChild(propertyName .. prefix .. "R").Text) or 0
        local g = tonumber(container:FindFirstChild(propertyName .. prefix .. "G").Text) or 0
        local b = tonumber(container:FindFirstChild(propertyName .. prefix .. "B").Text) or 0
        value = Color3.fromRGB(r, g, b)
    elseif propertyInfo.type == "number" then
        value = tonumber(container:FindFirstChild(propertyName .. prefix .. "Value").Text) or 0
    end
    
    if prefix == "Start" then
        self.startProperties[propertyName] = value
    else
        self.endProperties[propertyName] = value
    end
end

function TweenGeneratorUI:PreviewTween()
    if not self.selectedObject then
        warn("No object selected for preview")
        return
    end
    
    self:StopPreview()
    self:SaveOriginalProperties()
    
    -- Create tween info
    local tweenInfo = TweenInfo.new(
        self.duration,
        self.easingStyle,
        self.easingDirection,
        self.repeatCount,
        self.reverses,
        self.delay
    )
    
    -- Create goal properties
    local goals = {}
    for propertyName, value in pairs(self.endProperties) do
        goals[propertyName] = value
    end
    
    if next(goals) then
        self.currentTween = TweenService:Create(self.selectedObject, tweenInfo, goals)
        self.currentTween:Play()
        
        -- Auto-reset after completion if not repeating infinitely
        if self.repeatCount ~= -1 then
            local totalDuration = self.duration * (self.reverses and 2 or 1) * math.max(1, self.repeatCount)
            task.wait(totalDuration + self.delay + 0.1)
            self:ResetToOriginal()
        end
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
    if not self.selectedObject then return end
    
    self.originalProperties = {}
    for propertyName, _ in pairs(self.endProperties) do
        self.originalProperties[propertyName] = self.selectedObject[propertyName]
    end
end

function TweenGeneratorUI:ResetToOriginal()
    if not self.selectedObject or not self.originalProperties then return end
    
    for propertyName, value in pairs(self.originalProperties) do
        self.selectedObject[propertyName] = value
    end
end

function TweenGeneratorUI:ExportCode()
    if not self.selectedObject then
        warn("No object selected for export")
        return
    end
    
    local code = CodeExporter.GenerateCode(
        self.selectedObject,
        self.duration,
        self.easingStyle,
        self.easingDirection,
        self.repeatCount,
        self.reverses,
        self.delay,
        self.endProperties
    )
    
    -- Copy to clipboard (this is a simplified version - actual clipboard access may vary)
    print("=== TWEEN CODE (Copy this) ===")
    print(code)
    print("=== END TWEEN CODE ===")
end

function TweenGeneratorUI:SavePreset(name)
    local presetData = {
        duration = self.duration,
        delay = self.delay,
        repeatCount = self.repeatCount,
        reverses = self.reverses,
        easingStyle = self.easingStyle.Name,
        easingDirection = self.easingDirection.Name,
        startProperties = self.startProperties,
        endProperties = self.endProperties
    }
    
    PresetManager.SavePreset(self.plugin, name, presetData)
    print("Preset saved: " .. name)
end

function TweenGeneratorUI:UpdateCanvasSize()
    local totalHeight = 0
    for _, child in pairs(self.scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = math.max(totalHeight, child.Position.Y.Offset + child.Size.Y.Offset)
        end
    end
    self.scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

function TweenGeneratorUI:Cleanup()
    self:StopPreview()
    if self.widget then
        self.widget:Destroy()
    end
end

return TweenGeneratorUI 