--
-- (C) 2019-20 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

require "lua_utils"
local format_utils = require("format_utils")
local json = require("dkjson")
local plugins_utils = require("plugins_utils")
local active_monitoring_utils = plugins_utils.loadModule("active_monitoring", "am_utils")

sendHTTPContentTypeHeader('application/json')

local charts_available = plugins_utils.timeseriesCreationEnabled()

-- ################################################

local active_monitoring_hosts = active_monitoring_utils.getHosts()

local res = {}

for key, active_monitoring_host in pairs(active_monitoring_hosts) do
    local chart = ""
    local m_info = active_monitoring_utils.getMeasurementInfo(active_monitoring_host.measurement)

    if not m_info then
      goto continue
    end

    if charts_available then
      chart = plugins_utils.getUrl('active_monitoring_stats.lua') .. '?am_host='.. active_monitoring_host.host ..'&measurement='.. active_monitoring_host.measurement ..'&page=historical'
    end

    local column_last_ip = ""
    local column_last_update = ""
    local column_last_rtt = ""
    local last_update = active_monitoring_utils.getLastRttUpdate(active_monitoring_host.host, active_monitoring_host.measurement)

    if(last_update ~= nil) then
      local tdiff = os.time() - last_update.when

      if(tdiff <= 600) then
        column_last_update  = secondsToTime(tdiff).. " " ..i18n("details.ago")
      else
        column_last_update = format_utils.formatPastEpochShort(last_update.when)
      end

      column_last_rtt = last_update.value
      column_last_ip = last_update.ip
    end

    if(column_last_rtt == "") then chart = "" end

    res[#res + 1] = {
       key = key,
       url = active_monitoring_host.label,
       host = active_monitoring_host.host,
       measurement = active_monitoring_host.measurement,
       chart = chart,
       threshold = active_monitoring_host.max_rtt,
       last_measure = column_last_rtt,
       value_js_formatter = m_info.value_js_formatter,
       last_mesurement_time = column_last_update,
       last_ip = column_last_ip,
       granularity = active_monitoring_host.granularity,
       unit = i18n(m_info.i18n_unit) or m_info.i18n_unit,
    }

    ::continue::
end

-- ################################################

print(json.encode(res))