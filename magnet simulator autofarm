local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Create GUI for Timer
local screenGui = Instance.new("ScreenGui")
local timerLabel = Instance.new("TextLabel")

screenGui.Parent = player:WaitForChild("PlayerGui")
timerLabel.Parent = screenGui
timerLabel.Size = UDim2.new(0, 200, 0, 50)
timerLabel.Position = UDim2.new(0.5, -100, 0, 20) -- Center the label at the top
timerLabel.TextScaled = true
timerLabel.BackgroundColor3 = Color3.new(0, 0, 0)
timerLabel.TextColor3 = Color3.new(1, 1, 1)
timerLabel.Text = "Time: 120"

-- Function to get all target parts named "50000" in the Rebirth350 path
local function getTargetParts()
    local targetParts = {}
    local rebirthFolder = workspace:WaitForChild("GlobalCoins"):WaitForChild("Rebirth350")
    
    for _, part in pairs(rebirthFolder:GetChildren()) do
        if part.Name == "50000" and part:IsA("Part") then
            table.insert(targetParts, part)
        end
    end

    return targetParts
end

-- Function to tween the player to a random target part
local function tweenToRandomPart(targetParts)
    if #targetParts > 0 then
        local randomPart = targetParts[math.random(1, #targetParts)]
        local targetPosition = randomPart.Position + Vector3.new(0, 3, 0) -- Slightly above the part to avoid collisions
        
        -- Create a tween
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) -- Adjust duration and easing as needed
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = CFrame.new(targetPosition) })
        
        tween:Play()
        tween.Completed:Wait() -- Wait for the tween to finish
        print("Tweened to:", randomPart.Name, "at:", targetPosition)
    else
        print("No target parts found.")
    end
end

-- Function to tween to the Sell part
local function tweenToSell()
    local sellPart = workspace:WaitForChild("Rings"):WaitForChild("Sell")
    local targetPosition = sellPart.Position + Vector3.new(0, 3, 0) -- Slightly above the part to avoid collisions

    -- Create a tween
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) -- Adjust duration and easing as needed
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, { CFrame = CFrame.new(targetPosition) })
    
    tween:Play()
    tween.Completed:Wait() -- Wait for the tween to finish
    print("Tweened to Sell at:", targetPosition)
end

-- Initial teleport to a random "50000" part
local targetParts = getTargetParts()
if #targetParts > 0 then
    tweenToRandomPart(targetParts)
else
    print("No '50000' parts found to teleport to at the start.")
end

-- Rapid tween loop
local timer = 120 -- Timer set for 2 minutes (120 seconds)
while true do
    -- Update timer label
    timerLabel.Text = "Time: " .. math.ceil(timer)

    -- Get target parts from the Rebirth350 path
    targetParts = getTargetParts()

    -- Check if the timer has reached zero
    if timer <= 0 then
        tweenToSell()
        timer = 120 -- Reset the timer after tweening to Sell
    else
        -- Tween to a random "50000" part
        if #targetParts > 0 then
            tweenToRandomPart(targetParts)
        else
            print("No parts left to tween to. Waiting for new spawns...")
        end
    end
    
    -- Decrease timer and wait for a short interval
    timer = timer - 0.5 -- Decrement the timer
    wait(0.5) -- Adjust the interval if needed
end
