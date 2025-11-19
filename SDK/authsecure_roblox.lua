local HttpService = game:GetService("HttpService")

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

local function send_request(data)
	local encoded = ""
	for k, v in pairs(data) do
		encoded ..= k .. "=" .. HttpService:UrlEncode(v) .. "&"
	end
	encoded = string.sub(encoded, 1, -2)

	local success, response = pcall(function()
		return HttpService:PostAsync(AuthSecure.BASE_URL, encoded, Enum.HttpContentType.ApplicationUrlEncoded)
	end)

	if not success then
		warn("? HTTP Error:", response)
		return nil
	end

	local ok, json = pcall(function()
		return HttpService:JSONDecode(response)
	end)

	if ok then
		return json
	else
		warn("? JSON Decode Error:", response)
		return nil
	end
end

function AuthSecure.Init()
	print("Connecting...")
	local payload = {
		type = "init",
		name = AuthSecure.name,
		ownerid = AuthSecure.ownerid,
		secret = AuthSecure.secret,
		ver = AuthSecure.version
	}
	local resp = send_request(payload)
	if resp and resp.success then
		AuthSecure.sessionid = resp.sessionid
		print("? Initialized Successfully!")
	else
		warn("? Init Failed:", resp and resp.message or "Unknown error")
	end
end

function AuthSecure.Login(username, password)
	local hwid = "Roblox-" .. tostring(game.Players.LocalPlayer.UserId)
	local payload = {
		type = "login",
		sessionid = AuthSecure.sessionid,
		username = username,
		pass = password,
		hwid = hwid,
		name = AuthSecure.name,
		ownerid = AuthSecure.ownerid
	}
	local resp = send_request(payload)
	if resp and resp.success then
		print("? Logged in as " .. username)
	else
		warn("? Login Failed:", resp and resp.message or "Unknown error")
	end
end

return AuthSecure

