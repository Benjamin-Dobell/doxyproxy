local http = require "resty.http"
local cjson = require "cjson"

local container_url = ngx.var.container_url
local host = ngx.var.host

-- Check if key exists in local cache
local cache = ngx.shared.doxyproxy
local res, flags = cache:get(host)
if res then
    ngx.var.container_url = res
    return
end

local httpc = http.new()
httpc:connect("unix:/var/run/docker.sock")

local filter = "%7B%22label%22%3A%20%5B%22com.glassechidna.doxyproxy.HttpHost%3D" .. host .. "%22%5D%7D"

local res, err = httpc:request{
    path = "/v1.24/containers/json?filters=" .. filter,
    headers = {
        ["Host"] = "example.com",
    },
}

if not res then
    return
end

local body, err = res:read_body()

local dvalue = cjson.decode(body)
local container = dvalue[1]
local networks = container.NetworkSettings.Networks
local networkName = next(networks)
local ip = networks[networkName].IPAddress
local port = container.Labels["com.glassechidna.doxyproxy.HttpPort"]
res = ip .. ":" .. port

-- Save found key to local cache for 5 seconds
cache:set(host, res, 5)

ngx.var.container_url = res
