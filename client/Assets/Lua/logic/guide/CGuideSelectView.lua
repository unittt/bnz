local CGuideSelectView = class("CGuideSelectView", CViewBase)

function CGuideSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Guide/GuideSelectView.prefab", cb)
	--界面设置
	self.m_DepthType = "BeyondTop"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CGuideSelectView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_HasPlayBtn = self:NewUI(2, CButton)
	self.m_NoPlayBtn = self:NewUI(3, CButton)

	self.m_SelectIndex = 1
	
	self:InitContent()
	g_UploadDataCtrl:SetDotUpload("25")
end

function CGuideSelectView.InitContent(self)
	self.m_HasPlayBtn:AddUIEvent("click", callback(self, "OnClickPlay", 1))
	self.m_NoPlayBtn:AddUIEvent("click", callback(self, "OnClickPlay", 2))

	-- g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CGuideSelectView.OnClickPlay(self, index)
	self.m_SelectIndex = index
	
	self:CloseView()	
end

function CGuideSelectView.OnHideView(self)
	if self.m_SelectIndex == 1 then
		if not g_GuideHelpCtrl:CheckHasSelect() then
			table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "hasplay")
			g_GuideHelpCtrl.m_GuideExtraInfoHashList["hasplay"] = true
		end
		local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
		local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
		netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
	else
		if not g_GuideHelpCtrl:CheckHasSelect() then
			table.insert(g_GuideHelpCtrl.m_GuideExtraInfoList, "notplay")
			g_GuideHelpCtrl.m_GuideExtraInfoHashList["notplay"] = true
		end
		local list = {exdata = g_GuideHelpCtrl:TurnGuideExtraListToStr()}
		local encode = g_NetCtrl:EncodeMaskData(list, "UpdateNewbieGuide")
		netnewbieguide.C2GSUpdateNewbieGuideInfo(encode.mask, encode.guide_links, encode.exdata)
	end
	g_GuideCtrl:OnTriggerAll()
	
	-- 发送打点Log(新手引导开始)
	g_LogCtrl:SendLog(101)
end

return CGuideSelectView