local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Set the desired tween speed (e.g., speed of 25 studs per second for rapid tweening)
local tweenSpeed = 25 
local safeHeight = 50  -- Define a safe height to avoid death points
local lastCoinPart = nil -- Variable to track the last coin tweened to

-- Function to search for CoinContainer and Coin_Server
local function searchForCoinServer(folder)
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.Name == "CoinContainer" then
            -- Search for Coin_Server inside the CoinContainer model
            for _, coinPart in ipairs(item:GetChildren()) do
                if coinPart:IsA("Part") and coinPart.Name == "Coin_Server" then
                    return coinPart  -- Return the Coin_Server part itself
                end
            end
        end
        -- Recursively search in this model
        local foundCoinPart = searchForCoinServer(item)
        if foundCoinPart then
            return foundCoinPart  -- Return the Coin_Server part if found
        end
    end
    return nil
end

-- Function to check if the target position is safe
local function isPositionSafe(position)
    return position.Y <= safeHeight  -- Check if the Y position is below or equal to safeHeight
end

-- Function to tween the character to Coin_Server parts
local function tweenToCoinServer(coinPart)
    local targetPosition = coinPart.Position
    local targetCFrame = CFrame.new(targetPosition)  -- No vertical offset

    -- Check if the target position is safe
    if not isPositionSafe(targetPosition) then
        print("Target position is unsafe. Skipping...")
        return false  -- Skip tweening if position is unsafe
    end
    
    -- Calculate the distance and set duration for the tween
    local distance = (targetPosition - humanoidRootPart.Position).magnitude
    local duration = distance / tweenSpeed

    local tween = TweenService:Create(humanoidRootPart, TweenInfo.new(duration), {CFrame = targetCFrame})

    -- Disable character's collision and set humanoid state to flying during tween
    character.Humanoid.PlatformStand = true
    
    -- Allow character to fly (temporarily disable gravity)
    character.Humanoid:ChangeState(Enum.HumanoidStateType.Flying)
    
    tween:Play()

    -- Wait for the tween to complete
    tween.Completed:Wait()

    -- Check if the Coin_Server is still valid after tweening
    if coinPart and coinPart:IsDescendantOf(workspace) then
        print("Tweening completed to: " .. coinPart:GetFullName())
        return true
    else
        print("Coin_Server was destroyed before reaching it.")
        return false
    end
end

-- Function to handle touching the Coin_Server
local function onTouch(coinPart)
    print("Touched: " .. coinPart:GetFullName())
    
    -- Start tweening to the next coin as soon as the current coin is touched
    if coinPart ~= lastCoinPart then  -- Only tween if it's not the same coin
        lastCoinPart = coinPart  -- Update the lastCoinPart to the current one
        local nextCoinPart = searchForCoinServer(workspace)
        if nextCoinPart and nextCoinPart ~= lastCoinPart then
            local success = tweenToCoinServer(nextCoinPart)
            if not success then
                print("Could not tween to the next coin.")
            end
        else
            print("No valid Coin_Server found in the workspace.")
        end
    end
end

-- Function to start the continuous tweening process
local function startCoinCollection()
    while true do  -- Infinite loop for continuous tweening
        local coinPart = searchForCoinServer(workspace)

        if coinPart and coinPart ~= lastCoinPart then
            -- Connect the Touched event to the current Coin_Server
            coinPart.Touched:Connect(function(hit)
                if hit.Parent == character then
                    onTouch(coinPart)
                end
            end)

            -- Start the initial tween to the first coin
            local success = tweenToCoinServer(coinPart)
            if not success then
                print("Could not start tweening to the initial coin.")
            end

            -- Wait a moment before checking for the next coin
            wait(1)  -- Optional delay before the next search
        else
            print("No valid Coin_Server found in the workspace.")
            wait(1)  -- Wait a moment before trying again
        end
    end
end

-- Start the coin collection process
startCoinCollection()
