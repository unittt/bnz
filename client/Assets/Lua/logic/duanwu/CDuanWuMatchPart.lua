local CDuanWuMatchPart = class("CDuanWuMatchPart", CPageBase)

function CDuanWuMatchPart.ctor(self, cb)
	
	CPageBase.ctor(self, cb)
	self.m_Time = self:NewUI(1, CLabel)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ItemBox = self:NewUI(3, CZongZiGameProgress)
	self.m_LeftDes = self:NewUI(4, CLabel)
	self.m_RightDes = self:NewUI(5, CLabel)
	self.m_DuiHuanIcon = self:NewUI(6, CSprite)
	self.m_DuiHuanName = self:NewUI(7, CLabel)
	self.m_DuiHuanCnt = self:NewUI(8, CLabel)
	self.m_YuanBaoNode = self:NewUI(9, CObject)
	self.m_LeftYuanBaoCnt = self:NewUI(10, CLabel) 
	self.m_RightYuanBaoCnt = self:NewUI(11, CLabel) 
	self.m_RemainBuyTime = self:NewUI(12, CLabel) 
	self.m_Tip = self:NewUI(13, CSprite) 
	self.m_SweetDuiHuanBtn = self:NewUI(14, CSprite) 
	self.m_SaltyDuiHuanBtn = self:NewUI(15, CSprite)

	self.m_HadConfirmBuy = false 

end

function CDuanWuMatchPart.OnInitPage(self)

	g_DuanWuHuodongCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEvent"))
	self.m_SweetDuiHuanBtn:AddUIEvent("click", callback(self, "OnClickSweet"))
	self.m_SaltyDuiHuanBtn:AddUIEvent("click", callback(self, "OnClickSalty"))
	self.m_Tip:AddUIEvent("click", callback(self, "OnClickInfoBtn"))
	g_DuanWuHuodongCtrl:C2GSZongziOpenUI()

end

function CDuanWuMatchPart.RefreshAll(self)

	self:RefreshDes()
	self:RefreshZongZiProgress()
	self:RefreshDuiHuanItem()
	self:RefreshYuanBaoNode()
	self:RefreshTime()
	self:RefreshRemainBuyTime()

end 

function CDuanWuMatchPart.RefreshDes(self)

	self.m_LeftDes:SetText(g_DuanWuHuodongCtrl:GetZongZiTip(1007))
	self.m_RightDes:SetText(g_DuanWuHuodongCtrl:GetZongZiTip(1008))

end 

function CDuanWuMatchPart.RefreshZongZiProgress(self)

	local zongZiInfoList = g_DuanWuHuodongCtrl:GetZongZiInfoList()
	for k, v in ipairs(zongZiInfoList) do 
		local item = self.m_Grid:GetChild(k)
		if not item then 
			item = self.m_ItemBox:Clone()
			item:SetActive(true)
			self.m_Grid:AddChild(item)
		end 
		item:RefreshInfo(v)
	end 

end 

function CDuanWuMatchPart.RefreshDuiHuanItem(self)

	local duihuanInfo = g_DuanWuHuodongCtrl:GetDuiHuanItemInfo()
	self.m_DuiHuanIcon:SetSpriteName(duihuanInfo.icon)
	self.m_DuiHuanName:SetText(duihuanInfo.name)
	self.m_DuiHuanCnt:SetText(duihuanInfo.cnt)

end 

function CDuanWuMatchPart.RefreshYuanBaoNode(self)

	if g_DuanWuHuodongCtrl:GetDuiHuanJuanCnt() == 0 then 
		self.m_YuanBaoNode:SetActive(true)
		local cost = g_DuanWuHuodongCtrl:GetYuanBaoDuiHuanCost()
		self.m_LeftYuanBaoCnt:SetText(cost)
		self.m_RightYuanBaoCnt:SetText(cost)
	else
		self.m_YuanBaoNode:SetActive(false)
	end 

end 

function CDuanWuMatchPart.RefreshRemainBuyTime(self)

	self.m_RemainBuyTime:SetText(g_DuanWuHuodongCtrl:GetRemainBuyTime())

end

function CDuanWuMatchPart.RefreshTime(self)

	local cb = function (time)
        if not time then 
            self.m_Time:SetText("活动结束")
        else
            self.m_Time:SetText(time)
        end 
    end
	
	local endTime = g_DuanWuHuodongCtrl:GetMatchEndTime()

	if endTime and endTime > 0 then 
		local leftTime = endTime - g_TimeCtrl:GetTimeS()
		g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)
	end 

end

function CDuanWuMatchPart.OnEvent(self, oCtrl)

	if oCtrl.m_EventID == define.DuanWuHuodong.Event.MatchDataChange then
		self:RefreshAll()
	end 
 
end

function CDuanWuMatchPart.OnClickSweet(self)
	
	local duihuanInfo = g_DuanWuHuodongCtrl:GetDuiHuanItemInfo()
	local remainTime = g_DuanWuHuodongCtrl:GetRemainBuyTime()
	local cost = g_DuanWuHuodongCtrl:GetYuanBaoDuiHuanCost()
	local goldCoin = g_AttrCtrl:GetGoldCoin()
	if duihuanInfo.cnt == 0 then 
		if remainTime > 0 then
			if goldCoin >= cost then 
				if self.m_HadConfirmBuy then 
					g_DuanWuHuodongCtrl:C2GSZongziExchange(1,1)
				else
					self:ConfirmUI(function ( ... )
						g_DuanWuHuodongCtrl:C2GSZongziExchange(1,1)
					end)
				end 
			else
				self:JumpToBuyYuanBao()
			end 
		else
			g_NotifyCtrl:FloatMsg(g_DuanWuHuodongCtrl:GetZongZiTip(1006))
		end  
	else
		g_DuanWuHuodongCtrl:C2GSZongziExchange(1)
	end  
	
end

function CDuanWuMatchPart.OnClickSalty(self)
	
	local duihuanInfo = g_DuanWuHuodongCtrl:GetDuiHuanItemInfo()
	local remainTime = g_DuanWuHuodongCtrl:GetRemainBuyTime()
	local cost = g_DuanWuHuodongCtrl:GetYuanBaoDuiHuanCost()
	local goldCoin = g_AttrCtrl:GetGoldCoin()
	if duihuanInfo.cnt == 0 then 
		if remainTime > 0 then 
			if goldCoin >= cost then 
				if self.m_HadConfirmBuy then 
					g_DuanWuHuodongCtrl:C2GSZongziExchange(2,1)
				else
					self:ConfirmUI(function ( ... )
						g_DuanWuHuodongCtrl:C2GSZongziExchange(2,1)
					end)
				end 
			else
				self:JumpToBuyYuanBao()
			end 
		else
			g_NotifyCtrl:FloatMsg(g_DuanWuHuodongCtrl:GetZongZiTip(1006))
		end  
	else
		g_DuanWuHuodongCtrl:C2GSZongziExchange(2)
	end  

end

function CDuanWuMatchPart.JumpToBuyYuanBao(self)
	
	local windowTipInfo = {
		msg = "元宝不足，是否跳转到元宝购买界面?",
    	pivot = enum.UIWidget.Pivot.Center,
		okCallback = function () 
			CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end) 
		 end,
		okStr = "确定",
		cancelStr = "取消",
	}	
	g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)

end

function CDuanWuMatchPart.ConfirmUI(self, cb)
	
	local cost = g_DuanWuHuodongCtrl:GetYuanBaoDuiHuanCost()
	local str = "是否花费" .. tostring(cost) .. "元宝兑换粽子？"
	local windowTipInfo = {
		msg = str,
    	pivot = enum.UIWidget.Pivot.Center,
		okCallback = function () 
			if cb then 
				cb()
			end
			self.m_HadConfirmBuy = true 
		 end,
		okStr = "确定",
		cancelStr = "取消",
	}	
	g_WindowTipCtrl:SetWindowConfirm(windowTipInfo)

end

function CDuanWuMatchPart.OnClickInfoBtn(self)

	local id = 10072
	if data.instructiondata.DESC[id] ~= nil then 
	    local content = {
	        title = data.instructiondata.DESC[id].title,
	        desc  = data.instructiondata.DESC[id].desc
	    }
	    g_WindowTipCtrl:SetWindowInstructionInfo(content)
	end 

end

return CDuanWuMatchPart