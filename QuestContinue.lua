local NAME, S = ...
local VERSION = GetAddOnMetadata(NAME, "Version")
local QuestContinue = LibStub("AceAddon-3.0"):NewAddon("QuestContinue","AceConsole-3.0","AceEvent-3.0")

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = S.L

local defaults = {
	db_version = 2, -- update this on savedvars changes
	enabled = true,
}

local options = {
	type = "group",
	name = format("%s |cffADFF2F%s|r", NAME, VERSION),
	get = function(i) return QuestContinue.db[i[#i]] end,
	set = function(i, v) QuestContinue.db[i[#i]] = v end,
	args = {
		enabled = {
			type = "toggle", order = 1,
			width = "full", desc = "On accepting a quest. Automatically add to tracked list and set to selected",
			name = "Enable",
			get = function(info) return QuestContinue.db.enabled end,
			set = function(info, v)
				QuestContinue.db.enabled = v
				if v then QuestContinue:Enable() else QuestContinue:Disable() end
			end,
			disabled = false,
		},
	},
}

function QuestContinue:QuestAccepted(event, questId)
	C_QuestLog.AddQuestWatch(questId)
	C_SuperTrack.SetSuperTrackedQuestID(questId)
end

function QuestContinue:OnInitialize()
	if not ContinueQuestDB or ContinueQuestDB.db_version ~= defaults.db_version then
		ContinueQuestDB = CopyTable(defaults)
	end
	self.db = ContinueQuestDB
	self.db.version = VERSION
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(NAME, options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions(NAME, NAME)
end

function QuestContinue:OnEnable()
	if not self.db.enabled then
		self:Disable()
		return
	end

	self:RegisterEvent("QUEST_ACCEPTED", "QuestAccepted")
end

function QuestContinue:OnDisable()
	self:UnregisterEvent("QUEST_ACCEPTED")
end

