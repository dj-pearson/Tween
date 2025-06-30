**Product Requirement Document (PRD): Tween Generator Pro Plugin for Roblox Studio**

---

**Product Name:** Tween Generator Pro

**Purpose:**
A Roblox Studio plugin that allows developers to create, preview, and export tween animations visually for Parts, Models, and UI elements. This tool simplifies the use of TweenService by removing the need for trial-and-error scripting.

**Target Users:**

* Roblox developers (beginner to advanced)
* UI designers and scripters

**Problem Statement:**
Tweening in Roblox is widely used but currently requires manual scripting, guesswork, and time-consuming iteration. There’s no native visual tween builder inside Studio.

**Solution Overview:**
Tween Generator Pro allows developers to:

* Select an object (Part, Model, UI)
* Set start and end values for tweenable properties
* Choose easing style, duration, and delay
* Preview the animation live in Studio
* Export working Lua code for TweenService
* Save and load tween presets

---

**Core Features:**

1. **Object Selection Panel**

   * Dropdown to select currently selected object in Explorer
   * Auto-detect type (Part, Model, UIElement)

2. **Property Tweens**

   * Allow users to set:

     * Position (Vector3)
     * Size (Vector3)
     * Rotation (Vector3 or CFrame.Angles)
     * Transparency (number)
     * Color (Color3)
     * UI-specific: Position (UDim2), Size (UDim2)
   * Side-by-side view of Start vs. End values

3. **Tween Controls**

   * Duration (number input or slider)
   * Delay (number input)
   * Repeat Count
   * Reverses (true/false)
   * Easing Style (dropdown: Linear, Sine, Back, Bounce, etc.)
   * Easing Direction (In, Out, InOut)

4. **Live Preview**

   * Button to play the tween in Studio
   * Option to auto-reset to original position after preview

5. **Code Export**

   * Button to copy tween code to clipboard
   * Outputs full TweenService code:

     ```lua
     local TweenService = game:GetService("TweenService")
     local part = script.Parent -- or specific path

     local tweenInfo = TweenInfo.new(
         1, -- Duration
         Enum.EasingStyle.Sine,
         Enum.EasingDirection.Out,
         0, -- RepeatCount
         false, -- Reverses
         0 -- DelayTime
     )

     local goal = {
         Position = Vector3.new(...),
         Size = Vector3.new(...),
         -- other properties
     }

     local tween = TweenService:Create(part, tweenInfo, goal)
     tween:Play()
     ```

6. **Presets and Templates**

   * Save tween setups under a name (uses `plugin:SetSetting()`)
   * Load from preset list
   * Delete presets

7. **Plugin UI**

   * DockWidgetPluginGui panel
   * Tabs or collapsible sections for Object, Properties, Settings, Preview, and Export
   * Light and Dark theme compatible

---

**Technical Details:**

* Written in Lua using Roblox Studio plugin API
* Uses `TweenService`
* Should use `plugin:GetSetting()` and `plugin:SetSetting()` for saving presets
* Handles different property types safely (check for correct input types)
* Preview is non-destructive (resets object after playing)

---

**Stretch Goals (Post-MVP):**

* Timeline view to chain multiple tweens
* Visual handles in viewport for setting positions
* Audio cue tween (Sound pitch, volume)
* Group tweens (multiple parts at once)
* Export as reusable ModuleScript

---

**Success Metrics:**

* Plugin installs from Toolbox or GitHub
* User ratings and feedback on usability
* Scripts saved/copied from export
* Community uptake on DevForum and Discord

---

**License & Distribution:**

* Free version with limited export or property support
* Paid version for full access (via DevEx or plugin pass)
* Distributed through Roblox Plugin Marketplace or GitHub

---

**Developer Notes:**

* All generated code should be clean, readable, and ready to paste into a LocalScript or Script
* Preview tweens must be reversible without breaking object state
* Support Parts, Models, Frames, TextLabels, and ImageLabels
* Allow scaling UI tweens using AnchorPoint awareness

---

**Contact for Questions:** \[Insert Your Contact Info Here]

---

This document is complete and ready for handoff to a Roblox plugin developer with intermediate experience.
