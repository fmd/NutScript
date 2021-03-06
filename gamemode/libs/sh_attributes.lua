--[[
	Purpose: A library that adds attributes to the list of them so they can be used in
	character creation and such. Also functions for the player metatable to update
	attributes.
--]]

nut.attribs = nut.attribs or {}
nut.attribs.buffer = {}

--[[
	Purpose: Sets up an attribute, inserts it into the list of attributes, and returns the
	index to be used as an enum.
--]]
function nut.attribs.SetUp(name, desc, uniqueID, setup)
	return table.insert(nut.attribs.buffer, {name = name, desc = desc, uniqueID = uniqueID, setup = setup})
end

--[[
	Purpose: Returns the list of attributes.
--]]
function nut.attribs.GetAll()
	return nut.attribs.buffer
end

--[[
	Purpose: Takes an enum for an attribute and returns the table for the corresponding attribute.
--]]
function nut.attribs.Get(index)
	return nut.attribs.buffer[index]
end

if (SERVER) then
	--[[
		Purpose: Called when the player spawns and calls <attribute>.setup on all of the
		attributes, passing the player and how many points they have for that attribute.
	--]]
	function nut.attribs.OnSpawn(client)
		if (!client.character) then
			return
		end

		for k, v in pairs(nut.attribs.GetAll()) do
			if (v.setup) then
				v.setup(client, client:GetAttrib(k))
			end
		end
	end
end

do
	-- Define some stuff in the player metatable to change or get attributes.
	local playerMeta = FindMetaTable("Player")

	if (SERVER) then
		--[[
			Purpose: Updates the character data to change the specific attribute
			based on the enum passed.
		--]]
		function playerMeta:UpdateAttrib(index, value)
			if (!self.character) then
				return
			end

			-- No point in no change.
			if (value == 0) then
				return
			end

			local attribute = nut.attribs.buffer[index]

			if (attribute) then
				local current = self.character:GetData("attrib_"..attribute.uniqueID, 0)

				self.character:SetData("attrib_"..attribute.uniqueID, current + value)
				
				if (attribute.setup) then
					attribute.setup(self, current + value)
				end
			end
		end
	end

	--[[
		Purpose: Retrieves how many points the player has of a specific attribute
		based off the enum passed.
	--]]
	function playerMeta:GetAttrib(index, default)
		if (!self.character) then
			return default
		end

		local attribute = nut.attribs.buffer[index]

		if (!attribute) then
			return default
		end

		return self.character:GetData("attrib_"..attribute.uniqueID, 0)
	end
end

ATTRIB_ACR = nut.attribs.SetUp("Acrobatics", "Affects how fast high you can jump.", "acr", function(client, points)
	client:SetJumpPower(nut.config.jumpPower + points*5)
end)

ATTRIB_STR = nut.attribs.SetUp("Strength", "Affects how powerful your actions are.", "str")