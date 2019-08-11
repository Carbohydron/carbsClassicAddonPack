local updateInterval = (1 / 30);
local playerPosition;
local lastUpdate = 0;
local isAnyBGActive = false;
local showPreciseValues = false;

function MinimapCoordinates_OnUpdate(self, elapsed)
	local maxBattlefieldId = GetMaxBattlefieldID();
	local isBGActive = false;

	for i=1, maxBattlefieldId do
		local status = GetBattlefieldStatus(i);

		if (status == "active") then
			isBGActive = true
			break;
		end
	end

	isAnyBGActive = isBGActive;

	if (isAnyBGActive) then
		LocationManagerDisplay:Hide();
	else
		LocationManagerDisplay:Show();
	end

	if (not isAnyBGActive and lastUpdate >= updateInterval) then
		local currentPlayerPosition = MinimapCoordinates_GetPlayerLocation();
		
		if (currentPlayerPosition ~= nil and (EZCoordinates_SavedVars.ShowPreciseValues ~= showPreciseValues or not playerPosition or currentPlayerPosition.Map ~= playerPosition.Map or currentPlayerPosition.X ~= playerPosition.X or currentPlayerPosition.Y ~= playerPosition.Y)) then
			playerPosition = currentPlayerPosition;
			
			MinimapCoordinates_Update();
		end

		lastUpdate = 0;
		showPreciseValues = EZCoordinates_SavedVars.ShowPreciseValues;
	else
		lastUpdate = lastUpdate + elapsed;
	end
end

function MinimapCoordinates_GetPlayerLocation()
	local map = C_Map.GetBestMapForUnit("player");
	local position = C_Map.GetPlayerMapPosition(map, "player");

	if (position == nil) then
		return nil;
	end

	return {
		Map = map,
		X = position.x,
		Y = position.y,
	}
end

function MinimapCoordinates_Update()
	local positionText = LocationManager_GetPositionText(playerPosition);
	
	LocationManagerDisplay:SetText(positionText);
end

function LocationManager_GetPositionText(position)
	local x = position.X and position.X or 0;
	local y = position.Y and position.Y or 0;
	
	local formatString = "%d, %d";

	if (EZCoordinates_SavedVars.ShowPreciseValues) then
		formatString = "%0.2f,%0.2f";
	end

	local positionText = format("(" .. formatString .. ")", x * 100, y * 100);

	return positionText;
end