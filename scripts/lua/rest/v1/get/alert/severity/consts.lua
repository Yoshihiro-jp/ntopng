--
-- (C) 2013-20 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
local json = require "dkjson"
local alert_consts = require "alert_consts"
local rest_utils = require "rest_utils"

--
-- Read all the defined alert severity constants
-- Example: curl -u admin:admin http://localhost:3000/lua/rest/v1/get/alert/severity/consts.lua
--
-- NOTE: in case of invalid login, no error is returned but redirected to login
--

sendHTTPHeader('application/json')

local rc = rest_utils.consts_ok
local res = {}

for severity, severity_descr in pairs(alert_consts.alert_severities) do
   res[#res + 1] = {
     severity = severity,
     id = severity_descr.severity_id,
   }
end

print(rest_utils.rc(rc, res))

