--[[


		PrivateGroupInvite: Will allow you to enable a privacy feature which will automatically refuse 
				    all group requests from anyone not in your guild/friend list.
				    
		Copyright (C) 2006-2012 Madzen


]]

-- Initialise the Addon
PrivateGroupInvite_Enabled = 1;

local lOriginalUIParent_OnEvent;

----------------------------------------------------------------------------
-- Function to handle initialisation.
-- Registers events, commands and informs the user that the addon is loaded.
----------------------------------------------------------------------------
function PrivateGroupInvite_OnLoad()	
	-- Register slash command
	SlashCmdList["PRIVATEGROUPINVITESLASH"] = PrivateGroupInvite_Cmd;
	SLASH_PRIVATEGROUPINVITESLASH1 = "/privategroupinvite";
	SLASH_PRIVATEGROUPINVITESLASH2 = "/pgi"
	
	-- Register events for loading variables and party requests
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PARTY_INVITE_REQUEST");

	-- Inform user that the addon has been successfully loaded
	if( DEFAULT_CHAT_FRAME ) then
		DEFAULT_CHAT_FRAME:AddMessage("PrivateGroupInvite has been Loaded");
	end
	
	UIErrorsFrame:AddMessage("PrivateGroupInvite", 1.0, 1.0, 1.0, 1.0, UIERRORS_HOLD_TIME);

	lOriginalUIParent_OnEvent = UIParent_OnEvent;
	UIParent_OnEvent = PrivateGroupInvite_UIParent_OnEvent;
end

function PrivateGroupInvite_UIParent_OnEvent(event)
	-- Event triggered when a system message is received.
	if (event == "PARTY_INVITE_REQUEST" and PrivateGroupInvite_Enabled == 1) then
		ShowFriends();

		local PGIisProblem = true; 
		local numFriends = GetNumFriends();
		
		for x = 1, numFriends, 1 do
			--DEFAULT_CHAT_FRAME:AddMessage("Checking Friends List...");
			local name, level, class, area, connected, status = GetFriendInfo(x);
			if (arg1 == name) then
				--DEFAULT_CHAT_FRAME:AddMessage("Found on Friends List");				
				PGIisProblem = false;
			end
		end

		
		if (IsInGuild() and PGIisProblem == true) then
			--DEFAULT_CHAT_FRAME:AddMessage("Checking Guild List...");

			-- Get total number of all online and offline guild members.
			local numOfGuildMembers = GetNumGuildMembers(true);
	
			-- Process loop for each member of the guild.
			for x = 1, numOfGuildMembers, 1 do
				-- Note all guild details.
				local gname, grank, grankIndex, glevel, gclass, gzone, gnote, gofficernote, gonline, gstatus = GetGuildRosterInfo(x);
				if (arg1 == gname) then
					--DEFAULT_CHAT_FRAME:AddMessage("Found on Guild List");
					PGIisProblem = false;
				end				
			end			

		end

		if (PGIisProblem) then
			pgiRefuse = "Your group request has been automatically denied.";
			SendChatMessage(pgiRefuse, "WHISPER", nil, arg1);
			DeclineGroup();
			DEFAULT_CHAT_FRAME:AddMessage("Refused party request from " .. arg1);
		else
			lOriginalUIParent_OnEvent(event);
		end
	else
		lOriginalUIParent_OnEvent(event);
	end
end

------------------------------------------
-- Main event handler.
-- Describes functionality for each event.
------------------------------------------
function PrivateGroupInvite_OnEvent()
	-- Event triggered when all variables have been loaded.
	if (event == "VARIABLES_LOADED") then
		-- Nowt
	end	
end


----------------------------------
-- Handle any slash commands used.
----------------------------------
function PrivateGroupInvite_Cmd(msg)
	-- Convert the command to lowercase for the sake of convenience.
	msg = string.lower(msg);
	
	-- User enables the addon.
	if (msg == "on") then
		PrivateGroupInvite_Enabled = 1;
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> PrivateGroupInvite has been enabled for this character", 1.0, 0.0, 0.0, 1.0, 20);
	-- User disables the addon.
	elseif (msg == "off") then
		PrivateGroupInvite_Enabled = 0;
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> PrivateGroupInvite has been disabled for this character", 1.0, 0.0, 0.0, 1.0, 20);	
	-- User requests help or doesn't provide a parameter.
	elseif (msg == "help" or msg == "") then
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> PrivateGroupInvite Usage:", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> on - Enables PrivateGroupInvite for this character.", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> off - Disables PrivateGroupInvite for this character.", 1.0, 0.0, 0.0, 1.0, 20);
		DEFAULT_CHAT_FRAME:AddMessage("<PrivateGroupInvite> help - Provides this command list.", 1.0, 0.0, 0.0, 1.0, 20);
	end	
end
