#!/usr/bin/lua

local juci = require("juci/core"); 
local network = require("juci/network"); 

local function fields(str)
	local words = {}; 
	for w in str:gmatch("%S+") do 
		table.insert(words, w); 
	end
	return words; 
end

local function network_status_arp()
	local output = juci.readfile("/proc/net/arp"); 
	local clients = {}; 
	for line in output:gmatch("[^\r\n]+") do 
		local words = fields(line); 
		if(words[1] and words[1]:match("%d\\.%d\\.%d\\.%d")) then 
			table.insert(clients, {
				ipaddr = words[1], 
				hw = words[2], 
				flags = words[3], 
				macaddr = words[4],
				mask = words[5], 
				device = words[6]
			}); 
		end
	end
	print(json.encode({ clients = clients })); 
end

local function network_status_ipv4routes()
	local output = juci.shell("route -n"); 
	local routes = {}; 
	for line in output:gmatch("[^\r\n]+") do 
		local words = fields(line); 
		if(words[1] and words[1]:match("%d\\.%d\\.%d\\.%d")) then 
			table.insert(routes, {
				destination = words[1], 
				gateway = words[2], 
				mask = words[3], 
				flags = words[4],
				metric = words[5], 
				ref = words[6], 
				use = words[7], 
				iface = words[8]
			}); 
		end
	end
	print(json.encode({ routes = routes })); 
end

local function network_status_ipv6routes()
	local output = juci.shell("route -A inet6"); 
	local routes = {}; 
	for line in output:gmatch("[^\r\n]+") do 
		local words = fields(line); 
		if(words[1] and words[1]:match("[%a:]+/%d+")) then 
			table.insert(routes, {
				destination = words[1], 
				next_hop = words[2], 
				flags = words[3], 
				metric = words[4], 
				ref = words[5], 
				use = words[6], 
				iface = words[7]
			}); 
		end
	end
	print(json.encode({ routes = routes })); 
end

local function network_status_ipv6neigh()
	local neigh = network.ipv6neigh(); 
	print(json.encode({ neighbors = neigh })); 
end

return {
	["arp"] = network_status_arp,
	["ipv4routes"] = network_status_ipv4routes, 
	["ipv6routes"] = network_status_ipv6routes,
	["ipv6neigh"] = network_status_ipv6neigh
}; 
