#!/usr/bin/lua

local juci = require("juci/core");
local FILEPATH="/etc/dropbear/authorized_keys"

local function tokenize(str)
	local parts= {};
	local partCnt=0;
	for w in str:gmatch("%S+") do
		partCnt=partCnt + 1;
		table.insert(parts,w);
	end
	return parts
end

local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"));
end

local function dropbear_getpublickeys(opts)
	local res = {};
	local file = io.open(FILEPATH, "r");
	if file then 
		for line in file:lines() do
			local keyParts= tokenize(line);
			-- Generate a id if there is none
			--if (not keyParts[3]) then keyParts[3] = "Key ending with " .. keyParts[2]:sub(-4,-1);end;
			if(keyParts and keyParts[1] and keyParts[2] and keyParts[3]) then
				table.insert ( res,{
					type = keyParts[1],
					key  = keyParts[2],
					id   = keyParts[3]
				});
			end
		end
		file:close();
	end
	print(json.encode({keys=res}));
end

local function dropbear_addpublickey(opts)
	if(not opts["key"]) then print(json.encode({error="err-no-key"})); return; end;

	local keyPart=tokenize(opts["key"]);
	if(not keyPart[1] or not keyPart[2] or not keyPart[3]) then print(json.encode({error="Invalid Key: Missing part"})); return; end

	--check if key is right format
	local keyBaseId=keyPart[2]:sub(1, 16);
	if( not ((keyPart[1] == "ssh-rsa" and  keyBaseId == "AAAAB3NzaC1yc2EA") or (keyPart[1] == "ssh-dss" and keyBaseId == "AAAAB3NzaC1kc3MA"))) then
		 print(json.encode({error="Invalid Key:Malformed format"})); return; end

	local file = io.open(FILEPATH, "a+");
	-- check if key already exists
	local exists = false;
	for line in file:lines() do
		local parts = tokenize(line);
		if(parts[2] == keyPart[2]) then
			exists = true;
			break;
		end
	end
	file:close();
	if(exists) then print(json.encode({error = "Key already exists!"})); return; end

	-- add the new key
	file = io.open(FILEPATH, "a");
	if(not file) then
		print(json.encode({ error = "err-no-file-open" }));
		return;
	end
	file:write(trim(opts.key).."\n");
	file:close();

	print("{}");
end

local function dropbear_removepublickey(opts)
	if(not opts["type"]) then print(json.encode({error="err-no-type"})); return; end;
	if(not opts["id"]) then print(json.encode({status="err-no-id"})); return; end;
	if(not opts["key"]) then print(json.encode({status="err-no-key"})); return; end;

	-- read in keys and then remove the one that matches the line
	local file = io.open(FILEPATH, "r");
	if(file) then 
		local keys = {};
		local found = false;
		for line in file:lines() do
			local parts = tokenize(line);
			if(parts[2] ~= trim(opts.key)) then
				table.insert(keys, line);
			else
				found = true;
			end
		end
		file:close();
		if(not found) then print(json.encode({ error = "Key not found!" })); return; end
		-- TODO: can this be a race condition? What if someone else opens the file right after we have closed it? Any way to avoid it?
		file = io.open(FILEPATH, "w");
		for _,line in ipairs(keys) do
			file:write(line.."\n");
		end
		file:close();
	end
	print("{}");
end

return {
	["get_public_keys"] = dropbear_getpublickeys,
	["add_public_key"] = dropbear_addpublickey,
	["remove_public_key"] = dropbear_removepublickey
};
