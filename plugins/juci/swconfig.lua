#!/usr/bin/lua

-- JUCI Lua Backend Server API
-- Copyright (c) 2016 Martin Schröder <mkschreder.uk@gmail.com>. All rights reserved. 
-- This module is distributed under GNU GPLv3 with additional permission for signed images.
-- See LICENSE file for more details. 

local juci = require("juci/core"); 
local json = require("juci/json"); 

local function get_port_status()
	local links = juci.shell("swconfig dev switch0 show | grep link"); 
	local state = { ports = {} }; 
	for line in links:gmatch("[^\r\n]+") do 
		-- link: port:4 link:up speed:1000baseT full-duplex auto
		-- link: port:4 link:down
		local id,status = line:match("%s+link:%s+port:(%d+)%s+link:(%S+).*"); 
		if(id and status) then 
			table.insert(state.ports, { 
				id = tonumber(id), 
				state = status
			}); 
		end
	end
	return state; 
end

return {
	status = get_port_status
}; 
