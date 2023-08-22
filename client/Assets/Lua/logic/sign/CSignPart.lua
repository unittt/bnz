local CSignPart = class("CSignPart", CPageBase)

function CSignPart.ctor(self, cb)

	CPageBase.ctor(self, cb)
	self.m_CellHeigh = 110
	
end

function CSignPart.OnInitPage(self)

	self.m_FortuneName = self:NewUI(1, CLabel)
	self.m_FortuneDes = self:NewUI(2, CLabel)
	self.m_FortuneIcon = self:NewUI(3, CSprite)
	self.m_LotteryBtn = self:NewUI(4, CButton)
	self.m_RemedyBtn = self:NewUI(5, CButton)
	self.m_RemedyCountL = self:NewUI(6, CLabel)
	self.m_ItemSignBoxClone = self:NewUI(7, CItemSignBox)
	self.m_TipBtn = self:NewUI(8, CButton)
	self.m_ItemGrid = self:NewUI(9,CGrid)
	self.m_FortuneEffect = self:NewUI(10, CLabel)
	self.m_LotteryRedPoint = self:NewUI(11, CSprite)
	self.m_ShowLabel = self:NewUI(12, CLabel)
	self.m_ScrollView = self:NewUI(13, CScrollView)

	self.m_HadScroll = false

	self:InitContent()	
	
end

function CSignPart.InitContent(self)

	self.m_TipBtn:AddUIEvent("click", callback(self, "OnClickTip"))
	self.m_LotteryBtn:AddUIEvent("click", callback(self, "OnClickLottery"))
	self.m_RemedyBtn:AddUIEvent("click", callback(self, "OnClickRemedy"))

	self.m_ItemSignBoxClone:SetActive(false)
    self.m_FortuneName:SetText("?") 

	g_SignCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	nethuodong.C2GSSignInMainInfo()


	local t = {
		extrasignincnt = g_SignCtrl.m_extrasignincnt or 0,
		rewardset = g_SignCtrl.m_rewardset or 1,
		fortune = g_SignCtrl.m_fortune or 0,
		lottery = g_SignCtrl.m_lottery or 0,
		signincnt = g_SignCtrl.m_signincnt or 0,
		today = g_SignCtrl.m_today or 1,
		preView = true
	}

	g_SignCtrl:GS2CSetSignInfo(t)

end


--协议通知返回
function CSignPart.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.WelFare.Event.AddSignInfo then 

		self.data = oCtrl.m_EventData
		--处理签到box列表
		self:RefreshItemBoxs()
		--刷新运势
		self:RefreshFortune()
		--刷新重签btn
		self:RefreshRemedyBtn()
		--刷新抽奖小红点
		self:RefreshLotteryRedPoint()
		--DoTween入袋动画
		self:FloatItemBox()
		--滚动
		if not self.data.m_preView then 
			self:ScrollTo()
		end

	end

end



function CSignPart.RefreshItemBoxs(self)

	if not self.data.m_signDataList then 
		return
	end 

	self:HideAllRewardItems()

	for k , v in ipairs(self.data.m_signDataList) do 

		local box = self.m_ItemGrid:GetChild(k)
		if box == nil then 

			box =  self.m_ItemSignBoxClone:Clone()
			self.m_ItemGrid:AddChild(box)
		end

		--box:SetActive(true)
		box:SetData(v)

		if k == 1 then
			g_GuideCtrl:AddGuideUI("sign_item1_btn", box)
		end

	end 

	self.m_ItemGrid:Reposition()

end


--刷新补签按钮
function CSignPart.RefreshRemedyBtn(self)

	if self.data.m_extrasignincnt == 0 then 
		self.m_RemedyBtn:SetActive(false)
	else 
		self.m_RemedyBtn:SetActive(true)
	end
	self.m_RemedyCountL:SetText( "补签" .. "(" .. tostring(self.data.m_extrasignincnt) .. ")")

end


--刷新运势
function  CSignPart.RefreshFortune(self)

	if self.data.m_fortune == 0 then 
		self:SetFortuneActive(false)
		self.m_ShowLabel:SetActive(true)
		self.m_FortuneName:SetText("?") 
	else 
		local fortuneId = self.data.m_fortune
		local fortuneData = data.huodongdata.fortune[fortuneId]
		self.m_FortuneName:SetText(fortuneData.name) 
		self.m_FortuneDes:SetText(fortuneData.desc)
		self.m_FortuneEffect:SetText(fortuneData.effectdesc)
		self.m_FortuneIcon:SetSpriteName(fortuneData.icon)
		self:SetFortuneActive(true)
		self.m_ShowLabel:SetActive(false)
	end
	
end

function CSignPart.SetFortuneActive(self, isActive)
	
		self.m_FortuneDes:SetActive(isActive)
		self.m_FortuneEffect:SetActive(isActive)
		self.m_FortuneIcon:SetActive(isActive)

end

-----------------------处理点击事件----------------------------
function CSignPart.OnClickTip(self)

	local id = define.Instruction.Config.Sign
	if data.instructiondata.DESC[id] ~= nil then 

	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)

	end 

end


function CSignPart.OnClickLottery(self)

	CLotteryView:ShowView()

end

function CSignPart.OnClickRemedy(self)

	nethuodong:C2GSSignInReplenish()

end

function CSignPart.HideAllRewardItems(self)
	
	for k , v in pairs(self.m_ItemGrid:GetChildList()) do 

		v:SetActive(false)

	end 

end

function CSignPart.RefreshLotteryRedPoint(self)

	self.m_LotteryRedPoint:SetActive(self.data.m_lottery > 0)

end

function CSignPart.FloatItemBox(self)
	if g_SignCtrl.m_SelectItemList then
		for i=#g_SignCtrl.m_SelectItemList,1,-1 do
			local v = g_SignCtrl.m_SelectItemList[i]
			local oItemData = DataTools.GetItemData(v.itemid)
			g_NotifyCtrl:FloatItemBox(oItemData.icon, nil , v.pos)
			table.remove(g_SignCtrl.m_SelectItemList, i)
		end
	end
end

function CSignPart.ScrollTo(self)

	if not self.m_HadScroll then
		local signCnt = g_SignCtrl:GetSignCount() 
		local target = self.m_ItemGrid:GetChild(signCnt)
		if target then 
			self.m_ScrollView:ResetPosition()
			UITools.MoveToTarget(self.m_ScrollView, target)
			self.m_ScrollView:RestrictWithinBounds(true)
			self.m_HadScroll = true
		end 
	end 

end

return CSignPart