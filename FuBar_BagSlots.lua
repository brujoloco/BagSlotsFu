-- Global addon object
BagSlotsFu = nil

-- Required libraries
local tablet = AceLibrary("Tablet-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")

-- Localization table
local L = {
	TOOLTIP_TEXT = "Free Slots:",
	BAGSLOTS_HINT = "Left-click to toggle your backpack.\nRight-click for options.",
	BAGSLOTS_FORMAT = "%d / %d",
	MENU_TEXT_COLOR = "Text Color",
	COLOR_WHITE = "White",
	COLOR_GREEN = "Green",
	COLOR_YELLOW = "Yellow",
	PREFIX_TEXT = "Bags: ",
}

-- Color mapping
local colorMap = {
	white = "|cffffffff",
	green = "|cff00ff00",
	yellow = "|cffffff00",
}

-- This function correctly identifies regular bags.
local function isRegularBag(bag)
	if (bag < 0 or bag > 4) then return false end
	if (bag == 0) then return true end

	local itemLink = GetInventoryItemLink("player", ContainerIDToInventoryID(bag))
	if not itemLink then return false end

	local _, _, itemID = string.find(itemLink, "item:(%d+)")
	if itemID then
		-- GetItemInfo is safe to call with a number.
		local _, _, _, _, _, itemSubType = GetItemInfo(tonumber(itemID))
		if itemSubType == "Bag" then
			return true
		end
	end
	return false
end

-- Main addon definition using Ace2
BagSlotsFu = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0", "AceEvent-2.0", "AceDB-2.0")

-- FuBar Plugin properties
BagSlotsFu.hasIcon = true
BagSlotsFu.canHideText = true
BagSlotsFu.hasNoColor = true
BagSlotsFu.cannotDetachTooltip = true

-----------------------------------------------------------------------
-- Addon Methods
-----------------------------------------------------------------------

function BagSlotsFu:OnInitialize()
	self:RegisterDB("FuBar_BagSlotsDB")
	self:RegisterDefaults("profile", {
		textColor = "white",
	})
	self:SetIcon("Interface\\Buttons\\Button-Backpack-Up")
end

function BagSlotsFu:OnEnable()
	self:RegisterEvent("BAG_UPDATE", "Update")
	self:Update()
end

function BagSlotsFu:OnDisable()
	self:UnregisterAllEvents()
end

-- Helper function to get slot counts.
function BagSlotsFu:GetSlotCount()
	local freeSlots, totalSlots = 0, 0
	for i = 0, 4 do
		if isRegularBag(i) then
			local numContainerSlots = GetContainerNumSlots(i)
			if numContainerSlots and numContainerSlots > 0 then
				totalSlots = totalSlots + numContainerSlots
				for slot = 1, numContainerSlots do
					if not GetContainerItemLink(i, slot) then
						freeSlots = freeSlots + 1
					end
				end
			end
		end
	end
	return freeSlots, totalSlots
end

-- Text update function
function BagSlotsFu:OnTextUpdate()
	local freeSlots, totalSlots = self:GetSlotCount()
	local prefix = L.PREFIX_TEXT
	local colorCode = colorMap[self.db.profile.textColor] or colorMap.white
	local numberString = string.format(L.BAGSLOTS_FORMAT, freeSlots, totalSlots)
	local finalText = prefix .. colorCode .. numberString .. "|r"

	self:SetText(finalText)
end

-- Tooltip update function
function BagSlotsFu:OnTooltipUpdate()
	local freeSlots, totalSlots = self:GetSlotCount()

	-- Create a category to hold the content.
	local cat = tablet:AddCategory(
		'columns', 2,
		'child_textR', 1, 'child_textG', 1, 'child_textB', 1,
		'child_text2R', 1, 'child_text2G', 1, 'child_text2B', 1
	)

	cat:AddLine('text', L.TOOLTIP_TEXT, 'text2', string.format(L.BAGSLOTS_FORMAT, freeSlots, totalSlots))
	tablet:SetHint(L.BAGSLOTS_HINT)
end

function BagSlotsFu:OnClick(button)
	if button == "LeftButton" then
		ToggleBackpack()
	end
end

-- Menu request function
function BagSlotsFu:OnMenuRequest(level, value)
	if level == 1 then
		dewdrop:AddLine()
		dewdrop:AddLine(
			'text', L.MENU_TEXT_COLOR,
			'hasArrow', true,
			'value', 'color_menu'
		)
	elseif level == 2 and value == 'color_menu' then
		dewdrop:AddLine(
			'text', L.COLOR_WHITE,
			'isRadio', true,
			'checked', self.db.profile.textColor == 'white',
			'func', function()
				self.db.profile.textColor = 'white'
				self:Update()
			end,
			'closeWhenClicked', true
		)
		dewdrop:AddLine(
			'text', L.COLOR_GREEN,
			'isRadio', true,
			'checked', self.db.profile.textColor == 'green',
			'func', function()
				self.db.profile.textColor = 'green'
				self:Update()
			end,
			'closeWhenClicked', true
		)
		dewdrop:AddLine(
			'text', L.COLOR_YELLOW,
			'isRadio', true,
			'checked', self.db.profile.textColor == 'yellow',
			'func', function()
				self.db.profile.textColor = 'yellow'
				self:Update()
			end,
			'closeWhenClicked', true
		)
	end
end
