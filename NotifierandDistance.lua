local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game.Workspace

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

StarterGui:SetCore("SendNotification", {
    Title = "Script Status",
    Text = "Script running!",
    Duration = 3,
})

local originalPositions = {
    monster = Vector3.new(9.5, 3.5, -6.10001),
    monster2 = Vector3.new(-1.4, 3.99999, 36.6)
}

local targetParts = {"monster", "monster2"}
local billboards = {}

local function sendNotification(partName)
    StarterGui:SetCore("SendNotification", {
        Title = "Alert!",
        Text = partName .. " has spawned!",
        Duration = 5,
    })
end

local function createBillboard(part)
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Adornee = part
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold

    if part.Name:lower() == "monster" then
        textLabel.TextColor3 = Color3.new(1, 0, 0)
    else
        textLabel.TextColor3 = Color3.new(1, 1, 1)
    end

    textLabel.Parent = billboardGui
    billboardGui.Parent = part
    return billboardGui, textLabel
end

local function findTargetParts()
    local parts = {}
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and table.find(targetParts, part.Name:lower()) then
            parts[part.Name:lower()] = part
        end
    end
    return parts
end

local function trackParts()
    local targetPartsList = findTargetParts()

    for partName, part in pairs(targetPartsList) do
        local billboard, textLabel = createBillboard(part)
        billboard.Enabled = false
        billboards[partName] = {billboard = billboard, textLabel = textLabel}
    end

    RunService.RenderStepped:Connect(function()
        for partName, originalPos in pairs(originalPositions) do
            local part = targetPartsList[partName]
            local billboardInfo = billboards[partName]

            if part and billboardInfo then
                if (part.Position - originalPos).Magnitude > 0.1 then
                    if not billboardInfo.billboard.Enabled then
                        sendNotification(partName)
                    end

                    billboardInfo.billboard.Enabled = true
                    local distance = (humanoidRootPart.Position - part.Position).Magnitude
                    billboardInfo.textLabel.Text = string.format("Distance: %.2f studs", distance)
                else
                    billboardInfo.billboard.Enabled = false
                end
            end
        end
    end)
end

trackParts()
