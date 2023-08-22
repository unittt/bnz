local CJjcPrizeView = class("CJjcPrizeView", CViewBase)

function CJjcPrizeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Jjc/JjcPrizeView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CJjcPrizeView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_TitleLbl = self:NewUI(4, CLabel)
	self.m_RankLbl = self:NewUI(5, CLabel)
	self.m_ItemIcon = self:NewUI(6, CSprite)
	self.m_ItemQualitySp = self:NewUI(7, CSprite)
	self.m_ItemCountLbl = self:NewUI(8, CLabel)
	self.m_Widget = self:NewUI(9, CWidget)
	self.m_NormalObj = self:NewUI(10, CObject)
	self.m_FirstScrollView = self:NewUI(11, CScrollView)
	self.m_FirstGrid = self:NewUI(12, CGrid)
	self.m_FirstBoxClone = self:NewUI(13, CBox)
	self.m_BgSp = self:NewUI(14, CSprite)
	
	self:InitContent()
end

function CJjcPrizeView.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_FirstBoxClone:SetActive(false)

	-- self.m_EyeBtn:AddUIEvent("click", callback(self, "OnClickEye"))
end

function CJjcPrizeView.RefreshUI(self, oType, oWidget)
	-- self.m_ItemIcon:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData, self.m_ItemIcon)
	local oMyConfig
	if oType == define.Jjc.PrizeType.Day then
		self.m_NormalObj:SetActive(true)
		self.m_FirstScrollView:SetActive(false)
		self.m_TitleLbl:SetText("每日排名奖励")
		self.m_BgSp:SetHeight(490)
		self.m_BgSp:SetWidth(430)
		self:SetPrizeList(data.jjcdata.DAYREWARD)
		UITools.NearTarget(oWidget, self.m_Widget, enum.UIAnchor.Side.Center, Vector2.New(0, -50))

		local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
		local _, oConfig = g_JjcCtrl:GetDayConfigPrize(rank)
		oMyConfig = oConfig
	elseif oType == define.Jjc.PrizeType.Month then
		self.m_NormalObj:SetActive(true)
		self.m_FirstScrollView:SetActive(false)
		self.m_TitleLbl:SetText("赛季排名奖励")
		self.m_BgSp:SetHeight(490)
		self.m_BgSp:SetWidth(430)
		self:SetPrizeList(data.jjcdata.MONTHREWARD)
		UITools.NearTarget(oWidget, self.m_Widget, enum.UIAnchor.Side.Center, Vector2.New(0, -50))

		local rank = g_JjcCtrl.m_Rank == 0 and 100000 or g_JjcCtrl.m_Rank
		local _, oConfig = g_JjcCtrl:GetMonthConfigPrize(rank)
		oMyConfig = oConfig
	elseif oType == define.Jjc.PrizeType.First then
		self.m_TitleLbl:SetText("首胜奖励")
		self.m_BgSp:SetHeight(190)
		self.m_BgSp:SetWidth(340)
		self.m_NormalObj:SetActive(false)
		self.m_FirstScrollView:SetActive(true)
		self:SetFirstPrizeList()
		UITools.NearTarget(oWidget, self.m_Widget, enum.UIAnchor.Side.Center, Vector2.New(0, -200))
	end

	if oMyConfig then
		local oItemConfig = DataTools.GetItemData(oMyConfig.item[1].sid)
		self.m_ItemIcon:SpriteItemShape(oItemConfig.icon)
		local oAmount = tonumber(oMyConfig.item[1].amont)
		if oAmount <= 1 then
			self.m_ItemCountLbl:SetText("")
		else
			self.m_ItemCountLbl:SetText(oAmount)
		end
		self.m_ItemQualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ))
	end

	local oRankStr = ""
	if g_JjcCtrl.m_Rank == 0 then
		oRankStr = "我排名\n"..g_JjcCtrl.m_JjcOutSideRankStr
	else
		oRankStr = "我排名\n"..g_JjcCtrl.m_Rank
	end
	self.m_RankLbl:SetText(oRankStr)
end

function CJjcPrizeView.SetPrizeList(self, oConfig)
	local optionCount = #oConfig
	local GridList = self.m_Grid:GetChildList() or {}
	local oPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPrizeBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPrizeBox = GridList[i]
			end
			self:SetPrizeBox(oPrizeBox, oConfig[i], i, oConfig)
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CJjcPrizeView.SetPrizeBox(self, oPrizeBox, oData, oIndex, oConfig)
	oPrizeBox:SetActive(true)
	oPrizeBox.m_RankLbl = oPrizeBox:NewUI(1, CLabel)
	oPrizeBox.m_ItemIcon = oPrizeBox:NewUI(2, CSprite)
	oPrizeBox.m_ItemQualitySp = oPrizeBox:NewUI(3, CSprite)
	oPrizeBox.m_ItemCountLbl = oPrizeBox:NewUI(4, CLabel)
	oPrizeBox.m_ItemScrollView = oPrizeBox:NewUI(5, CScrollView)
	oPrizeBox.m_ItemGrid = oPrizeBox:NewUI(6, CGrid)
	oPrizeBox.m_ItemBoxClone = oPrizeBox:NewUI(7, CBox)
	oPrizeBox.m_ItemBoxClone:SetActive(false)

	local oRankStr = ""
	if oIndex >= #oConfig then
		if oData.rank[1] > g_JjcCtrl.m_JjcOutSideRank then
			oRankStr = g_JjcCtrl.m_JjcOutSidePrizeRankStr
		else
			if not oData.rank[2] or oData.rank[1] == oData.rank[2] then
				oRankStr = "第"..oData.rank[1].."名"
			else
				oRankStr = "第"..oData.rank[1].."-"..oData.rank[2].."名"
			end
		end
	else
		if not oData.rank[2] or oData.rank[1] == oData.rank[2] then
			oRankStr = "第"..oData.rank[1].."名"
		else
			oRankStr = "第"..oData.rank[1].."-"..oData.rank[2].."名"
		end
	end
	oPrizeBox.m_RankLbl:SetText(oRankStr)

	if oIndex == 1 then
		oPrizeBox.m_RankLbl:SetColor(Color.RGBAToColor("d74aff"))
	elseif oIndex == 2 then
		oPrizeBox.m_RankLbl:SetColor(Color.RGBAToColor("2dffe9"))
	elseif oIndex == 3 then
		oPrizeBox.m_RankLbl:SetColor(Color.RGBAToColor("0fff32"))
	else
		oPrizeBox.m_RankLbl:SetColor(Color.RGBAToColor("c3e3d4"))
	end

	self:SetItemList(oData.item, oPrizeBox)

	self.m_Grid:AddChild(oPrizeBox)
	self.m_Grid:Reposition()
end

function CJjcPrizeView.SetItemList(self, oList, oPrizeBox)
    local optionCount = #oList
    local GridList = oPrizeBox.m_ItemGrid:GetChildList() or {}
    local oItemBox
    if optionCount > 0 then
        for i=1,optionCount do
            if i > #GridList then
                oItemBox = oPrizeBox.m_ItemBoxClone:Clone(false)
                -- self.m_ItemGrid:AddChild(oOptionBtn)
            else
                oItemBox = GridList[i]
            end
            self:SetItemBox(oItemBox, oList[i], oPrizeBox)
        end

        if #GridList > optionCount then
            for i=optionCount+1,#GridList do
                GridList[i]:SetActive(false)
            end
        end
    else
        if GridList and #GridList > 0 then
            for _,v in ipairs(GridList) do
                v:SetActive(false)
            end
        end
    end

    oPrizeBox.m_ItemGrid:Reposition()
    oPrizeBox.m_ItemScrollView:ResetPosition()
end

function CJjcPrizeView.SetItemBox(self, oItemBox, oData, oPrizeBox)
    oItemBox:SetActive(true)
    oItemBox.m_IconSp = oItemBox:NewUI(1, CSprite)
    oItemBox.m_CountLbl = oItemBox:NewUI(2, CLabel)
    oItemBox.m_QualitySp = oItemBox:NewUI(3, CSprite)
    oItemBox.m_Data = oData

    local oItemConfig = DataTools.GetItemData(oData.sid)
	oItemBox.m_IconSp:SpriteItemShape(oItemConfig.icon)
	local oAmount = tonumber(oData.amont)
	if oAmount <= 1 then
		oItemBox.m_CountLbl:SetText("")
	else
		oItemBox.m_CountLbl:SetText(oAmount)
	end
	 oItemBox.m_QualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ))

	oItemBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickPrizeBox", oData, oItemBox.m_IconSp))


    oPrizeBox.m_ItemGrid:AddChild(oItemBox)
    oPrizeBox.m_ItemGrid:Reposition()
end

--显示奖励tips
function CJjcPrizeView.OnClickPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Right,
        offset = Vector2.New(0, 0)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

function CJjcPrizeView.SetFirstPrizeList(self)
	local optionCount = #data.jjcdata.JJCGLOBAL[1].first_win_gift
	local GridList = self.m_FirstGrid:GetChildList() or {}
	local oFirstPrizeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oFirstPrizeBox = self.m_FirstBoxClone:Clone(false)
				-- self.m_FirstGrid:AddChild(oOptionBtn)
			else
				oFirstPrizeBox = GridList[i]
			end
			self:SetFirstPrizeBox(oFirstPrizeBox, data.jjcdata.JJCGLOBAL[1].first_win_gift[i])
		end

		if #GridList > optionCount then
			for i=optionCount+1,#GridList do
				GridList[i]:SetActive(false)
			end
		end
	else
		if GridList and #GridList > 0 then
			for _,v in ipairs(GridList) do
				v:SetActive(false)
			end
		end
	end

	self.m_FirstGrid:Reposition()
	self.m_FirstScrollView:ResetPosition()
end

function CJjcPrizeView.SetFirstPrizeBox(self, oFirstPrizeBox, oData)
	oFirstPrizeBox:SetActive(true)
	oFirstPrizeBox.m_ItemIcon = oFirstPrizeBox:NewUI(2, CSprite)
	oFirstPrizeBox.m_ItemQualitySp = oFirstPrizeBox:NewUI(3, CSprite)
	oFirstPrizeBox.m_ItemCountLbl = oFirstPrizeBox:NewUI(4, CLabel)

	local oItemConfig = DataTools.GetItemData(oData.sid)
	oFirstPrizeBox.m_ItemIcon:SpriteItemShape(oItemConfig.icon)
	local oAmount = tonumber(oData.cnt)
	if oAmount <= 1 then
		oFirstPrizeBox.m_ItemCountLbl:SetText("")
	else
		oFirstPrizeBox.m_ItemCountLbl:SetText(oAmount)
	end
	oFirstPrizeBox.m_ItemQualitySp:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemConfig.id, oItemConfig.quality or 0 ))

	oFirstPrizeBox.m_ItemIcon:AddUIEvent("click", callback(self, "OnClickFirstPrizeBox", oData, oFirstPrizeBox.m_ItemIcon))

	self.m_FirstGrid:AddChild(oFirstPrizeBox)
	self.m_FirstGrid:Reposition()
end

--显示奖励tips
function CJjcPrizeView.OnClickFirstPrizeBox(self, oPrize, oPrizeBox)
	local args = {
        widget = oPrizeBox,
        side = enum.UIAnchor.Side.Top,
        offset = Vector2.New(0, 10)
    }
    g_WindowTipCtrl:SetWindowItemTip(oPrize.sid, args)
end

return CJjcPrizeView