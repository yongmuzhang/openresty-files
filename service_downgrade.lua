local redis = require "resty.redis"
local red = redis:new()
red:set_timeout(5000)

-- redis连接
local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
	return
end

-- redis密码
local res, err = red:auth("12345")
if not res then
 	return
end

-- redis存取降级的key和value
local api_uri = ngx.var.uri
local downgrade_api_key = "service:downgrade:api"

-- 降级api是否存在
local exists, err = red:hexists(downgrade_api_key, ngx.var.uri)
if not exists or err then
	return
else
	red:set_keepalive(10000, 100)
	if exists > 0 then
		local message = '{"message":"系统繁忙!"}'
		ngx.status = ngx.HTTP_FORBIDDEN
		ngx.header['Content-Type'] = 'application/json'
		ngx.say(message)
		ngx.exit(ngx.HTTP_FORBIDDEN)
		return
	end
	return
end