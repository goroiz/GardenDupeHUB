-- Grow Garden Ultimate Duplication HUB v2
local Player = game.Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Hapus GUI lama
if CoreGui:FindFirstChild("DupeHUB") then CoreGui.DupeHUB:Destroy() end
if CoreGui:FindFirstChild("MinimizedIcon") then CoreGui.MinimizedIcon:Destroy() end

-- ========== VARIABEL UTAMA ==========
local originalInventory = {}
local dupeHistory = {}
local lastDupeTime = 0
local DUPE_COOLDOWN = 3  -- Detik

-- Fungsi untuk cek item di inventory
local function GetInventory()
    local backpack = Player:FindFirstChild("Backpack")
    local character = Player.Character
    local inventory = {}
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            table.insert(inventory, item.Name)
        end
    end
    
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(inventory, item.Name)
            end
        end
    end
    
    return inventory
end

-- Simpan inventory awal
originalInventory = GetInventory()

-- ========== FUNGSI DUPLIKASI ==========
local function FindNearestObject(objType)
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local validObjects = {}
    local objNames = {
        Fruit = {"fruit", "berry", "crop", "plant", "tree", "carrot", "tomato"},
        Pet = {"pet", "animal", "companion", "chicken", "dino", "creature"},
        Tool = {"sprinkler", "watering", "shovel", "axe", "tool", "bucket"}
    }
    
    -- Kumpulkan semua objek valid
    for _, obj in ipairs(workspace:GetDescendants()) do
        for _, keyword in ipairs(objNames[objType]) do
            if obj.Name:lower():find(keyword:lower()) then
                local objRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if objRoot then
                    table.insert(validObjects, {
                        Object = obj,
                        Position = objRoot.Position,
                        Distance = (root.Position - objRoot.Position).Magnitude
                    })
                end
            end
        end
    end
    
    -- Urutkan berdasarkan jarak terdekat
    table.sort(validObjects, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return #validObjects > 0 and validObjects[1].Object or nil
end

local function DuplicateObject(objType)
    -- Cek cooldown
    if os.time() - lastDupeTime < DUPE_COOLDOWN then
        return false, "Cooldown active"
    end
    
    local obj = FindNearestObject(objType)
    if not obj then
        return false, "No "..objType.." found nearby"
    end
    
    -- Cari prompt
    local prompt = obj:FindFirstChild("ProximityPrompt") 
        or obj:FindFirstChild("HarvestPrompt")
        or obj:FindFirstChild("InteractPrompt")
    
    if not prompt then
        return false, "No interaction prompt found"
    end
    
    -- Simpan state sebelum duplikasi
    local preDupeInventory = GetInventory()
    
    -- Proses duplikasi
    for i = 1, 5 do
        fireproximityprompt(prompt)
        task.wait(0.15)
    end
    
    -- Cek hasil duplikasi
    task.wait(1)  -- Beri waktu untuk proses
    local postDupeInventory = GetInventory()
    local newItems = {}
    
    for _, item in ipairs(postDupeInventory) do
        if not table.find(preDupeInventory, item) then
            table.insert(newItems, item)
        end
    end
    
    lastDupeTime = os.time()
    
    if #newItems > 0 then
        -- Catat history
        table.insert(dupeHistory, {
            Type = objType,
            Item = obj.Name,
            Count = #newItems,
            Time = os.time()
        })
        return true, "Duplicated "..#newItems.." "..objType.."(s)"
    end
    
    return false, "Duplication failed"
end

-- ========== SISTEM MINIMIZE YANG FIX ==========
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
    frame.ZIndex = 10
    frame.Parent = icon

    local label = Instance.new("TextLabel")
    label.Text = "🌱"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 30
    label.ZIndex = 11
    label.Parent = frame

    -- Fungsi untuk buka kembali UI
    local function RestoreUI()
        icon:Destroy()
        Frame.Visible = true
        minimized = false
    end

    frame.MouseButton1Click:Connect(RestoreUI)
    
    -- Tombol close di minimize icon
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -20, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 14
    closeBtn.ZIndex = 12
    closeBtn.Parent = frame
    
    closeBtn.MouseButton1Click:Connect(function()
        icon:Destroy()
        ScreenGui:Destroy()
    end)

    return icon
end

-- ========== BUAT GUI UTAMA ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DupeHUB"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 350)
Frame.Position = UDim2.new(0.5, -175, 0.5, -175)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Visible = true
Frame.ZIndex = 2
Frame.Parent = ScreenGui

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(60, 100, 60)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Text = "🌱 GARDEN DUPE HUB v2 🌱"
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
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
MinimizeBtn.ZIndex = 4
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
CloseBtn.ZIndex = 4
CloseBtn.Parent = TitleBar

-- Tombol Duplikasi
local FruitBtn = Instance.new("TextButton")
FruitBtn.Text = "🍓 DUPLICATE FRUIT"
FruitBtn.Size = UDim2.new(0.9, 0, 0, 50)
FruitBtn.Position = UDim2.new(0.05, 0, 0.2, 30)
FruitBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
FruitBtn.TextColor3 = Color3.new(1, 1, 1)
FruitBtn.Font = Enum.Font.SourceSansBold
FruitBtn.TextSize = 18
FruitBtn.ZIndex = 2
FruitBtn.Parent = Frame

local PetBtn = Instance.new("TextButton")
PetBtn.Text = "🐶 DUPE PET"
PetBtn.Size = UDim2.new(0.9, 0, 0, 50)
PetBtn.Position = UDim2.new(0.05, 0, 0.4, 30)
PetBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 200)
PetBtn.TextColor3 = Color3.new(1, 1, 1)
PetBtn.Font = Enum.Font.SourceSansBold
PetBtn.TextSize = 18
PetBtn.ZIndex = 2
PetBtn.Parent = Frame

local ToolBtn = Instance.new("TextButton")
ToolBtn.Text = "⛏️ DUPE TOOL"
ToolBtn.Size = UDim2.new(0.9, 0, 0, 50)
ToolBtn.Position = UDim2.new(0.05, 0, 0.6, 30)
ToolBtn.BackgroundColor3 = Color3.fromRGB(200, 160, 60)
ToolBtn.TextColor3 = Color3.new(1, 1, 1)
ToolBtn.Font = Enum.Font.SourceSansBold
ToolBtn.TextSize = 18
ToolBtn.ZIndex = 2
ToolBtn.Parent = Frame

-- Status dan History
local Status = Instance.new("TextLabel")
Status.Text = "✅ Ready to dupe!"
Status.Size = UDim2.new(0.9, 0, 0, 40)
Status.Position = UDim2.new(0.05, 0, 0.8, 30)
Status.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
Status.TextColor3 = Color3.new(0, 1, 0)
Status.Font = Enum.Font.SourceSans
Status.TextSize = 16
Status.ZIndex = 2
Status.Parent = Frame

-- ========== FUNGSI TOMBOL ==========
local function UpdateStatus(message, color)
    Status.Text = message
    Status.TextColor3 = color
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DUPE HUB",
        Text = message,
        Duration = 3
    })
end

FruitBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duplicating fruits...", Color3.new(1, 1, 0))
    local success, result = DuplicateObject("Fruit")
    if success then
        UpdateStatus(result, Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ "..result, Color3.new(1, 0, 0))
    end
end)

PetBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duping pet...", Color3.new(1, 1, 0))
    local success, result = DuplicateObject("Pet")
    if success then
        UpdateStatus(result, Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ "..result, Color3.new(1, 0, 0))
    end
end)

ToolBtn.MouseButton1Click:Connect(function()
    UpdateStatus("🔄 Duping tool...", Color3.new(1, 1, 0))
    local success, result = DuplicateObject("Tool")
    if success then
        UpdateStatus(result, Color3.new(0, 1, 0))
    else
        UpdateStatus("❌ "..result, Color3.new(1, 0, 0))
    end
end)

-- ========== MINIMIZE & CLOSE ==========
MinimizeBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
    task.wait(0.1)
    minimizedIcon = CreateMinimizedIcon()
    minimized = true
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    if minimizedIcon then minimizedIcon:Destroy() end
end)

-- ========== INISIALISASI ==========
-- Auto pickup untuk hasil duplikasi
task.spawn(function()
    while task.wait(1) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:FindFirstChild("ProximityPrompt") and obj.Name:find("Drop") then
                fireproximityprompt(obj.ProximityPrompt)
            end
        end
    end
end)

-- Notifikasi
UpdateStatus("✅ Script loaded! Stand near target", Color3.new(0, 1, 0))
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "GARDEN DUPE HUB",
    Text = "Enhanced duplication system activated!",
    Duration = 5
})
