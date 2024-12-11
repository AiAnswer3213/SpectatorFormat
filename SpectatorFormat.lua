--[[
Default UI format example
Main window:
  Spectate live 2vs2 games
  Spectate live 3vs3 games
  Spectate live 5vs5 games
  Spectate live Solo Queue games
  Spectate live game by Player Name
  Replay a Match ID
  Replay list by Player Name
  Replay top 2vs2 games of the last 7 days
  Replay top 3vs3 games of the last 7 days
  Replay top Solo Queue games of the last 7 days

Spectate live 2vs2 games:
  Pick a game to spectate from the list below.

  (1758) Blackrock Dawin Nodrod -VS- Blackrock Nodnavos Zampv (1847)
  (1781) Blackrock Speerolittle Devilzed -VS- Blackrock Tronerblakea Thonhwiller (1772)

Spectate live 3vs3 games:
  Pick a game to spectate from the list below.

  (1545) Onyxia Riarkapat Pacitoahdes Dalmun -VS- Blackrock Shxdshee Raderxloott Shas (1621)

Replay...:
  These menus dont contain the player names, only team names in '' quotes
  We want to skip all of these
  Such as:
  (1999) 'theeblah' -VS- 'blackcoocks strikes' (2093)

Max line length: 
  based on character size
  example max length text:
    ABCD ABCD ABCD ABCD ABCD ABCDEFGHI
    34 upper characters including spaces

Frame names:
  GossipTitleButton1
  GossipTitleButton2
  ...

Scratch:
  for more space remove the icon somehow.
  reposition text to the left
  /run GossipTitleButton1:GetFontString():SetPoint("LEFT", GossipTitleButton1, "LEFT", 5, 0)
  widen text. maybe works
  /run GossipTitleButton1:GetFontString():SetWidth(GossipTitleButton1:GetWidth())
]]

local NPC_NAME = "Arena Spectator"
local MATCH_GOSIP_TEXT_LIST = "Pick a game to spectate from the list below."
local MATCH_NUM_PARTS = {
  [9] = "2v2",
  [11] = "3v3",
  [15] = "5v5",
}

local classTilemap = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"

local sfframe = CreateFrame("Frame", "SpectatorFormatFrame", UIParent)
sfframe:RegisterEvent("GOSSIP_SHOW")

local function StringReverse(str)
  -- reverse all characters. lower case all. upper case first
  return str:reverse():lower():gsub("^%l", string.upper)
end

local function ReformatName(name, realm)
  local class = TryGetClass(name, realm)

  if not class then
    print("No class for " .. name)
    return string.format("|T%s:10:10:0:0|t%s", "Interface\\Icons\\INV_Misc_QuestionMark", name)
  end

  -- The class icons are tilemapped. This functionality here finds the coordinates and adds the icon from the tilemap in to a textstring formatting magic whatever
  -- 10 is the size in unknown units
  local x0, x1, y0, y1 = unpack(CLASS_BUTTONS[class])
  return string.format("|T%s:10:10:0:0:256:256:%d:%d:%d:%d|t%s", classTilemap, x0*256, x1*256, y0*256, y1*256, name)

  -- local classTextColor = RAID_CLASS_COLORS[class]
  -- local hexClassColor = format("ff%02X%02X%02X", 255 * classTextColor.r, 255 * classTextColor.g, 255 * classTextColor.b)
  -- return format("|c%s%s|r", hexClassColor, name)
end

local function MapVarargsArg1(func, arg1, ...)
  local outputs = {}
  local inputs = {...}
  for i, input in ipairs(inputs) do
    outputs[i] = func(input, arg1)
  end
  return unpack(outputs)
end

local function ReformatText(input)
  -- if the text contains ' character, we want to skip
  if input:find("'") then
    return input
  end

  local arenaType = MATCH_NUM_PARTS[select(2, input:gsub("%S+", ""))]

  if not arenaType then
    return input
  end

  local text = ""

  -- naming convention: left team and right team
  if (arenaType == "2v2") then
    local matchStr = "%((%d+)%) (%a+) (%a+) (%a+) %-VS%- (%a+) (%a+) (%a+) %((%d+)%)"
    local lrating, lrealm, lname1, lname2, rrealm, rname1, rname2, rrating = input:match(matchStr)
    -- to disable the classes just skip this. if enable classes then ... or whatev
    lname1, lname2 = MapVarargsArg1(ReformatName, lrealm, lname1, lname2)
    rname1, rname2 = MapVarargsArg1(ReformatName, rrealm, rname1, rname2)
    lrealm = lrealm:sub(1, 4)
    rrealm = rrealm:sub(1, 4)
    text = string.format("%s %s [%s:%s]\n%s %s [%s:%s]", lname1, lname2, lrealm, lrating, rname1, rname2, rrealm, rrating)
  end

  if (arenaType == "3v3") then
    local matchStr = "%((%d+)%) (%a+) (%a+) (%a+) (%a+) %-VS%- (%a+) (%a+) (%a+) (%a+) %((%d+)%)"
    local lrating, lrealm, lname1, lname2, lname3, rrealm, rname1, rname2, rname3, rrating = input:match(matchStr)
    lname1, lname2, lname3 = MapVarargsArg1(ReformatName, lrealm, lname1, lname2, lname3)
    rname1, rname2, rname3 = MapVarargsArg1(ReformatName, rrealm, rname1, rname2, rname3)
    lrealm = lrealm:sub(1, 1)
    rrealm = rrealm:sub(1, 1)
    text = string.format("%s %s %s [%s:%s]\n%s %s %s [%s:%s]", lname1, lname2, lname3, lrealm, lrating, rname1, rname2, rname3, rrealm, rrating)
  end

  if (arenaType == "5v5") then
    local matchStr = "%((%d+)%) (%a+) (%a+) (%a+) (%a+) (%a+) %-VS%- (%a+) (%a+) (%a+) (%a+) (%a+) %((%d+)%)"
    local lrating, lrealm, lname1, lname2, lname3, lname4, lname5, rrealm, rname1, rname2, rname3, rname4, rname5, rrating = input:match(matchStr)
    lname1, lname2, lname3, lname4, lname5 = MapVarargsArg1(ReformatName, lrealm, lname1, lname2, lname3, lname4, lname5)
    rname1, rname2, rname3, rname4, rname5 = MapVarargsArg1(ReformatName, rrealm, rname1, rname2, rname3, rname4, rname5)
    -- these long maps generated by AI and not tested or read
    text = string.format("%s %s %s %s %s [%s:%s]\n%s %s %s %s %s [%s:%s]", lname1, lname2, lname3, lname4, lname5, lrealm, lrating, rname1, rname2, rname3, rname4, rname5, rrealm, rrating)
  end

  return text
end

local function OnGossipShow()
  local gossipText = GetGossipText()
  if (gossipText ~= MATCH_GOSIP_TEXT_LIST) then
    return
  end

  local numOptions = GetNumGossipOptions()
  local frameName = "GossipTitleButton"

  for i = 1, numOptions do
    local button = _G[frameName..i]
    if not button then
      print("Error: " .. button .. " not found")
      return
    end

    local text = button:GetText()
    text = ReformatText(text)
    button:SetText(text)
  end
end

sfframe:SetScript("OnEvent", function(self, event, ...)
  if event == "GOSSIP_SHOW" then
    OnGossipShow()
  end
end)