
local PitBull4 = _G.PitBull4
local L = PitBull4.L

local EXAMPLE_VALUE = 0.3

local PitBull4_ReputationBar = PitBull4:NewModule("ReputationBar")

PitBull4_ReputationBar:SetModuleType("bar")
PitBull4_ReputationBar:SetName(L["Reputation bar"])
PitBull4_ReputationBar:SetDescription(L["Show a reputation bar."])
PitBull4_ReputationBar:SetDefaults({
	size = 1,
	position = 3,
})

function PitBull4_ReputationBar:GetValue(frame)
	if frame.unit ~= "player" then
		return nil
	end

	local name, _, min, max, value, id = GetWatchedFactionInfo()
	if not name then
		return nil
	end
	-- Normalize values
	max = max - min
	value = value - min
	min = 0
	local y = max - min
	if y == 0 then
		return 0
	end
	return (value - min) / y
end
function PitBull4_ReputationBar:GetExampleValue(frame)
	if frame and frame.unit ~= "player" then
		return nil
	end
	return EXAMPLE_VALUE
end

function PitBull4_ReputationBar:GetColor(frame, value)
	local _, reaction, _, _, _, id = GetWatchedFactionInfo()
	local color = PitBull4.ReactionColors[reaction]
	if color then
		return color[1], color[2], color[3]
	end
end
function PitBull4_ReputationBar:GetExampleColor(frame)
	local color = PitBull4.ReactionColors[5]
	return color[1], color[2], color[3]
end

local function Update()
	if not PitBull4_ReputationBar:IsEnabled() then return end
	for frame in PitBull4:IterateFramesForUnitID("player") do
		PitBull4_ReputationBar:Update(frame)
	end
end
hooksecurefunc("MainMenuBar_UpdateExperienceBars", Update)
