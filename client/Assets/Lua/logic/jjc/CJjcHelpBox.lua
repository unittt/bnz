local CJjcHelpBox = class("CJjcHelpBox", CBox)

--宠物、伙伴、好友帮助的Box
function CJjcHelpBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_AddBtn = self:NewUI(1, CButton)
	self.m_IconSp = self:NewUI(2, CSprite)
	self.m_LevelLbl = self:NewUI(3, CLabel)
	self.m_DownBtn = self:NewUI(4, CButton)
	self.m_InfoObj = self:NewUI(5, CObject)
	self.m_SwapBtn = self:NewUI(6, CButton)
	self.m_QualitySp = self:NewUI(7, CSprite)
end

--设置是宠物的时候这个框的内容
function CJjcHelpBox.SetSummonBox(self, summid, summicon, summlv)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(false)
	self.m_SwapBtn:SetActive(false)
	self.m_QualitySp:SetActive(false)

	if summid ~= 0 then
		self.m_IconSp:SpriteAvatar(summicon)
		self.m_LevelLbl:SetText(summlv.."级")
	else
		self.m_AddBtn:SetActive(true)
		self.m_InfoObj:SetActive(false)
	end
end

function CJjcHelpBox.DownSummonState(self, summid, summicon, summlv)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(true)
	self.m_SwapBtn:SetActive(false)
	self.m_QualitySp:SetActive(false)

	if summid ~= 0 then
		self.m_IconSp:SpriteAvatar(summicon)
		self.m_LevelLbl:SetText(summlv.."级")
	else
		self.m_AddBtn:SetActive(true)
		self.m_InfoObj:SetActive(false)
	end
end

--设置目标的宠物内容
function CJjcHelpBox.SetTargetSummonBox(self, summicon, summlv)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(false)
	self.m_SwapBtn:SetActive(false)
	self.m_QualitySp:SetActive(false)

	if summicon ~= 0 then
		self.m_IconSp:SpriteAvatar(summicon)
		self.m_LevelLbl:SetText(summlv.."级")
	else
		self.m_InfoObj:SetActive(false)
	end
end

--设置是伙伴的时候这个框的内容
function CJjcHelpBox.SetBuddyBox(self, oData)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(false)
	self.m_SwapBtn:SetActive(false)
	self.m_IconSp:SpriteAvatar(oData.icon)
	self.m_LevelLbl:SetText(oData.lv.."级")

	local list = {}
	for k,v in pairs(oData) do
		list[k] = v
	end
	if list.type then
		if list.type == 1 then
			self.m_QualitySp:SetActive(false)
		else
			self.m_QualitySp:SetActive(true)
			self.m_QualitySp:SetItemQuality(list.quality)
		end
	else
		self.m_QualitySp:SetActive(true)
		self.m_QualitySp:SetItemQuality(list.quality)
	end
end

function CJjcHelpBox.DownBuddyState(self, oData)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(true)
	self.m_SwapBtn:SetActive(false)
	self.m_IconSp:SpriteAvatar(oData.icon)
	self.m_LevelLbl:SetText(oData.lv.."级")

	local list = {}
	for k,v in pairs(oData) do
		list[k] = v
	end
	if list.type then
		if list.type == 1 then
			self.m_QualitySp:SetActive(false)
		else
			self.m_QualitySp:SetActive(true)
			self.m_QualitySp:SetItemQuality(list.quality)
		end
	else
		self.m_QualitySp:SetActive(true)
		self.m_QualitySp:SetItemQuality(list.quality)
	end
end

function CJjcHelpBox.SwapBuddyState(self, oData)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(true)
	self.m_DownBtn:SetActive(false)
	self.m_SwapBtn:SetActive(true)
	self.m_IconSp:SpriteAvatar(oData.icon)
	self.m_LevelLbl:SetText(oData.lv.."级")

	local list = {}
	for k,v in pairs(oData) do
		list[k] = v
	end
	if list.type then
		if list.type == 1 then
			self.m_QualitySp:SetActive(false)
		else
			self.m_QualitySp:SetActive(true)
			self.m_QualitySp:SetItemQuality(list.quality)
		end
	else
		self.m_QualitySp:SetActive(true)
		self.m_QualitySp:SetItemQuality(list.quality)
	end
end

function CJjcHelpBox.AddBuddyState(self)
	self.m_AddBtn:SetActive(true)
	self.m_InfoObj:SetActive(false)
end

function CJjcHelpBox.AddTargetBuddyState(self)
	self.m_AddBtn:SetActive(false)
	self.m_InfoObj:SetActive(false)
end

--设置是好友的时候这个框的内容
function CJjcHelpBox.SetFriendBox(self)
	
end

return CJjcHelpBox