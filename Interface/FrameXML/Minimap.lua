MINIMAPPING_TIMER = 5.5;
MINIMAPPING_FADE_TIMER = 0.5;
MINIMAP_BOTTOM_EDGE_EXTENT = 192;	-- pixels from the top of the screen to the bottom edge of the minimap, needed for UIParentManageFramePositions

MINIMAP_RECORDING_INDICATOR_ON = false;

MINIMAP_EXPANDER_MAXSIZE = 28;
HUNTER_TRACKING = 1;
TOWNSFOLK = 2;

GARRISON_ALERT_CONTEXT_BUILDING = 1;
GARRISON_ALERT_CONTEXT_MISSION = {
	[Enum.GarrisonFollowerType.FollowerType_6_0_GarrisonFollower] = 2,
	[Enum.GarrisonFollowerType.FollowerType_6_0_Boat] = 4,
	[Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower] = 5,
	[Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower] = 6,

	-- TODO:: Replace with the correct flash.
	[Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower] = 6,
};
GARRISON_ALERT_CONTEXT_INVASION = 3;

MinimapZoneTextButtonMixin = { };

function MinimapZoneTextButtonMixin:OnLoad()
	self.tooltipText = MicroButtonTooltipText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP");
	self:RegisterEvent("UPDATE_BINDINGS");
end

function MinimapZoneTextButtonMixin:OnEvent()
	self.tooltipText = MicroButtonTooltipText(WORLDMAP_BUTTON, "TOGGLEWORLDMAP");
end

function MinimapZoneTextButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
	Minimap_SetTooltip( pvpType, factionName );
	GameTooltip:AddLine(self.tooltipText);
	GameTooltip:Show();
end

function MinimapZoneTextButtonMixin:OnClick()
	ToggleWorldMap();
end

function MinimapZoneTextButtonMixin:OnLeave()
	GameTooltip_Hide();
end

MinimapMixin = { };

function MinimapMixin:OnLoad()
	self.fadeOut = nil;
	self:RegisterEvent("MINIMAP_PING");
	self:RegisterEvent("MINIMAP_UPDATE_ZOOM");
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function MinimapMixin:OnClick()
	local x, y = GetCursorPosition();
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local cx, cy = self:GetCenter();
	x = x - cx;
	y = y - cy;
	if ( sqrt(x * x + y * y) < (self:GetWidth() / 2) ) then
		Minimap:PingLocation(x, y);
	end
end

function MinimapMixin:OnMouseWheel(d)
	if d > 0 then
		Minimap_ZoomIn();
	elseif d < 0 then
		Minimap_ZoomOut();
	end
end

function ToggleMinimap()
	if(Minimap:IsShown()) then
		PlaySound(SOUNDKIT.IG_MINIMAP_CLOSE);
		Minimap:Hide();
	else
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN);
		Minimap:Show();
	end
	UpdateUIPanelPositions();
end

function Minimap_Update()
	MinimapZoneText:SetText(GetMinimapZoneText());

	local pvpType, isSubZonePvP, factionName = GetZonePVPInfo();
	if ( pvpType == "sanctuary" ) then
		MinimapZoneText:SetTextColor(0.41, 0.8, 0.94);
	elseif ( pvpType == "arena" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "friendly" ) then
		MinimapZoneText:SetTextColor(0.1, 1.0, 0.1);
	elseif ( pvpType == "hostile" ) then
		MinimapZoneText:SetTextColor(1.0, 0.1, 0.1);
	elseif ( pvpType == "contested" ) then
		MinimapZoneText:SetTextColor(1.0, 0.7, 0.0);
	else
		MinimapZoneText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	Minimap_SetTooltip( pvpType, factionName );
end

function Minimap_SetTooltip( pvpType, factionName )
	if ( GameTooltip:IsOwned(MinimapCluster.ZoneTextButton) ) then
		GameTooltip:SetOwner(MinimapCluster.ZoneTextButton, "ANCHOR_LEFT");
		local zoneName = GetZoneText();
		local subzoneName = GetSubZoneText();
		if ( subzoneName == zoneName ) then
			subzoneName = "";
		end
		GameTooltip:AddLine( zoneName, 1.0, 1.0, 1.0 );
		if ( pvpType == "sanctuary" ) then
			GameTooltip:AddLine( subzoneName, 0.41, 0.8, 0.94 );
			GameTooltip:AddLine(SANCTUARY_TERRITORY, 0.41, 0.8, 0.94);
		elseif ( pvpType == "arena" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
			GameTooltip:AddLine(FREE_FOR_ALL_TERRITORY, 1.0, 0.1, 0.1);
		elseif ( pvpType == "friendly" ) then
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine( subzoneName, 0.1, 1.0, 0.1 );
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 0.1, 1.0, 0.1);
			end
		elseif ( pvpType == "hostile" ) then
			if (factionName and factionName ~= "") then
				GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
				GameTooltip:AddLine(format(FACTION_CONTROLLED_TERRITORY, factionName), 1.0, 0.1, 0.1);
			end
		elseif ( pvpType == "contested" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.7, 0.0 );
			GameTooltip:AddLine(CONTESTED_TERRITORY, 1.0, 0.7, 0.0);
		elseif ( pvpType == "combat" ) then
			GameTooltip:AddLine( subzoneName, 1.0, 0.1, 0.1 );
			GameTooltip:AddLine(COMBAT_ZONE, 1.0, 0.1, 0.1);
		else
			GameTooltip:AddLine( subzoneName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b );
		end
		GameTooltip:Show();
	end
end

function MinimapMixin:OnEvent(event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self:UpdateBlips();
	elseif ( event == "MINIMAP_PING" ) then
		local arg1, arg2, arg3 = ...;
		Minimap_SetPing(arg2, arg3, 1);
	elseif ( event == "MINIMAP_UPDATE_ZOOM" ) then
		self.ZoomIn:Enable();
		self.ZoomOut:Enable();
		local zoom = Minimap:GetZoom();
		if ( zoom == (Minimap:GetZoomLevels() - 1) ) then
			self.ZoomIn:Disable();
		elseif ( zoom == 0 ) then
			self.ZoomOut:Disable();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if C_Minimap.ShouldUseHybridMinimap() then
			if not HybridMinimap then
				UIParentLoadAddOn("Blizzard_HybridMinimap");
			end
			C_Minimap.GetUiMapID = function() return C_Map.GetBestMapForUnit("player"); end
			HybridMinimap:Enable();
			HybridMinimap:CheckMap();
		else
			if HybridMinimap then
				HybridMinimap:Disable();
			end
		end
	end
end

function MinimapMixin:OnEnter()
	self:SetScript("OnUpdate", Minimap_OnUpdate);

	if(not DISABLE_MAP_ZOOM) then 
	self.ZoomIn:Show();
	self.ZoomOut:Show();
	end
end

function MinimapMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	GameTooltip:Hide();
	if not self.ZoomIn:IsMouseOver() and not self.ZoomOut:IsMouseOver() and not self.ZoomHitArea:IsMouseOver() then
		self.ZoomIn:Hide();
		self.ZoomOut:Hide();
	end
end

function Minimap_OnUpdate(self)
	GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR");
	GameTooltip:SetMinimapMouseover();
end

function Minimap_SetPing(x, y, playSound)
	if ( playSound ) then
		PlaySound(SOUNDKIT.MAP_PING);
	end
end

MinimapZoomInButtonMixin = { };

function MinimapZoomInButtonMixin:OnClick()
	Minimap.ZoomOut:Enable();
	PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_IN);
	Minimap:SetZoom(Minimap:GetZoom() + 1);
	if(Minimap:GetZoom() == (Minimap:GetZoomLevels() - 1)) then
		Minimap.ZoomIn:Disable();
	end
end

function MinimapZoomInButtonMixin:OnEnter()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(ZOOM_IN);
	end
end

function MinimapZoomInButtonMixin:OnLeave()
	GameTooltip_Hide();
end

MinimapZoomOutButtonMixin = { };

function MinimapZoomOutButtonMixin:OnClick()
	Minimap.ZoomIn:Enable();
	PlaySound(SOUNDKIT.IG_MINIMAP_ZOOM_OUT);
	Minimap:SetZoom(Minimap:GetZoom() - 1);
	if(Minimap:GetZoom() == 0) then
		Minimap.ZoomOut:Disable();
	end
end

function MinimapZoomOutButtonMixin:OnEnter()
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(ZOOM_OUT);
	end
end

function MinimapZoomOutButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function Minimap_ZoomIn()
	Minimap.ZoomIn:Click();
end

function Minimap_ZoomOut()
	Minimap.ZoomOut:Click();
end

MinimapClusterMixin = { };

function MinimapClusterMixin:OnLoad()
	Minimap.timer = 0;
	Minimap_Update();
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_INDOORS");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("SETTINGS_LOADED");
	local raisedFrameLevel = self:GetFrameLevel() + 10;
	self.InstanceDifficulty:SetFrameLevel(raisedFrameLevel);

	-- Cache minimap piece points so we can reset them if needed
	local function CacheFramePoints(frame)
		frame.defaultFramePoints = {};
		for i = 1, frame:GetNumPoints() do
			local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(i);
			frame.defaultFramePoints[i] = { point = point, relativeTo = relativeTo, relativePoint = relativePoint, offsetX = offsetX, offsetY = offsetY };
		end
	end
	CacheFramePoints(self.MinimapContainer);
	CacheFramePoints(self.BorderTop);
	CacheFramePoints(self.InstanceDifficulty);
	CacheFramePoints(self.IndicatorFrame);
end

function MinimapClusterMixin:OnEvent(event, ...)
	if event == "SETTINGS_LOADED" then
		self:CheckTutorials();
	end
	Minimap_Update();
end

function MinimapClusterMixin:CheckTutorials()
	if not self:IsShown() then
		return;
	end
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HUD_REVAMP_TRACKING_CHANGES) then
		local helpTipInfo = {
			text = TUTORIAL_HUD_REVAMP_TRACKING_CHANGES,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_HUD_REVAMP_TRACKING_CHANGES,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetX = 0,
			alignment = HelpTip.Alignment.Right,
			onAcknowledgeCallback = GenerateClosure(self.CheckTutorials, self),
			useParentStrata	= false,
		};
		HelpTip:Show(UIParent, helpTipInfo, self.Tracking);
	end
end

local function ResetFramePoints(frame, accountForFrameScale)
	local scale = accountForFrameScale and frame:GetScale() or 1;

	frame:ClearAllPoints();
	for i, value in ipairs(frame.defaultFramePoints) do
		frame:SetPoint(value.point, value.relativeTo, value.relativePoint, value.offsetX / scale, value.offsetY / scale);
	end
end

function MinimapClusterMixin:SetHeaderUnderneath(headerUnderneath)
	if (headerUnderneath) then
		-- Since minimap container can be scaled, account for it's scale when setting offsets
		local scale = self.MinimapContainer:GetScale();
		self.MinimapContainer:ClearAllPoints();
		self.MinimapContainer:SetPoint("BOTTOM", self, "BOTTOM", 10 / scale, 30 / scale);

		self.BorderTop:ClearAllPoints();
		self.BorderTop:SetPoint("BOTTOM", self, "BOTTOM", 15, 2);

		self.InstanceDifficulty:ClearAllPoints();
		self.InstanceDifficulty:SetPoint("BOTTOMRIGHT", self.BorderTop, "TOPRIGHT", -2, -2);

		self.IndicatorFrame:ClearAllPoints();
		self.IndicatorFrame:SetPoint("BOTTOMRIGHT", self.Tracking, "TOPRIGHT");
	else
		local accountForFrameScaleYes = true;
		ResetFramePoints(self.MinimapContainer, accountForFrameScaleYes);
		ResetFramePoints(self.BorderTop);
		ResetFramePoints(self.InstanceDifficulty);
		ResetFramePoints(self.IndicatorFrame);
	end

	self.InstanceDifficulty:SetFlipped(headerUnderneath);
end

function MinimapClusterMixin:SetRotateMinimap(rotateMinimap)
	SetCVar("rotateMinimap", rotateMinimap);
end


function MiniMapIndicatorFrame_UpdatePosition()
	if MinimapCluster.Tracking:IsShown() then
		MinimapCluster.IndicatorFrame:SetPoint("TOPRIGHT", MinimapCluster.Tracking, "BOTTOMRIGHT", 2, -1);
	else
		MinimapCluster.IndicatorFrame:SetPoint("TOPRIGHT", MinimapCluster.BorderTop, "TOPLEFT", -1, -1);
	end
end


MiniMapMailFrameMixin = { };

function MiniMapMailFrameMixin:OnLoad()
	self:RegisterEvent("UPDATE_PENDING_MAIL");
	self:SetFrameLevel(self:GetFrameLevel()+1);
end

function MiniMapMailFrameMixin:OnEvent(event)
	if ( event == "UPDATE_PENDING_MAIL" ) then
		if ( HasNewMail() ) then
			self:Show();
			self:TryPlayMailNotification();

			if( GameTooltip:IsOwned(self) ) then
				MinimapMailFrameUpdate();
			end
		else
			self:Hide();
		end
		self:GetParent():Layout();
	end
end

function MiniMapMailFrameMixin:OnHide()
	self:ResetMailIcon();
end

function MiniMapMailFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	if( GameTooltip:IsOwned(self) ) then
		MinimapMailFrameUpdate();
	end
end

function MiniMapMailFrameMixin:OnLeave()
	GameTooltip_Hide();
end

function MinimapMailFrameUpdate()
	local senders = { GetLatestThreeSenders() };
	local headerText = #senders >= 1 and HAVE_MAIL_FROM or HAVE_MAIL;
	FormatUnreadMailTooltip(GameTooltip, headerText, senders);
	GameTooltip:Show();
end

function MiniMapMailFrameMixin:ResetMailIcon()
	self.NewMailAnim:SetPlaying(false);
	self.MailReminderAnim:SetPlaying(false);
	self.MailIcon:SetShown(false);
end

function MiniMapMailFrameMixin:TryPlayMailNotification()
	if self.NewMailAnim:IsPlaying() or self.MailReminderAnim:IsPlaying() then
		return;
	end

	local alreadyNotifiedOfNewMail = GetCVarBool("notifiedOfNewMail");
	if alreadyNotifiedOfNewMail then
		self.MailReminderAnim:Restart();
	else
		self.NewMailAnim:Restart();
		SetCVar("notifiedOfNewMail", true);
	end
end

MinimapMailAnimMixin = {};

function MinimapMailAnimMixin:OnPlay()
	MiniMapMailIcon:SetShown(false);
end

function MinimapMailAnimMixin:OnFinished()
	MiniMapMailIcon:SetShown(HasNewMail());
end

MiniMapCraftingOrderFrameMixin = {};

function MiniMapCraftingOrderFrameMixin:OnLoad()
	self:RegisterEvent("CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetFrameLevel(self:GetFrameLevel()+1);
end

function MiniMapCraftingOrderFrameMixin:OnEvent(event)
	if ( event == "CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS" or event == "PLAYER_ENTERING_WORLD" ) then
		self.countInfos = C_CraftingOrders.GetPersonalOrdersInfo();
		if ( #self.countInfos > 0 ) then
			self:Show();
		else
			self:Hide();
		end
		self:GetParent():Layout();
	end
end

function MiniMapCraftingOrderFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	local wrap = false;
	GameTooltip_AddNormalLine(GameTooltip, MAILFRAME_CRAFTING_ORDERS_TOOLTIP_TITLE, wrap);
	for _, countInfo in ipairs(self.countInfos) do
		GameTooltip_AddNormalLine(GameTooltip, PERSONAL_CRAFTING_ORDERS_AVAIL_FMT:format(countInfo.numPersonalOrders, countInfo.professionName), wrap);
	end
	GameTooltip:Show();
end

function MiniMapCraftingOrderFrameMixin:OnLeave()
	GameTooltip_Hide();
end


MiniMapTrackingButtonMixin = { };

function MiniMapTrackingButtonMixin:OnLoad()
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:Update();
end

function MiniMapTrackingButtonMixin:OnEvent(event, arg1)
	if event == "MINIMAP_UPDATE_TRACKING" then
		self:Update();
	end
end

function MiniMapTrackingButtonMixin:Update()
	if UIDROPDOWNMENU_OPEN_MENU == MinimapCluster.Tracking.DropDown then
		UIDropDownMenu_RefreshAll(MinimapCluster.Tracking.DropDown);
	end
end

function MiniMapTrackingButtonMixin:Show(shown)
	MinimapCluster.Tracking:SetShown(shown);
	if MinimapCluster.IndicatorFrame then
		MiniMapIndicatorFrame_UpdatePosition();
	end
end

function MiniMapTrackingButtonMixin:OnMouseDown()
	MinimapCluster.Tracking.DropDown.point = "TOPRIGHT";
	MinimapCluster.Tracking.DropDown.relativePoint = "BOTTOMLEFT";
	ToggleDropDownMenu(1, nil, MinimapCluster.Tracking.DropDown, MinimapCluster.Tracking, 8, 5);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function MiniMapTrackingButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(TRACKING, 1, 1, 1);
	GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE, nil, nil, nil, true);
	GameTooltip:Show();
end

function MiniMapTrackingButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function MiniMapTrackingDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, MiniMapTrackingDropDown_Initialize, "MENU");
	self.noResize = true;
end

function MiniMapTrackingDropDown_SetTracking(self, id, unused, on)
	C_Minimap.SetTracking(id, on);

	UIDropDownMenu_Refresh(MinimapCluster.Tracking.DropDown);
end

function MiniMapTrackingDropDown_IsActive(button)
	local name, texture, active, category = C_Minimap.GetTrackingInfo(button.arg1);
	return active;
end

function MiniMapTrackingDropDown_IsNoTrackingActive()
	local name, texture, active, category;
	local count = C_Minimap.GetNumTrackingTypes();
	for id=1, count do
		name, texture, active, category  = C_Minimap.GetTrackingInfo(id);
		if (active) then
			return false;
		end
	end
	return true;
end

local REMOVED_FILTERS = {
	[Enum.MinimapTrackingFilter.VenderFood] = true,
	[Enum.MinimapTrackingFilter.VendorReagent] = true,
	[Enum.MinimapTrackingFilter.POI] = true,
	[Enum.MinimapTrackingFilter.Focus] = true,
};

local ALWAYS_ON_FILTERS = {
	[Enum.MinimapTrackingFilter.QuestPoIs] = true,
	[Enum.MinimapTrackingFilter.TaxiNode] = true,
	[Enum.MinimapTrackingFilter.Innkeeper] = true,
	[Enum.MinimapTrackingFilter.ItemUpgrade] = true,
	[Enum.MinimapTrackingFilter.Battlemaster] = true,
	[Enum.MinimapTrackingFilter.Stablemaster] = true,
};

local CONDITIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Target] = true,
	[Enum.MinimapTrackingFilter.Digsites] = true,
	[Enum.MinimapTrackingFilter.Repair] = true,
};

local OPTIONAL_FILTERS = {
	[Enum.MinimapTrackingFilter.Banker] = true,
	[Enum.MinimapTrackingFilter.Auctioneer] = true,
	[Enum.MinimapTrackingFilter.Barber] = true,
	[Enum.MinimapTrackingFilter.TrainerProfession] = true,
	[Enum.MinimapTrackingFilter.TrivialQuests] = true,
	[Enum.MinimapTrackingFilter.Transmogrifier] = true,
	[Enum.MinimapTrackingFilter.Mailbox] = true,
};

local LOW_PRIORITY_TRACKING_SPELLS = {
	[261764] = true; -- Track Warboards
};

local TRACKING_SPELL_OVERRIDE_TEXTURES = {
	[43308] = "professions_tracking_fish";-- Find Fish
	[2580] = "professions_tracking_ore"; -- Find Minerals 1
	[8388] = "professions_tracking_ore"; -- Find Minerals 2
	[2383] = "professions_tracking_herb"; -- Find Herbs 1
	[8387] = "professions_tracking_herb"; -- Find Herbs 2
};

function MiniMapTrackingDropDown_SetTrackingNone()
	C_Minimap.ClearAllTracking();
	
	local count = C_Minimap.GetNumTrackingTypes();
	for id=1, count do
		local filter = C_Minimap.GetTrackingFilter(id);
		if ALWAYS_ON_FILTERS[filter.filterID] or CONDITIONAL_FILTERS[filter.filterID] then
			C_Minimap.SetTracking(id, true);
		end
	end
	
	UIDropDownMenu_Refresh(MinimapCluster.Tracking.DropDown);
end

function MiniMapTracking_FilterIsVisible(id)
	local filter = C_Minimap.GetTrackingFilter(id);
	local optionalFilter = filter and OPTIONAL_FILTERS[filter.filterID];
	local filterIsSpell = filter and filter.spellID;
	local filterTypeIsVisible = optionalFilter or filterIsSpell;
	return filterTypeIsVisible;
end

function MiniMapTrackingDropDown_Initialize(self, level)
	local name, texture, active, category, nested, numTracking;
	local count = C_Minimap.GetNumTrackingTypes();
	local info;
	local _, class = UnitClass("player");

	local showAll = GetCVarBool("minimapTrackingShowAll");

	if (level == 1) then
		info = UIDropDownMenu_CreateInfo();
		info.text = MINIMAP_TRACKING_NONE;
		info.checked = MiniMapTrackingDropDown_IsNoTrackingActive;
		info.func = MiniMapTrackingDropDown_SetTrackingNone;
		info.icon = nil;
		info.arg1 = nil;
		info.isNotRadio = true;
		info.keepShownOnClick = true;
		UIDropDownMenu_AddButton(info, level);
		UIDropDownMenu_AddSeparator(level);

		if (class == "HUNTER") then --only show hunter dropdown for hunters
			numTracking = 0;
			-- make sure there are at least two options in dropdown
			for id=1, count do
				name, texture, active, category, nested = C_Minimap.GetTrackingInfo(id);
				if (nested == HUNTER_TRACKING and category == "spell") then
					numTracking = numTracking + 1;
				end
			end
			if (numTracking > 1) then
				info.text = HUNTER_TRACKING_TEXT;
				info.func =  nil;
				info.notCheckable = true;
				info.keepShownOnClick = false;
				info.hasArrow = true;
				info.value = HUNTER_TRACKING;
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end

	if (level == 1 and showAll) then
		info.text = TOWNSFOLK_TRACKING_TEXT;
		info.func =  nil;
		info.notCheckable = true;
		info.keepShownOnClick = false;
		info.hasArrow = true;
		info.value = TOWNSFOLK;
		UIDropDownMenu_AddButton(info, level)
	end

	local trackingInfos = { };
	for id=1, count do
		name, texture, active, category, nested, spellID = C_Minimap.GetTrackingInfo(id);

		if showAll or MiniMapTracking_FilterIsVisible(id) then
			-- Remove nested townsfold unless showing all
			if nested == TOWNSFOLK and not showAll then
				nested = -1;
			end

			info = UIDropDownMenu_CreateInfo();
			info.text = name;
			info.checked = MiniMapTrackingDropDown_IsActive;
			info.func = MiniMapTrackingDropDown_SetTracking;
			info.icon = TRACKING_SPELL_OVERRIDE_TEXTURES[spellID] or texture;
			info.arg1 = id;
			info.isNotRadio = true;
			info.keepShownOnClick = true;

			if ( category == "spell" ) then
				info.tCoordLeft = 0.0625;
				info.tCoordRight = 0.9;
				info.tCoordTop = 0.0625;
				info.tCoordBottom = 0.9;
			else
				info.tCoordLeft = 0;
				info.tCoordRight = 1;
				info.tCoordTop = 0;
				info.tCoordBottom = 1;
			end
			if (level == 1 and
				(nested < 0 or -- this tracking shouldn't be nested
				(nested == HUNTER_TRACKING and class ~= "HUNTER") or
				(numTracking == 1 and category == "spell"))) then -- this is a hunter tracking ability, but you only have one
				table.insert(trackingInfos, info);
			elseif (level == 2 and (nested == TOWNSFOLK or (nested == HUNTER_TRACKING and class == "HUNTER")) and nested == UIDROPDOWNMENU_MENU_VALUE) then
				table.insert(trackingInfos, info);
			end
		end
	end

	table.sort(trackingInfos, function(a, b)
		-- Sort low priority tracking spells to the end
		local filterA = C_Minimap.GetTrackingFilter(a.arg1);
		local filterB = C_Minimap.GetTrackingFilter(b.arg1);
		local lowPriorityA = LOW_PRIORITY_TRACKING_SPELLS[filterA.spellID] or false;
		local lowPriorityB = LOW_PRIORITY_TRACKING_SPELLS[filterB.spellID] or false;
		if lowPriorityA ~= lowPriorityB then
			return not lowPriorityA;
		end

		-- Sort by id
		return a.arg1 < b.arg1;
	end);

	for _, info in ipairs(trackingInfos) do
		UIDropDownMenu_AddButton(info, level);
	end

end

ExpansionLandingPageMinimapButtonMixin = { };

local GarrisonLandingPageEvents = {
	"GARRISON_SHOW_LANDING_PAGE",
	"GARRISON_HIDE_LANDING_PAGE",
	"GARRISON_BUILDING_ACTIVATABLE",
	"GARRISON_BUILDING_ACTIVATED",
	"GARRISON_ARCHITECT_OPENED",
	"GARRISON_MISSION_FINISHED",
	"GARRISON_MISSION_NPC_OPENED",
	"GARRISON_SHIPYARD_NPC_OPENED",
	"GARRISON_INVASION_AVAILABLE",
	"GARRISON_INVASION_UNAVAILABLE",
	"SHIPMENT_UPDATE",
	"PLAYER_ENTERING_WORLD",
};

function ExpansionLandingPageMinimapButtonMixin:OnLoad()
	EventRegistry:RegisterCallback("ExpansionLandingPage.OverlayChanged", self.RefreshButton, self);

	self.pulseLocks = {};

	FrameUtil.RegisterFrameForEvents(self, GarrisonLandingPageEvents);
	self.garrisonMode = true;
end

function ExpansionLandingPageMinimapButtonMixin:IsInGarrisonMode()
	return self.garrisonMode;
end

function ExpansionLandingPageMinimapButtonMixin:RefreshButton()
	if ExpansionLandingPage:IsOverlayApplied() then
		if self.garrisonMode then
			if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
				HideUIPanel(GarrisonLandingPage);
			end
			self:ClearPulses();
			FrameUtil.UnregisterFrameForEvents(self, GarrisonLandingPageEvents);
			self.garrisonMode = false;
		end
		
		self:Hide();
		self:UpdateIcon();
		self:Show();
	end
end

function ExpansionLandingPageMinimapButtonMixin:OnShow()
	EventRegistry:RegisterCallback("ExpansionLandingPage.TriggerPulseLock", self.TriggerPulseLock, self);
	EventRegistry:RegisterCallback("ExpansionLandingPage.HidePulse", self.HidePulse, self);
	EventRegistry:RegisterCallback("ExpansionLandingPage.ClearPulses", self.ClearPulses, self);
	EventRegistry:RegisterCallback("ExpansionLandingPage.TriggerAlert", self.TriggerAlert, self);
end

function ExpansionLandingPageMinimapButtonMixin:OnHide()
	EventRegistry:UnregisterCallback("ExpansionLandingPage.TriggerPulseLock", self);
	EventRegistry:UnregisterCallback("ExpansionLandingPage.HidePulse", self);
	EventRegistry:UnregisterCallback("ExpansionLandingPage.ClearPulses", self);
	EventRegistry:UnregisterCallback("ExpansionLandingPage.TriggerAlert", self);
end


function ExpansionLandingPageMinimapButtonMixin:OnEvent(event, ...)
	if self.garrisonMode and tContains(GarrisonLandingPageEvents, event) then
		self:HandleGarrisonEvent(event, ...);
	end
end

local function SetLandingPageIconFromAtlases(self, up, down, highlight, glow, useDefaultButtonSize)
	local width, height;
	if useDefaultButtonSize then
		width = self.defaultWidth;
		height = self.defaultHeight;
		self.LoopingGlow:SetSize(self.defaultGlowWidth, self.defaultGlowHeight);
	else
		local info = C_Texture.GetAtlasInfo(up);
		width = info and info.width or 0;
		height = info and info.height or 0;
	end
	self:SetSize(width, height);

	local useAtlasSize = not useDefaultButtonSize;
	self:GetNormalTexture():SetAtlas(up, useAtlasSize);
	self:GetPushedTexture():SetAtlas(down, useAtlasSize);
	self:GetHighlightTexture():SetAtlas(highlight, useAtlasSize);
	self.LoopingGlow:SetAtlas(glow, useAtlasSize);
end

function ExpansionLandingPageMinimapButtonMixin:UpdateIcon()
	if self.garrisonMode then
		self:UpdateIconForGarrison();
	else
		local minimapDisplayInfo = ExpansionLandingPage:GetOverlayMinimapDisplayInfo();
		if minimapDisplayInfo then
			SetLandingPageIconFromAtlases(self, minimapDisplayInfo.normalAtlas, minimapDisplayInfo.pushedAtlas, minimapDisplayInfo.highlightAtlas, minimapDisplayInfo.glowAtlas, minimapDisplayInfo.useDefaultButtonSize);
			self.title = minimapDisplayInfo.title;
			self.description = minimapDisplayInfo.description;
		end
	end
end

function ExpansionLandingPageMinimapButtonMixin:OnClick(button)
	self:ToggleLandingPage();
end

function ExpansionLandingPageMinimapButtonMixin:ToggleLandingPage()
	if self.garrisonMode then
		GarrisonLandingPage_Toggle();
		GarrisonMinimap_HideHelpTip(self);
	else
		ToggleExpansionLandingPage();
	end
end

function ExpansionLandingPageMinimapButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(self.title, 1, 1, 1);
	GameTooltip:AddLine(self.description, nil, nil, nil, true);
	GameTooltip:Show();
end

function ExpansionLandingPageMinimapButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ExpansionLandingPageMinimapButtonMixin:SetPulseLock(lock, enabled)
	self.pulseLocks[lock] = enabled;
end

function ExpansionLandingPageMinimapButtonMixin:TriggerPulseLock(lock)
	local enabled = true;
	self:SetPulseLock(lock, enabled)
	self.MinimapLoopPulseAnim:Play();
end

-- We play an animation on the minimap icon for a number of reasons, but only want to turn the
-- animation off if the user handles all actions related to that alert. For example if we play the animation
-- because a garrison building can be activated and then another because a garrison invasion has occurred,  we want to
-- turn off the animation after they handle both the building and invasion, but not if they handle only one.
-- We always stop the pulse when they click on the landing page icon.

function ExpansionLandingPageMinimapButtonMixin:HidePulse(lock)
	self:SetPulseLock(lock, false);
	local enabled = false;
	for k, v in pairs(self.pulseLocks) do
		if ( v ) then
			enabled = true;
			break;
		end
	end

	-- If there are no other reasons to show the pulse, hide it
	if (not enabled) then
		self.MinimapLoopPulseAnim:Stop();
	end
end

function ExpansionLandingPageMinimapButtonMixin:ClearPulses()
	for k, v in pairs(self.pulseLocks) do
		self.pulseLocks[k] = false;
	end
	self.MinimapLoopPulseAnim:Stop();
end

function ExpansionLandingPageMinimapButtonMixin:TriggerAlert(text)
	self.AlertText:SetText(text);
	self:JustifyText(self.AlertText);
	self.MinimapAlertAnim:Play();
end

function ExpansionLandingPageMinimapButtonMixin:JustifyText(text)
	--Center justify if we're on more than one line
	if ( text:GetNumLines() > 1 ) then
		text:SetJustifyH("CENTER");
	else
		text:SetJustifyH("RIGHT");
	end
end

-------------------- Garrison Specific ------------------------

local function GetMinimapAtlases_GarrisonType8_0(faction)
	if faction == "Horde" then
		return "bfa-landingbutton-horde-up", "bfa-landingbutton-horde-down", "bfa-landingbutton-horde-diamondhighlight", "bfa-landingbutton-horde-diamondglow";
	else
		return "bfa-landingbutton-alliance-up", "bfa-landingbutton-alliance-down", "bfa-landingbutton-alliance-shieldhighlight", "bfa-landingbutton-alliance-shieldglow";
	end
end

local garrisonTypeAnchors = {
	["default"] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", 5, -162),
	[Enum.GarrisonType.Type_9_0_Garrison] = AnchorUtil.CreateAnchor("TOPLEFT", "MinimapBackdrop", "TOPLEFT", -3, -150),
}

local function GetGarrisonTypeAnchor(garrisonType)
	return garrisonTypeAnchors[garrisonType or "default"] or garrisonTypeAnchors["default"];
end

local function ApplyGarrisonTypeAnchor(self, garrisonType)
	local anchor = GetGarrisonTypeAnchor(garrisonType);
	local clearAllPoints = true;
	anchor:SetPoint(self, clearAllPoints);
end

local garrisonType9_0AtlasFormats = {
	"shadowlands-landingbutton-%s-up",
	"shadowlands-landingbutton-%s-down",
	"shadowlands-landingbutton-%s-highlight",
	"shadowlands-landingbutton-%s-glow",
};

local function GetMinimapAtlases_GarrisonType9_0(covenantData)
	local kit = covenantData and covenantData.textureKit or "kyrian";
	if kit then
		local t = garrisonType9_0AtlasFormats;
		return t[1]:format(kit), t[2]:format(kit), t[3]:format(kit), t[4]:format(kit);
	end
end

function ExpansionLandingPageMinimapButtonMixin:HandleGarrisonEvent(event, ...)
	if (event == "GARRISON_HIDE_LANDING_PAGE") then
		self:Hide();
	elseif (event == "GARRISON_SHOW_LANDING_PAGE") then
		self:UpdateIcon();
		self:Show();
	elseif ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		local buildingName, garrisonType = ...;
		if ( garrisonType == C_Garrison.GetLandingPageGarrisonType() ) then
			GarrisonMinimapBuilding_ShowPulse(self);
		end
	elseif ( event == "GARRISON_BUILDING_ACTIVATED" or event == "GARRISON_ARCHITECT_OPENED") then
		self:HidePulse(GARRISON_ALERT_CONTEXT_BUILDING);
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		local followerType = ...;
		if ( DoesFollowerMatchCurrentGarrisonType(followerType) ) then
			GarrisonMinimapMission_ShowPulse(self, followerType);
		end
	elseif ( event == "GARRISON_MISSION_NPC_OPENED" ) then
		local followerType = ...;
		self:HidePulse(GARRISON_ALERT_CONTEXT_MISSION[followerType]);
	elseif ( event == "GARRISON_SHIPYARD_NPC_OPENED" ) then
		self:HidePulse(GARRISON_ALERT_CONTEXT_MISSION[Enum.GarrisonFollowerType.FollowerType_6_0_Boat]);
	elseif (event == "GARRISON_INVASION_AVAILABLE") then
		if ( C_Garrison.GetLandingPageGarrisonType() == Enum.GarrisonType.Type_6_0_Garrison ) then
			GarrisonMinimapInvasion_ShowPulse(self);
		end
	elseif (event == "GARRISON_INVASION_UNAVAILABLE") then
		self:HidePulse(GARRISON_ALERT_CONTEXT_INVASION);
	elseif (event == "SHIPMENT_UPDATE") then
		local shipmentStarted, isTroop = ...;
		if (shipmentStarted) then
			GarrisonMinimapShipmentCreated_ShowPulse(self, isTroop);
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		self.isInitialLogin = ...;
		if self.isInitialLogin then
			EventRegistry:RegisterCallback("CovenantCallings.CallingsUpdated", GarrisonMinimap_OnCallingsUpdated, self);
			CovenantCalling_CheckCallings();
		end
	end
end

function ExpansionLandingPageMinimapButtonMixin:UpdateIconForGarrison()
	local garrisonType = C_Garrison.GetLandingPageGarrisonType();
	self.garrisonType = garrisonType;

	ApplyGarrisonTypeAnchor(self, garrisonType);

	if (garrisonType == Enum.GarrisonType.Type_6_0_Garrison) then
		self.faction = UnitFactionGroup("player");
		if ( self.faction == "Horde" ) then
			self:GetNormalTexture():SetAtlas("GarrLanding-MinimapIcon-Horde-Up", true);
			self:GetPushedTexture():SetAtlas("GarrLanding-MinimapIcon-Horde-Down", true);
		else
			self:GetNormalTexture():SetAtlas("GarrLanding-MinimapIcon-Alliance-Up", true);
			self:GetPushedTexture():SetAtlas("GarrLanding-MinimapIcon-Alliance-Down", true);
		end
		self.title = GARRISON_LANDING_PAGE_TITLE;
		self.description = MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_7_0_Garrison) then
		local _, className = UnitClass("player");
		self:GetNormalTexture():SetAtlas("legionmission-landingbutton-"..className.."-up", true);
		self:GetPushedTexture():SetAtlas("legionmission-landingbutton-"..className.."-down", true);
		self.title = ORDER_HALL_LANDING_PAGE_TITLE;
		self.description = MINIMAP_ORDER_HALL_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_8_0_Garrison) then
		self.faction = UnitFactionGroup("player");
		SetLandingPageIconFromAtlases(self, GetMinimapAtlases_GarrisonType8_0(self.faction));
		self.title = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE;
		self.description = GARRISON_TYPE_8_0_LANDING_PAGE_TOOLTIP;
	elseif (garrisonType == Enum.GarrisonType.Type_9_0_Garrison) then
		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
		if covenantData then
			SetLandingPageIconFromAtlases(self, GetMinimapAtlases_GarrisonType9_0(covenantData));
		end

		self.title = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE;
		self.description = GARRISON_TYPE_9_0_LANDING_PAGE_TOOLTIP;
	end
end

function GarrisonLandingPage_Toggle()
	if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
		HideUIPanel(GarrisonLandingPage);
	else
		ShowGarrisonLandingPage(C_Garrison.GetLandingPageGarrisonType());
	end
end

function GarrisonMinimapBuilding_ShowPulse(self)
	self:SetPulseLock(GARRISON_ALERT_CONTEXT_BUILDING, true);
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimapMission_ShowPulse(self, followerType)
	self:SetPulseLock(GARRISON_ALERT_CONTEXT_MISSION[followerType], true);
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimapInvasion_ShowPulse(self)
	PlaySound(SOUNDKIT.UI_GARRISON_TOAST_INVASION_ALERT);
	self.AlertText:SetText(GARRISON_LANDING_INVASION_ALERT);
	self:JustifyText(self.AlertText);
	self:SetPulseLock(GARRISON_ALERT_CONTEXT_INVASION, true);
	self.MinimapAlertAnim:Play();
	self.MinimapLoopPulseAnim:Play();
end

function GarrisonMinimapShipmentCreated_ShowPulse(self, isTroop)
    local text;
    if (isTroop) then
        text = GARRISON_LANDING_RECRUITMENT_STARTED_ALERT;
    else
        text = GARRISON_LANDING_SHIPMENT_STARTED_ALERT;
    end

	self.AlertText:SetText(text);
	self:JustifyText(self.AlertText);
	self.MinimapAlertAnim:Play();
end

function GarrisonMinimap_ShowCovenantCallingsNotification(self)
	self.AlertText:SetText(COVENANT_CALLINGS_AVAILABLE);
	self:JustifyText(self.AlertText);
	self.MinimapAlertAnim:Play();
	self.MinimapLoopPulseAnim:Play();

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS) then
		GarrisonMinimap_SetQueuedHelpTip(self, {
			text = FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 0,
			useParentStrata = true,
		});
	end
end

function GarrisonMinimap_OnCallingsUpdated(self, callings, completedCount, availableCount)
	if self.isInitialLogin then
		if availableCount > 0 then
			GarrisonMinimap_ShowCovenantCallingsNotification(self);
		end

		self.isInitialLogin = false;
	end
end

function GarrisonMinimap_SetQueuedHelpTip(self, tipInfo)
	self.queuedHelpTip = tipInfo;
end

function GarrisonMinimap_CheckQueuedHelpTip(self)
	if self.queuedHelpTip then
		local tip = self.queuedHelpTip;
		self.queuedHelpTip = nil;
		HelpTip:Show(self, tip);
	end
end

function GarrisonMinimap_ClearQueuedHelpTip(self)
	if self.queuedHelpTip and self.queuedHelpTip.text == FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS then
		self.queuedHelpTip = nil;
	end
end

function GarrisonMinimap_HideHelpTip(self)
	if self.garrisonType == Enum.GarrisonType.Type_9_0_Garrison then
		HelpTip:Acknowledge(self, FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS);
		GarrisonMinimap_ClearQueuedHelpTip(self, FRAME_TUTORIAL_9_0_GRRISON_LANDING_PAGE_BUTTON_CALLINGS);
	end
end