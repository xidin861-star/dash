-- =================================================================
-- ระบบพุ่งอัตโนมัติ "dash" สีรุ้ง (ความเร็วล็อกตายตัว 55.5 + ไม่ทะลุ) By kuya
-- =================================================================

if getgenv().KuyaDashAutoLoaded then
    if game.CoreGui:FindFirstChild("KuyaDashAutoUI") then
        game.CoreGui.KuyaDashAutoUI:Destroy()
    end
end
getgenv().KuyaDashAutoLoaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().DashAutoActive = false
local fixedSpeed = 55.5 -- 👈 ล็อกความเร็วตายตัวไว้ที่ 55.5 ตามที่น้าสั่งเป๊ะๆ
local dashVelocity = nil
local dashGyro = nil

-- ==========================================
-- 1. สร้างหน้าต่าง UI แบบตายไม่หาย (CoreGui)
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KuyaDashAutoUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false 

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 180, 0, 110)
MainFrame.Position = UDim2.new(0.1, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 3 
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
local fontValue = Enum.Font.SourceSansBold
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "dash SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = fontValue
Title.Parent = MainFrame

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0.3, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 0"
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedLabel.TextSize = 18
SpeedLabel.Font = fontValue
SpeedLabel.Parent = MainFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -70, 0.6, 5)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ToggleBtn.Text = "dash (OFF)"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = fontValue
ToggleBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = ToggleBtn

-- แอนิเมชันขอบสีรุ้ง
task.spawn(function()
    local hue = 0
    while MainFrame and MainFrame.Parent do
        hue = hue + 0.01
        if hue > 1 then hue = 0 end
        MainFrame.BorderColor3 = Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

-- ==========================================
-- 2. ระบบหยุดพุ่งแบบปลอดภัย
-- ==========================================
local function stopDash()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum then 
        hum.PlatformStand = false 
    end
    
    if dashVelocity then dashVelocity:Destroy() dashVelocity = nil end
    if dashGyro then dashGyro:Destroy() dashGyro = nil end
    
    SpeedLabel.Text = "Speed: 0"
end

-- ==========================================
-- 3. ลูปพุ่งอัตโนมัติ (ความเร็วคงที่ 55.5 ไม่ทะลุกำแพง)
-- ==========================================
RunService.Stepped:Connect(function()
    local char = player.Character
    if not char or not getgenv().DashAutoActive then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if root and hum and Camera then
        hum.PlatformStand = true -- เปิดโหมดพุ่งลอยตัว
        
        -- สร้างตัวควบคุมความเร็วและทิศทาง
        if not dashVelocity or dashVelocity.Parent ~= root then
            if dashVelocity then dashVelocity:Destroy() end
            dashVelocity = Instance.new("BodyVelocity")
            dashVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
            dashVelocity.Parent = root
        end
        
        if not dashGyro or dashGyro.Parent ~= root then
            if dashGyro then dashGyro:Destroy() end
            dashGyro = Instance.new("BodyGyro")
            dashGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
            dashGyro.CFrame = Camera.CFrame
            dashGyro.Parent = root
        end
        
        -- แสดงสถานะความเร็วคงที่บนหน้าจอ
        SpeedLabel.Text = "Speed: " .. tostring(fixedSpeed)
        
        -- พุ่งไปข้างหน้าอัตโนมัติตามหน้ากล้องด้วยความเร็ว 55.5
        local lookDir = Camera.CFrame.LookVector
        dashVelocity.Velocity = lookDir * fixedSpeed
        dashGyro.CFrame = Camera.CFrame 
    else
        stopDash()
    end
end)

-- ปุ่มกด เปิด/ปิด
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().DashAutoActive = not getgenv().DashAutoActive
    
    if getgenv().DashAutoActive then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        ToggleBtn.Text = "dash (ON)"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        ToggleBtn.Text = "dash (OFF)"
        stopDash()
    end
end)

-- ระบบรีเซ็ตค่าเวลาตาย
player.CharacterAdded:Connect(function()
    task.wait(0.3)
    if getgenv().DashAutoActive then
        stopDash()
    end
end)
