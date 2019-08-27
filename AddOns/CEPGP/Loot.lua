function CEPGP_LootFrame_Update()
	local items = {};
	local count = 0;
	local numLootItems = LootFrame.numLootItems;
	local texture, item, quantity, quality;
	for index = 1, numLootItems do
		local slot = index;
		if ( slot <= numLootItems ) then	
			if (LootSlotHasItem(slot)) then
				texture, item, quantity, _, quality = GetLootSlotInfo(slot);
				if tostring(GetLootSlotLink(slot)) ~= "nil" or CEPGP_inOverride(item) then
					items[index-count] = {};
					items[index-count][1] = texture;
					items[index-count][2] = item;
					items[index-count][3] = quality;
					items[index-count][4] = GetLootSlotLink(slot);
					local link = GetLootSlotLink(index);
					local itemString = string.find(link, "item[%-?%d:]+");
					itemString = strsub(link, itemString, string.len(link)-string.len(item)-6);
					items[index-count][5] = itemString;
					items[index-count][6] = slot;
					items[index-count][7] = quantity;
				else
					count = count + 1;
				end
			end
		end
	end
	for k, v in pairs(items) do -- k = loot slot number, v is the table result
		if (UnitInRaid("player") or CEPGP_debugMode) and (v[3] > 2 or CEPGP_inOverride(item)) then --or itemsIndex[v[2]]) then
			CEPGP_frame:Show();
			CEPGP_mode = "loot";
			CEPGP_toggleFrame("CEPGP_loot");
			break;
		end
	end
	CEPGP_populateFrame(_, items, numLootItems);
end

function CEPGP_announce(link, x, slotNum, quantity)
	if (GetLootMethod() == "master" and CEPGP_isML() == 0) or CEPGP_debugMode then
		local iString = CEPGP_getItemString(link);
		local name, _, _, _, _, _, _, _, slot, tex = GetItemInfo(iString);
		local id = CEPGP_getItemID(iString);
		CEPGP_itemsTable = {};
		CEPGP_distItemLink = link;
		CEPGP_DistID = id;
		CEPGP_distSlot = slot;
		gp = _G[CEPGP_mode..'itemGP'..x]:GetText();
		CEPGP_lootSlot = slotNum;
		CEPGP_responses = {};
		CEPGP_UpdateLootScrollBar();
		CEPGP_SendAddonMsg("RaidAssistLootDist"..link..","..gp.."\\"..UnitName("player"), "RAID");
		local rank = 0;
		for i = 1, GetNumGroupMembers() do
			if UnitName("player") == GetRaidRosterInfo(i) then
				_, rank = GetRaidRosterInfo(i);
			end
		end
		SendChatMessage("--------------------------", RAID, CEPGP_LANGUAGE);
		if rank > 0 then
			if quantity > 1 then
				SendChatMessage("NOW DISTRIBUTING: x" .. quantity .. " " .. link, "RAID_WARNING", CEPGP_LANGUAGE);
			else
				SendChatMessage("NOW DISTRIBUTING: " .. link, "RAID_WARNING", CEPGP_LANGUAGE);
			end
		else
			if quantity > 1 then
				SendChatMessage("NOW DISTRIBUTING: x" .. quantity .. " " .. link, "RAID", CEPGP_LANGUAGE);
			else
				SendChatMessage("NOW DISTRIBUTING: " .. link, "RAID", CEPGP_LANGUAGE);
			end
		end
		if quantity > 1 then
			SendChatMessage("GP Value: " .. gp .. " (~" .. math.floor(gp/quantity) .. "GP per unit)", RAID, CEPGP_LANGUAGE);
		else
			SendChatMessage("GP Value: " .. gp, RAID, CEPGP_LANGUAGE);
		end
		SendChatMessage("Whisper me " .. CEPGP_keyword .. " for mainspec only", RAID, CEPGP_LANGUAGE);
		SendChatMessage("--------------------------", RAID, CEPGP_LANGUAGE);
		CEPGP_distribute:Show();
		CEPGP_loot:Hide();
		_G["CEPGP_distribute_item_name"]:SetText(link);
		_G["CEPGP_distribute_item_name_frame"]:SetScript('OnClick', function() SetItemRef(iString, name) end);
		_G["CEPGP_distribute_item_tex"]:SetScript('OnEnter', function() GameTooltip:SetOwner(_G["CEPGP_distribute_item_tex"], "ANCHOR_TOPLEFT") GameTooltip:SetHyperlink(iString) GameTooltip:Show() end);
		_G["CEPGP_distribute_item_texture"]:SetTexture(tex);
		_G["CEPGP_distribute_item_tex"]:SetScript('OnLeave', function() GameTooltip:Hide() end);
		_G["CEPGP_distribute_GP_value"]:SetText(gp);
		CEPGP_distributing = true;
	elseif GetLootMethod() == "master" then
		CEPGP_print("You are not the Loot Master.", 1);
		return;
	elseif GetLootMethod() ~= "master" then
		CEPGP_print("The loot method is not Master Looter", 1);
	end
end