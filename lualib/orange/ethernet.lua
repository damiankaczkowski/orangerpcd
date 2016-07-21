-- JUCI Lua Backend Server API
-- Copyright (c) 2016 Martin Schröder <mkschreder.uk@gmail.com>. All rights reserved. 
-- This module is distributed under JUCI Genereal Public License as published
-- at https://github.com/mkschreder/oranged/COPYING. See COPYING file for details. 

local orange = require("orange/core"); 

local function network_list_adapters(opts)
	function words(str) 
		local f = {}; 
		local count = 0; 
		for w in str:gmatch("%S+") do table.insert(f, w); count = count + 1; end
		return count,f; 
	end
	
	function ipv4parse(ip)
		if not ip then return "",""; end
		local ip,num = ip:match("([%d\\.]+)/(%d+)"); 
		local mask = "0.0.0.0"; 
		if num then 
			local inet_mask = "255"; 
			for i = 16,32,8 do 
				if i <= tonumber(num) then 
					inet_mask = inet_mask..".255";
				else 
					inet_mask = inet_mask..".0"; 
				end
			end
			mask = inet_mask; 
		end
		return ip,mask; 
	end
	
	function ipv6parse(ip)
		if not ip then return "",""; end
		local ip,num = ip:match("([%w:]+)/(%d+)"); 
		-- TODO: return also mask/prefix? whatever..
		return ip; 
	end
	
	local adapters = {}; 
	local obj = {}; 
	local ip_output = orange.shell("ip addr"); 
	for line in ip_output:gmatch("[^\r\n]+") do
		local count,fields = words(line); 
		if fields[1] then 
			if fields[1]:match("%d+:") then
				if(next(obj) ~= nil) then table.insert(adapters, obj); end
				obj = {}; 
				obj.name = fields[2]:match("([^:@]+)"); -- match until @ in vlan adapters 
				obj.flags = fields[3]:match("<([^>]+)>"); 
				-- parse remaining pairs after flags
				for id = 4,count,2 do
					obj[fields[id]] = fields[id+1]; 
				end
			elseif fields[1]:match("link/.*") then 
				obj.link_type = fields[1]:match("link/(.*)"); 
				obj.macaddr = fields[2]; 
				-- parse remaining pairs after link type
				for id = 3,count,2 do
					obj[fields[id]] = fields[id+1]; 
				end
			elseif fields[1] == "inet" then
				if not obj.ipv4 then obj.ipv4 = {} end
				local ipobj = {}; 
				ipobj.addr,ipobj.mask = ipv4parse(fields[2]); 
				-- parse remaining pairs for ipaddr options
				for id = 3,count,2 do
					ipobj[fields[id]] = fields[id+1]; 
				end
				table.insert(obj.ipv4, ipobj); 
			elseif fields[1] == "inet6" then
				if not obj.ipv6 then obj.ipv6 = {} end
				local ipobj = {}; 
				ipobj.addr = ipv6parse(fields[2]); 
				-- parse remaining pairs for ipaddr options
				for id = 3,count,2 do
					ipobj[fields[id]] = fields[id+1]; 
				end
				table.insert(obj.ipv6, ipobj); 
			else 
				-- all other lines are assumed to consist of only pairs
				for id = 1,count,2 do
					obj[fields[id]] = fields[id+1]; 
				end
			end
		end
	end
	-- add last parsed adapter to the list as well
	if(next(obj) ~= nil) then table.insert(adapters, obj); end
	return adapters; 	
end

return {
	adapters = network_list_adapters
}; 
