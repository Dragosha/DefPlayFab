-- Put functions in this file to use them in several other scripts.
-- To get access to the functions, you need to put:
-- require "my_directory.my_file"
-- in any script using the functions.
local PlayFabClientApi = require("PlayFab.PlayFabClientApi")
local IPlayFabHttps = require("PlayFab.IPlayFabHttps")
local PlayFabHttps_Defold = require("PlayFab.PlayFabHttps_Defold")

IPlayFabHttps.SetHttp(PlayFabHttps_Defold) -- Assign the Defold-specific IHttps wrapper
PlayFabClientApi.settings.titleId = "XXXX" -- Please change this value to your own titleId from PlayFab Game Manager
local M={}

local random = math.random
M.uid=""
M.nickname="Player"
M.login=false
M.fb_login=false
M.lastloginTime=0
M.PlayFabId=""
M.DisplayName=""
function M.uuid()
    math.randomseed(os.time()+os.clock()+random(1,1000))
    local a=random(1,10)+random(1,10)+random(1,10)
    print (a)
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function M.getPlayerProfile(PlayFabId, onSuccess, OnFailed)
    PlayFabClientApi.GetPlayerProfile({PlayFabId=PlayFabId}, function(result)
        pprint(result)
        if result.PlayerProfile then M.DisplayName=result.PlayerProfile.DisplayName end
        onSuccess(result)
    end, function(error)
         M.login=false
         OnFailed(error) end )
end

function M.sigIn(OnLoginSuccess, OnLoginFailed)
    print("lb.sigIn:",M.login)
    local dif=socket.gettime()-M.lastloginTime
    if dif>3600 then
        M.login=false
        print("1 hour from the last login. Reset lb.login.")
    end
    if M.login then
        OnLoginSuccess()
        return
    end
--[[
    local info = sys.get_sys_info()
    if info.system_name == "Android" then
    --  Android
        local loginRequest = {
            AndroidDeviceId = info.device_ident,
            AndroidDevice = info.device_model,
            OS = info.system_version,
            CreateAccount = true
        }
        PlayFabClientApi.LoginWithAndroidDeviceID(loginRequest, function(result)
             M.login=true
             pprint(result)
             M.PlayFabId=result.PlayFabId
             OnLoginSuccess(result)
           end, OnLoginFailed)
    else]]--
    -- HTML5
        local loginRequest = {
            CustomId = M.uid,
            CreateAccount = true
        }
        PlayFabClientApi.LoginWithCustomID(loginRequest, function(result)
             M.lastloginTime=socket.gettime()
             M.login=true
             pprint(result)
             M.PlayFabId=result.PlayFabId
             OnLoginSuccess(result)
           end, OnLoginFailed)
     --end
end

function M.getLeaderboard(board, onSuccess, OnFailed, MaxResults, StartPosition)
    PlayFabClientApi.GetLeaderboard({
		StatisticName=board,
		MaxResultsCount=MaxResults or 25,
		StartPosition=StartPosition or 0
	},onSuccess, function(error)
         M.login=false
         OnFailed(error) end )
end
function M.getLeaderboardAroundPlayer(board, onSuccess, OnFailed, MaxResults)
    PlayFabClientApi.GetLeaderboardAroundPlayer({
		StatisticName=board,
		MaxResultsCount=MaxResults or 10
	},onSuccess, function(error)
         M.login=false
         OnFailed(error) end )
end

function M.sendScore(value, onSuccess, onError, class)
    PlayFabClientApi.UpdatePlayerStatistics({Statistics= {{StatisticName= "daily", Value= value  },{StatisticName= "weekly", Value= value  },{StatisticName= class, Value= value  }}},
    onSuccess, function(error)
         M.login=false
         onError(error) end)
end
function M.customSendScore(value, onSuccess, onError, class)
    PlayFabClientApi.UpdatePlayerStatistics({Statistics= {{StatisticName= class, Value= value  }}},
    onSuccess, function(error)
         M.login=false
         onError(error) end)
end
function M.changeName(nickname, onSuccess, onError)

    if M.login then
        PlayFabClientApi.UpdateUserTitleDisplayName({DisplayName=nickname}, function(result)
            print("New DisplayName:",result.DisplayName)
            M.DisplayName=result.DisplayName
            M.nickname=M.DisplayName
            onSuccess(result)
            end,
            function(error) print(error.errorMessage)
            M.login=false
            onError(error)
            end)
    end
end

function M.linkToFB(onSuccess, onError)
    if M.login then
        PlayFabClientApi.LinkFacebookAccount({AccessToken=facebook.access_token(),ForceLink=false},onSuccess, function(error)
             M.login=false
             onError(error) end)
    end
end

function M.loginWithFB(onSuccess, onError)
    local loginRequest = {
        CreateAccount = false,
        AccessToken=facebook.access_token()
    }
    PlayFabClientApi.LoginWithFacebook(loginRequest,
        function(result)
             M.lastloginTime=socket.gettime()
             M.login=true
             M.fb_login=true
             pprint(result)
             M.PlayFabId=result.PlayFabId
             onSuccess(result)
        end,
        function(error)
             M.login=false
             onError(error)
        end)

end

function M.updateUserData(data, onSuccess, onError)
    local request={}
    request.Data=data
    PlayFabClientApi.UpdateUserData(request, onSuccess, function(error)
         M.login=false
         onError(error) end)
end

function M.getUserData(keys, onSuccess, onError)
    local request={}
    request.PlayFabId = M.PlayFabId
    request.Keys =keys
    PlayFabClientApi.GetUserData(request, onSuccess, function(error)
         M.login=false
         onError(error) end)
end

return M
