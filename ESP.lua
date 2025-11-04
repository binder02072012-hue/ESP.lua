-- =========================================
-- Services
-- =========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- =========================================
-- Переменные
-- =========================================
local ESPEnabled = true
local ESPTags = {}
local savedPosition = nil
local flying = false
local correctKey = "MaXooN_i1"
local mainFrame = nil
local menuVisible = false

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- BodyForce для Gravity
local bodyForce = Instance.new("BodyForce")
bodyForce.Parent = HumanoidRootPart

local function setGravity(value)
	local forceY = workspace.Gravity - value
	bodyForce.Force = Vector3.new(0, HumanoidRootPart.AssemblyMass * forceY, 0)
end

-- =========================================
-- GUI
-- =========================================
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.ResetOnSpawn = false -- GUI не пропадает при респавне

-- Ввод ключа
local keyFrame = Instance.new("Frame", screenGui)
keyFrame.Size = UDim2.new(0, 300, 0, 150)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
keyFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
keyFrame.BorderSizePixel = 0
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,12)

local keyLabel = Instance.new("TextLabel", keyFrame)
keyLabel.Size = UDim2.new(1, -20, 0, 50)
keyLabel.Position = UDim2.new(0, 10, 0, 10)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Введите ключ:"
keyLabel.TextColor3 = Color3.fromRGB(255,255,255)
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextScaled = true

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(0.8, 0, 0, 40)
keyBox.Position = UDim2.new(0.1, 0, 0, 60)
keyBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
keyBox.TextColor3 = Color3.fromRGB(255,255,255)
keyBox.ClearTextOnFocus = false
keyBox.PlaceholderText = "Введите ключ здесь"
keyBox.Font = Enum.Font.GothamBold
keyBox.TextScaled = true
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0,8)

local keyButton = Instance.new("TextButton", keyFrame)
keyButton.Size = UDim2.new(0.5,0,0,30)
keyButton.Position = UDim2.new(0.25,0,0,110)
keyButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
keyButton.TextColor3 = Color3.fromRGB(255,255,255)
keyButton.Font = Enum.Font.GothamBold
keyButton.TextScaled = true
keyButton.Text = "Войти"
Instance.new("UICorner", keyButton).CornerRadius = UDim.new(0,8)

-- =========================================
-- ESP функции
-- =========================================
local function createESP(player)
	local character = player.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head then return end

	if ESPTags[player] then ESPTags[player]:Destroy() end

	local billboard = Instance.new("BillboardGui", head)
	billboard.Name = "ESPTag"
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0,2,0)
	billboard.AlwaysOnTop = true

	local label = Instance.new("TextLabel", billboard)
	label.Size = UDim2.new(1,0,1,0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = player.Name

	ESPTags[player] = billboard
end

local function removeESP(player)
	if ESPTags[player] then
		ESPTags[player]:Destroy()
		ESPTags[player] = nil
	end
end

local function updateAllESP()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if ESPEnabled then createESP(player) else removeESP(player) end
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if ESPEnabled then createESP(player) end
	end)
end)
Players.PlayerRemoving:Connect(removeESP)

for _, player in pairs(Players:GetPlayers()) do
	if player.Character then
		if ESPEnabled then createESP(player) end
		player.CharacterAdded:Connect(function(character)
			if ESPEnabled then createESP(player) end
		end)
	end
end

-- =========================================
-- Главное меню
-- =========================================
local function createMainGUI()
	if mainFrame then mainFrame:Destroy() end

	mainFrame = Instance.new("Frame", screenGui)
	mainFrame.Size = UDim2.new(0, 300, 0, 350)
	mainFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	mainFrame.BorderSizePixel = 0
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0,12)

	-- Крестик
	local closeButton = Instance.new("TextButton", mainFrame)
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
	closeButton.TextColor3 = Color3.fromRGB(255,255,255)
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextScaled = true
	closeButton.Text = "X"
	Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0,5)
	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		menuVisible = false
	end)

	-- Заголовок
	local title = Instance.new("TextLabel", mainFrame)
	title.Size = UDim2.new(1,0,0,30)
	title.BackgroundTransparency = 1
	title.Text = "Меню"
	title.TextColor3 = Color3.fromRGB(255,255,255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true

	-- ===== DRAGGING =====
	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	mainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			update(input)
		end
	end)

	-- ===== Кнопки =====
	local toggleESP = Instance.new("TextButton", mainFrame)
	toggleESP.Size = UDim2.new(0.8,0,0,30)
	toggleESP.Position = UDim2.new(0.1,0,0,40)
	toggleESP.BackgroundColor3 = Color3.fromRGB(50,50,50)
	toggleESP.TextColor3 = Color3.fromRGB(255,255,255)
	toggleESP.Font = Enum.Font.GothamBold
	toggleESP.TextScaled = true
	toggleESP.Text = "ESP: Вкл"
	Instance.new("UICorner", toggleESP).CornerRadius = UDim.new(0,8)

	toggleESP.MouseButton1Click:Connect(function()
		ESPEnabled = not ESPEnabled
		toggleESP.Text = ESPEnabled and "ESP: Вкл" or "ESP: Выкл"
		updateAllESP()
	end)

	local gravities = {50,70,100,192}
	for i, g in ipairs(gravities) do
		local btn = Instance.new("TextButton", mainFrame)
		btn.Size = UDim2.new(0.8,0,0,30)
		btn.Position = UDim2.new(0.1,0,0,80 + (i-1)*35)
		btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.Text = "Gravity " .. g
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
		btn.MouseButton1Click:Connect(function()
			setGravity(g)
		end)
	end
end

-- =========================================
-- Проверка ключа
-- =========================================
keyButton.MouseButton1Click:Connect(function()
	if keyBox.Text == correctKey then
		keyFrame.Visible = false
		createMainGUI()
		mainFrame.Visible = true
		menuVisible = true
	else
		keyLabel.Text = "Неверный ключ!"
		keyLabel.TextColor3 = Color3.fromRGB(255,50,50)
	end
end)

-- =========================================
-- Переключение меню клавишей G
-- =========================================
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.G and mainFrame then
		menuVisible = not menuVisible
		mainFrame.Visible = menuVisible
	end
end)

