local json = require "json"

local AuthSecure = {}
AuthSecure.BASE_URL = "https://www.horrorgamingkeyauth.shop/post/api.php"
AuthSecure.sessionid = nil
AuthSecure.name = ""
AuthSecure.ownerid = ""
AuthSecure.secret = ""
AuthSecure.version = ""

function AuthSecure.Api(name, ownerid, secret, version)
    AuthSecure.name = name
    AuthSecure.ownerid = ownerid
    AuthSecure.secret = secret
    AuthSecure.version = version
end

local function send_request(data, callback)
    local form = ""
    for k, v in pairs(data) do
        form = form .. k .. "=" .. v .. "&"
    end
    form = string.sub(form, 1, -2)

    PerformHttpRequest(AuthSecure.BASE_URL, function(status, body)
        if status == 200 then
            local ok, resp = pcall(function() return json.decode(body) end)
            if ok then callback(resp)
            else print("? JSON Decode Error:", body) end
        else
            print("? HTTP Error:", status)
        end
    end, 'POST', form, { ['Content-Type'] = 'application/x-www-form-urlencoded' })
end

function AuthSecure.Init()
    print("Connecting...")
    send_request({
        type = "init",
        name = AuthSecure.name,
        ownerid = AuthSecure.ownerid,
        secret = AuthSecure.secret,
        ver = AuthSecure.version
    }, function(resp)
        if resp.success then
            AuthSecure.sessionid = resp.sessionid
            print("? Initialized Successfully!")
        else
            print("? Init Failed:", resp.message)
        end
    end)
end

function AuthSecure.Login(src, username, password)
    local hwid = "FIVEM-" .. GetPlayerIdentifier(src, 0)
    send_request({
        type = "login",
        sessionid = AuthSecure.sessionid,
        username = username,
        pass = password,
        hwid = hwid,
        name = AuthSecure.name,
        ownerid = AuthSecure.ownerid
    }, function(resp)
        if resp.success then
            print("? " .. username .. " Logged in successfully!")
            TriggerClientEvent("auth:loginSuccess", src, resp.info)
        else
            TriggerClientEvent("auth:loginFailed", src, resp.message)
        end
    end)
end

return AuthSecure

