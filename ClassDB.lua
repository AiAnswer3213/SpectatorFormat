--[[
Blackrock realm name shows up as Blackrock [PvP Only] from GetRealmName() but its not used in unit names
Replaying arenas displays player name as Name (Replay). UnitName returns the realm name so just strip the (replay) from name

For every case of missing realm we assume player realm, saved in a local var at PLAYER_ENTERING_WORLD
For some cases we can find class from Prat_NamesModule,
enable setting:
    /prat > Chat Formatting > PlayerNames > "Keep Lots of Info"

This custom class DB saves every target change and mouseover unit class if UnitIsPlayer.
Maybe add filter for only max level?

TODO: performance considerations for inserts
]]

SPECTATOR_DB = {
    CLASS_DB = {}
}

local PratNamesModule = nil
local playerRealm = nil
local cdbframe = CreateFrame("Frame", "ClassDBFrame", UIParent)
cdbframe:RegisterEvent("PLAYER_TARGET_CHANGED")
cdbframe:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
cdbframe:RegisterEvent("PLAYER_REGEN_DISABLED")
cdbframe:RegisterEvent("PLAYER_REGEN_ENABLED")

cdbframe:RegisterEvent("PLAYER_ENTERING_WORLD")

local pratErrorShown = false
function TryGetClass(name, realm)
    realm = realm or playerRealm
    --print("TryGetClass for " .. name .. " " .. realm)

    if SPECTATOR_DB.CLASS_DB[realm] then
        local class = SPECTATOR_DB.CLASS_DB[realm][name]

        if class then
            return class
        end
    else
        print("No realm table for " .. name .. " " .. realm)
    end

    if not PratNamesModule then
        if not pratErrorShown then
            print("Error: PratNamesModule not found")
            pratErrorShown = true
        end
        return name
    end

    local class = PratNamesModule:getClass(name)
    if class then
        print("Found class from PratNamesModule: " .. name .. " " .. class)
    end
    return class
end

local function InsertClass(name, realm, class)
    if not realm then realm = playerRealm end
    name = name:match("^(%S+)") -- get the name up to first space exclusive

    if not SPECTATOR_DB.CLASS_DB[realm] then
        SPECTATOR_DB.CLASS_DB[realm] = {}
    end
    SPECTATOR_DB.CLASS_DB[realm][name] = class
end

cdbframe:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_TARGET_CHANGED" then
        local name, realm = UnitName("target")
        local _, class = UnitClass("target")
        local isPlayer = UnitIsPlayer("target")
        if name and isPlayer and class then
            InsertClass(name, realm, class)
        end
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        local name, realm = UnitName("mouseover")
        local _, class = UnitClass("mouseover")
        local isPlayer = UnitIsPlayer("mouseover")
        if name and isPlayer and class then
            InsertClass(name, realm, class)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then -- drop these events for combat
        cdbframe:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
        cdbframe:UnregisterEvent("PLAYER_TARGET_CHANGED")
    elseif event == "PLAYER_REGEN_ENABLED" then
        cdbframe:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        cdbframe:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- get the relam name up to first space exclusive
        playerRealm = GetRealmName():match("^(%S+)")
        PratNamesModule = Prat.Addon:GetModule("PlayerNames")
        cdbframe:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
