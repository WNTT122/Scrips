--[[
	Wlib Usage Example
	
	This script demonstrates all the features of Wlib UI library
--]]

-- Load Wlib (replace with your loadstring when hosted)
local Wlib = loadstring(game:HttpGet("https://raw.githubusercontent.com/WNTT122/Scrips/refs/heads/main/Wlib.lua"))()
-- For local testing: local Wlib = require(script.Parent.Wlib)

-- Create Window
local Window = Wlib:CreateWindow({
	Name = "Wlib Example Hub",
	LoadingTitle = "Wlib Example",
	LoadingSubtitle = "by Developer",
	Theme = "Default", -- Options: "Default", "Dark", "Light"
	ConfigurationSaving = {
		Enabled = true,
		FileName = "WlibExample"
	}
})

-- Show welcome notification
Wlib:Notify({
	Title = "Welcome to Wlib!",
	Content = "This is an example of the notification system.",
	Duration = 5
})

--[[ TAB 1: MAIN ]]--
local MainTab = Window:CreateTab("Main", "home")

-- Section
MainTab:CreateSection("Basic Elements")

-- Button
MainTab:CreateButton({
	Name = "Click Me!",
	Callback = function()
		print("Button was clicked!")
		Wlib:Notify({
			Title = "Button Clicked",
			Content = "You clicked the button!",
			Duration = 3
		})
	end
})

-- Toggle
local MyToggle = MainTab:CreateToggle({
	Name = "Enable Feature",
	CurrentValue = false,
	Flag = "Toggle1", -- For configuration saving
	Callback = function(value)
		print("Toggle is now:", value)
	end
})

-- You can also set the toggle programmatically
task.delay(2, function()
	-- MyToggle:Set(true) -- This would enable the toggle after 2 seconds
end)

-- Slider
local MySlider = MainTab:CreateSlider({
	Name = "Speed",
	Min = 0,
	Max = 100,
	CurrentValue = 50,
	Increment = 1,
	Flag = "Slider1",
	Callback = function(value)
		print("Slider value:", value)
	end
})

-- Dropdown
local MyDropdown = MainTab:CreateDropdown({
	Name = "Select Mode",
	Options = {"Option 1", "Option 2", "Option 3", "Option 4"},
	CurrentOption = "Option 1",
	Flag = "Dropdown1",
	Callback = function(option)
		print("Selected option:", option)
	end
})

--[[ TAB 2: COMBAT ]]--
local CombatTab = Window:CreateTab("Combat", "sword")

CombatTab:CreateSection("Combat Features")

CombatTab:CreateToggle({
	Name = "Auto Attack",
	CurrentValue = false,
	Flag = "AutoAttack",
	Callback = function(value)
		print("Auto Attack:", value)
		-- Your auto attack code here
	end
})

CombatTab:CreateSlider({
	Name = "Attack Speed",
	Min = 1,
	Max = 10,
	CurrentValue = 5,
	Increment = 0.5,
	Flag = "AttackSpeed",
	Callback = function(value)
		print("Attack Speed:", value)
		-- Your attack speed code here
	end
})

CombatTab:CreateDropdown({
	Name = "Weapon",
	Options = {"Sword", "Axe", "Bow", "Magic Staff"},
	CurrentOption = "Sword",
	Flag = "Weapon",
	Callback = function(option)
		print("Selected weapon:", option)
		-- Your weapon selection code here
	end
})

CombatTab:CreateButton({
	Name = "Reset Combat",
	Callback = function()
		print("Combat reset!")
		Wlib:Notify({
			Title = "Combat Reset",
			Content = "All combat features have been reset.",
			Duration = 3
		})
	end
})

--[[ TAB 3: PLAYER ]]--
local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Player Stats")

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 200,
	CurrentValue = 16,
	Increment = 1,
	Flag = "WalkSpeed",
	Callback = function(value)
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = value
		end
	end
})

PlayerTab:CreateSlider({
	Name = "JumpPower",
	Min = 50,
	Max = 300,
	CurrentValue = 50,
	Increment = 5,
	Flag = "JumpPower",
	Callback = function(value)
		local player = game.Players.LocalPlayer
		if player and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.JumpPower = value
		end
	end
})

PlayerTab:CreateToggle({
	Name = "Infinite Jump",
	CurrentValue = false,
	Flag = "InfiniteJump",
	Callback = function(value)
		local player = game.Players.LocalPlayer
		if value then
			-- Enable infinite jump
			_G.InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		else
			-- Disable infinite jump
			if _G.InfiniteJumpConnection then
				_G.InfiniteJumpConnection:Disconnect()
				_G.InfiniteJumpConnection = nil
			end
		end
	end
})

PlayerTab:CreateSection("Teleportation")

PlayerTab:CreateInput({
	Name = "Teleport to Player",
	CurrentValue = "",
	PlaceholderText = "Enter player name...",
	Flag = "TeleportPlayer",
	Callback = function(value)
		local player = game.Players.LocalPlayer
		local targetPlayer = game.Players:FindFirstChild(value)
		
		if targetPlayer and targetPlayer.Character and player.Character then
			player.Character:SetPrimaryPartCFrame(targetPlayer.Character.PrimaryPart.CFrame)
			Wlib:Notify({
				Title = "Teleported",
				Content = "Teleported to " .. value,
				Duration = 3
			})
		else
			Wlib:Notify({
				Title = "Error",
				Content = "Player not found!",
				Duration = 3
			})
		end
	end
})

--[[ TAB 4: MISC ]]--
local MiscTab = Window:CreateTab("Misc", "settings")

MiscTab:CreateSection("Information")

MiscTab:CreateParagraph({
	Title = "About Wlib",
	Content = "Wlib is a lightweight UI library for Roblox inspired by Rayfield. It features a modern interface, multiple themes, and automatic configuration saving."
})

MiscTab:CreateLabel("Version: " .. Wlib.Version)
MiscTab:CreateLabel("Created for easy script development")

MiscTab:CreateSection("Settings")

MiscTab:CreateDropdown({
	Name = "UI Theme",
	Options = {"Default", "Dark", "Light"},
	CurrentOption = "Default",
	Callback = function(option)
		-- Note: Changing theme requires recreating the window
		Wlib:Notify({
			Title = "Theme Change",
			Content = "Reload the script to apply the " .. option .. " theme.",
			Duration = 5
		})
	end
})

MiscTab:CreateButton({
	Name = "Save Configuration",
	Callback = function()
		Window:SaveConfig()
	end
})

MiscTab:CreateButton({
	Name = "Load Configuration",
	Callback = function()
		Window:LoadConfig()
	end
})

MiscTab:CreateSection("Actions")

MiscTab:CreateButton({
	Name = "Destroy UI",
	Callback = function()
		Wlib:Notify({
			Title = "Goodbye!",
			Content = "UI will be destroyed in 2 seconds...",
			Duration = 2
		})
		task.wait(2)
		Wlib:Destroy()
	end
})

--[[ TAB 5: CREDITS ]]--
local CreditsTab = Window:CreateTab("Credits", "info")

CreditsTab:CreateSection("Developer")

CreditsTab:CreateParagraph({
	Title = "Created by",
	Content = "Wlib was created as an example UI library for Roblox script development. Inspired by Rayfield UI Library."
})

CreditsTab:CreateLabel("Special thanks to:")
CreditsTab:CreateLabel("- Rayfield UI for inspiration")
CreditsTab:CreateLabel("- Roblox community for feedback")

CreditsTab:CreateSection("Links")

CreditsTab:CreateButton({
	Name = "Copy Discord",
	Callback = function()
		setclipboard("discord.gg/example")
		Wlib:Notify({
			Title = "Copied!",
			Content = "Discord link copied to clipboard.",
			Duration = 3
		})
	end
})

CreditsTab:CreateButton({
	Name = "Visit Website",
	Callback = function()
		Wlib:Notify({
			Title = "Opening...",
			Content = "Opening website in browser...",
			Duration = 3
		})
		-- Add website opening code here
	end
})

-- Final notification
task.delay(1, function()
	Wlib:Notify({
		Title = "Loaded Successfully",
		Content = "All features are ready to use!",
		Duration = 4
	})
end)

print("Wlib Example loaded successfully!")
