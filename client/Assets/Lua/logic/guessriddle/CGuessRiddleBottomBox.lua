local CGuessRiddleBottomBox = class("CGuessRiddleBottomBox", CBox)

function CGuessRiddleBottomBox.ctor(self, obj)
	-- body
	CBox.ctor(self, obj)
	self:InitContent()
end

function CGuessRiddleBottomBox.InitContent(self)
	
	self.m_PopBtn = self:NewUI(1, CSprite)
	self.m_FoldRank = self:NewUI(2, CBox) --排行展开
	self.m_UnfoldRank = self:NewUI(3, CBox)  --排行收缩
	self.m_MyInfo = self:NewUI(4, CLabel)
	self.m_RankGrid = self:NewUI(5, CGrid)
	self.m_LabelBox = self:NewUI(6, CBox)

	self.m_RewardGrid = self:NewUI(7, CGrid)
	self.m_ItemCell = self:NewUI(8, CBox)
	self.m_SkillBox = self:NewUI(9, CBox)
	self.m_KickBox = self:NewUI(10, CHfdmSkillBox)
	self.m_AnchorBox = self:NewUI(11, CHfdmSkillBox)
	self.m_RewardLabel = self:NewUI(12, CLabel)
	self.m_ReBtn = self:NewUI(13, CSprite)
	self.m_SkillInfoBox = self:NewUI(14, CBox)
	self.m_infoBoxicon = self.m_SkillInfoBox:NewUI(1, CSprite)
	self.m_infoboxname = self.m_SkillInfoBox:NewUI(2, CLabel)
	self.m_infoboxdes =  self.m_SkillInfoBox:NewUI(3, CLabel)
	self.m_TipBtn  = self:NewUI(15, CButton)
	
	g_UITouchCtrl:TouchOutDetect(self.m_SkillInfoBox, callback(self.m_SkillInfoBox, "SetActive", false))

	self:InitMyReward()
	self:InitEvent()
	self:InitSkill()
	self:RefreshMyInfo()
	self:RefreshRankUI()
end

function CGuessRiddleBottomBox.InitMyReward(self)
	local rewardList = self.m_RewardGrid:GetChildList()
	local rewarddate = {}
	for i,v in ipairs(data.rewarddata.HFDMREWARD) do
		if v.idx == 10003 then
			table.insert(rewarddate, v)
		end
	end
	
	for i,v in ipairs(rewarddate) do
		local itemcell = nil
		if i>#rewardList then
			itemcell = self.m_ItemCell:Clone()
			self.m_RewardGrid:AddChild(itemcell)
			itemcell:SetActive(true)
			itemcell:SetGroup(self.m_RewardGrid:GetInstanceID())
			itemcell.icon = itemcell:NewUI(1, CSprite)
			itemcell.num = itemcell:NewUI(2, CLabel)
			local itemdata = DataTools.GetItemData(v.sid)
			itemcell.icon:SetSpriteName(itemdata.icon)
			itemcell.num:SetText(v.amount)
			itemcell.icon:AddUIEvent("click", callback(self, "ShowItemInfo", v.sid, itemcell))
		else
			itemcell = rewardList[i]
		end
	end
	self.m_ItemCell:SetActive(false)
end

function CGuessRiddleBottomBox.ShowItemInfo(self, info, item)
	local config = {widget = item} 
	g_WindowTipCtrl:SetWindowItemTip(info, config)
end

function CGuessRiddleBottomBox.InitEvent(self)
	self.m_ReBtn:AddUIEvent("click", callback(self, "OnReBtn"))
	self.m_PopBtn:AddUIEvent("click", callback(self, "OnPopRank"))
	self.m_TipBtn:AddUIEvent("click", callback(self, "OnTipsBtn"))
end

function CGuessRiddleBottomBox.OnReBtn(self)
	local oView = CGuessRiddleView:GetView()
	if oView then
		oView.m_TopPart:SetActive(true)
		self.m_UnfoldRank:SetActive(true)
		self.m_FoldRank:SetActive(true)
		self.m_SkillBox:SetActive(true)
		self.m_PopBtn:SetActive(true)
		self.m_ReBtn:SetActive(false)
	end
	g_GuessRiddleCtrl.m_CanKickPlayer = false
	self.m_KickBox:DestroyKickEffect()
end

function CGuessRiddleBottomBox.OnPopRank(self)
	local tweenbtnPos  	 =  self.m_PopBtn:GetComponent(classtype.TweenPosition)
	local tweenbtnRot  	 =  self.m_PopBtn:GetComponent(classtype.TweenRotation)
	local tweenUnFoldPos = 	self.m_UnfoldRank:GetComponent(classtype.TweenPosition)
	
	local tweenFoldPos   =  self.m_FoldRank:GetComponent(classtype.TweenPosition)
	local tweenFoldAlp   = 	self.m_FoldRank:GetComponent(classtype.TweenAlpha)
	
	local tweenSkillPos  =	self.m_SkillBox:GetComponent(classtype.TweenPosition)
	tweenbtnPos:Toggle()
	tweenbtnRot:Toggle()
	tweenUnFoldPos:Toggle()
	tweenFoldPos:Toggle()
	tweenFoldAlp:Toggle()
	tweenSkillPos:Toggle()
end


function CGuessRiddleBottomBox.OnTipsBtn(self)
	-- body
	local Id = 10032
	if data.instructiondata.DESC[Id]~=nil then
		local Content = {
		 title = data.instructiondata.DESC[Id].title,
	 	 desc = data.instructiondata.DESC[Id].desc
		}
		g_WindowTipCtrl:SetWindowInstructionInfo(Content)
	end
end

function CGuessRiddleBottomBox.InitSkill(self)
	local data = DataTools.GetScheduleSkill("HFDMSKILL")
	self.m_AnchorBox:SetData(data[1001])
	self.m_KickBox:SetData(data[1002])
end

function CGuessRiddleBottomBox.RefreshRankUI(self, data)
	if not data then
		return
	end
	self.m_RankGrid:Clear()
	local list = self.m_RankGrid:GetChildList()
	for i,v in ipairs(data) do
		local rank = nil
		if i>#list then
			rank = self.m_LabelBox:Clone()
			-- rank:SetGroup(self.m_RankGrid:GetInstanceID())
			rank:SetActive(true)
			self.m_RankGrid:AddChild(rank)
			rank.name = rank:NewUI(1, CLabel)
			rank.score = rank:NewUI(2, CLabel)
			if v.pid == g_AttrCtrl.pid then
				rank.score:SetColor(Color.RGBAToColor("FF9E14FF"))
				rank.name:SetColor(Color.RGBAToColor("FF9E14FF"))
			end
			-- rank:SetText(v.rank.." "..v.name.." "..v.score)
			rank.name:SetText(v.rank.."   "..v.name)
			rank.score:SetText(v.score)
		else
			rank = list[i]
		end
	end
	self.m_LabelBox:SetActive(false)
	self.m_RankGrid:Reposition()
end

function CGuessRiddleBottomBox.RefreshMyInfo(self, data)
	if data then
		self.m_MyInfo:SetText("我的排名:"..data.rank.."     "..data.score)
	else
		self.m_MyInfo:SetText("我的排名:当前没有排名")
	end
end

function CGuessRiddleBottomBox.RefreshReward(self, info)
	if info then
		if info.need_cnt == 0 then
			self.m_RewardLabel:SetText(data.hfdmdata.HFDMTEXT[9006].content)
		else
			self.m_RewardLabel:SetText("[70F3DEFF]再答对[-][0fff32]"..info.need_cnt.."/"..info.total_cnt.."[-][70F3DEFF]题得以下奖励[-]")
		end
	end
end

return CGuessRiddleBottomBox