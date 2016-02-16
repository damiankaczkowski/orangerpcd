#!/usr/bin/lua

local juci = require("juci.core");
local json = require("juci.json");

local function folder_tree()
	print(json.encode(juci.file.folder_tree()));
end

local function autocomplete(opts)
	local ret = juci.file.autocomplete(opts);
	if(ret == 1) then return ret; end
	print(json.encode(ret));
end

return {
	["folder_tree"] = folder_tree,
	["autocomplete"] = autocomplete,
};
