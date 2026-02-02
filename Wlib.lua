--[[
	Wlib - UI Library for Roblox
	Inspired by Rayfield UI Library
	
	A lightweight, feature-rich UI library for Roblox script development
	
	Features:
	- Modern, customizable interface
	- Multiple themes
	- Drag functionality
	- Configuration saving
	- Notifications system
	- Various UI elements (Buttons, Toggles, Sliders, Dropdowns, Inputs, Keybinds, ColorPickers)
	
	Usage Example:
	
	local Wlib = loadstring(game:HttpGet("YOUR_URL_HERE"))()
	
	local Window = Wlib:CreateWindow({
		Name = "Wlib Example",
		LoadingTitle = "Loading...",
		LoadingSubtitle = "by Your Name",
		ConfigurationSaving = {
			Enabled = true,
			FileName = "WlibConfig"
		}
	})
	
	local Tab = Window:CreateTab("Main", "home")
	
	Tab:CreateButton({
		Name = "Click Me!",
		Callback = function()
			print("Button clicked!")
		end
	})
--]]

-- Version
local VERSION = "1.0.0"

-- Service Helper
local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Services
local RunService = getService("RunService")
local TweenService = getService("TweenService")
local UserInputService = getService("UserInputService")
local HttpService = getService("HttpService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- Environment Check
local useStudio = RunService:IsStudio()

-- Configuration
local WlibFolder = "Wlib"
local ConfigurationFolder = WlibFolder .. "/Configurations"
local ConfigurationExtension = ".wlib"

-- Safe Function Caller
local function callSafely(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Wlib | Function failed: " .. tostring(result))
			return false
		end
		return result
	end
	return false
end

-- Folder Management
local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder, folderPath) then
		callSafely(makefolder, folderPath)
	end
end

-- Color Utilities
local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

-- Main Library Table
local Wlib = {
	Flags = {},
	Version = VERSION,
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),
			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),
			
			TabBackground = Color3.fromRGB(80, 80, 80),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),
			
			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			
			SliderBackground = Color3.fromRGB(50, 138, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			
			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},
		
		Dark = {
			TextColor = Color3.fromRGB(230, 230, 230),
			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),
			
			TabBackground = Color3.fromRGB(35, 40, 45),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),
			
			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			ElementStroke = Color3.fromRGB(45, 50, 60),
			
			SliderBackground = Color3.fromRGB(0, 90, 180),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			
			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60),
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},
		
		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),
			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),
			
			TabBackground = Color3.fromRGB(235, 235, 235),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),
			
			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			
			SliderBackground = Color3.fromRGB(150, 180, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			
			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		}
	}
}

-- Current Theme
local SelectedTheme = Wlib.Theme.Default

-- UI Creation Helper
local function Create(className, properties)
	local instance = Instance.new(className)
	for prop, value in pairs(properties or {}) do
		if prop ~= "Parent" then
			instance[prop] = value
		end
	end
	if properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

-- Tween Helper
local function Tween(instance, properties, duration, style, direction)
	duration = duration or 0.3
	style = style or Enum.EasingStyle.Exponential
	direction = direction or Enum.EasingDirection.Out
	
	return TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
end

-- Create Main GUI
local function CreateMainGui()
	local ScreenGui = Create("ScreenGui", {
		Name = "Wlib",
		ResetOnSpawn = false,
		DisplayOrder = 100,
		IgnoreGuiInset = true
	})
	
	-- Parent to appropriate location
	if gethui then
		ScreenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(ScreenGui)
		ScreenGui.Parent = CoreGui
	else
		ScreenGui.Parent = CoreGui
	end
	
	return ScreenGui
end

-- Notification System
function Wlib:Notify(options)
	options = options or {}
	local title = options.Title or "Notification"
	local content = options.Content or ""
	local duration = options.Duration or 5
	
	task.spawn(function()
		-- Find or create notifications container
		local gui = self.ScreenGui
		if not gui then return end
		
		local notifContainer = gui:FindFirstChild("Notifications")
		if not notifContainer then
			notifContainer = Create("Frame", {
				Name = "Notifications",
				Parent = gui,
				Size = UDim2.new(0, 300, 1, 0),
				Position = UDim2.new(1, -310, 0, 10),
				BackgroundTransparency = 1
			})
			
			Create("UIListLayout", {
				Parent = notifContainer,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		end
		
		-- Create notification
		local notif = Create("Frame", {
			Parent = notifContainer,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = SelectedTheme.ElementBackground,
			BorderSizePixel = 0,
			BackgroundTransparency = 1
		})
		
		Create("UICorner", {
			Parent = notif,
			CornerRadius = UDim.new(0, 6)
		})
		
		Create("UIStroke", {
			Parent = notif,
			Color = SelectedTheme.ElementStroke,
			Transparency = 1
		})
		
		local titleLabel = Create("TextLabel", {
			Parent = notif,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 10),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = SelectedTheme.TextColor,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})
		
		local contentLabel = Create("TextLabel", {
			Parent = notif,
			Size = UDim2.new(1, -20, 0, 30),
			Position = UDim2.new(0, 10, 0, 30),
			BackgroundTransparency = 1,
			Text = content,
			TextColor3 = SelectedTheme.TextColor,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextTransparency = 1
		})
		
		-- Calculate height based on text
		local textHeight = contentLabel.TextBounds.Y
		local finalHeight = math.max(textHeight + 50, 70)
		
		-- Animate in
		Tween(notif, {Size = UDim2.new(1, 0, 0, finalHeight)}):Play()
		Tween(notif, {BackgroundTransparency = 0.1}, 0.4):Play()
		Tween(notif:FindFirstChildOfClass("UIStroke"), {Transparency = 0.8}, 0.4):Play()
		Tween(titleLabel, {TextTransparency = 0}, 0.4):Play()
		Tween(contentLabel, {TextTransparency = 0.3}, 0.4):Play()
		
		-- Wait and animate out
		task.wait(duration)
		
		Tween(notif, {BackgroundTransparency = 1}, 0.3):Play()
		Tween(notif:FindFirstChildOfClass("UIStroke"), {Transparency = 1}, 0.3):Play()
		Tween(titleLabel, {TextTransparency = 1}, 0.3):Play()
		Tween(contentLabel, {TextTransparency = 1}, 0.3):Play()
		Tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.4):Play()
		
		task.wait(0.5)
		notif:Destroy()
	end)
end

-- Window Creation
function Wlib:CreateWindow(settings)
	settings = settings or {}
	
	local WindowName = settings.Name or "Wlib"
	local LoadingTitle = settings.LoadingTitle or "Wlib"
	local LoadingSubtitle = settings.LoadingSubtitle or "UI Library"
	
	-- Configuration setup
	local ConfigEnabled = false
	local ConfigFileName = nil
	
	if settings.ConfigurationSaving then
		ConfigEnabled = settings.ConfigurationSaving.Enabled or false
		ConfigFileName = settings.ConfigurationSaving.FileName or "WlibConfig"
		
		if ConfigEnabled then
			ensureFolder(WlibFolder)
			ensureFolder(ConfigurationFolder)
		end
	end
	
	-- Apply theme
	if settings.Theme then
		if type(settings.Theme) == "string" and Wlib.Theme[settings.Theme] then
			SelectedTheme = Wlib.Theme[settings.Theme]
		elseif type(settings.Theme) == "table" then
			SelectedTheme = settings.Theme
		end
	end
	
	-- Create main GUI
	local ScreenGui = CreateMainGui()
	Wlib.ScreenGui = ScreenGui
	
	-- Main container
	local Main = Create("Frame", {
		Name = "Main",
		Parent = ScreenGui,
		Size = UDim2.new(0, 550, 0, 400),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = SelectedTheme.Background,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {
		Parent = Main,
		CornerRadius = UDim.new(0, 8)
	})
	
	-- Shadow
	local Shadow = Create("ImageLabel", {
		Name = "Shadow",
		Parent = Main,
		Size = UDim2.new(1, 40, 1, 40),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = SelectedTheme.Shadow,
		ImageTransparency = 0.6,
		ZIndex = 0
	})
	
	-- Topbar
	local Topbar = Create("Frame", {
		Name = "Topbar",
		Parent = Main,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = SelectedTheme.Topbar,
		BorderSizePixel = 0
	})
	
	Create("UICorner", {
		Parent = Topbar,
		CornerRadius = UDim.new(0, 8)
	})
	
	-- Corner repair for topbar
	Create("Frame", {
		Name = "CornerRepair",
		Parent = Topbar,
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 1, -8),
		BackgroundColor3 = SelectedTheme.Topbar,
		BorderSizePixel = 0
	})
	
	-- Title
	local Title = Create("TextLabel", {
		Name = "Title",
		Parent = Topbar,
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0, 15, 0, 0),
		BackgroundTransparency = 1,
		Text = WindowName,
		TextColor3 = SelectedTheme.TextColor,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Close button
	local CloseButton = Create("TextButton", {
		Name = "Close",
		Parent = Topbar,
		Size = UDim2.new(0, 30, 0, 30),
		Position = UDim2.new(1, -35, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255, 60, 60),
		BorderSizePixel = 0,
		Text = "✕",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 18,
		Font = Enum.Font.GothamBold
	})
	
	Create("UICorner", {
		Parent = CloseButton,
		CornerRadius = UDim.new(0, 6)
	})
	
	CloseButton.MouseButton1Click:Connect(function()
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3):Play()
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	-- Make draggable
	local dragging = false
	local dragInput, mousePos, framePos
	
	Topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			mousePos = input.Position
			framePos = Main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	Topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			Main.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
	
	-- Tab container
	local TabList = Create("Frame", {
		Name = "TabList",
		Parent = Main,
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 10, 0, 45),
		BackgroundTransparency = 1
	})
	
	Create("UIListLayout", {
		Parent = TabList,
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Elements container
	local Elements = Create("Frame", {
		Name = "Elements",
		Parent = Main,
		Size = UDim2.new(1, -175, 1, -50),
		Position = UDim2.new(0, 165, 0, 45),
		BackgroundTransparency = 1,
		ClipsDescendants = true
	})
	
	-- Tab page layout
	Create("UIPageLayout", {
		Name = "PageLayout",
		Parent = Elements,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		EasingDirection = Enum.EasingDirection.InOut,
		EasingStyle = Enum.EasingStyle.Exponential,
		Padding = UDim.new(0, 0),
		TweenTime = 0.3
	})
	
	local PageLayout = Elements.PageLayout
	
	-- Window object
	local Window = {
		Name = WindowName,
		Main = Main,
		TabList = TabList,
		Elements = Elements,
		PageLayout = PageLayout,
		ConfigEnabled = ConfigEnabled,
		ConfigFileName = ConfigFileName,
		Tabs = {}
	}
	
	-- Save configuration
	function Window:SaveConfig()
		if not self.ConfigEnabled then return end
		
		local data = {}
		for flag, element in pairs(Wlib.Flags) do
			if element.Type == "ColorPicker" then
				data[flag] = PackColor(element.Color)
			else
				data[flag] = element.CurrentValue or element.CurrentKeybind or element.CurrentOption or element.Color
			end
		end
		
		local success = callSafely(writefile, ConfigurationFolder .. "/" .. self.ConfigFileName .. ConfigurationExtension, HttpService:JSONEncode(data))
		if success then
			Wlib:Notify({
				Title = "Configuration Saved",
				Content = "Your settings have been saved successfully.",
				Duration = 3
			})
		end
	end
	
	-- Load configuration
	function Window:LoadConfig()
		if not self.ConfigEnabled then return end
		
		local filePath = ConfigurationFolder .. "/" .. self.ConfigFileName .. ConfigurationExtension
		if not callSafely(isfile, filePath) then return end
		
		local content = callSafely(readfile, filePath)
		if not content then return end
		
		local success, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		
		if not success then return end
		
		for flag, value in pairs(data) do
			if Wlib.Flags[flag] then
				local element = Wlib.Flags[flag]
				task.spawn(function()
					if element.Type == "ColorPicker" then
						element:Set(UnpackColor(value))
					else
						element:Set(value)
					end
				end)
			end
		end
		
		Wlib:Notify({
			Title = "Configuration Loaded",
			Content = "Your settings have been restored.",
			Duration = 3
		})
	end
	
	-- Create tab
	function Window:CreateTab(name, icon)
		local Tab = {
			Name = name,
			Window = self,
			Elements = {}
		}
		
		-- Tab button
		local TabButton = Create("Frame", {
			Name = name,
			Parent = TabList,
			Size = UDim2.new(1, 0, 0, 35),
			BackgroundColor3 = SelectedTheme.TabBackground,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.7
		})
		
		Create("UICorner", {
			Parent = TabButton,
			CornerRadius = UDim.new(0, 6)
		})
		
		local TabTitle = Create("TextLabel", {
			Name = "Title",
			Parent = TabButton,
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = SelectedTheme.TabTextColor,
			TextSize = 14,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 0.2
		})
		
		local TabInteract = Create("TextButton", {
			Name = "Interact",
			Parent = TabButton,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = ""
		})
		
		-- Tab page
		local TabPage = Create("ScrollingFrame", {
			Name = name,
			Parent = Elements,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = SelectedTheme.ElementStroke,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y
		})
		
		Create("UIListLayout", {
			Parent = TabPage,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		Create("UIPadding", {
			Parent = TabPage,
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 5)
		})
		
		-- Tab switching
		local function SelectTab()
			PageLayout:JumpTo(TabPage)
			
			for _, otherTab in ipairs(TabList:GetChildren()) do
				if otherTab:IsA("Frame") then
					Tween(otherTab, {BackgroundTransparency = 0.7}):Play()
					if otherTab:FindFirstChild("Title") then
						Tween(otherTab.Title, {TextTransparency = 0.2}):Play()
					end
				end
			end
			
			Tween(TabButton, {BackgroundTransparency = 0}):Play()
			Tween(TabTitle, {TextTransparency = 0}):Play()
		end
		
		TabInteract.MouseButton1Click:Connect(SelectTab)
		
		-- Select first tab by default
		if #TabList:GetChildren() == 2 then -- UIListLayout + 1 tab
			SelectTab()
		end
		
		table.insert(self.Tabs, Tab)
		
		-- Section
		function Tab:CreateSection(name)
			local Section = Create("TextLabel", {
				Name = "Section",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 14,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTransparency = 0.4
			})
			
			return Section
		end
		
		-- Button
		function Tab:CreateButton(options)
			options = options or {}
			local buttonName = options.Name or "Button"
			local callback = options.Callback or function() end
			
			local ButtonFrame = Create("Frame", {
				Name = "Button",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = ButtonFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = ButtonFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local ButtonTitle = Create("TextLabel", {
				Name = "Title",
				Parent = ButtonFrame,
				Size = UDim2.new(1, -15, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = buttonName,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local ButtonInteract = Create("TextButton", {
				Name = "Interact",
				Parent = ButtonFrame,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = ""
			})
			
			ButtonInteract.MouseEnter:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
			end)
			
			ButtonInteract.MouseLeave:Connect(function()
				Tween(ButtonFrame, {BackgroundColor3 = SelectedTheme.ElementBackground}):Play()
			end)
			
			ButtonInteract.MouseButton1Click:Connect(function()
				callback()
			end)
			
			return ButtonFrame
		end
		
		-- Toggle
		function Tab:CreateToggle(options)
			options = options or {}
			local toggleName = options.Name or "Toggle"
			local defaultValue = options.CurrentValue or false
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local ToggleFrame = Create("Frame", {
				Name = "Toggle",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = ToggleFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = ToggleFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local ToggleTitle = Create("TextLabel", {
				Name = "Title",
				Parent = ToggleFrame,
				Size = UDim2.new(1, -60, 1, 0),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = toggleName,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local ToggleSwitch = Create("Frame", {
				Name = "Switch",
				Parent = ToggleFrame,
				Size = UDim2.new(0, 40, 0, 20),
				Position = UDim2.new(1, -50, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = SelectedTheme.ToggleDisabled,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = ToggleSwitch,
				CornerRadius = UDim.new(1, 0)
			})
			
			local ToggleKnob = Create("Frame", {
				Name = "Knob",
				Parent = ToggleSwitch,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = ToggleKnob,
				CornerRadius = UDim.new(1, 0)
			})
			
			local currentValue = defaultValue
			
			local function UpdateToggle(value)
				currentValue = value
				
				if value then
					Tween(ToggleSwitch, {BackgroundColor3 = SelectedTheme.ToggleEnabled}):Play()
					Tween(ToggleKnob, {Position = UDim2.new(1, -18, 0.5, 0)}):Play()
				else
					Tween(ToggleSwitch, {BackgroundColor3 = SelectedTheme.ToggleDisabled}):Play()
					Tween(ToggleKnob, {Position = UDim2.new(0, 2, 0.5, 0)}):Play()
				end
				
				callback(value)
			end
			
			local ToggleInteract = Create("TextButton", {
				Name = "Interact",
				Parent = ToggleFrame,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = ""
			})
			
			ToggleInteract.MouseButton1Click:Connect(function()
				UpdateToggle(not currentValue)
			end)
			
			-- Initialize
			UpdateToggle(defaultValue)
			
			local Toggle = {
				Type = "Toggle",
				CurrentValue = currentValue,
				Set = UpdateToggle
			}
			
			if flag then
				Wlib.Flags[flag] = Toggle
			end
			
			return Toggle
		end
		
		-- Slider
		function Tab:CreateSlider(options)
			options = options or {}
			local sliderName = options.Name or "Slider"
			local min = options.Min or 0
			local max = options.Max or 100
			local defaultValue = options.CurrentValue or min
			local increment = options.Increment or 1
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local SliderFrame = Create("Frame", {
				Name = "Slider",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 45),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = SliderFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = SliderFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local SliderTitle = Create("TextLabel", {
				Name = "Title",
				Parent = SliderFrame,
				Size = UDim2.new(1, -70, 0, 20),
				Position = UDim2.new(0, 15, 0, 5),
				BackgroundTransparency = 1,
				Text = sliderName,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local SliderValue = Create("TextLabel", {
				Name = "Value",
				Parent = SliderFrame,
				Size = UDim2.new(0, 50, 0, 20),
				Position = UDim2.new(1, -60, 0, 5),
				BackgroundTransparency = 1,
				Text = tostring(defaultValue),
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local SliderBar = Create("Frame", {
				Name = "Bar",
				Parent = SliderFrame,
				Size = UDim2.new(1, -30, 0, 4),
				Position = UDim2.new(0, 15, 1, -12),
				BackgroundColor3 = SelectedTheme.InputBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = SliderBar,
				CornerRadius = UDim.new(1, 0)
			})
			
			local SliderFill = Create("Frame", {
				Name = "Fill",
				Parent = SliderBar,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = SelectedTheme.SliderBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = SliderFill,
				CornerRadius = UDim.new(1, 0)
			})
			
			local currentValue = defaultValue
			local dragging = false
			
			local function UpdateSlider(value)
				value = math.clamp(value, min, max)
				value = math.floor(value / increment + 0.5) * increment
				currentValue = value
				
				local percentage = (value - min) / (max - min)
				Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1):Play()
				SliderValue.Text = tostring(value)
				
				callback(value)
			end
			
			SliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local mouseX = input.Position.X
					local barX = SliderBar.AbsolutePosition.X
					local barWidth = SliderBar.AbsoluteSize.X
					local percentage = math.clamp((mouseX - barX) / barWidth, 0, 1)
					local value = min + (max - min) * percentage
					UpdateSlider(value)
				end
			end)
			
			SliderBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mouseX = input.Position.X
					local barX = SliderBar.AbsolutePosition.X
					local barWidth = SliderBar.AbsoluteSize.X
					local percentage = math.clamp((mouseX - barX) / barWidth, 0, 1)
					local value = min + (max - min) * percentage
					UpdateSlider(value)
				end
			end)
			
			-- Initialize
			UpdateSlider(defaultValue)
			
			local Slider = {
				Type = "Slider",
				CurrentValue = currentValue,
				Set = UpdateSlider
			}
			
			if flag then
				Wlib.Flags[flag] = Slider
			end
			
			return Slider
		end
		
		-- Dropdown
		function Tab:CreateDropdown(options)
			options = options or {}
			local dropdownName = options.Name or "Dropdown"
			local optionsList = options.Options or {"Option 1", "Option 2"}
			local defaultValue = options.CurrentOption or optionsList[1]
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local DropdownFrame = Create("Frame", {
				Name = "Dropdown",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			
			Create("UICorner", {
				Parent = DropdownFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = DropdownFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local DropdownTitle = Create("TextLabel", {
				Name = "Title",
				Parent = DropdownFrame,
				Size = UDim2.new(1, -40, 0, 35),
				Position = UDim2.new(0, 15, 0, 0),
				BackgroundTransparency = 1,
				Text = dropdownName,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local DropdownValue = Create("TextLabel", {
				Name = "Value",
				Parent = DropdownFrame,
				Size = UDim2.new(0, 80, 0, 35),
				Position = UDim2.new(1, -95, 0, 0),
				BackgroundTransparency = 1,
				Text = defaultValue,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTransparency = 0.3
			})
			
			local DropdownIcon = Create("TextLabel", {
				Name = "Icon",
				Parent = DropdownFrame,
				Size = UDim2.new(0, 20, 0, 35),
				Position = UDim2.new(1, -25, 0, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 10,
				Font = Enum.Font.Gotham,
				TextTransparency = 0.3
			})
			
			local OptionsContainer = Create("Frame", {
				Name = "Options",
				Parent = DropdownFrame,
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 35),
				BackgroundTransparency = 1
			})
			
			Create("UIListLayout", {
				Parent = OptionsContainer,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			
			local expanded = false
			local currentOption = defaultValue
			
			local function UpdateDropdown(option)
				currentOption = option
				DropdownValue.Text = option
				callback(option)
			end
			
			local function Toggle()
				expanded = not expanded
				
				if expanded then
					local optionHeight = 30
					local totalHeight = 35 + (#optionsList * optionHeight) + (#optionsList * 2)
					Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3):Play()
					Tween(DropdownIcon, {Rotation = 180}, 0.3):Play()
				else
					Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.3):Play()
					Tween(DropdownIcon, {Rotation = 0}, 0.3):Play()
				end
			end
			
			local DropdownInteract = Create("TextButton", {
				Name = "Interact",
				Parent = DropdownFrame,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 2
			})
			
			DropdownInteract.MouseButton1Click:Connect(Toggle)
			
			-- Create options
			for _, option in ipairs(optionsList) do
				local OptionButton = Create("TextButton", {
					Name = option,
					Parent = OptionsContainer,
					Size = UDim2.new(1, -10, 0, 30),
					Position = UDim2.new(0, 5, 0, 0),
					BackgroundColor3 = SelectedTheme.InputBackground,
					BorderSizePixel = 0,
					Text = option,
					TextColor3 = SelectedTheme.TextColor,
					TextSize = 12,
					Font = Enum.Font.Gotham
				})
				
				Create("UICorner", {
					Parent = OptionButton,
					CornerRadius = UDim.new(0, 4)
				})
				
				OptionButton.MouseButton1Click:Connect(function()
					UpdateDropdown(option)
					Toggle()
				end)
				
				OptionButton.MouseEnter:Connect(function()
					Tween(OptionButton, {BackgroundColor3 = SelectedTheme.ElementBackgroundHover}):Play()
				end)
				
				OptionButton.MouseLeave:Connect(function()
					Tween(OptionButton, {BackgroundColor3 = SelectedTheme.InputBackground}):Play()
				end)
			end
			
			-- Initialize
			UpdateDropdown(defaultValue)
			
			local Dropdown = {
				Type = "Dropdown",
				CurrentOption = currentOption,
				Set = UpdateDropdown
			}
			
			if flag then
				Wlib.Flags[flag] = Dropdown
			end
			
			return Dropdown
		end
		
		-- Input
		function Tab:CreateInput(options)
			options = options or {}
			local inputName = options.Name or "Input"
			local defaultValue = options.CurrentValue or ""
			local placeholder = options.PlaceholderText or "Enter text..."
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local InputFrame = Create("Frame", {
				Name = "Input",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = InputFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = InputFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local InputTitle = Create("TextLabel", {
				Name = "Title",
				Parent = InputFrame,
				Size = UDim2.new(1, -15, 0, 20),
				Position = UDim2.new(0, 15, 0, 5),
				BackgroundTransparency = 1,
				Text = inputName,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local InputBox = Create("TextBox", {
				Name = "InputBox",
				Parent = InputFrame,
				Size = UDim2.new(1, -30, 0, 25),
				Position = UDim2.new(0, 15, 0, 30),
				BackgroundColor3 = SelectedTheme.InputBackground,
				BorderSizePixel = 0,
				Text = defaultValue,
				PlaceholderText = placeholder,
				PlaceholderColor3 = SelectedTheme.PlaceholderColor,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = false
			})
			
			Create("UICorner", {
				Parent = InputBox,
				CornerRadius = UDim.new(0, 4)
			})
			
			Create("UIStroke", {
				Parent = InputBox,
				Color = SelectedTheme.InputStroke,
				Transparency = 0.7
			})
			
			local currentValue = defaultValue
			
			local function UpdateInput(value)
				currentValue = value
				InputBox.Text = value
				callback(value)
			end
			
			InputBox.FocusLost:Connect(function()
				UpdateInput(InputBox.Text)
			end)
			
			local Input = {
				Type = "Input",
				CurrentValue = currentValue,
				Set = UpdateInput
			}
			
			if flag then
				Wlib.Flags[flag] = Input
			end
			
			return Input
		end
		
		-- Label
		function Tab:CreateLabel(text)
			local Label = Create("TextLabel", {
				Name = "Label",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 25),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				TextTransparency = 0.3
			})
			
			return Label
		end
		
		-- Paragraph
		function Tab:CreateParagraph(options)
			options = options or {}
			local title = options.Title or "Paragraph"
			local content = options.Content or ""
			
			local ParagraphFrame = Create("Frame", {
				Name = "Paragraph",
				Parent = TabPage,
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundColor3 = SelectedTheme.ElementBackground,
				BorderSizePixel = 0
			})
			
			Create("UICorner", {
				Parent = ParagraphFrame,
				CornerRadius = UDim.new(0, 6)
			})
			
			Create("UIStroke", {
				Parent = ParagraphFrame,
				Color = SelectedTheme.ElementStroke,
				Transparency = 0.5
			})
			
			local ParagraphTitle = Create("TextLabel", {
				Name = "Title",
				Parent = ParagraphFrame,
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 15, 0, 5),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local ParagraphContent = Create("TextLabel", {
				Name = "Content",
				Parent = ParagraphFrame,
				Size = UDim2.new(1, -30, 1, -30),
				Position = UDim2.new(0, 15, 0, 25),
				BackgroundTransparency = 1,
				Text = content,
				TextColor3 = SelectedTheme.TextColor,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				TextTransparency = 0.3
			})
			
			-- Auto-resize based on content
			local textHeight = ParagraphContent.TextBounds.Y
			ParagraphFrame.Size = UDim2.new(1, 0, 0, math.max(textHeight + 40, 70))
			
			return ParagraphFrame
		end
		
		return Tab
	end
	
	-- Load config on startup
	task.spawn(function()
		task.wait(0.5)
		Window:LoadConfig()
	end)
	
	return Window
end

-- Destroy function
function Wlib:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return Wlib
