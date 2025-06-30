# Installation Guide for Tween Generator Pro

This guide will walk you through installing the Tween Generator Pro plugin in Roblox Studio, with support for modern development workflows using Rojo/Argon.

## Prerequisites

- Roblox Studio installed on your computer
- Basic familiarity with Roblox Studio interface
- For development: [Rojo](https://rojo.space/) or [Argon VS Code Extension](https://marketplace.visualstudio.com/items?itemName=daimond113.argon) (recommended)

## Installation Methods

### Method 1: Rojo/Argon Sync (Recommended for Developers)

This method is best for developers who want to modify the plugin or integrate it into their development workflow.

#### Using Rojo

1. **Install Rojo**:
   ```bash
   # Install via Foreman (recommended)
   foreman install
   
   # Or install directly
   cargo install rojo
   ```

2. **Clone and Setup**:
   ```bash
   git clone <repository-url>
   cd TweenGeneratorPro
   ```

3. **Start Rojo Server**:
   ```bash
   rojo serve
   ```

4. **Connect in Studio**:
   - Open Roblox Studio
   - In the Plugins tab, click "Rojo" → "Connect"
   - The plugin will appear as a Plugin object in your place

#### Using Argon

1. **Install Argon VS Code Extension**:
   - Open VS Code
   - Install the "Argon" extension by daimond113

2. **Setup Project**:
   - Open the TweenGeneratorPro folder in VS Code
   - Use Command Palette (Ctrl/Cmd + Shift + P)
   - Run "Argon: Start Session"

3. **Connect in Studio**:
   - Open Roblox Studio
   - Install Argon plugin from Studio if not already installed
   - Connect to the Argon session

### Method 2: Pre-built Plugin File

1. **Download or Build**:
   - Use Rojo to build: `rojo build -o TweenGeneratorPro.rbxm`
   - Or download a pre-built `.rbxm` file

2. **Install Plugin**:
   - Navigate to your Roblox Studio Plugins folder
   - Copy the `.rbxm` file into the folder
   - Restart Roblox Studio

### Method 3: Manual File Installation (Legacy)

This method works but doesn't support hot reloading or modern development features.

1. **Locate Plugins Folder**:
   - Open Roblox Studio
   - Go to Plugins tab → Plugin Folder
   - Alternative locations:
     - Windows: `%LOCALAPPDATA%\Roblox\Plugins`
     - Mac: `~/Documents/Roblox/Plugins`

2. **Copy Files**:
   - Copy the entire `TweenGeneratorPro` folder
   - Paste into your Plugins directory

3. **Manual Setup**:
   - Create a Plugin object in ServerStorage
   - Copy contents of `src/init.server.lua` into a Script
   - Create a UI folder with ModuleScripts for each file

4. **Save and Install**:
   - Right-click Plugin → Save to File
   - Save as `.rbxm` in Plugins folder
   - Restart Studio

## Project Structure Explanation

The plugin uses a simplified bundled structure:

```
TweenGeneratorPro/
├── src/
│   └── init.server.lua          # Bundled plugin (Server Script with all functionality)
├── project.json                 # Rojo configuration
└── documentation files...
```

**Bundled Architecture**: All plugin functionality (UI, property handling, code export, presets) is contained in a single `init.server.lua` file. This approach:
- Simplifies distribution and installation
- Ensures compatibility with various sync tools
- Reduces complexity for end users
- Follows the pattern of successful Roblox plugins

## Verification

After installation, verify the plugin is working:

### Check Plugin Appears

1. **Toolbar Check**:
   - Look for "Tween Generator Pro" in the Plugins toolbar
   - You should see a "Tween Generator" button

2. **Test Opening**:
   - Click the button
   - A dock widget should appear with the plugin interface

### Check Console

1. Open View → Output
2. Look for any error messages
3. Should see no red errors on plugin load

### Test Basic Functionality

1. Select a Part in workspace
2. Click "Refresh" in the plugin
3. Verify the Part appears as selected
4. Try setting some property values and preview

## Development Setup

If you want to modify or contribute to the plugin:

### Environment Setup

1. **Install Development Tools**:
   ```bash
   # Install Rojo
   cargo install rojo
   
   # Or use Foreman
   foreman install
   ```

2. **Clone Repository**:
   ```bash
   git clone <repository-url>
   cd TweenGeneratorPro
   ```

3. **Start Development Server**:
   ```bash
   rojo serve
   ```

### Development Workflow

1. **Make Changes**: Edit the bundled `src/init.server.lua` file
2. **Hot Reload**: Changes sync automatically to Studio
3. **Test**: Immediately test changes without restart
4. **Build**: Use `rojo build` for distribution

### VS Code Setup

1. Install recommended extensions:
   - Argon (for Roblox sync)
   - Luau Language Server (for autocomplete)

2. Configure workspace:
   - Open folder in VS Code
   - Extensions should auto-configure

## Common Installation Issues

### Plugin Not Appearing

**Possible Causes**:
- Incorrect file structure
- Missing required files
- Sync connection issues

**Solutions**:
- Verify all files are present in `src/` directory
- Check Rojo/Argon connection status
- Restart sync server and reconnect
- Check Output window for errors

### Sync Connection Failed

**Rojo Issues**:
- Verify server is running: `rojo serve`
- Check port isn't blocked (default: 34872)
- Try different port: `rojo serve --port 34873`

**Argon Issues**:
- Restart VS Code extension
- Check Argon plugin installed in Studio
- Verify workspace folder is correct

### Script Errors on Load

**Possible Causes**:
- Syntax errors in source files
- Missing dependencies
- Incorrect require paths

**Solutions**:
- Check Output window for specific errors
- Verify file structure matches project.json
- Ensure the bundled init.server.lua file is present and contains all functionality

### Permission Issues

**Windows**:
- Run Studio as administrator
- Check antivirus isn't blocking files

**Mac**:
- Verify folder permissions
- Check Gatekeeper settings

## File Structure Verification

Your synced project should look like this in Studio:

```
ServerStorage
└── TweenGeneratorPro (Folder)
    └── init (Server Script) -- Contains all bundled functionality
```

The bundled `init` Server Script contains all plugin functionality including UI, property handling, code export, and preset management.

## Alternative Sync Tools

If Rojo/Argon don't work for you:

1. **Roblox Studio Sync**: Use Studio's built-in sync (limited)
2. **Other Tools**: Remodel, rbxlx-to-rojo converters
3. **Manual Import**: Copy-paste code directly

## Getting Help

If you continue to have installation issues:

1. **Check Documentation**: Review README.md and examples
2. **Console Errors**: Copy exact error messages
3. **Environment Info**: Include OS, Studio version, tool versions
4. **Minimal Reproduction**: Try basic Rojo project first

## Uninstalling

### Remove Plugin File
1. Navigate to Plugins folder
2. Delete `TweenGeneratorPro.rbxm`
3. Restart Studio

### Remove Source Files
1. Delete project folder
2. Stop any running sync servers
3. Remove from Studio if synced

## Next Steps

Once installed successfully:

1. **Read Usage Guide**: Check README.md for detailed usage
2. **Try Examples**: Review EXAMPLES.md for common scenarios
3. **Experiment**: Start with simple Part tweening
4. **Explore**: Test different easing styles and properties

The plugin will no longer appear in the toolbar after uninstalling. 