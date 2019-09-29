local XPTracker = LibStub("AceAddon-3.0"):GetAddon("XPTracker")
local L = LibStub("AceLocale-3.0"):GetLocale("XPTracker")

local ConfigMenu = XPTracker:GetModule("ConfigMenu")

local function getOptions()
  local profile = XPTracker.db.profile
  options = {
    name = "XPTracker",
    type = "group",
    args = {
      general = {
        type = "group",
        inline = true,
        name = "",
        args = {
          lockWindow = {
            name = "Lock Window",
            desc = "Lock the GUI window in place",
            type = "toggle",
            set = function(info, val)
              profile.MainWindow.IsLocked = val
              ConfigMenu:HandleMainWindowMovement()
            end,
            get = function(info) return profile.MainWindow.IsLocked end
          }
        }
      }
    },
  }
  return options
end

function ConfigMenu:HandleMainWindowMovement()
  local isLocked = XPTracker.db.profile.MainWindow.IsLocked
  XPTracker.MainWindow:SetMovable(not isLocked)
  if isLocked then
    XPTracker.MainWindow:RegisterForDrag()
  else
    XPTracker.MainWindow:RegisterForDrag("LeftButton")
  end
end

function ConfigMenu:RegisterConfigMenu()
  LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("XPTracker Options", getOptions())
  LibStub("AceConfigDialog-3.0"):AddToBlizOptions("XPTracker Options", "XPTracker", nil, "general")
end
