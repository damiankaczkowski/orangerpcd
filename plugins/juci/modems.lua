#!/usr/bin/lua

local juci = require("juci/core"); 
local PATH = "/tmp/usbnets"

function list_modems()
	local data = juci.shell("ls /dev/tty*S*");
	local modems = {};
	for line in data:gmatch("[^\r\n]+") do
		table.insert(modems, line);
	end
	if next(modems) == nil then
		data = juci.shell("ls /dev/tts/*");
		for line in data:gmatch("[\r\n]+") do
			table.insert(modems, line);
		end
	end
	print(json.encode({ modems = modems }));
end

function list_4g_modems()
	local file = io.open(PATH, "r");
	if(file == nil) then
		print(json.encode({info = "could not open file"}));
		return;
	end;
	local modems = {};
	local tmp = {};
	for line in io.lines(PATH) do
		tmp = {};
		for word in line:gmatch("%S+") do table.insert(tmp, word) end
		local name = "";
		for i=8,100,1
		do
			if tmp[i] then
				name = name..tmp[i].." ";
			else
				break;
			end
		end
		table.insert(modems, {service=tmp[7], dev=tmp[6], name=name, ifname=tmp[5]});
		if next(modems) then
			print(json.encode({modems = modems}));
			return;
		end
	end
	print(json.encode({info = "no data"}));
end

return {
	["list"] = list_modems,
	["list4g"] = list_4g_modems
}; 
