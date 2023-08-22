local CWarSummonView = class("CWarSummonView", CViewBase)

function CWarSummonView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarSummonView.prefab", cb)

	self.m_GroupName = "WarOrder"
	self.m_ExtendClose = "ClickOut"
end


function CWarSummonView.OnCreateView(self)
	self.m_SummonGrid = self:NewUI(1, CGrid)
	self.m_SummonBox = self:NewUI(2, CBox)
	self.m_NearSpr = self:NewUI(3, CSprite)
	self.m_FightCntLabel = self:NewUI(4, CLabel)
	self.m_CloseBtn = self:NewUI(5, CSprite)
	self.m_ConfirmBtn = self:NewUI(6, CSprite)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_SummonBox:SetActive(false)
	self:RefreshSummonGrid()
end

function CWarSummonView.OnConfirm(self)
	if not self.m_SeleSummonID then
		g_NotifyCtrl:FloatMsg("请选择要出战的宠物")
		return
	end
	if #g_WarCtrl.m_FightSummonIDList >= self.m_MaxCnt then
		g_NotifyCtrl:FloatMsg("本场战斗出战宠物数量已达上限")
		return
	end
	g_WarOrderCtrl:SetHeroOrder("Call", self.m_SeleSummonID)
	self:CloseView()
end

function CWarSummonView.RefreshSummonGrid(self)
	self.m_SummonGrid:Clear()
	local list = self:GetSummonList()
	for i, dSummon in ipairs(list) do
		local oBox = self:CreateSummonBox(dSummon)
		self.m_SummonGrid:AddChild(oBox)
	end
end

function CWarSummonView.CreateSummonBox(self, dSummon)
	local oBox = self.m_SummonBox:Clone()
	oBox:SetActive(true)
	oBox.m_NameLabel = oBox:NewUI(1, CLabel)
	oBox.m_GradeLabel = oBox:NewUI(2, CLabel)
	oBox.m_AvatarSpr = oBox:NewUI(3, CSprite)
	oBox.m_SummonID = dSummon.id
	oBox:AddUIEvent("click", function ()
		oBox:SetSelected(true)
		self.m_SeleSummonID = dSummon.id
	end)
	oBox.m_NameLabel:SetText(dSummon.name)
	oBox.m_GradeLabel:SetText(string.format("等级:%d", dSummon.grade))
	oBox.m_AvatarSpr:SpriteAvatar(dSummon.model_info.shape)
	return oBox
end

function CWarSummonView.GetSummonList(self)
	local summons = g_SummonCtrl:GetSummons()
	local list = {}
	local iCnt = #g_WarCtrl.m_FightSummonIDList
	for k, dSummon in pairs(summons) do
		if not g_WarCtrl:IsSummonFighted(dSummon.id) and dSummon.carrygrade <= g_AttrCtrl.grade and (dSummon.life>50 or SummonDataTool.IsExpensiveSumm(dSummon.type)) then
			table.insert(list, dSummon)
		end
	end
	local iMax = SummonDataTool.GetMaxFightCnt(g_AttrCtrl.grade)
	self.m_FightCntLabel:SetText(string.format("已出战宠物:%d/%d", iCnt, iMax))
	self.m_MaxCnt = iMax
	return list
end

return CWarSummonView