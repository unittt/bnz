local CJjcResultView = class("CJjcResultView", CViewBase)

function CJjcResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Jjc/JjcResultView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CJjcResultView.OnCreateView(self)
	self.m_ResultLbl = self:NewUI(1, CLabel)
	self.m_NoChangeLbl = self:NewUI(2, CLabel)
	self.m_ChangeBox = self:NewUI(3, CBox)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_PrizeScrollView = self:NewUI(5, CScrollView)
	self.m_PrizeGrid = self:NewUI(6, CGrid)
	self.m_PrizeBoxClone = self:NewUI(7, CBox)
	self.m_PrizeGo = self:NewUI(8, CObject)
	-- self.m_Bg = self:NewUI(9, CTexture)
	self.m_WinBgBox = self:NewUI(10, CBox)
	self.m_LoseBgBox = self:NewUI(11, CBox)
	self.m_FailDescLbl = self:NewUI(12, CLabel)
    self.m_PromoteGrid = self:NewUI(13, CGrid)
    self.m_PromoteBtnClone = self:NewUI(14, CButton)
    self.m_PromoteBtnClone:SetActive(false)

	self.m_ChangeBox.m_StartValueLbl = self.m_ChangeBox:NewUI(1, CLabel)
	self.m_ChangeBox.m_EndValueLbl = self.m_ChangeBox:NewUI(2, CLabel)

	self:InitContent()
end

function CJjcResultView.InitContent(self)
	self.m_PrizeBoxClone:SetActive(false)

	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnClickConfirm"))
end

--result 1 是战斗成功，0是战斗失败
function CJjcResultView.SetContent(self, pbdata)
	local oldrank = pbdata.oldrank
	local newrank = pbdata.newrank
	local result = pbdata.result
	local items = pbdata.items

	self.m_ResultData = pbdata
    
    if result == 1 then
    	self.m_WinBgBox:SetActive(true)
    	self.m_LoseBgBox:SetActive(false)
    	self.m_ConfirmBtn:SetActive(true)
    	self.m_FailDescLbl:SetActive(false)
    	-- self.m_ResultLbl:SetText("战斗成功")
    else
    	self.m_WinBgBox:SetActive(false)
    	self.m_LoseBgBox:SetActive(true)
    	self.m_ConfirmBtn:SetActive(false)
    	self.m_FailDescLbl:SetActive(true)
    	-- self.m_ResultLbl:SetText("战斗失败")

    	-- 实例战败跳转按钮Grid
    	self:InitPromoteGrid()
    end

    -- g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))
    if not items or not next(items) then
    	self.m_PrizeGo:SetActive(false)
    else
    	self.m_PrizeGo:SetActive(true)
    end
    self:SetPrizeInfo(items)
	if oldrank == newrank then
		self.m_NoChangeLbl:SetActive(true)
		self.m_ChangeBox:SetActive(false)
	else
		self.m_NoChangeLbl:SetActive(false)
		self.m_ChangeBox:SetActive(true)
		if oldrank == 0 then
			self.m_ChangeBox.m_StartValueLbl:SetText("排名 "..g_JjcCtrl.m_JjcOutSideRankStr)
		else
			self.m_ChangeBox.m_StartValueLbl:SetText("排名 "..oldrank)
		end
		if newrank == 0 then
			self.m_ChangeBox.m_EndValueLbl:SetText("排名 "..g_JjcCtrl.m_JjcOutSideRankStr)
		else
			self.m_ChangeBox.m_EndValueLbl:SetText("排名 "..newrank)
		end
	end
end

function CJjcResultView.InitPromoteGrid(self)
    local failInfo = DataTools.GetWarFailInfo(g_AttrCtrl.grade)
    if failInfo == nil then
    	return
    end

    local configList = g_PromoteCtrl:GetWarFailConfigList(failInfo.showlist)

    self.m_PromoteGrid:Clear()
    for _,config in ipairs(configList) do
        local oPromoteBtn = self.m_PromoteBtnClone:Clone()
        oPromoteBtn:SetActive(true)
        self.m_PromoteGrid:AddChild(oPromoteBtn)
        
        oPromoteBtn:SetSpriteName(config.iconname)
        oPromoteBtn:SetText(config.des)
        oPromoteBtn:AddUIEvent("click", callback(self, "OnPromote", config))
    end
    self.m_PromoteGrid:Reposition()
end

function CJjcResultView.OnPromote(self, config)
	self.m_NotShowJjcMain = true
    g_ViewCtrl:ShowViewBySysName(config.logic.sysname, config.logic.tabname)
    self:CloseView()
end

-- function CJjcResultView.SetTexture(self, prefab, errcode)
-- 	if prefab then
-- 		self.m_Bg:SetMainTexture(prefab)
-- 	else
-- 		print(errcode)
-- 	end
-- end

function CJjcResultView.SetPrizeInfo(self, oData)
	self.m_PrizeGrid:Clear()
	if oData and next(oData) then
		for k,v in ipairs(oData) do
			self:AddPrizeBox(v)
		end
	end
	self.m_PrizeGrid:Reposition()
	self.m_PrizeScrollView:ResetPosition()
end

function CJjcResultView.AddPrizeBox(self, oPrize)
	local oPrizeBox = self.m_PrizeBoxClone:Clone()
	
	oPrizeBox:SetActive(true)
	oPrizeBox.m_IconSp = oPrizeBox:NewUI(1, CSprite)
	oPrizeBox.m_CountLbl = oPrizeBox:NewUI(2, CLabel)
	oPrizeBox.m_QualitySp = oPrizeBox:NewUI(3, CSprite)
	local oItemConfig = DataTools.GetItemData(oPrize.sid)
    oPrizeBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ) )
	oPrizeBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	oPrizeBox:AddUIEvent("click", callback(self, "OnClickPrizeBox", oPrize, oPrizeBox))
	oPrizeBox.m_CountLbl:SetText(oPrize.amount)
	self.m_PrizeGrid:AddChild(oPrizeBox)
	self.m_PrizeGrid:Reposition()
end

--显示奖励tips
function CJjcResultView.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

function CJjcResultView.OnClickConfirm(self)
	self:CloseView()
	g_JjcCtrl:OpenJjcMainView()
end

function CJjcResultView.OnHideView(self)
	if self.m_NotShowJjcMain then
		self.m_NotShowJjcMain = false
		return
	end
	g_JjcCtrl:OpenJjcMainView()
end

return CJjcResultView