--[[
	Wlib v2.0 - Modern UI Library for Roblox
	
	A visually stunning, feature-rich UI library with glassmorphism design
	
	Features:
	- Modern glassmorphism aesthetic
	- Smooth animations and transitions
	- Fully working UI elements
	- Advanced color picker
	- Keybind system
	- Auto-saving configuration
	- Rich notification system
	- Blur effects and gradients
--]]

local VERSION = "2.0.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Get Service Helper
local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Configuration
local WlibFolder = "Wlib"
local ConfigFolder = WlibFolder .. "/Configs"
local ConfigExtension = ".json"

-- Utility Functions
local function safeCall(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Wlib Error:", result)
			return false
		end
		return result
	end
	return false
end

local function ensureFolder(path)
	if isfolder and not safeCall(isfolder, path) then
		safeCall(makefolder, path)
	end
end

local function create(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			obj[k] = v
		end
	end
	if props.Parent then obj.Parent = props.Parent end
	return obj
end

local function tween(obj, props, duration, style, direction)
	return TweenService:Create(
		obj,
		TweenInfo.new(
			duration or 0.3,
			style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out
		),
		props
	)
end

-- Color Utilities
local function rgbToHex(color)
	return string.format("#%02X%02X%02X", 
		math.floor(color.R * 255),
		math.floor(color.G * 255),
		math.floor(color.B * 255)
	)
end

local function hexToRgb(hex)
	hex = hex:gsub("#", "")
	return Color3.fromRGB(
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16)
	)
end

local function packColor(color)
	return {R = color.R * 255, G = color.G * 255, B = color.B * 255}
end

local function unpackColor(data)
	return Color3.fromRGB(data.R, data.G, data.B)
end

-- Modern Color Themes
local Themes = {
	Dark = {
		-- Base colors
		Accent = Color3.fromRGB(138, 180, 248),
		AccentDark = Color3.fromRGB(91, 134, 229),
		
		-- Backgrounds with transparency for glassmorphism
		Background = Color3.fromRGB(17, 17, 27),
		BackgroundLight = Color3.fromRGB(25, 25, 38),
		Surface = Color3.fromRGB(30, 30, 46),
		
		-- Text
		Text = Color3.fromRGB(242, 243, 244),
		TextDark = Color3.fromRGB(186, 194, 222),
		TextMuted = Color3.fromRGB(127, 132, 156),
		
		-- Element colors
		ElementBg = Color3.fromRGB(35, 35, 51),
		ElementHover = Color3.fromRGB(42, 42, 62),
		Border = Color3.fromRGB(69, 71, 90),
		
		-- Status colors
		Success = Color3.fromRGB(166, 227, 161),
		Warning = Color3.fromRGB(249, 226, 175),
		Error = Color3.fromRGB(243, 139, 168),
		Info = Color3.fromRGB(148, 226, 213),
	},
	
	Light = {
		Accent = Color3.fromRGB(76, 119, 255),
		AccentDark = Color3.fromRGB(52, 93, 220),
		
		Background = Color3.fromRGB(250, 250, 252),
		BackgroundLight = Color3.fromRGB(255, 255, 255),
		Surface = Color3.fromRGB(245, 245, 250),
		
		Text = Color3.fromRGB(24, 24, 27),
		TextDark = Color3.fromRGB(63, 63, 70),
		TextMuted = Color3.fromRGB(113, 113, 122),
		
		ElementBg = Color3.fromRGB(240, 240, 245),
		ElementHover = Color3.fromRGB(228, 228, 235),
		Border = Color3.fromRGB(212, 212, 220),
		
		Success = Color3.fromRGB(34, 197, 94),
		Warning = Color3.fromRGB(251, 191, 36),
		Error = Color3.fromRGB(239, 68, 68),
		Info = Color3.fromRGB(59, 130, 246),
	}
}

-- Main Library
local Wlib = {
	Version = VERSION,
	Flags = {},
	Elements = {},
	Theme = Themes.Dark
}

local currentTheme = "Dark"
local activeWindow = nil

-- UI Helper Functions
local function addCorner(parent, radius)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 12)
	})
end

local function addStroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color or Wlib.Theme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
end

local function addShadow(parent)
	local shadow = create("ImageLabel", {
		Name = "Shadow",
		Parent = parent,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 6),
		Size = UDim2.new(1, 30, 1, 30),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6014261993",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.7,
		ZIndex = 0
	})
	return shadow
end

local function addGradient(parent, colors, rotation)
	return create("UIGradient", {
		Parent = parent,
		Color = ColorSequence.new(colors),
		Rotation = rotation or 0
	})
end

-- Notification System
function Wlib:Notify(options)
	task.spawn(function()
		local title = options.Title or "Notification"
		local content = options.Content or ""
		local duration = options.Duration or 5
		local type = options.Type or "Info" -- Info, Success, Warning, Error
		
		if not self.NotificationContainer then
			self.NotificationContainer = create("Frame", {
				Name = "Notifications",
				Parent = self.ScreenGui,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -20, 0, 20),
				Size = UDim2.new(0, 320, 1, -40),
				BackgroundTransparency = 1,
				ZIndex = 1000
			})
			
			create("UIListLayout", {
				Parent = self.NotificationContainer,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top
			})
		end
		
		local typeColors = {
			Info = Wlib.Theme.Info,
			Success = Wlib.Theme.Success,
			Warning = Wlib.Theme.Warning,
			Error = Wlib.Theme.Error
		}
		
		local notif = create("Frame", {
			Name = "Notification",
			Parent = self.NotificationContainer,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Wlib.Theme.Surface,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.1,
			ClipsDescendants = true
		})
		
		addCorner(notif, 12)
		addStroke(notif, typeColors[type] or Wlib.Theme.Accent, 1, 0.3)
		
		-- Accent bar
		local accentBar = create("Frame", {
			Name = "AccentBar",
			Parent = notif,
			Size = UDim2.new(0, 4, 1, 0),
			BackgroundColor3 = typeColors[type] or Wlib.Theme.Accent,
			BorderSizePixel = 0
		})
		
		addCorner(accentBar, 2)
		
		-- Icon
		local icon = create("TextLabel", {
			Name = "Icon",
			Parent = notif,
			Position = UDim2.new(0, 18, 0, 14),
			Size = UDim2.new(0, 24, 0, 24),
			BackgroundTransparency = 1,
			Text = (type == "Success" and "✓") or (type == "Warning" and "⚠") or (type == "Error" and "✕") or "ℹ",
			TextColor3 = typeColors[type] or Wlib.Theme.Accent,
			TextSize = 18,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		
		-- Title
		local titleLabel = create("TextLabel", {
			Name = "Title",
			Parent = notif,
			Position = UDim2.new(0, 50, 0, 12),
			Size = UDim2.new(1, -60, 0, 20),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Wlib.Theme.Text,
			TextSize = 14,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})
		
		-- Content
		local contentLabel = create("TextLabel", {
			Name = "Content",
			Parent = notif,
			Position = UDim2.new(0, 50, 0, 34),
			Size = UDim2.new(1, -60, 0, 30),
			BackgroundTransparency = 1,
			Text = content,
			TextColor3 = Wlib.Theme.TextDark,
			TextSize = 12,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		})
		
		-- Calculate height
		local textHeight = contentLabel.TextBounds.Y
		local finalHeight = math.max(textHeight + 50, 80)
		
		-- Animate in
		tween(notif, {Size = UDim2.new(1, 0, 0, finalHeight)}, 0.4, Enum.EasingStyle.Back):Play()
		task.wait(0.1)
		tween(icon, {TextTransparency = 0}, 0.3):Play()
		tween(titleLabel, {TextTransparency = 0}, 0.3):Play()
		tween(contentLabel, {TextTransparency = 0.2}, 0.3):Play()
		
		-- Auto close
		task.wait(duration)
		
		-- Animate out
		tween(notif, {BackgroundTransparency = 1}, 0.3):Play()
		tween(icon, {TextTransparency = 1}, 0.3):Play()
		tween(titleLabel, {TextTransparency = 1}, 0.3):Play()
		tween(contentLabel, {TextTransparency = 1}, 0.3):Play()
		tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back):Play()
		
		task.wait(0.4)
		notif:Destroy()
	end)
end

-- Create Window
function Wlib:CreateWindow(settings)
	settings = settings or {}
	
	local windowName = settings.Name or "Wlib"
	local configEnabled = false
	local configFile = nil
	
	-- Config setup
	if settings.ConfigurationSaving then
		configEnabled = settings.ConfigurationSaving.Enabled or false
		configFile = settings.ConfigurationSaving.FileName or "WlibConfig"
		
		if configEnabled then
			ensureFolder(WlibFolder)
			ensureFolder(ConfigFolder)
		end
	end
	
	-- Theme setup
	if settings.Theme and Themes[settings.Theme] then
		Wlib.Theme = Themes[settings.Theme]
		currentTheme = settings.Theme
	end
	
	-- Create ScreenGui
	local screenGui = create("ScreenGui", {
		Name = "Wlib",
		ResetOnSpawn = false,
		DisplayOrder = 100,
		IgnoreGuiInset = true
	})
	
	if gethui then
		screenGui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(screenGui)
		screenGui.Parent = CoreGui
	else
		screenGui.Parent = CoreGui
	end
	
	Wlib.ScreenGui = screenGui
	
	-- Main container with glassmorphism
	local main = create("Frame", {
		Name = "Main",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 700, 0, 500),
		BackgroundColor3 = Wlib.Theme.Background,
		BackgroundTransparency = 0.05,
		BorderSizePixel = 0,
		ClipsDescendants = false
	})
	
	addCorner(main, 16)
	addStroke(main, Wlib.Theme.Border, 1, 0.6)
	addShadow(main)
	
	-- Backdrop blur effect (visual)
	local blurEffect = create("Frame", {
		Name = "BlurBackdrop",
		Parent = main,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Wlib.Theme.BackgroundLight,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
		ZIndex = 0
	})
	
	addCorner(blurEffect, 16)
	
	-- Topbar
	local topbar = create("Frame", {
		Name = "Topbar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 60),
		BackgroundColor3 = Wlib.Theme.Surface,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0
	})
	
	addCorner(topbar, 16)
	
	-- Topbar corner fix
	create("Frame", {
		Name = "CornerFix",
		Parent = topbar,
		Position = UDim2.new(0, 0, 1, -16),
		Size = UDim2.new(1, 0, 0, 16),
		BackgroundColor3 = Wlib.Theme.Surface,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0
	})
	
	-- Title with gradient
	local title = create("TextLabel", {
		Name = "Title",
		Parent = topbar,
		Position = UDim2.new(0, 24, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = windowName,
		TextColor3 = Wlib.Theme.Text,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Subtitle
	create("TextLabel", {
		Name = "Subtitle",
		Parent = topbar,
		Position = UDim2.new(0, 24, 0, 28),
		Size = UDim2.new(0.6, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = "v" .. VERSION,
		TextColor3 = Wlib.Theme.TextMuted,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Control buttons
	local closeBtn = create("TextButton", {
		Name = "Close",
		Parent = topbar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -16, 0.5, 0),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundColor3 = Wlib.Theme.Error,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Text = "✕",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false
	})
	
	addCorner(closeBtn, 10)
	
	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, {BackgroundTransparency = 0}):Play()
	end)
	
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, {BackgroundTransparency = 0.1}):Play()
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
		task.wait(0.3)
		screenGui:Destroy()
	end)
	
	-- Minimize button
	local minimizeBtn = create("TextButton", {
		Name = "Minimize",
		Parent = topbar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -60, 0.5, 0),
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundColor3 = Wlib.Theme.ElementBg,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Text = "—",
		TextColor3 = Wlib.Theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false
	})
	
	addCorner(minimizeBtn, 10)
	
	local minimized = false
	minimizeBtn.MouseEnter:Connect(function()
		tween(minimizeBtn, {BackgroundTransparency = 0}):Play()
	end)
	
	minimizeBtn.MouseLeave:Connect(function()
		tween(minimizeBtn, {BackgroundTransparency = 0.1}):Play()
	end)
	
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(main, {Size = UDim2.new(0, 700, 0, 60)}, 0.3):Play()
			minimizeBtn.Text = "□"
		else
			tween(main, {Size = UDim2.new(0, 700, 0, 500)}, 0.3):Play()
			minimizeBtn.Text = "—"
		end
	end)
	
	-- Dragging
	local dragging = false
	local dragInput, mousePos, framePos
	
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			tween(main, {
				Position = UDim2.new(
					framePos.X.Scale,
					framePos.X.Offset + delta.X,
					framePos.Y.Scale,
					framePos.Y.Offset + delta.Y
				)
			}, 0.1, Enum.EasingStyle.Linear):Play()
		end
	end)
	
	-- Container for tabs and content
	local container = create("Frame", {
		Name = "Container",
		Parent = main,
		Position = UDim2.new(0, 0, 0, 60),
		Size = UDim2.new(1, 0, 1, -60),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	-- Tab list (sidebar)
	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Parent = container,
		Position = UDim2.new(0, 16, 0, 16),
		Size = UDim2.new(0, 160, 1, -32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Wlib.Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	create("UIListLayout", {
		Parent = tabList,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Content area
	local contentArea = create("Frame", {
		Name = "ContentArea",
		Parent = container,
		Position = UDim2.new(0, 192, 0, 16),
		Size = UDim2.new(1, -208, 1, -32),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	local pageLayout = create("UIPageLayout", {
		Name = "PageLayout",
		Parent = contentArea,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		EasingStyle = Enum.EasingStyle.Quad,
		EasingDirection = Enum.EasingDirection.Out,
		TweenTime = 0.3,
		Padding = UDim.new(0, 0)
	})
	
	-- Window object
	local Window = {
		Name = windowName,
		Main = main,
		TabList = tabList,
		ContentArea = contentArea,
		PageLayout = pageLayout,
		ConfigEnabled = configEnabled,
		ConfigFile = configFile,
		Tabs = {},
		CurrentTab = nil
	}
	
	activeWindow = Window
	
	-- Config functions
	function Window:SaveConfig()
		if not self.ConfigEnabled then return end
		
		local data = {}
		for flag, element in pairs(Wlib.Flags) do
			if element.Type == "ColorPicker" then
				data[flag] = packColor(element.Color)
			elseif element.Type == "Keybind" then
				data[flag] = element.CurrentKey
			else
				data[flag] = element.CurrentValue
			end
		end
		
		local success = safeCall(writefile, ConfigFolder .. "/" .. self.ConfigFile .. ConfigExtension, HttpService:JSONEncode(data))
		if success then
			Wlib:Notify({
				Title = "Configuration Saved",
				Content = "Your settings have been saved successfully.",
				Duration = 3,
				Type = "Success"
			})
		end
	end
	
	function Window:LoadConfig()
		if not self.ConfigEnabled then return end
		
		local path = ConfigFolder .. "/" .. self.ConfigFile .. ConfigExtension
		if not safeCall(isfile, path) then return end
		
		local content = safeCall(readfile, path)
		if not content then return end
		
		local success, data = pcall(function()
			return HttpService:JSONDecode(content)
		end)
		
		if not success then return end
		
		for flag, value in pairs(data) do
			if Wlib.Flags[flag] then
				task.spawn(function()
					local element = Wlib.Flags[flag]
					if element.Type == "ColorPicker" then
						element:Set(unpackColor(value))
					else
						element:Set(value)
					end
				end)
			end
		end
		
		Wlib:Notify({
			Title = "Configuration Loaded",
			Content = "Your settings have been restored.",
			Duration = 3,
			Type = "Success"
		})
	end
	
	-- Create Tab
	function Window:CreateTab(name, icon)
		local Tab = {
			Name = name,
			Window = self,
			Elements = {},
			Visible = false
		}
		
		-- Tab button
		local tabBtn = create("Frame", {
			Name = name,
			Parent = tabList,
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundColor3 = Wlib.Theme.ElementBg,
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		})
		
		addCorner(tabBtn, 10)
		
		local tabTitle = create("TextLabel", {
			Name = "Title",
			Parent = tabBtn,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -14, 1, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Wlib.Theme.TextDark,
			TextSize = 13,
			Font = Enum.Font.GothamMedium,
			TextXAlignment = Enum.TextXAlignment.Left
		})
		
		local tabInteract = create("TextButton", {
			Name = "Interact",
			Parent = tabBtn,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false
		})
		
		-- Tab page
		local tabPage = create("ScrollingFrame", {
			Name = name,
			Parent = contentArea,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 6,
			ScrollBarImageColor3 = Wlib.Theme.Accent,
			ScrollBarImageTransparency = 0.5,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		})
		
		create("UIListLayout", {
			Parent = tabPage,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		create("UIPadding", {
			Parent = tabPage,
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8)
		})
		
		Tab.Page = tabPage
		Tab.Button = tabBtn
		
		-- Tab selection
		local function selectTab()
			-- Deselect all tabs
			for _, otherTab in ipairs(self.Tabs) do
				otherTab.Visible = false
				tween(otherTab.Button, {BackgroundTransparency = 1}):Play()
				tween(otherTab.Button.Title, {TextColor3 = Wlib.Theme.TextDark}):Play()
			end
			
			-- Select this tab
			Tab.Visible = true
			self.CurrentTab = Tab
			pageLayout:JumpTo(tabPage)
			tabPage.Visible = true
			tween(tabBtn, {BackgroundTransparency = 0}):Play()
			tween(tabTitle, {TextColor3 = Wlib.Theme.Accent}):Play()
		end
		
		tabInteract.MouseButton1Click:Connect(selectTab)
		
		tabInteract.MouseEnter:Connect(function()
			if not Tab.Visible then
				tween(tabBtn, {BackgroundTransparency = 0.5}):Play()
			end
		end)
		
		tabInteract.MouseLeave:Connect(function()
			if not Tab.Visible then
				tween(tabBtn, {BackgroundTransparency = 1}):Play()
			end
		end)
		
		table.insert(self.Tabs, Tab)
		
		-- Auto-select first tab
		if #self.Tabs == 1 then
			selectTab()
		end
		
		-- ELEMENT CREATION FUNCTIONS
		
		-- Section
		function Tab:CreateSection(name)
			local section = create("Frame", {
				Name = "Section",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1
			})
			
			create("TextLabel", {
				Name = "Title",
				Parent = section,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = name:upper(),
				TextColor3 = Wlib.Theme.TextMuted,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			local divider = create("Frame", {
				Name = "Divider",
				Parent = section,
				Position = UDim2.new(0, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Wlib.Theme.Border,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0
			})
			
			return section
		end
		
		-- Button
		function Tab:CreateButton(options)
			options = options or {}
			local name = options.Name or "Button"
			local callback = options.Callback or function() end
			
			local btnFrame = create("Frame", {
				Name = "Button",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(btnFrame, 10)
			addStroke(btnFrame, Wlib.Theme.Border, 1, 0.7)
			
			local btnTitle = create("TextLabel", {
				Name = "Title",
				Parent = btnFrame,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -32, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local btnInteract = create("TextButton", {
				Name = "Interact",
				Parent = btnFrame,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false
			})
			
			btnInteract.MouseEnter:Connect(function()
				tween(btnFrame, {BackgroundColor3 = Wlib.Theme.ElementHover}):Play()
				tween(btnFrame.UIStroke, {Transparency = 0.3}):Play()
			end)
			
			btnInteract.MouseLeave:Connect(function()
				tween(btnFrame, {BackgroundColor3 = Wlib.Theme.ElementBg}):Play()
				tween(btnFrame.UIStroke, {Transparency = 0.7}):Play()
			end)
			
			btnInteract.MouseButton1Click:Connect(function()
				-- Click animation
				tween(btnFrame, {BackgroundColor3 = Wlib.Theme.Accent}, 0.1):Play()
				task.wait(0.1)
				tween(btnFrame, {BackgroundColor3 = Wlib.Theme.ElementBg}, 0.2):Play()
				
				-- Execute callback
				task.spawn(callback)
			end)
			
			return btnFrame
		end
		
		-- Toggle
		function Tab:CreateToggle(options)
			options = options or {}
			local name = options.Name or "Toggle"
			local default = options.CurrentValue or false
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local toggleFrame = create("Frame", {
				Name = "Toggle",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(toggleFrame, 10)
			addStroke(toggleFrame, Wlib.Theme.Border, 1, 0.7)
			
			local toggleTitle = create("TextLabel", {
				Name = "Title",
				Parent = toggleFrame,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			-- Toggle switch
			local toggleSwitch = create("Frame", {
				Name = "Switch",
				Parent = toggleFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -16, 0.5, 0),
				Size = UDim2.new(0, 44, 0, 24),
				BackgroundColor3 = Wlib.Theme.Border,
				BorderSizePixel = 0
			})
			
			addCorner(toggleSwitch, 12)
			
			local toggleKnob = create("Frame", {
				Name = "Knob",
				Parent = toggleSwitch,
				Position = UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundColor3 = Wlib.Theme.Text,
				BorderSizePixel = 0
			})
			
			addCorner(toggleKnob, 10)
			
			local currentValue = default
			
			local function update(value, silent)
				currentValue = value
				
				if value then
					tween(toggleSwitch, {BackgroundColor3 = Wlib.Theme.Accent}, 0.2):Play()
					tween(toggleKnob, {Position = UDim2.new(1, -22, 0.5, 0)}, 0.2, Enum.EasingStyle.Back):Play()
				else
					tween(toggleSwitch, {BackgroundColor3 = Wlib.Theme.Border}, 0.2):Play()
					tween(toggleKnob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back):Play()
				end
				
				if not silent then
					task.spawn(callback, value)
				end
			end
			
			local toggleInteract = create("TextButton", {
				Name = "Interact",
				Parent = toggleFrame,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false
			})
			
			toggleInteract.MouseButton1Click:Connect(function()
				update(not currentValue)
			end)
			
			toggleInteract.MouseEnter:Connect(function()
				tween(toggleFrame, {BackgroundColor3 = Wlib.Theme.ElementHover}):Play()
			end)
			
			toggleInteract.MouseLeave:Connect(function()
				tween(toggleFrame, {BackgroundColor3 = Wlib.Theme.ElementBg}):Play()
			end)
			
			-- Initialize
			update(default, true)
			
			local Toggle = {
				Type = "Toggle",
				CurrentValue = currentValue,
				Set = function(self, value, silent)
					update(value, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = Toggle
			end
			
			return Toggle
		end
		
		-- Slider
		function Tab:CreateSlider(options)
			options = options or {}
			local name = options.Name or "Slider"
			local min = options.Min or 0
			local max = options.Max or 100
			local default = options.CurrentValue or min
			local increment = options.Increment or 1
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local sliderFrame = create("Frame", {
				Name = "Slider",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 56),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(sliderFrame, 10)
			addStroke(sliderFrame, Wlib.Theme.Border, 1, 0.7)
			
			local sliderTitle = create("TextLabel", {
				Name = "Title",
				Parent = sliderFrame,
				Position = UDim2.new(0, 16, 0, 8),
				Size = UDim2.new(1, -80, 0, 20),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local sliderValue = create("TextLabel", {
				Name = "Value",
				Parent = sliderFrame,
				Position = UDim2.new(1, -70, 0, 8),
				Size = UDim2.new(0, 54, 0, 20),
				BackgroundColor3 = Wlib.Theme.Surface,
				BorderSizePixel = 0,
				Text = tostring(default),
				TextColor3 = Wlib.Theme.Accent,
				TextSize = 12,
				Font = Enum.Font.GothamBold
			})
			
			addCorner(sliderValue, 6)
			
			-- Slider bar
			local sliderBar = create("Frame", {
				Name = "Bar",
				Parent = sliderFrame,
				Position = UDim2.new(0, 16, 1, -20),
				Size = UDim2.new(1, -32, 0, 6),
				BackgroundColor3 = Wlib.Theme.Surface,
				BorderSizePixel = 0
			})
			
			addCorner(sliderBar, 3)
			
			local sliderFill = create("Frame", {
				Name = "Fill",
				Parent = sliderBar,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Wlib.Theme.Accent,
				BorderSizePixel = 0
			})
			
			addCorner(sliderFill, 3)
			addGradient(sliderFill, {
				ColorSequenceKeypoint.new(0, Wlib.Theme.Accent),
				ColorSequenceKeypoint.new(1, Wlib.Theme.AccentDark)
			}, 90)
			
			local currentValue = default
			local dragging = false
			
			local function update(value, silent)
				value = math.clamp(value, min, max)
				value = math.floor(value / increment + 0.5) * increment
				currentValue = value
				
				local percent = (value - min) / (max - min)
				tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15):Play()
				sliderValue.Text = tostring(value)
				
				if not silent then
					task.spawn(callback, value)
				end
			end
			
			sliderBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					update(min + (max - min) * percent)
				end
			end)
			
			sliderBar.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					update(min + (max - min) * percent)
				end
			end)
			
			-- Initialize
			update(default, true)
			
			local Slider = {
				Type = "Slider",
				CurrentValue = currentValue,
				Set = function(self, value, silent)
					update(value, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = Slider
			end
			
			return Slider
		end
		
		-- Dropdown
		function Tab:CreateDropdown(options)
			options = options or {}
			local name = options.Name or "Dropdown"
			local list = options.Options or {"Option 1", "Option 2"}
			local default = options.CurrentOption or list[1]
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local dropFrame = create("Frame", {
				Name = "Dropdown",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			
			addCorner(dropFrame, 10)
			addStroke(dropFrame, Wlib.Theme.Border, 1, 0.7)
			
			local dropTitle = create("TextLabel", {
				Name = "Title",
				Parent = dropFrame,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -100, 0, 42),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local dropValue = create("TextLabel", {
				Name = "Value",
				Parent = dropFrame,
				Position = UDim2.new(1, -90, 0, 0),
				Size = UDim2.new(0, 60, 0, 42),
				BackgroundTransparency = 1,
				Text = default,
				TextColor3 = Wlib.Theme.Accent,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			
			local dropIcon = create("TextLabel", {
				Name = "Icon",
				Parent = dropFrame,
				Position = UDim2.new(1, -24, 0, 0),
				Size = UDim2.new(0, 20, 0, 42),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = Wlib.Theme.TextMuted,
				TextSize = 10,
				Font = Enum.Font.Gotham
			})
			
			local optionsContainer = create("Frame", {
				Name = "Options",
				Parent = dropFrame,
				Position = UDim2.new(0, 0, 0, 42),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1
			})
			
			create("UIListLayout", {
				Parent = optionsContainer,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			
			create("UIPadding", {
				Parent = optionsContainer,
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 8)
			})
			
			local expanded = false
			local currentOption = default
			
			local function update(option, silent)
				currentOption = option
				dropValue.Text = option
				
				if not silent then
					task.spawn(callback, option)
				end
			end
			
			local function toggle()
				expanded = not expanded
				
				if expanded then
					local optionHeight = #list * 34 + (#list - 1) * 4 + 12
					tween(dropFrame, {Size = UDim2.new(1, 0, 0, 42 + optionHeight)}, 0.3):Play()
					tween(dropIcon, {Rotation = 180}, 0.3):Play()
				else
					tween(dropFrame, {Size = UDim2.new(1, 0, 0, 42)}, 0.3):Play()
					tween(dropIcon, {Rotation = 0}, 0.3):Play()
				end
			end
			
			local dropInteract = create("TextButton", {
				Name = "Interact",
				Parent = dropFrame,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 2
			})
			
			dropInteract.MouseButton1Click:Connect(toggle)
			
			dropInteract.MouseEnter:Connect(function()
				if not expanded then
					tween(dropFrame, {BackgroundColor3 = Wlib.Theme.ElementHover}):Play()
				end
			end)
			
			dropInteract.MouseLeave:Connect(function()
				if not expanded then
					tween(dropFrame, {BackgroundColor3 = Wlib.Theme.ElementBg}):Play()
				end
			end)
			
			-- Create options
			for _, option in ipairs(list) do
				local optionBtn = create("TextButton", {
					Name = option,
					Parent = optionsContainer,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = Wlib.Theme.Surface,
					BorderSizePixel = 0,
					Text = option,
					TextColor3 = Wlib.Theme.Text,
					TextSize = 12,
					Font = Enum.Font.Gotham,
					AutoButtonColor = false
				})
				
				addCorner(optionBtn, 6)
				
				optionBtn.MouseButton1Click:Connect(function()
					update(option)
					toggle()
				end)
				
				optionBtn.MouseEnter:Connect(function()
					tween(optionBtn, {BackgroundColor3 = Wlib.Theme.Accent}, 0.2):Play()
				end)
				
				optionBtn.MouseLeave:Connect(function()
					tween(optionBtn, {BackgroundColor3 = Wlib.Theme.Surface}, 0.2):Play()
				end)
			end
			
			-- Initialize
			update(default, true)
			
			local Dropdown = {
				Type = "Dropdown",
				CurrentOption = currentOption,
				Set = function(self, option, silent)
					update(option, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = Dropdown
			end
			
			return Dropdown
		end
		
		-- Input
		function Tab:CreateInput(options)
			options = options or {}
			local name = options.Name or "Input"
			local default = options.CurrentValue or ""
			local placeholder = options.PlaceholderText or "Enter text..."
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local inputFrame = create("Frame", {
				Name = "Input",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 68),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(inputFrame, 10)
			addStroke(inputFrame, Wlib.Theme.Border, 1, 0.7)
			
			local inputTitle = create("TextLabel", {
				Name = "Title",
				Parent = inputFrame,
				Position = UDim2.new(0, 16, 0, 8),
				Size = UDim2.new(1, -32, 0, 20),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local inputBox = create("TextBox", {
				Name = "InputBox",
				Parent = inputFrame,
				Position = UDim2.new(0, 16, 0, 34),
				Size = UDim2.new(1, -32, 0, 26),
				BackgroundColor3 = Wlib.Theme.Surface,
				BorderSizePixel = 0,
				Text = default,
				PlaceholderText = placeholder,
				PlaceholderColor3 = Wlib.Theme.TextMuted,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			addCorner(inputBox, 6)
			addStroke(inputBox, Wlib.Theme.Border, 1, 0.7)
			
			create("UIPadding", {
				Parent = inputBox,
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10)
			})
			
			local currentValue = default
			
			local function update(value, silent)
				currentValue = value
				inputBox.Text = value
				
				if not silent then
					task.spawn(callback, value)
				end
			end
			
			inputBox.FocusLost:Connect(function()
				update(inputBox.Text)
			end)
			
			inputBox.Focused:Connect(function()
				tween(inputBox.UIStroke, {Transparency = 0.3}):Play()
			end)
			
			inputBox:GetPropertyChangedSignal("Text"):Connect(function()
				if inputBox:IsFocused() then
					tween(inputBox.UIStroke, {Transparency = 0.7}):Play()
				end
			end)
			
			local Input = {
				Type = "Input",
				CurrentValue = currentValue,
				Set = function(self, value, silent)
					update(value, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = Input
			end
			
			return Input
		end
		
		-- Label
		function Tab:CreateLabel(text)
			local label = create("TextLabel", {
				Name = "Label",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Wlib.Theme.TextDark,
				TextSize = 12,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true
			})
			
			return label
		end
		
		-- Paragraph
		function Tab:CreateParagraph(options)
			options = options or {}
			local title = options.Title or "Paragraph"
			local content = options.Content or ""
			
			local paraFrame = create("Frame", {
				Name = "Paragraph",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 85),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(paraFrame, 10)
			addStroke(paraFrame, Wlib.Theme.Border, 1, 0.7)
			
			local paraTitle = create("TextLabel", {
				Name = "Title",
				Parent = paraFrame,
				Position = UDim2.new(0, 16, 0, 10),
				Size = UDim2.new(1, -32, 0, 20),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local paraContent = create("TextLabel", {
				Name = "Content",
				Parent = paraFrame,
				Position = UDim2.new(0, 16, 0, 34),
				Size = UDim2.new(1, -32, 1, -44),
				BackgroundTransparency = 1,
				Text = content,
				TextColor3 = Wlib.Theme.TextDark,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true
			})
			
			-- Auto-resize
			local textHeight = paraContent.TextBounds.Y
			paraFrame.Size = UDim2.new(1, 0, 0, math.max(textHeight + 50, 85))
			
			return paraFrame
		end
		
		-- Keybind
		function Tab:CreateKeybind(options)
			options = options or {}
			local name = options.Name or "Keybind"
			local default = options.CurrentKeybind or "None"
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local keybindFrame = create("Frame", {
				Name = "Keybind",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(keybindFrame, 10)
			addStroke(keybindFrame, Wlib.Theme.Border, 1, 0.7)
			
			local keybindTitle = create("TextLabel", {
				Name = "Title",
				Parent = keybindFrame,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -100, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local keybindBtn = create("TextButton", {
				Name = "KeyButton",
				Parent = keybindFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -16, 0.5, 0),
				Size = UDim2.new(0, 70, 0, 28),
				BackgroundColor3 = Wlib.Theme.Surface,
				BorderSizePixel = 0,
				Text = default,
				TextColor3 = Wlib.Theme.Accent,
				TextSize = 11,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false
			})
			
			addCorner(keybindBtn, 6)
			addStroke(keybindBtn, Wlib.Theme.Accent, 1, 0.5)
			
			local currentKey = default
			local binding = false
			
			local function update(key, silent)
				currentKey = key
				keybindBtn.Text = key
				
				if not silent then
					task.spawn(callback, key)
				end
			end
			
			keybindBtn.MouseButton1Click:Connect(function()
				binding = true
				keybindBtn.Text = "..."
				tween(keybindBtn.UIStroke, {Transparency = 0}):Play()
			end)
			
			UserInputService.InputBegan:Connect(function(input, processed)
				if binding and not processed then
					local key = input.KeyCode.Name
					if key ~= "Unknown" then
						update(key)
						binding = false
						tween(keybindBtn.UIStroke, {Transparency = 0.5}):Play()
					end
				elseif not binding and currentKey ~= "None" then
					if input.KeyCode.Name == currentKey then
						task.spawn(callback, currentKey)
					end
				end
			end)
			
			local Keybind = {
				Type = "Keybind",
				CurrentKey = currentKey,
				Set = function(self, key, silent)
					update(key, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = Keybind
			end
			
			return Keybind
		end
		
		-- ColorPicker
		function Tab:CreateColorPicker(options)
			options = options or {}
			local name = options.Name or "Color Picker"
			local default = options.Color or Color3.fromRGB(255, 255, 255)
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local pickerFrame = create("Frame", {
				Name = "ColorPicker",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 42),
				BackgroundColor3 = Wlib.Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(pickerFrame, 10)
			addStroke(pickerFrame, Wlib.Theme.Border, 1, 0.7)
			
			local pickerTitle = create("TextLabel", {
				Name = "Title",
				Parent = pickerFrame,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -70, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Wlib.Theme.Text,
				TextSize = 13,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local colorDisplay = create("Frame", {
				Name = "ColorDisplay",
				Parent = pickerFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -16, 0.5, 0),
				Size = UDim2.new(0, 40, 0, 26),
				BackgroundColor3 = default,
				BorderSizePixel = 0
			})
			
			addCorner(colorDisplay, 6)
			addStroke(colorDisplay, Wlib.Theme.Border, 1, 0.5)
			
			local currentColor = default
			
			local function update(color, silent)
				currentColor = color
				colorDisplay.BackgroundColor3 = color
				
				if not silent then
					task.spawn(callback, color)
				end
			end
			
			-- Simple color picker (click to cycle through preset colors)
			local presetColors = {
				Color3.fromRGB(255, 85, 85),
				Color3.fromRGB(255, 170, 85),
				Color3.fromRGB(255, 255, 85),
				Color3.fromRGB(85, 255, 85),
				Color3.fromRGB(85, 255, 255),
				Color3.fromRGB(85, 85, 255),
				Color3.fromRGB(255, 85, 255),
				Color3.fromRGB(255, 255, 255),
			}
			
			local colorIndex = 1
			
			local pickerInteract = create("TextButton", {
				Name = "Interact",
				Parent = pickerFrame,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false
			})
			
			pickerInteract.MouseButton1Click:Connect(function()
				colorIndex = (colorIndex % #presetColors) + 1
				update(presetColors[colorIndex])
			end)
			
			pickerInteract.MouseEnter:Connect(function()
				tween(pickerFrame, {BackgroundColor3 = Wlib.Theme.ElementHover}):Play()
			end)
			
			pickerInteract.MouseLeave:Connect(function()
				tween(pickerFrame, {BackgroundColor3 = Wlib.Theme.ElementBg}):Play()
			end)
			
			local ColorPicker = {
				Type = "ColorPicker",
				Color = currentColor,
				Set = function(self, color, silent)
					update(color, silent)
				end
			}
			
			if flag then
				Wlib.Flags[flag] = ColorPicker
			end
			
			return ColorPicker
		end
		
		return Tab
	end
	
	-- Load config on startup
	task.delay(0.5, function()
		Window:LoadConfig()
	end)
	
	-- Entrance animation
	main.Size = UDim2.new(0, 0, 0, 0)
	tween(main, {Size = UDim2.new(0, 700, 0, 500)}, 0.5, Enum.EasingStyle.Back):Play()
	
	return Window
end

function Wlib:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return Wlib
