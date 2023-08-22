local CTaskStorySelectView = class("CTaskStorySelectView", CViewBase)

function CTaskStorySelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Task/TaskStorySelectView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Shelter"
end

function CTaskStorySelectView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DescLbl = self:NewUI(2, CLabel)
	self.m_ClickTexture1 = self:NewUI(3, CTexture)
	self.m_ClickTexture2 = self:NewUI(4, CTexture)
	self.m_SelectSp1 = self:NewUI(5, CSprite)
	self.m_SelectSp2 = self:NewUI(6, CSprite)
	self.m_DisableWidget = self:NewUI(7, CWidget)
	self.m_RandomBtn = self:NewUI(8, CButton)
	
	self:InitContent()
end

function CTaskStorySelectView.InitContent(self)
	self.m_DisableWidget:SetActive(false)
	self.m_ClickTexture1:AddUIEvent("click", callback(self, "OnClickTex", 1))
	self.m_ClickTexture2:AddUIEvent("click", callback(self, "OnClickTex", 2))
	self.m_RandomBtn:AddUIEvent("click", callback(self, "OnClickRandom"))

	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

--任务协议返回
function CTaskStorySelectView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Task.Event.TaskSelectCountTime then
		self.m_RandomBtn:SetText("听天由命("..g_TaskCtrl.m_TaskSelectTime..")")
		if g_TaskCtrl.m_TaskSelectTime <= 0 then
			local idx = Utils.RandomInt(1, 2)
			self:OnClickTex(idx)
		end
	end
end

function CTaskStorySelectView.RefreshUI(self, pbdata)
	self.m_NpcSayData = pbdata
	if not self.m_NpcSayData then
		return
	end
	local tMsgStr = self.m_NpcSayData.text
	if tMsgStr and type(tMsgStr) == "string" and string.len(tMsgStr) > 0 then
		local strList = string.split(tMsgStr, "%&Q")
		self.m_DescLbl:SetText(strList[1])

		self.m_SelectSp1:SetSpriteName("h7_storyselect_"..strList[2])
		self.m_SelectSp2:SetSpriteName("h7_storyselect_"..strList[3])

		local sTextureName1 = "Texture/Task/h7_storyselectbg_"..strList[2]..".png"
		local sTextureName2 = "Texture/Task/h7_storyselectbg_"..strList[3]..".png"
		g_ResCtrl:LoadAsync(sTextureName1, callback(self, "SetTexture1"))
		g_ResCtrl:LoadAsync(sTextureName2, callback(self, "SetTexture2"))
	end
	self.m_RandomBtn:SetActive(true)
	g_TaskCtrl:SetTaskSelectCountTime(10)
end

function CTaskStorySelectView.SetTexture1(self, prefab, errcode)
	if prefab then
		self.m_ClickTexture1:SetMainTexture(prefab)
	end
end

function CTaskStorySelectView.SetTexture2(self, prefab, errcode)
	if prefab then
		self.m_ClickTexture2:SetMainTexture(prefab)
	end
end

function CTaskStorySelectView.OnClickTex(self, oIndex)
	if not self.m_NpcSayData then
		return
	end
	g_TaskCtrl:ResetTaskSelectTimer()
	self.m_RandomBtn:SetActive(false)
	self.m_DisableWidget:SetActive(true)
	
	self["m_ClickTexture"..oIndex]:AddEffect("Screen", "ui_eff_0036")

	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil
	end
	local function progress()
		if Utils.IsNil(self) then
			return false
		end
		netother.C2GSCallback(self.m_NpcSayData.sessionidx, oIndex)
		self:CloseView()
		return false
	end	
	self.m_DelayTimer = Utils.AddTimer(progress, 0, 2)	
end

function CTaskStorySelectView.OnClickRandom(self)
	local idx = Utils.RandomInt(1, 2)
	self:OnClickTex(idx)
end

return CTaskStorySelectView