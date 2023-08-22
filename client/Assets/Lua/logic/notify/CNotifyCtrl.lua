local CNotifyCtrl = class("CNotifyCtrl", CCtrlBase)

function CNotifyCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_RecordScore = nil 
end

--返回登陆界面清除CNotifyView残余的效果
function CNotifyCtrl.Clear(self)
	self:ClearRumor()
	local oView = CNotifyView:GetView()
	if oView then
		oView.m_RedPacketEffect:ClearEffect()
		oView.m_ScreenWidget:ClearEffect()
		oView.m_ChapterOpen:ClearEffect()
	end
end

function CNotifyCtrl.Update(self, dt)
	self:OnEvent(define.Notify.Event.Update, dt)
end

function CNotifyCtrl.GetWorldPos(self, screenPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local WorldPos = oUICamera:ScreenToWorldPoint(screenPos)
	return WorldPos
end

function CNotifyCtrl.GetScreenPos(self, oWorldPos)
	local oUICamera = g_CameraCtrl:GetUICamera()
	local oScreenPos = oUICamera:WorldToScreenPoint(oWorldPos)
	return oScreenPos
end

function CNotifyCtrl.InitScore(self, loginscore)
	self.m_RecordScore = loginscore
end

function CNotifyCtrl.FloatMsg(self, text, itemData, bNotCheckTime)
	local oView = CNotifyView:GetView()
	--快捷获得不提示缺少信息
	if self:SpecificSceneHideMsg() and g_WarCtrl:IsWar() then
		return
	end
	
	if oView then
		oView:FloatMsg(text, itemData, bNotCheckTime)
	end
end

function CNotifyCtrl.FloatSimpleMsg(self, sText, vPos, iFloatHeight, vColor)
	local oView = CNotifyView:GetView()
	
	if oView then
		oView:FloatSimpleMsg(sText, vPos, iFloatHeight, vColor)
	end
end

function CNotifyCtrl.SpecificSceneHideMsg(self)
	-- body
	local sign = false
	local sceneid = g_MapCtrl:GetMapID()
	if sceneid == 502000 or sceneid == 503000 or sceneid == 504000 then
		sign = true
	end
	return sign
end

function CNotifyCtrl.FloatSummonMsg(self, id)
	local oView = CNotifyView:GetView()
	oView:FloatMsg(data.summondata.TEXT[id].content)
end

function CNotifyCtrl.GauideFloatMsg(self, text, depth)
	local oView = CNotifyView:GetView()
	oView:SetDepth(depth)
	oView:FloatMsg(text)
end

function CNotifyCtrl.ShowProgress(self, cb, text, waitTime, pastTime, cancelFunc, oMarkPosPoint)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowProgress(cb, text, waitTime, pastTime, cancelFunc, oMarkPosPoint)
	end
end

function CNotifyCtrl.CancelProgress(self, cbFun)
	local oView = CNotifyView:GetView()
	oView:CancelProgress(cbFun)
end

function CNotifyCtrl.FloatItemBox(self, itemiconid, vPos, time, bScale, cb)
	local oView = CNotifyView:GetView()
	if g_WarCtrl:IsWar() then return end --战斗中，屏蔽入袋动画
	oView:FloatItemBox(itemiconid, vPos, time, bScale, cb)
end

function CNotifyCtrl.FloatMultipleItemBox(self, floatList, bScale, cb)
	-- body
	local oView = CNotifyView:GetView()
	if g_WarCtrl:IsWar() then return end --战斗中，屏蔽入袋动画
	oView:FloatMultipleItemBox(floatList, bScale, cb)
end

function CNotifyCtrl.QuickFloatItemBox(self, itemiconid, vStartpos, vEndPos)
	local oView = CNotifyView:GetView()
	oView:QuickFloatItemBox(itemiconid, vStartpos, vEndPos)
end

function CNotifyCtrl.SetMenuBagEffect(self)
	self:OnEvent(define.MainMenu.Event.BagIconEffect)
end

function CNotifyCtrl.FloatNpcInfoList(self, npcInfoList)
	local oView = CNotifyView:GetView()
	oView:FloatNpcInfoList(npcInfoList)
end

function CNotifyCtrl.FloatWarriorList(self, widList)
	local oView = CNotifyView:GetView()
	if oView then
		oView:FloatWarriorList(widList)
	end
end

function CNotifyCtrl.FloatAudioMsg(self, sText)
	local oView = CNotifyView:GetView()
	oView:FloatAudioMsg(sText)
end

function CNotifyCtrl.ShowRedPacket(self)
	local oView = CNotifyView:GetView()
	oView:ShowRedPacket()
end

function CNotifyCtrl.FloatPieceBox(self, oChapterId, oPieceIndex)
	self.m_IsPieceShowing = true
	local oView = CNotifyView:GetView()
	oView:FloatPieceBox(oChapterId, oPieceIndex)
end

-- 限时活动未开启提示
function CNotifyCtrl.FloatTimelimitHuodongMsg(self, sName)
	local dText = DataTools.GetMiscText(3017)
	if dText then
		local sText = string.FormatString(dText.content, {name = sName}, true)
		self:FloatMsg(sText)
	end
end

function CNotifyCtrl.ShowRedPacketEffect(self)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowRedPacketEffect()
	end
end

function CNotifyCtrl.ShowLockScreen(self,bIslock)
	local oView = CNotifyView:GetView()
	if oView then
		oView:RefreshLockScreen(bIslock)
	end
end

function CNotifyCtrl.ShowTaskDoneEffect(self)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowTaskDoneEffect()
	end
end

function CNotifyCtrl.ShowTreasurePrizeEffect(self, index)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowTreasurePrizeEffect(index)
	end
end

function CNotifyCtrl.ShowFlowerEffect(self, effectId)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowFlowerEffect(effectId)
	end
end

function CNotifyCtrl.ClearRumor(self)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ClearRumor()
	end
end

function CNotifyCtrl.ShowDisableWidget(self, bIsShow, sText, oAudioOffset)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowDisableWidget(bIsShow, sText, oAudioOffset)
	end
end

function CNotifyCtrl.ShowScreenEffect(self, effectName)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowScreenEffect(effectName)
	end
end

function CNotifyCtrl.ShowChapterOpen(self, oChapterId)
	self.m_IsChapterOpenShowing = true
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowChapterOpen(oChapterId)
	end
end

function CNotifyCtrl.ShowClickIngot(self, parent)
	-- body
	local oView = CNotifyView:GetView()
	if oView then
		oView:OnClickIngot(parent)
	end
end

function CNotifyCtrl.ShowScore(self, oScore, oOldScore)
	if not oScore or oScore == 0 or oScore - oOldScore == 0 then
		return 
	end
	if not g_OpenSysCtrl:GetOpenSysState(define.System.ScoreShow) then
		return
	end
	CScoreShowView:CloseView()
	CScoreShowView:ShowView(function (oView)
		oView:RefreshUI(oScore, oOldScore)
	end)
end

function CNotifyCtrl.ShowNetCircle(self, bShow, sTip, bContent)
	local oView = CNotifyView:GetView()
	if oView then
		oView:ShowNetCircle(bShow, sTip, bContent)
	end
end

function CNotifyCtrl.SetFloatTableActive(self, bActive)
	local oView = CNotifyView:GetView()
	if oView then
		oView:SetFloatTableActive(bActive)
	end
end

function CNotifyCtrl.SetMoneryInfo(self, open)
	local oView = CNotifyView:GetView()
	if oView then
		oView.m_MenoryBox:SetActive(open)
		if open then
			oView:SetMenoryInfo(collectgarbage("count"))
		end
	end
end

function CNotifyCtrl.SetStatsInfo(self, open)
	local oView = CNotifyView:GetView()
	if oView then
		oView:SetStatsInfo(open)
	end
end

function CNotifyCtrl.SetEffectMsgActive(self, bActive)
	local oView = CNotifyView:GetView()
	if oView then
		oView:SetEffectMsgActive(bActive)
	end
end

function CNotifyCtrl.RefreshPowerSaveLayer(self, bShow)
	local oView = CNotifyView:GetView()
	if oView then
		oView:RefreshPowerSaveLayer(bShow)
	end
end

return CNotifyCtrl