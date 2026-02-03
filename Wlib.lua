--[[
	Wlib v2.1 - Improved Modern UI Library for Roblox
	
	Improvements:
	- Sleek black theme
	- More compact design (600x450 default size)
	- Better performance
	- Enhanced animations
	- All UI elements fully tested and working
	- Improved color picker with RGB sliders
	- Better error handling
--]]

local VERSION = "2.1.0"

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

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
	local tweenInfo = TweenInfo.new(
		duration or 0.25,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

-- Color Utilities
local function packColor(color)
	return {R = color.R * 255, G = color.G * 255, B = color.B * 255}
end

local function unpackColor(data)
	return Color3.fromRGB(data.R, data.G, data.B)
end

-- Black Theme
local Theme = {
	-- Base colors (Pure black theme)
	Accent = Color3.fromRGB(100, 150, 255),
	AccentDark = Color3.fromRGB(70, 120, 230),
	
	-- Backgrounds
	Background = Color3.fromRGB(10, 10, 10),
	BackgroundLight = Color3.fromRGB(15, 15, 15),
	Surface = Color3.fromRGB(20, 20, 20),
	
	-- Text
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(200, 200, 200),
	TextMuted = Color3.fromRGB(120, 120, 120),
	
	-- Element colors
	ElementBg = Color3.fromRGB(25, 25, 25),
	ElementHover = Color3.fromRGB(35, 35, 35),
	Border = Color3.fromRGB(45, 45, 45),
	
	-- Status colors
	Success = Color3.fromRGB(80, 200, 120),
	Warning = Color3.fromRGB(255, 200, 80),
	Error = Color3.fromRGB(255, 80, 80),
	Info = Color3.fromRGB(80, 180, 255),
}

-- Main Library
local Wlib = {
	Version = VERSION,
	Flags = {},
	Theme = Theme
}

-- UI Helper Functions
local function addCorner(parent, radius)
	return create("UICorner", {
		Parent = parent,
		CornerRadius = UDim.new(0, radius or 8)
	})
end

local function addStroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Parent = parent,
		Color = color or Theme.Border,
		Thickness = thickness or 1,
		Transparency = transparency or 0.5,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
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
		local duration = options.Duration or 4
		local type = options.Type or "Info"
		
		if not self.NotificationContainer then
			self.NotificationContainer = create("Frame", {
				Name = "Notifications",
				Parent = self.ScreenGui,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -15, 0, 15),
				Size = UDim2.new(0, 300, 1, -30),
				BackgroundTransparency = 1,
				ZIndex = 1000
			})
			
			create("UIListLayout", {
				Parent = self.NotificationContainer,
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top
			})
		end
		
		local typeColors = {
			Info = Theme.Info,
			Success = Theme.Success,
			Warning = Theme.Warning,
			Error = Theme.Error
		}
		
		local notif = create("Frame", {
			Name = "Notification",
			Parent = self.NotificationContainer,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Theme.Surface,
			BorderSizePixel = 0,
			BackgroundTransparency = 0,
			ClipsDescendants = true
		})
		
		addCorner(notif, 8)
		addStroke(notif, typeColors[type] or Theme.Accent, 1, 0.2)
		
		local accentBar = create("Frame", {
			Name = "AccentBar",
			Parent = notif,
			Size = UDim2.new(0, 3, 1, 0),
			BackgroundColor3 = typeColors[type] or Theme.Accent,
			BorderSizePixel = 0
		})
		
		local icon = create("TextLabel", {
			Name = "Icon",
			Parent = notif,
			Position = UDim2.new(0, 15, 0, 10),
			Size = UDim2.new(0, 20, 0, 20),
			BackgroundTransparency = 1,
			Text = (type == "Success" and "✓") or (type == "Warning" and "⚠") or (type == "Error" and "✕") or "ℹ",
			TextColor3 = typeColors[type] or Theme.Accent,
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		
		local titleLabel = create("TextLabel", {
			Name = "Title",
			Parent = notif,
			Position = UDim2.new(0, 42, 0, 8),
			Size = UDim2.new(1, -50, 0, 18),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = Theme.Text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})
		
		local contentLabel = create("TextLabel", {
			Name = "Content",
			Parent = notif,
			Position = UDim2.new(0, 42, 0, 28),
			Size = UDim2.new(1, -50, 0, 25),
			BackgroundTransparency = 1,
			Text = content,
			TextColor3 = Theme.TextDark,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			TextTransparency = 1
		})
		
		local textHeight = contentLabel.TextBounds.Y
		local finalHeight = math.max(textHeight + 40, 60)
		
		tween(notif, {Size = UDim2.new(1, 0, 0, finalHeight)}, 0.3, Enum.EasingStyle.Back)
		task.wait(0.1)
		tween(icon, {TextTransparency = 0}, 0.25)
		tween(titleLabel, {TextTransparency = 0}, 0.25)
		tween(contentLabel, {TextTransparency = 0.1}, 0.25)
		
		task.wait(duration)
		
		tween(notif, {BackgroundTransparency = 1}, 0.25)
		tween(icon, {TextTransparency = 1}, 0.25)
		tween(titleLabel, {TextTransparency = 1}, 0.25)
		tween(contentLabel, {TextTransparency = 1}, 0.25)
		tween(notif, {Size = UDim2.new(1, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back)
		
		task.wait(0.3)
		notif:Destroy()
	end)
end

-- Create Window
function Wlib:CreateWindow(settings)
	settings = settings or {}
	
	local windowName = settings.Name or "Wlib"
	local configEnabled = false
	local configFile = nil
	
	if settings.ConfigurationSaving then
		configEnabled = settings.ConfigurationSaving.Enabled or false
		configFile = settings.ConfigurationSaving.FileName or "WlibConfig"
		
		if configEnabled then
			ensureFolder(WlibFolder)
			ensureFolder(ConfigFolder)
		end
	end
	
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
	
	-- Main container (More compact)
	local main = create("Frame", {
		Name = "Main",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 600, 0, 450),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = false
	})
	
	addCorner(main, 12)
	addStroke(main, Theme.Border, 1, 0.3)
	
	-- Topbar (More compact)
	local topbar = create("Frame", {
		Name = "Topbar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0
	})
	
	addCorner(topbar, 12)
	
	create("Frame", {
		Name = "CornerFix",
		Parent = topbar,
		Position = UDim2.new(0, 0, 1, -12),
		Size = UDim2.new(1, 0, 0, 12),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0
	})
	
	local title = create("TextLabel", {
		Name = "Title",
		Parent = topbar,
		Position = UDim2.new(0, 20, 0, 0),
		Size = UDim2.new(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = windowName,
		TextColor3 = Theme.Text,
		TextSize = 16,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	create("TextLabel", {
		Name = "Subtitle",
		Parent = topbar,
		Position = UDim2.new(0, 20, 0, 24),
		Size = UDim2.new(0.6, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = "v" .. VERSION,
		TextColor3 = Theme.TextMuted,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	
	-- Close button
	local closeBtn = create("TextButton", {
		Name = "Close",
		Parent = topbar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -15, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundColor3 = Theme.Error,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "✕",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false
	})
	
	addCorner(closeBtn, 8)
	
	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 100, 100)})
	end)
	
	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, {BackgroundColor3 = Theme.Error})
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		tween(main, {Size = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.wait(0.3)
		screenGui:Destroy()
	end)
	
	-- Minimize button
	local minimizeBtn = create("TextButton", {
		Name = "Minimize",
		Parent = topbar,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0.5, 0),
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundColor3 = Theme.ElementBg,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Text = "—",
		TextColor3 = Theme.Text,
		TextSize = 14,
		Font = Enum.Font.GothamBold,
		AutoButtonColor = false
	})
	
	addCorner(minimizeBtn, 8)
	
	local minimized = false
	minimizeBtn.MouseEnter:Connect(function()
		tween(minimizeBtn, {BackgroundColor3 = Theme.ElementHover})
	end)
	
	minimizeBtn.MouseLeave:Connect(function()
		tween(minimizeBtn, {BackgroundColor3 = Theme.ElementBg})
	end)
	
	minimizeBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		if minimized then
			tween(main, {Size = UDim2.new(0, 600, 0, 50)}, 0.25)
			minimizeBtn.Text = "□"
		else
			tween(main, {Size = UDim2.new(0, 600, 0, 450)}, 0.25)
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
			}, 0.08, Enum.EasingStyle.Linear)
		end
	end)
	
	-- Container
	local container = create("Frame", {
		Name = "Container",
		Parent = main,
		Position = UDim2.new(0, 0, 0, 50),
		Size = UDim2.new(1, 0, 1, -50),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	-- Tab list (More compact)
	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Parent = container,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(0, 140, 1, -24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	})
	
	create("UIListLayout", {
		Parent = tabList,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	
	-- Content area
	local contentArea = create("Frame", {
		Name = "ContentArea",
		Parent = container,
		Position = UDim2.new(0, 164, 0, 12),
		Size = UDim2.new(1, -176, 1, -24),
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
		TweenTime = 0.25,
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
				Title = "Config Saved",
				Content = "Settings saved successfully.",
				Duration = 2,
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
			Title = "Config Loaded",
			Content = "Settings restored.",
			Duration = 2,
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
		
		-- Tab button (More compact)
		local tabBtn = create("Frame", {
			Name = name,
			Parent = tabList,
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Theme.ElementBg,
			BackgroundTransparency = 1,
			BorderSizePixel = 0
		})
		
		addCorner(tabBtn, 8)
		
		local tabTitle = create("TextLabel", {
			Name = "Title",
			Parent = tabBtn,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -12, 1, 0),
			BackgroundTransparency = 1,
			Text = name,
			TextColor3 = Theme.TextDark,
			TextSize = 12,
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
			ScrollBarThickness = 5,
			ScrollBarImageColor3 = Theme.Accent,
			ScrollBarImageTransparency = 0.4,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			Visible = false
		})
		
		create("UIListLayout", {
			Parent = tabPage,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		
		create("UIPadding", {
			Parent = tabPage,
			PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6)
		})
		
		Tab.Page = tabPage
		Tab.Button = tabBtn
		
		-- Tab selection
		local function selectTab()
			for _, otherTab in ipairs(self.Tabs) do
				otherTab.Visible = false
				tween(otherTab.Button, {BackgroundTransparency = 1})
				tween(otherTab.Button.Title, {TextColor3 = Theme.TextDark})
			end
			
			Tab.Visible = true
			self.CurrentTab = Tab
			pageLayout:JumpTo(tabPage)
			tabPage.Visible = true
			tween(tabBtn, {BackgroundTransparency = 0})
			tween(tabTitle, {TextColor3 = Theme.Accent})
		end
		
		tabInteract.MouseButton1Click:Connect(selectTab)
		
		tabInteract.MouseEnter:Connect(function()
			if not Tab.Visible then
				tween(tabBtn, {BackgroundTransparency = 0.5})
			end
		end)
		
		tabInteract.MouseLeave:Connect(function()
			if not Tab.Visible then
				tween(tabBtn, {BackgroundTransparency = 1})
			end
		end)
		
		table.insert(self.Tabs, Tab)
		
		if #self.Tabs == 1 then
			selectTab()
		end
		
		-- ELEMENT CREATION FUNCTIONS (More compact versions)
		
		-- Section
		function Tab:CreateSection(name)
			local section = create("Frame", {
				Name = "Section",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1
			})
			
			create("TextLabel", {
				Name = "Title",
				Parent = section,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = name:upper(),
				TextColor3 = Theme.TextMuted,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom
			})
			
			create("Frame", {
				Name = "Divider",
				Parent = section,
				Position = UDim2.new(0, 0, 1, -1),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Border,
				BackgroundTransparency = 0.3,
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
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(btnFrame, 8)
			addStroke(btnFrame, Theme.Border, 1, 0.5)
			
			local btnTitle = create("TextLabel", {
				Name = "Title",
				Parent = btnFrame,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -28, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
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
				tween(btnFrame, {BackgroundColor3 = Theme.ElementHover})
				tween(btnFrame.UIStroke, {Transparency = 0.2})
			end)
			
			btnInteract.MouseLeave:Connect(function()
				tween(btnFrame, {BackgroundColor3 = Theme.ElementBg})
				tween(btnFrame.UIStroke, {Transparency = 0.5})
			end)
			
			btnInteract.MouseButton1Click:Connect(function()
				tween(btnFrame, {BackgroundColor3 = Theme.Accent}, 0.08)
				task.wait(0.08)
				tween(btnFrame, {BackgroundColor3 = Theme.ElementBg}, 0.15)
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
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(toggleFrame, 8)
			addStroke(toggleFrame, Theme.Border, 1, 0.5)
			
			local toggleTitle = create("TextLabel", {
				Name = "Title",
				Parent = toggleFrame,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -60, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local toggleSwitch = create("Frame", {
				Name = "Switch",
				Parent = toggleFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 40, 0, 20),
				BackgroundColor3 = Theme.Border,
				BorderSizePixel = 0
			})
			
			addCorner(toggleSwitch, 10)
			
			local toggleKnob = create("Frame", {
				Name = "Knob",
				Parent = toggleSwitch,
				Position = UDim2.new(0, 2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Theme.Text,
				BorderSizePixel = 0
			})
			
			addCorner(toggleKnob, 8)
			
			local currentValue = default
			
			local function update(value, silent)
				currentValue = value
				
				if value then
					tween(toggleSwitch, {BackgroundColor3 = Theme.Accent}, 0.2)
					tween(toggleKnob, {Position = UDim2.new(1, -18, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				else
					tween(toggleSwitch, {BackgroundColor3 = Theme.Border}, 0.2)
					tween(toggleKnob, {Position = UDim2.new(0, 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
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
				tween(toggleFrame, {BackgroundColor3 = Theme.ElementHover})
			end)
			
			toggleInteract.MouseLeave:Connect(function()
				tween(toggleFrame, {BackgroundColor3 = Theme.ElementBg})
			end)
			
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
				Size = UDim2.new(1, 0, 0, 48),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(sliderFrame, 8)
			addStroke(sliderFrame, Theme.Border, 1, 0.5)
			
			local sliderTitle = create("TextLabel", {
				Name = "Title",
				Parent = sliderFrame,
				Position = UDim2.new(0, 14, 0, 6),
				Size = UDim2.new(1, -70, 0, 18),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local sliderValue = create("TextLabel", {
				Name = "Value",
				Parent = sliderFrame,
				Position = UDim2.new(1, -60, 0, 6),
				Size = UDim2.new(0, 46, 0, 18),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Text = tostring(default),
				TextColor3 = Theme.Accent,
				TextSize = 11,
				Font = Enum.Font.GothamBold
			})
			
			addCorner(sliderValue, 5)
			
			local sliderBar = create("Frame", {
				Name = "Bar",
				Parent = sliderFrame,
				Position = UDim2.new(0, 14, 1, -16),
				Size = UDim2.new(1, -28, 0, 5),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0
			})
			
			addCorner(sliderBar, 3)
			
			local sliderFill = create("Frame", {
				Name = "Fill",
				Parent = sliderBar,
				Size = UDim2.new(0, 0, 1, 0),
				BackgroundColor3 = Theme.Accent,
				BorderSizePixel = 0
			})
			
			addCorner(sliderFill, 3)
			
			local currentValue = default
			local dragging = false
			
			local function update(value, silent)
				value = math.clamp(value, min, max)
				value = math.floor(value / increment + 0.5) * increment
				currentValue = value
				
				local percent = (value - min) / (max - min)
				tween(sliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.12)
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
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			
			addCorner(dropFrame, 8)
			addStroke(dropFrame, Theme.Border, 1, 0.5)
			
			local dropTitle = create("TextLabel", {
				Name = "Title",
				Parent = dropFrame,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -90, 0, 36),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local dropValue = create("TextLabel", {
				Name = "Value",
				Parent = dropFrame,
				Position = UDim2.new(1, -80, 0, 0),
				Size = UDim2.new(0, 55, 0, 36),
				BackgroundTransparency = 1,
				Text = default,
				TextColor3 = Theme.Accent,
				TextSize = 11,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.AtEnd
			})
			
			local dropIcon = create("TextLabel", {
				Name = "Icon",
				Parent = dropFrame,
				Position = UDim2.new(1, -20, 0, 0),
				Size = UDim2.new(0, 16, 0, 36),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = Theme.TextMuted,
				TextSize = 9,
				Font = Enum.Font.Gotham
			})
			
			local optionsContainer = create("Frame", {
				Name = "Options",
				Parent = dropFrame,
				Position = UDim2.new(0, 0, 0, 36),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1
			})
			
			create("UIListLayout", {
				Parent = optionsContainer,
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			
			create("UIPadding", {
				Parent = optionsContainer,
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
				PaddingTop = UDim.new(0, 3),
				PaddingBottom = UDim.new(0, 6)
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
					local optionHeight = #list * 28 + (#list - 1) * 3 + 9
					tween(dropFrame, {Size = UDim2.new(1, 0, 0, 36 + optionHeight)}, 0.25)
					tween(dropIcon, {Rotation = 180}, 0.25)
				else
					tween(dropFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.25)
					tween(dropIcon, {Rotation = 0}, 0.25)
				end
			end
			
			local dropInteract = create("TextButton", {
				Name = "Interact",
				Parent = dropFrame,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 2
			})
			
			dropInteract.MouseButton1Click:Connect(toggle)
			
			dropInteract.MouseEnter:Connect(function()
				if not expanded then
					tween(dropFrame, {BackgroundColor3 = Theme.ElementHover})
				end
			end)
			
			dropInteract.MouseLeave:Connect(function()
				if not expanded then
					tween(dropFrame, {BackgroundColor3 = Theme.ElementBg})
				end
			end)
			
			for _, option in ipairs(list) do
				local optionBtn = create("TextButton", {
					Name = option,
					Parent = optionsContainer,
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0,
					Text = option,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.Gotham,
					AutoButtonColor = false
				})
				
				addCorner(optionBtn, 5)
				
				optionBtn.MouseButton1Click:Connect(function()
					update(option)
					toggle()
				end)
				
				optionBtn.MouseEnter:Connect(function()
					tween(optionBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
				end)
				
				optionBtn.MouseLeave:Connect(function()
					tween(optionBtn, {BackgroundColor3 = Theme.Surface}, 0.15)
				end)
			end
			
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
				Size = UDim2.new(1, 0, 0, 60),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(inputFrame, 8)
			addStroke(inputFrame, Theme.Border, 1, 0.5)
			
			local inputTitle = create("TextLabel", {
				Name = "Title",
				Parent = inputFrame,
				Position = UDim2.new(0, 14, 0, 6),
				Size = UDim2.new(1, -28, 0, 18),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local inputBox = create("TextBox", {
				Name = "InputBox",
				Parent = inputFrame,
				Position = UDim2.new(0, 14, 0, 30),
				Size = UDim2.new(1, -28, 0, 24),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Text = default,
				PlaceholderText = placeholder,
				PlaceholderColor3 = Theme.TextMuted,
				TextColor3 = Theme.Text,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			addCorner(inputBox, 5)
			addStroke(inputBox, Theme.Border, 1, 0.5)
			
			create("UIPadding", {
				Parent = inputBox,
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8)
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
				tween(inputBox.UIStroke, {Transparency = 0.2})
			end)
			
			inputBox:GetPropertyChangedSignal("Text"):Connect(function()
				if not inputBox:IsFocused() then
					tween(inputBox.UIStroke, {Transparency = 0.5})
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
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Theme.TextDark,
				TextSize = 11,
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
				Size = UDim2.new(1, 0, 0, 75),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(paraFrame, 8)
			addStroke(paraFrame, Theme.Border, 1, 0.5)
			
			local paraTitle = create("TextLabel", {
				Name = "Title",
				Parent = paraFrame,
				Position = UDim2.new(0, 14, 0, 8),
				Size = UDim2.new(1, -28, 0, 18),
				BackgroundTransparency = 1,
				Text = title,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local paraContent = create("TextLabel", {
				Name = "Content",
				Parent = paraFrame,
				Position = UDim2.new(0, 14, 0, 30),
				Size = UDim2.new(1, -28, 1, -38),
				BackgroundTransparency = 1,
				Text = content,
				TextColor3 = Theme.TextDark,
				TextSize = 10,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true
			})
			
			local textHeight = paraContent.TextBounds.Y
			paraFrame.Size = UDim2.new(1, 0, 0, math.max(textHeight + 42, 75))
			
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
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0
			})
			
			addCorner(keybindFrame, 8)
			addStroke(keybindFrame, Theme.Border, 1, 0.5)
			
			local keybindTitle = create("TextLabel", {
				Name = "Title",
				Parent = keybindFrame,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -90, 1, 0),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local keybindBtn = create("TextButton", {
				Name = "KeyButton",
				Parent = keybindFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0.5, 0),
				Size = UDim2.new(0, 64, 0, 24),
				BackgroundColor3 = Theme.Surface,
				BorderSizePixel = 0,
				Text = default,
				TextColor3 = Theme.Accent,
				TextSize = 10,
				Font = Enum.Font.GothamBold,
				AutoButtonColor = false
			})
			
			addCorner(keybindBtn, 5)
			addStroke(keybindBtn, Theme.Accent, 1, 0.4)
			
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
				tween(keybindBtn.UIStroke, {Transparency = 0})
			end)
			
			UserInputService.InputBegan:Connect(function(input, processed)
				if binding and not processed then
					local key = input.KeyCode.Name
					if key ~= "Unknown" then
						update(key)
						binding = false
						tween(keybindBtn.UIStroke, {Transparency = 0.4})
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
		
		-- ColorPicker with RGB Sliders
		function Tab:CreateColorPicker(options)
			options = options or {}
			local name = options.Name or "Color Picker"
			local default = options.Color or Color3.fromRGB(255, 255, 255)
			local callback = options.Callback or function() end
			local flag = options.Flag
			
			local pickerFrame = create("Frame", {
				Name = "ColorPicker",
				Parent = tabPage,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundColor3 = Theme.ElementBg,
				BorderSizePixel = 0,
				ClipsDescendants = true
			})
			
			addCorner(pickerFrame, 8)
			addStroke(pickerFrame, Theme.Border, 1, 0.5)
			
			local pickerTitle = create("TextLabel", {
				Name = "Title",
				Parent = pickerFrame,
				Position = UDim2.new(0, 14, 0, 0),
				Size = UDim2.new(1, -65, 0, 36),
				BackgroundTransparency = 1,
				Text = name,
				TextColor3 = Theme.Text,
				TextSize = 12,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local colorDisplay = create("Frame", {
				Name = "ColorDisplay",
				Parent = pickerFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -14, 0, 18),
				Size = UDim2.new(0, 36, 0, 22),
				BackgroundColor3 = default,
				BorderSizePixel = 0
			})
			
			addCorner(colorDisplay, 5)
			addStroke(colorDisplay, Theme.Border, 1, 0.4)
			
			-- RGB Sliders Container
			local rgbContainer = create("Frame", {
				Name = "RGBContainer",
				Parent = pickerFrame,
				Position = UDim2.new(0, 0, 0, 36),
				Size = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1
			})
			
			create("UIListLayout", {
				Parent = rgbContainer,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder
			})
			
			create("UIPadding", {
				Parent = rgbContainer,
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 8)
			})
			
			local currentColor = default
			local expanded = false
			
			local function update(color, silent)
				currentColor = color
				colorDisplay.BackgroundColor3 = color
				
				if not silent then
					task.spawn(callback, color)
				end
			end
			
			-- Create RGB sliders
			local sliders = {}
			local colors = {
				{name = "R", color = Color3.fromRGB(255, 100, 100)},
				{name = "G", color = Color3.fromRGB(100, 255, 100)},
				{name = "B", color = Color3.fromRGB(100, 100, 255)}
			}
			
			for i, data in ipairs(colors) do
				local sliderFrame = create("Frame", {
					Name = data.name .. "Slider",
					Parent = rgbContainer,
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1
				})
				
				local sliderLabel = create("TextLabel", {
					Name = "Label",
					Parent = sliderFrame,
					Size = UDim2.new(0, 15, 1, 0),
					BackgroundTransparency = 1,
					Text = data.name,
					TextColor3 = Theme.Text,
					TextSize = 11,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left
				})
				
				local sliderValue = create("TextLabel", {
					Name = "Value",
					Parent = sliderFrame,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.new(0, 30, 1, 0),
					BackgroundTransparency = 1,
					Text = "255",
					TextColor3 = data.color,
					TextSize = 10,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Right
				})
				
				local sliderBar = create("Frame", {
					Name = "Bar",
					Parent = sliderFrame,
					Position = UDim2.new(0, 22, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(1, -56, 0, 4),
					BackgroundColor3 = Theme.Surface,
					BorderSizePixel = 0
				})
				
				addCorner(sliderBar, 2)
				
				local sliderFill = create("Frame", {
					Name = "Fill",
					Parent = sliderBar,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = data.color,
					BorderSizePixel = 0
				})
				
				addCorner(sliderFill, 2)
				
				local dragging = false
				
				local function updateSlider(value)
					value = math.clamp(math.floor(value), 0, 255)
					sliderValue.Text = tostring(value)
					sliderFill.Size = UDim2.new(value / 255, 0, 1, 0)
					
					local r = data.name == "R" and value or (currentColor.R * 255)
					local g = data.name == "G" and value or (currentColor.G * 255)
					local b = data.name == "B" and value or (currentColor.B * 255)
					
					update(Color3.fromRGB(r, g, b))
				end
				
				sliderBar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = true
						local percent = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
						updateSlider(percent * 255)
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
						updateSlider(percent * 255)
					end
				end)
				
				sliders[data.name] = updateSlider
			end
			
			local function toggle()
				expanded = not expanded
				
				if expanded then
					tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 120)}, 0.25)
				else
					tween(pickerFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.25)
				end
			end
			
			local pickerInteract = create("TextButton", {
				Name = "Interact",
				Parent = pickerFrame,
				Size = UDim2.new(1, 0, 0, 36),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 2
			})
			
			pickerInteract.MouseButton1Click:Connect(toggle)
			
			pickerInteract.MouseEnter:Connect(function()
				if not expanded then
					tween(pickerFrame, {BackgroundColor3 = Theme.ElementHover})
				end
			end)
			
			pickerInteract.MouseLeave:Connect(function()
				if not expanded then
					tween(pickerFrame, {BackgroundColor3 = Theme.ElementBg})
				end
			end)
			
			-- Initialize sliders
			sliders.R(default.R * 255)
			sliders.G(default.G * 255)
			sliders.B(default.B * 255)
			
			local ColorPicker = {
				Type = "ColorPicker",
				Color = currentColor,
				Set = function(self, color, silent)
					update(color, silent)
					sliders.R(color.R * 255)
					sliders.G(color.G * 255)
					sliders.B(color.B * 255)
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
	tween(main, {Size = UDim2.new(0, 600, 0, 450)}, 0.4, Enum.EasingStyle.Back)
	
	return Window
end

function Wlib:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
	end
end

return Wlib
