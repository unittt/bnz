local CItemWHPart = class("CItemWHPart", CPageBase)

function CItemWHPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CItemWHPart.OnInitPage(self)
	self.m_WHCellMax = tonumber(DataTools.GetGlobalData(102).value or 9)
	self.m_WHCellConsume  = tonumber(DataTools.GetGlobalData(104).value or 1000000)
	self.m_WHOpenCount = 0
	self.m_WHCellCount = 0
	self.m_RefreshCellName = false
	self.m_WinTipViwe = nil
	self.m_WinInputViwe = nil

	-- 仓库名称
	self.m_TitleLab = self:NewUI(1, CLabel)
	self.m_RenameBtn = self:NewUI(2, CButton)
	self.m_TitleFlagBtn = self:NewUI(3, CButton)
	
	-- 仓库物品Itemcell
	self.m_WHItemBoxGrid = self:NewUI(4, CGrid)
	self.m_CloneItemCell = self:NewUI(5, CItemBox)
	
	-- 仓库翻页、整理
	self.m_PageTurnLeftLab = self:NewUI(6, CLabel)
	self.m_PrePageBtn = self:NewUI(7, CButton)
	self.m_NextPageBtn = self:NewUI(8, CButton)
	self.m_WHArrangeBtn = self:NewUI(9, CButton)

	-- 仓库格子
	self.m_WHCellGroup = self:NewUI(10, CObject)
	self.m_WHCellScly = self:NewUI(11, CScrollView)
	self.m_WHCellGrid =  self:NewUI(12, CGrid)
	self.m_CloneWHCell = self:NewUI(13, CButton)
	self.m_WHLockSpr = self:NewUI(14, CSprite)
	self.m_WHBgSpr = self:NewUI(15, CSprite)

	-- 仓库mgr数据监听
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	-- 仓库物品克隆
	self.m_CloneItemCell:SetActive(false)
	self:InitWHItemBox()

	-- 仓库格子默认隐藏
	self.m_WHCellGroup:SetActive(false)
	g_UITouchCtrl:TouchOutDetect(self.m_WHCellGroup, callback(self, "OnWHCellTouchOutDetect"))
	-- 仓库格子克隆
	self.m_CloneWHCell:SetActive(false)
	self:RefreshWHCellBox()

	-- 仓库数量背景高度
	-- self:SetWHBgSprHeight()

	-- 仓库UI事件监听
	self.m_RenameBtn:AddUIEvent("click", callback(self, "OnRenameBtn"))
	self.m_TitleFlagBtn:AddUIEvent("click", callback(self, "OnTitleArrowBtn"))
	self.m_PrePageBtn:AddUIEvent("click", callback(self, "OnPageTurnBtn", -1))
	self.m_NextPageBtn:AddUIEvent("click", callback(self, "OnPageTurnBtn", 1))
	self.m_WHArrangeBtn:AddUIEvent("click", callback(self, "OnWHArrangeBtn"))

	self.m_PrePageBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
	self.m_NextPageBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
	self.m_WHArrangeBtn:SetClickSounPath(define.Audio.SoundPath.Tab)

	-- 仓库设置默认
	self:SwitchWHCell()
	self:RefreshWHName()
	self:RefreshWhBoxGrid()
end

function CItemWHPart.OnWHCellTouchOutDetect(self, gameObj)
	if gameObj == self.m_TitleFlagBtn.m_GameObject or gameObj == self.m_RenameBtn.m_GameObject then
		return
	end

	if self.m_WinTipViwe and not Utils.IsNil(self.m_WinTipViwe) then
		if UITools.IsChild(self.m_WinTipViwe.m_Transform, gameObj.transform) then
			return
		end
	end

	if self.m_WinInputViwe and not Utils.IsNil(self.m_WinInputViwe) then
		if UITools.IsChild(self.m_WinInputViwe.m_Transform, gameObj.transform) then
			return
		end
	end

	if self.m_WHCellGroup:GetActive() then
		self:OnTitleArrowBtn()
	end
end

function CItemWHPart.InitWHItemBox(self)
	for i = 1, define.Item.Constant.WHFixCount do
		local oItemBox = self.m_CloneItemCell:Clone(define.Item.CellType.WHCell)
		oItemBox:SetActive(true)
		oItemBox:ShowEquipLevel(true)
		oItemBox:ShowWenShiLevel(true)
		self.m_WHItemBoxGrid:AddChild(oItemBox)
		oItemBox:SetGroup(99999)
	end
end

function CItemWHPart.RefreshWHCellBox(self)
	self.m_WHOpenCount = g_ItemCtrl:GetWHCellOpenCount()
	self.m_WHCellCount = self.m_WHOpenCount + 1
	local isCellMax = self.m_WHCellCount > self.m_WHCellMax
	-- self.m_WHLockSpr:SetActive(not isCellMax)
	self.m_WHLockSpr:SetActive(false)
	if isCellMax then
		self.m_WHCellCount = self.m_WHCellMax
	end

	local oCellBtn = nil
	local gridList = self.m_WHCellGrid:GetChildList()

	for i=1,self.m_WHCellCount do
		if i > #gridList then
			oCellBtn = self.m_CloneWHCell:Clone()
			self.m_WHCellGrid:AddChild(oCellBtn)
			oCellBtn:SetGroup(self.m_WHCellGrid:GetInstanceID())
			oCellBtn:SetClickSounPath(define.Audio.SoundPath.Tab)
		else
			oCellBtn = gridList[i]
		end

		local showLock = i > self.m_WHOpenCount
		if oCellBtn:IsLabelInChild() then
			oCellBtn.m_ChildLabel:SetActive(not showLock)
		end

		if showLock then
			self.m_WHLockSpr:SetParent(oCellBtn.m_Transform)
			self.m_WHLockSpr:SetLocalPos(Vector3.zero)
		else
			oCellBtn:SetText(self:GetWHCellName(i))
		end
		oCellBtn:SetSpriteName("h7_an_4")
		self.m_WHLockSpr:SetActive(showLock)
		oCellBtn:SetActive(true)

		oCellBtn:AddUIEvent("click", callback(self, "OnWHCellBtn", i, oCellBtn))
	end

	self:SetWHBgSprHeight()
	local panel = NGUI.UIPanel.Find(self.m_WHCellScly.m_Transform)
	panel:UpdateAnchors()
end

function CItemWHPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshWHData then
		self:RefreshWhBoxGrid()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshWHCell then
		self:RefreshWHCellBox()
		self:RefreshPageTurn()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshWHName then
		self:RefreshWHName(oCtrl.m_EventData)
	end
end

function CItemWHPart.RefreshWhBoxGrid(self)
	local itemList = g_ItemCtrl.m_WHItems[g_ItemCtrl.m_RecordWHIndex]	
	if itemList == nil then 
		return false
	end

	local gridList = self.m_WHItemBoxGrid:GetChildList()
	for _,v in ipairs(gridList) do
		v:SetBagItem(nil)
	end

	for _,v in pairs(itemList) do
		local pos = v:GetSValueByKey("pos")
		local oItemBox = gridList[pos]
		if oItemBox then
			oItemBox:SetBagItem(v)
		end
		if g_ItemCtrl.m_CurrClickItem then
			if g_ItemCtrl.m_CurrClickItem:GetSValueByKey("id") == v:GetSValueByKey("id") then
				g_ItemCtrl.m_CurrClickItem = v
				g_ItemCtrl.m_CurrClickBox = oItemBox
				g_ItemCtrl.m_CurrClickBox:ForceSelected(true)
			end
		end
	end
end

function CItemWHPart.RefreshWHName(self, dWHCell)
	if dWHCell then
		local wid = dWHCell.wid
		if wid == g_ItemCtrl.m_RecordWHIndex then
			local cellName = "[b][ad6944]" .. dWHCell.name
			-- self.m_TitleLab:SetText(cellName)
			self.m_TitleLab:SetText(dWHCell.name)

			local whCellBox = self.m_WHCellGrid:GetChild(wid)
			if whCellBox then
				whCellBox:SetText(dWHCell.name)
			end
			return
		end
	end

	local cellName = "[b][ad6944]" .. self:GetWHCellName(g_ItemCtrl.m_RecordWHIndex)
	-- self.m_TitleLab:SetText(cellName)
	self.m_TitleLab:SetText(self:GetWHCellName(g_ItemCtrl.m_RecordWHIndex))
end

function CItemWHPart.OnWHCellBtn(self, index, box)
	self:SwitchWHCell(index)
	box:ForceSelected(true)
	g_ItemCtrl:OnEvent(define.Item.Event.TabSwitch)
	local clickLock = index == self.m_WHCellCount and self.m_WHOpenCount ~= self.m_WHCellCount
	if not clickLock then
		self:OnTitleArrowBtn()
	end
end

function CItemWHPart.SwitchWHCell(self, index)
	if g_ItemCtrl.m_RecordWHIndex ~= index then
		if index == self.m_WHCellCount and self.m_WHOpenCount ~= self.m_WHCellCount then
			self:ShowLockWindowTip()
		else
			self:RefreshPageTurn(index)

			self:RefreshWHName()
			self:CheckSwitchWareHouse()
		end
	end
end

function CItemWHPart.RefreshPageTurn(self, index)
	g_ItemCtrl.m_RecordWHIndex = index or g_ItemCtrl.m_RecordWHIndex
	local pageLabel = string.format("[63432C]%s/%s[-]", g_ItemCtrl.m_RecordWHIndex, self.m_WHOpenCount)
	self.m_PageTurnLeftLab:SetText(pageLabel)

	local oCellBtn = self.m_WHCellGrid:GetChild(g_ItemCtrl.m_RecordWHIndex)
	g_AudioCtrl:SetRecordInfo(self.m_WHCellGrid:GetInstanceID(), oCellBtn:GetInstanceID())
end

function CItemWHPart.CheckSwitchWareHouse(self)
	local itemList = g_ItemCtrl.m_WHItems[g_ItemCtrl.m_RecordWHIndex]
	if itemList == nil then 
		netwarehouse.C2GSSwitchWareHouse(g_ItemCtrl.m_RecordWHIndex)
	else
		self:RefreshWhBoxGrid()
	end
end

function CItemWHPart.OnTitleArrowBtn(self)
	self.m_WHArrowStatus = not self.m_WHArrowStatus
	local tSpriteName = self.m_WHArrowStatus and "h7_xiaoan_11" or "h7_xiaoan_12"
	self.m_TitleFlagBtn:SetSpriteName(tSpriteName)

	self.m_WHCellGroup:SetActive(self.m_WHArrowStatus)
end

function CItemWHPart.ShowLockWindowTip(self)
	local okCb = function()
		if Utils.IsNil(self) then return end
		if g_AttrCtrl.silver >= self.m_WHCellConsume then
			netwarehouse.C2GSBuyWareHouse()
		else
	        g_QuickGetCtrl:CheckLackItemInfo({
	            coinlist = {{sid = 1002, amount = self.m_WHCellConsume, count = g_AttrCtrl.silver}},
	            exchangeCb = function()
	                netwarehouse.C2GSBuyWareHouse()
	            end
	        })
		end
	end
	local windowConfirmInfo = {
		msg = string.gsub(DataTools.GetMiscText(2007).content, "#consume", self.m_WHCellConsume),
		title = "开启仓库",
		okCallback = okCb,
		cancelCallback = function ()
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
		self.m_WinTipViwe = oView
	end)
end

function CItemWHPart.OnRenameBtn(self)
	local windowInputInfo = {
		des				= "[63432c]最多输入4个汉字的长度~",
		title			= "仓库改名",
		inputLimit		= 8,
		defaultCallback = function (inputStr)
			if inputStr and string.len(inputStr) > 0 then
				if g_MaskWordCtrl:IsContainMaskWord(inputStr) then
					g_NotifyCtrl:FloatMsg("包含屏蔽字，请重新输入")
					return true
				end
				netwarehouse.C2GSRenameWareHouse(g_ItemCtrl.m_RecordWHIndex, inputStr)
			else
				g_NotifyCtrl:FloatMsg("请输入新的仓库名称")
				return true
			end
		end,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo, function (oView)
		self.m_WinInputViwe = oView
	end)
end

function CItemWHPart.OnPageTurnBtn(self, interval)
	local curIndex = g_ItemCtrl.m_RecordWHIndex + interval
	if curIndex < 1 then
		curIndex = self.m_WHOpenCount
	else if curIndex > self.m_WHOpenCount then
			curIndex = 1
		end
	end
	g_ItemCtrl:OnEvent(define.Item.Event.TabSwitch)
	self:SwitchWHCell(curIndex)
end

function CItemWHPart.OnWHArrangeBtn(self)
    if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.BagItemArrange, self:GetInstanceID()) then
        local ss = self.m_OnBagArragreTime - g_TimeCtrl:GetTimeS()
        if ss <= 1 then
        	ss = 1
        end
        g_NotifyCtrl:FloatMsg(string.gsub(DataTools.GetMiscText(2003).content, "#SS", ss))
        return
    end
    g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.BagItemArrange, self:GetInstanceID(), define.Item.Constant.ArrangeCD)
    self.m_OnBagArragreTime = g_TimeCtrl:GetTimeS() + define.Item.Constant.ArrangeCD

	netwarehouse.C2GSWareHouseArrange(g_ItemCtrl.m_RecordWHIndex)
end

function CItemWHPart.GetWHCellName(self, index)
	local nameList = g_ItemCtrl.m_WHNameList
	if nameList then
		return nameList[index] or (index > 2 and "" or "免费") .. "仓库" ..index
	end
end

function CItemWHPart.SetWHBgSprHeight(self)
	local _, iGridCellHeight = self.m_WHCellGrid:GetCellSize()
	local finalHeight = math.ceil(self.m_WHCellCount/3) * iGridCellHeight + 28
	self.m_WHBgSpr:SetHeight(finalHeight)
end

return CItemWHPart