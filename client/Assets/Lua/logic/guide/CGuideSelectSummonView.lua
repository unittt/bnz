local CGuideSelectSummonView = class("CGuideSelectSummonView", CViewBase)

function CGuideSelectSummonView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/GuideSelectSummonView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondGuide"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CGuideSelectSummonView.OnCreateView(self)
	self.m_TitleLbl = self:NewUI(1, CLabel)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_ActorTexture1 = self:NewUI(4, CActorTexture)
	self.m_ActorTexture2 = self:NewUI(5, CActorTexture)
	self.m_ClickWidget1 = self:NewUI(6, CWidget)
	self.m_ClickWidget2 = self:NewUI(7, CWidget)

	self:InitContent()
end

function CGuideSelectSummonView.InitContent(self)
	self.m_ClickWidget1:AddUIEvent("click", callback(self, "OnClickSelectSummon", 1))
	self.m_ClickWidget2:AddUIEvent("click", callback(self, "OnClickSelectSummon", 2))

	local sumid1 = data.guideconfigdata.NEWBIESUMMON[1].summon_id
	local sumid2 = data.guideconfigdata.NEWBIESUMMON[2].summon_id

	local model_info = {}
	model_info.shape = data.summondata.INFO[sumid1].shape
	self.m_ActorTexture1:ChangeShape(model_info)
	local model_info = {}
	model_info.shape = data.summondata.INFO[sumid2].shape
	self.m_ActorTexture2:ChangeShape(model_info)

	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CGuideSelectSummonView.OnClickSelectSummon(self, index)
	if not g_GuideHelpCtrl:GetIsGuideExtraInfoKeyExist("sumselect") then
		CNpcShowView:ShowView(function (oView)
			oView:RefreshUI({parnter = 0, summon = data.guideconfigdata.NEWBIESUMMON[index].summon_id})
		end)
		g_MapCtrl.m_IsNpcCloseUp = true
		g_MapCtrl.m_IsNpcNeedShowInGuide = true		
		
		table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "sumselect")
		g_GuideHelpCtrl.m_GuideExtraInfoHashList["sumselect"] = true
		local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
		local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
		netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)

		netnewbieguide.C2GSSelectNewbieSummon(index)
	end
	self:CloseView()
	g_GuideCtrl:OnTriggerAll()
	printc("CGuideSelectSummonView.OnClickSelectSummon"..index)
end

return CGuideSelectSummonView