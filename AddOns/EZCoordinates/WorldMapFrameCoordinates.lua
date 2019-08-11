local updateInterval = (1 / 30);
local playerPosition;
local mousePosition;
local trackMouse = false;
local lastUpdate = 0;
local localWorldMapFrame = WorldMapFrame;
local isAnyBGActive = false;
local showPreciseValues = false;

function WorldMapFrameCoordinates_OnUpdate(self, elapsed)
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
		WorldMapFramePlayerCoordinatesDisplay:Hide();
		WorldMapFrameMouseCoordinatesDisplay:Hide();
	else
		WorldMapFramePlayerCoordinatesDisplay:Show();
		WorldMapFrameMouseCoordinatesDisplay:Show();
	end
	
	if ((not isAnyBGActive and lastUpdate >= updateInterval)) then
		local currentPlayerPosition = WorldMapFramePlayerCoordinates_GetPlayerLocation();
		
		if (currentPlayerPosition ~= nil and (EZCoordinates_SavedVars.ShowPreciseValues ~= showPreciseValues or not playerPosition or currentPlayerPosition.Map ~= playerPosition.Map or currentPlayerPosition.X ~= playerPosition.X or currentPlayerPosition.Y ~= playerPosition.Y)) then
			playerPosition = currentPlayerPosition;
			
			WorldMapFramePlayerCoordinates_Update();
		end
		
		if (trackMouse) then
			local currentMousePosition  = WorldMapFramePlayerCoordinates_GetMouseLocation();
			if (EZCoordinates_SavedVars.ShowPreciseValues ~= showPreciseValues or not mousePosition or mousePosition.X ~= currentMousePosition.X or mousePosition.Y ~= currentMousePosition.Y) then
				mousePosition = currentMousePosition;

				WorldMapFrameMouseCoordinates_Update();
			end
		end

		lastUpdate = 0;
		showPreciseValues = EZCoordinates_SavedVars.ShowPreciseValues;
	else
		lastUpdate = lastUpdate + elapsed;
	end
end

function WorldMapFrameCoordinates_OnEnter(self)
	trackMouse = true;
end

function WorldMapFrameCoordinates_OnLeave(self)
	trackMouse = false;
	mousePosition = nil;

	if (not isAnyBGActive) then
		WorldMapFrameMouseCoordinates_Update();
	end
end

function WorldMapFramePlayerCoordinates_GetPlayerLocation()
	local map = C_Map.GetBestMapForUnit("player");
	local position = C_Map.GetPlayerMapPosition(map, "player");

	return {
		Map = map,
		X = position.x,
		Y = position.y,
	}
end

function WorldMapFramePlayerCoordinates_GetMouseLocation()
	if (localWorldMapFrame) then
		local x, y = GetCursorPosition();
		local left, top = localWorldMapFrame.ScrollContainer:GetLeft(), localWorldMapFrame.ScrollContainer:GetTop();
		local width = localWorldMapFrame.ScrollContainer:GetWidth();
		local height = localWorldMapFrame.ScrollContainer:GetHeight()
		local scale = localWorldMapFrame.ScrollContainer:GetEffectiveScale();
		local cx = (x/scale - left) / width
		local cy = (top - y/scale) / height

		if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
			cx, cy = nil, nil
		end

		return {
			X = cx,
			Y = cy,
		};
	end
end

function WorldMapFramePlayerCoordinates_Update()
	local positionText = WorldMapFrameCoordinates_GetPositionText(playerPosition);
	
	WorldMapFramePlayerCoordinatesDisplay:SetText("Player: " .. positionText);
end

function WorldMapFrameMouseCoordinates_Update()
	local positionText = WorldMapFrameCoordinates_GetPositionText(mousePosition);
	
	if (positionText ~= nil) then
		WorldMapFrameMouseCoordinatesDisplay:SetText("Mouse: " .. positionText);
	else
		WorldMapFrameMouseCoordinatesDisplay:SetText(nil);
	end
end

function WorldMapFrameCoordinates_GetPositionText(position)
	if (position) then
		local x = position.X and position.X or 0;
		local y = position.Y and position.Y or 0;

		local formatString = "%d, %d";

		if (EZCoordinates_SavedVars.ShowPreciseValues) then
			formatString = "%0.2f,%0.2f";
		end

		local positionText = format("(" .. formatString .. ")", x * 100, y * 100);

		return positionText;
	end
end

localWorldMapFrame.ScrollContainer:SetScript("OnEnter", WorldMapFrameCoordinates_OnEnter);
localWorldMapFrame.ScrollContainer:SetScript("OnLeave", WorldMapFrameCoordinates_OnLeave);