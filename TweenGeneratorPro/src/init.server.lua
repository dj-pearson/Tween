-- Tween Generator Pro Plugin for Roblox Studio
-- Main plugin entry point (Server Script for Rojo/Argon sync)

local plugin = script.Parent.Parent
local TweenGeneratorUI = require(script.UI.TweenGeneratorUI)
local TweenService = game:GetService("TweenService")
local Selection = game:GetService("Selection")

-- Plugin Info
local pluginName = "Tween Generator Pro"
local pluginDescription = "Visual tween animation creator for Roblox Studio"

-- Create toolbar
local toolbar = plugin:CreateToolbar("Tween Generator Pro")

-- Create button
local button = toolbar:CreateButton(
    "Tween Generator",
    "Open Tween Generator Pro",
    "rbxasset://textures/DevConsole/Close.png" -- Placeholder icon
)

-- Create DockWidget
local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Float,
    false, -- InitialEnabled
    false, -- InitialEnabledShouldOverrideRestore
    400,   -- FloatingXSize
    600,   -- FloatingYSize
    300,   -- MinWidth
    400    -- MinHeight
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