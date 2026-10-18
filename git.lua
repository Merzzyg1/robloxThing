-- Base GUI template (LocalScript)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- Theme
local Theme = {
	Background = Color3.fromRGB(25, 25, 30),
	TitleBar   = Color3.fromRGB(35, 35, 42),
	Element    = Color3.fromRGB(45, 45, 55),
	Accent     = Color3.fromRGB(90, 120, 255),
	Text       = Color3.fromRGB(235, 235, 240),
	Off        = Color3.fromRGB(70, 70, 80),
}

-- Small helpers
local function create(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
end

-- Root
local screenGui = create("ScreenGui", {
	Name = "BaseGui",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	Parent = player:WaitForChild("PlayerGui"),
})

local main = create("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(280, 340),
	Position = UDim2.new(0.5, -140, 0.5, -170),
	BackgroundColor3 = Theme.Background,
	BorderSizePixel = 0,
	Parent = screenGui,
}, { corner(8) })

-- Title bar
local titleBar = create("Frame", {
	Name = "TitleBar",
	Size = UDim2.new(1, 0, 0, 32),
	BackgroundColor3 = Theme.TitleBar,
	BorderSizePixel = 0,
	Parent = main,
}, { corner(8) })

create("TextLabel", {
	Size = UDim2.new(1, -70, 1, 0),
	Position = UDim2.fromOffset(10, 0),
	BackgroundTransparency = 1,
	Text = "My GUI",
	TextColor3 = Theme.Text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	Parent = titleBar,
})

local minimizeBtn = create("TextButton", {
	Size = UDim2.fromOffset(28, 24),
	Position = UDim2.new(1, -62, 0, 4),
	BackgroundColor3 = Theme.Element,
	Text = "-",
	TextColor3 = Theme.Text,
	Font = Enum.Font.GothamBold,
	TextSize = 16,
	Parent = titleBar,
}, { corner(4) })

local closeBtn = create("TextButton", {
	Size = UDim2.fromOffset(28, 24),
	Position = UDim2.new(1, -32, 0, 4),
	BackgroundColor3 = Color3.fromRGB(200, 60, 60),
	Text = "X",
	TextColor3 = Theme.Text,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	Parent = titleBar,
}, { corner(4) })

-- Scrolling content area
local content = create("ScrollingFrame", {
	Name = "Content",
	Size = UDim2.new(1, -16, 1, -44),
	Position = UDim2.fromOffset(8, 38),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	CanvasSize = UDim2.new(),
	Parent = main,
}, {
	create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}),
})

-- Dragging
do
	local dragging, dragStart, startPos

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Minimize / close
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	content.Visible = not minimized
	TweenService:Create(main, TweenInfo.new(0.2), {
		Size = minimized and UDim2.fromOffset(280, 32) or UDim2.fromOffset(280, 340),
	}):Play()
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Show/hide with a keybind
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.RightShift then
		main.Visible = not main.Visible
	end
end)

-- Element builders
local Library = {}

function Library.Button(text, callback)
	local btn = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Element,
		Text = text,
		TextColor3 = Theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		AutoButtonColor = true,
		Parent = content,
	}, { corner(6) })

	btn.MouseButton1Click:Connect(function()
		task.spawn(callback)
	end)
	return btn
end

function Library.Toggle(text, default, callback)
	local state = default or false

	local holder = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = Theme.Element,
		Text = "",
		AutoButtonColor = false,
		Parent = content,
	}, { corner(6) })

	create("TextLabel", {
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Parent = holder,
	})

	local switch = create("Frame", {
		Size = UDim2.fromOffset(40, 20),
		Position = UDim2.new(1, -50, 0.5, -10),
		BackgroundColor3 = state and Theme.Accent or Theme.Off,
		Parent = holder,
	}, { corner(10) })

	local knob = create("Frame", {
		Size = UDim2.fromOffset(16, 16),
		Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = switch,
	}, { corner(8) })

	local function set(value)
		state = value
		TweenService:Create(switch, TweenInfo.new(0.15), {
			BackgroundColor3 = state and Theme.Accent or Theme.Off,
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.15), {
			Position = state and UDim2.fromOffset(22, 2) or UDim2.fromOffset(2, 2),
		}):Play()
		task.spawn(callback, state)
	end

	holder.MouseButton1Click:Connect(function()
		set(not state)
	end)

	return { Set = set, Get = function() return state end }
end

function Library.Slider(text, min, max, default, callback)
	local value = math.clamp(default or min, min, max)

	local holder = create("Frame", {
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = Theme.Element,
		Parent = content,
	}, { corner(6) })

	local label = create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.fromOffset(10, 4),
		BackgroundTransparency = 1,
		Text = ("%s: %d"):format(text, value),
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		Parent = holder,
	})

	local bar = create("Frame", {
		Size = UDim2.new(1, -20, 0, 6),
		Position = UDim2.fromOffset(10, 30),
		BackgroundColor3 = Theme.Off,
		Parent = holder,
	}, { corner(3) })

	local fill = create("Frame", {
		Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		Parent = bar,
	}, { corner(3) })

	local sliding = false

	local function update(x)
		local alpha = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * alpha + 0.5)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		label.Text = ("%s: %d"):format(text, value)
		task.spawn(callback, value)
	end

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			update(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	return { Get = function() return value end }
end

-- Example usage: replace the callbacks with your own logic
Library.Button("Say Hello", function()
	print("Hello from the GUI!")
end)

Library.Toggle("Example Toggle", false, function(on)
	print("Toggle is now", on)
end)

Library.Slider("Example Slider", 0, 100, 50, function(v)
	print("Slider value:", v)
end)
