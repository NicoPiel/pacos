frame = CreateFrame("Frame", nil, UIParent);
--frame:SetSize(128, 256);

local t = frame:CreateTexture(nil,"BACKGROUND")
t:SetColorTexture(0, 0, 0, 0.5);
t:SetAllPoints(frame);
frame.texture = t;

frame:SetPoint("CENTER", 0, 0);
frame:Show();

frame:EnableMouse(true);
frame:SetMovable(true);

frame:RegisterForDrag("LeftButton");
frame:SetScript("OnDragStart", frame.StartMoving);
frame:SetScript("OnDragStop", frame.StopMovingOrSizing);

--[[ frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("ADDON_LOADED", function(self)
    CreateButtonsForGroup();
end);
frame:RegisterEvent("GROUP_ROSTER_UPDATE");
frame:SetScript("GROUP_ROSTER_UPDATE", function(self)
    CreateButtonsForGroup();
end); ]]
--frame:RegisterEvent("")

-- Main function for testing purposes
function main()
    print(GetNumGroupMembers());
    CreateButtonsForGroup();
end

-- Creates buttons for all Group and Raidmembers (both excluding UnitID:player)
function CreateButtonsForGroup()
    if (IsInGroup() and not IsInRaid()) then
        local member_num = GetNumGroupMembers() - 1;
        if (member_num > 0) then     
            for i = 1, member_num do
                local membername, realm = UnitName(string.format("party%d", i))
                pacos_CreateButton(membername, frame, 0, 32*(1-i));
                frame:SetSize(80, 32*(1-i));
            end
        end
    elseif (IsInRaid()) then
        local member_num = GetNumGroupMembers();
        local playername, playerrealm = UnitName("player");
        local found_player = false;

        if (member_num > 0) then     
            for i = 1, member_num do
                local membername, realm = UnitName(string.format("raid%d", i))
                if (playername == membername) then
                    found_player = true;
                end
				if (not found_player) then
                    pacos_CreateButton(membername, frame, 0, 32*(1-i));
                    frame:SetSize(80, 32*(1-i));
                elseif (found_player) then
					if (playername ~= membername) then
                        pacos_CreateButton(membername, frame, 0, (32*(1-i) + 32))
                        frame:SetSize(80, 32*(1-i));
					end
                end
   
            end                
        end
    end
end

-- All properties for creating a button
function pacos_CreateButton(_name, _frame, _ofsx, _ofsy)
    local button = CreateFrame("Button", nil, _frame);
	local buttonColor = "green";
    button:SetPoint("TOPLEFT", _frame, "TOPLEFT", _ofsx, _ofsy);
    button:SetSize(64, 32);

    button:SetText(_name);
    button:SetNormalFontObject("GameFontNormal");

    local ntex = button:CreateTexture();
    ntex:SetColorTexture(0, 0.5, 0, 0.7);
    ntex:SetAllPoints();
    button:SetNormalTexture(ntex);

    local htex = button:CreateTexture();
    htex:SetColorTexture(0, 0.3, 0, 0.8);
    htex:SetAllPoints();
    button:SetHighlightTexture(htex);

    local ptex = button:CreateTexture();
    ptex:SetColorTexture(0, 0.6, 0, 0.8);
    ptex:SetAllPoints();
    button:SetPushedTexture(ptex);

    button:SetDisabledFontObject(GameFontDisable);

    button:RegisterForClicks("LeftButtonUp");
    button:SetScript("OnClick", function(self)
		if(buttonColor=="green") then
			pacos_ChangeButtonColor(self, "red");
			buttonColor="red";
		elseif(buttonColor=="red")then
			pacos_ChangeButtonColor(self, "green");
			buttonColor="green";
		end
			
    end)

    return button;
end

-- Returns true if player is a tank
function pacos_PlayerIsTank()
    if GetSpecializationRole("player") == "TANK" then
        return true;
    else
        return false;
    end
end

-- Test function to change a button's colour
function pacos_ChangeButtonColor(_button, color)
    local button = _button;
    local ntex = button:CreateTexture();
	if (color=="red") then
		ntex:SetColorTexture(0.9, 0, 0, 0.9);
	elseif(color=="green") then
		ntex:SetColorTexture(0, 0.5, 0, 0.7);
	end
    ntex:SetAllPoints();
    button:SetNormalTexture(ntex);
end


--[[ 
    
status values:
nil = unit is not on otherunit's threat table.
0 = not tanking, lower threat than tank.
1 = not tanking, higher threat than tank.
2 = insecurely tanking, another unit have higher threat but not tanking.
3 = securely tanking, highest threat

isTanking, status, threatpct, rawthreatpct, threatvalue = UnitDetailedThreatSituation("player", "target");

    If tank -> Fenster geht auf
	Fenster beinhaltet: "Gruppenmitglieder"                                                |  Gegner die im Kampf verwickelt sind"
    Klickbare Objekte:  Den angegriffenen Spieler durch Spott auf den Angreifer entlasten  | "Spot" auf das jeweilige Ziel durchführt - (Für jede Klasse individuell)
	Klickbare Objekte:  Färben sich ein wenn Spieler belastet							   |  Bei Aggroverlust leuchtet Namensplakette von Gegner auf (rot) 
]]