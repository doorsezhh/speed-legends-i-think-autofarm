-- Variables
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Chat = game:GetService("Chat")

-- Function to search for CoinContainer and Coin_Server in workspace
local function searchForCoinServer(folder)
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Model") and item.Name == "CoinContainer" then
            for _, coinPart in ipairs(item:GetChildren()) do
                if coinPart:IsA("Part") and coinPart.Name == "Coin_Server" then
                    return coinPart
                end
            end
        end
        -- Recursive search through everything
        local foundCoinPart = searchForCoinServer(item)
        if foundCoinPart then
            return foundCoinPart
        end
    end
    return nil
end

-- Tween the player to the next coin with fast speed
local function tweenToCoin(humanoidRootPart, coinPart)
    if coinPart then
        -- Calculate the distance between the player and the coin
        local distance = (coinPart.Position - humanoidRootPart.Position).Magnitude
        
        -- Fast tweening with a short duration (scale to make it faster)
        local tweenDuration = math.min(distance / 100, 0.3) -- "100" is adjustable; max duration is 0.3s
        
        -- TweenInfo using calculated duration
        local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear)
        
        -- Create the tween
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = coinPart.CFrame})
        
        tween:Play() -- Play the tween

        tween.Completed:Wait() -- Wait for tween to complete
    end
end

-- Function to find a player with the tool "Knife"
local function findPlayerWithKnife()
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local backpack = otherPlayer:FindFirstChild("Backpack")
            if backpack and backpack:FindFirstChild("Knife") then
                return otherPlayer
            end
        end
    end
    return nil
end

-- Tween the player to another player's position
local function tweenToPlayer(humanoidRootPart, targetPlayer)
    if targetPlayer then
        local targetCharacter = targetPlayer.Character
        if targetCharacter then
            local targetHumanoidRootPart = targetCharacter:WaitForChild("HumanoidRootPart")
            local distance = (targetHumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
            
            -- Fast tweening with a short duration
            local tweenDuration = math.min(distance / 100, 0.3)
            local tweenInfo = TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear)
            
            local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = targetHumanoidRootPart.CFrame})
            tween:Play()
            tween.Completed:Wait() -- Wait for tween to complete
            
            -- Notify the player
            local message = targetPlayer.Name .. " has the Knife!"
            Chat:Chat(player.Character, message, Enum.ChatColor.Blue) -- Send message in blue color
        end
    end
end

-- Main function to run the autofarm logic
local function startAutoFarm()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Continuous loop to search for and tween to coins
    while true do
        -- Search through workspace for the next Coin_Server part
        local coinPart = searchForCoinServer(workspace)
        
        -- If a coin is found, tween to it
        if coinPart then
            print("Coin found, tweening...")
            tweenToCoin(humanoidRootPart, coinPart)

            -- Wait for the coin to be destroyed before moving to the next one
            repeat
                wait(0.005) -- Check every 0.005 seconds
            until not coinPart or not coinPart.Parent

            -- Find a player with the "Knife" and tween to them
            local targetPlayer = findPlayerWithKnife()
            if targetPlayer then
                print("Found player with Knife, tweening to them...")
                tweenToPlayer(humanoidRootPart, targetPlayer)
            else
                print("No player with Knife found!")
            end
        else
            print("No coins found!")
            wait(1) -- If no coin is found, wait before searching again
        end
    end
end

-- Monitor player respawn and restart the autofarm after death
player.CharacterAdded:Connect(function(character)
    -- Wait for the new character's HumanoidRootPart to load
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Start the autofarm again
    startAutoFarm()
end)

-- Start the autofarm for the first time
startAutoFarm()
