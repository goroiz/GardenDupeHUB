-- Grow Garden Ultimate Duplication HUB
local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

-- Hapus GUI lama
if CoreGui:FindFirstChild("DupeHUB") then CoreGui.DupeHUB:Destroy() end
if CoreGui:FindFirstChild("MinimizedIcon") then CoreGui.MinimizedIcon:Destroy() end

-- ========== FUNGSI UTAMA ==========
local function Teleport(pos)
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function FindNearestObject(names)
    local closest, dist = nil, math.huge
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        for _, name in ipairs(names) do
            if obj.Name:lower():find(name:lower()) then
                local objRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if objRoot then
                    local d = (root.Position - objRoot.Position).Magnitude
                    if d < dist then
                        closest = obj
                        dist = d
                    end
                end
            end
        end
    end
    return closest
end

local function DuplicateObject(objType)
    local objNames = {
        Fruit = {"fruit", "tree", "harvest", "berry", "crop"},
        Pet = {"pet", "animal", "companion", "dino", "creature"},
        Tool = {"sprinkler", "watering can", "shovel", "axe", "tool"}
    }
    
    local obj = FindNearestObject(objNames[objType])
    if not obj then return false end
    
    local prompt = obj:FindFirstChild("ProximityPrompt") 
        or obj:FindFirstChild("HarvestPrompt")
        or obj:FindFirstChild("InteractPrompt")
    
    if not prompt then return false end
    
    -- Duplikasi
    for i = 1, 5 do
        if objType == "Tool" then
            Teleport(obj.PrimaryPart.Position + Vector3.new(0, 3, 0))
        end
        fireproximityprompt(prompt)
        task.wait(0.1)
    end
    return true
end

-- ========== BUAT GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 320)
Frame.Position = UDim2.new(0.5, -160, 0.5, -160)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Active = true  -- Agar bisa di-drag
Frame.Draggable = true -- Aktifkan drag
Frame.Parent = ScreenGui

-- Buat title bar untuk drag
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Text = "🌱 GARDEN DUPE HUB 🌱"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Tombol Minimize
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "_"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 60)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 24
MinimizeBtn.Parent = TitleBar

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar

local FruitBtn = Instance.new("TextButton")
FruitBtn.Text = "🍓 DUPLICATE FRUIT"
FruitBtn.Size = UDim2.new(0.9, 0, 0, 50)
FruitBtn.Position = UDim2.new(0.05, 0, 0.2, 30) -- Perhatikan penambahan Y karena title bar
FruitBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
FruitBtn.TextColor3 = Color3.new(1, 1, 1)
FruitBtn.Font = Enum.Font.SourceSansBold
FruitBtn.TextSize = 18
FruitBtn.Parent = Frame

local PetBtn = Instance.new("TextButton")
PetBtn.Text = "🐶 DUPE PET"
PetBtn.Size = UDim2.new(0.9, 0, 0, 50)
PetBtn.Position = UDim2.new(0.05, 0, 0.4, 30)
PetBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
PetBtn.TextColor3 = Color3.new(1, 1, 1)
PetBtn.Font = Enum.Font.SourceSansBold
PetBtn.TextSize = 18
PetBtn.Parent = Frame

local ToolBtn = Instance.new("TextButton")
ToolBtn.Text = "⛏️ DUPE TOOL"
ToolBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToolBtn.Position = UDim2.new(0.05, 0, 0.6, 30)
ToolBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 60)
ToolBtn.TextColor3 = Color3.new(1, 1, 1)
ToolBtn.Font = Enum.Font.SourceSansBold
ToolBtn.TextSize = 18
ToolBtn.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Text = "✅ Ready to dupe!"
Status.Size = UDim2.new(0.9, 0, 0, 40)
Status.Position = UDim2.new(0.05, 0, 0.8, 30)
Status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
Status.TextColor3 = Color3.new(0, 1, 0)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 16
Status.Parent = Frame

-- ========== FUNGSI TOMBOL ==========
local function UpdateStatus(message, color)
    Status.Text = message
    Status.TextColor3 = color
end

FruitBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duplicating fruits...", Color3.new(1, 1, 0))
    task.wait(0.5)
    if DuplicateObject("Fruit") then
        UpdateStatus("✅ Fruits duplicated!", Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ No fruits found!", Color3.new(1, 0, 0))
    end
end)

PetBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duping pet...", Color3.new(1, 1, 0))
    task.wait(0.5)
    if DuplicateObject("Pet") then
        UpdateStatus("✅ Pet duplicated!", Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ No pets found!", Color3.new(1, 0, 0))
    end
end)

ToolBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duping tool...", Color3.new(1, 1, 0))
    task.wait(0.5)
    if DuplicateObject("Tool") then
        UpdateStatus("✅ Tool duplicated!", Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ No tools found!", Color3.new(1, 0, 0))
    end
end)

-- ========== MINIMIZE & CLOSE ==========
local minimized = false
local minimizedIcon

local function CreateMinimizedIcon()
    local icon = Instance.new("ScreenGui")
    icon.Name = "MinimizedIcon"
    icon.ResetOnSpawn = false
    icon.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 50, 0, 50)
    frame.Position = UDim2.new(0, 10, 0.5, -25) -- Pojok kiri tengah
    frame.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = icon

    local label = Instance.new("TextLabel")
    label.Text = "🌱"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 30
    label.Parent = frame

    frame.MouseButton1Click:Connect(function()
        icon:Destroy()
        Frame.Visible = true
        minimized = false
    end)

    return icon
end

MinimizeBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    minimizedIcon = CreateMinimizedIcon()
    minimized = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if minimizedIcon then minimizedIcon:Destroy() end
end)

-- ========== INISIALISASI ==========
Teleport(Vector3.new(0, 5, 0))  -- Reset position
UpdateStatus("✅ Script loaded! Stand near target", Color3.new(0, 1, 0))
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "GARDEN DUPE HUB",
    Text = "Script activated!",
    Duration = 5
})
