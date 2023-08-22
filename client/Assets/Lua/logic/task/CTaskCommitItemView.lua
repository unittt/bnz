local CTaskCommitItemView = class("CTaskCommitItemView", CViewBase)

function CTaskCommitItemView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/CommitItemView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"

	self.m_YibaoDrugQuality = 60
	self.m_YibaoEquipQuality = 3
end

function CTaskCommitItemView.OnCreateView(self)
	self.m_Sessionidx = ""
	self.m_RecordTable = {}

	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CommitBtn = self:NewUI(2, CButton)
	self.m_TitleLabel = self:NewUI(3, CLabel)
	self.m_ItemBoxSry = self:NewUI(4, CScrollView)
	self.m_BoxGrid = self:NewUI(5, CGrid)
	self.m_CloneCommitItemBox = self:NewUI(6, CCommitItemBox)

	CTaskCommitSummonView:CloseView()

	self:InitContent()
end

function CTaskCommitItemView.InitContent(self)
	self.m_CloneCommitItemBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CommitBtn:AddUIEvent("click", callback(self, "OnCommitBtn"))
end

function CTaskCommitItemView.SetContent(self, sessionidx, oTask)
	self.m_Sessionidx = sessionidx
	self.m_TitleLabel:SetText("任务提交物品")
	local idList, tNeedItem, commitType = CTaskHelp.GetTaskFindItemDic(oTask)
	-- self.m_NeedItem = tNeedItem
	self.m_NeedItem = {}
	table.copy(tNeedItem, self.m_NeedItem)
	self.m_CommitType = commitType
	self.m_LimitQuality = oTask:GetLimitQuality()
	local itemTable = {}
	if commitType == "normal" then
		itemTable = g_ItemCtrl:GetBagItemTableBySidList(idList, self.m_LimitQuality)
	elseif commitType == "group" then
		itemTable = g_ItemCtrl:GetBagItemTableByGroupidList(idList, self.m_LimitQuality)
	end
	self.m_RecordTable = {}
	self:InitItemBoxGridNoamal(itemTable)
end

function CTaskCommitItemView.InitItemBoxGridNoamal(self, itemTable)
	if not itemTable then
		return
	end
	local sortItemTable = {}
	for k,v in pairs(itemTable) do
		for i,j in pairs(v) do
			table.insert(sortItemTable, j)
		end
	end
	table.sort(sortItemTable,  function (a, b)
		local aQuality = a:GetSValueByKey("itemlevel") or 0
		local bQuality = b:GetSValueByKey("itemlevel") or 0
		local aPos = a:GetSValueByKey("pos")
		local bPos = b:GetSValueByKey("pos")
		if aQuality ~= bQuality then
			return aQuality < bQuality
		else
			return aPos < bPos
		end
	end)
	-- table.print(sortItemTable, "提交物品列表")
	--暂时屏蔽
	-- if next(sortItemTable) then
	-- 	local oItem = sortItemTable[1]
	-- 	local firstItemSid = oItem:GetSValueByKey("sid")
	-- 	if self.m_CommitType == "normal" then
	-- 		self.m_RecordTable[firstItemSid] = {oItem}
	-- 	elseif self.m_CommitType == "group" then
	-- 		for k,_ in pairs(self.m_NeedItem) do
	-- 			local itemgroups = DataTools.GetItemGroup(k)
	-- 			if table.index(itemgroups.itemgroup, firstItemSid) then
	-- 				self.m_RecordTable[k] = {oItem}
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
	self.m_BoxGrid:Clear()
	-- 获取可提交道具数据
	for k,v in ipairs(sortItemTable) do
		local oItemBox = self.m_CloneCommitItemBox:Clone(function (commitBox)
			return self:OnClickSelectBox(commitBox)
		end)
		self.m_BoxGrid:AddChild(oItemBox)
		oItemBox:SetCommitItemInfo(v)
		oItemBox:SetActive(true)
		--暂时屏蔽
		-- if k == 1 then
		-- 	oItemBox:ForceSelected(true)
		-- end
	end
	local oItemBoxList = self.m_BoxGrid:GetChildList()
	for i=1, #oItemBoxList, 1 do
		self:OnClickSelectBox(oItemBoxList[i], true)
	end
	-- table.print(self.m_RecordTable, "222222222222222")
end

function CTaskCommitItemView.OnClickSelectBox(self, commitBox, isForceSelect)
	local exist = false
	local itemList = {}
	local needCount = 0
	local sid = commitBox.m_Item:GetSValueByKey("sid")
	local recordKey = ""

	if self.m_CommitType == "normal" then
		recordKey = sid
		itemList = self.m_RecordTable[sid] or {}
		needCount = self.m_NeedItem and self.m_NeedItem[sid].amount or 0
	elseif self.m_CommitType == "group" then
		for k,_ in pairs(self.m_NeedItem) do
			local itemgroups = DataTools.GetItemGroup(k)
			if table.index(itemgroups.itemgroup, sid) then
				recordKey = k
				itemList = self.m_RecordTable[k] or {}
				needCount = self.m_NeedItem and self.m_NeedItem[k].amount or 0
				break
			end
		end
	end

	for i,m in ipairs(itemList) do
		if m.m_ID == commitBox.m_Item.m_ID then
			exist = true
			commitBox:ForceSelected(false)
			table.remove(itemList, i)
			break
		end
	end
	if not exist then
		local count = 0
		for _,m in ipairs(itemList) do
			count = count + m:GetSValueByKey("amount")
		end
		
		if count < needCount then
			table.insert(itemList, commitBox.m_Item)
			self.m_RecordTable[recordKey] = itemList
			commitBox:ForceSelected(true)
		else
			if not isForceSelect then
				for k, v in ipairs(self.m_BoxGrid:GetChildList()) do
					if v.m_Item.m_ID == itemList[1].m_ID then
						v:ForceSelected(false)
						break
					end
				end
				table.remove(itemList, 1)
				table.insert(itemList, commitBox.m_Item)
				self.m_RecordTable[recordKey] = itemList
				commitBox:ForceSelected(true)
			else
				--isForceSelect为true时满足条件就不选择下一个了
				commitBox:ForceSelected(false)
			end
			
			-- g_NotifyCtrl:FloatMsg("不能选择更多了")			
		end
	end
	return exist
end

function CTaskCommitItemView.OnCommitBtn(self)
	local itemCount = 0
	local amountTable = {}
	for k,t in pairs(self.m_RecordTable) do
		amountTable[k] = {itemName = "", amount = 0, list = {}}
		for _,v in ipairs(t) do
			if not amountTable[k].itemName or string.len(amountTable[k].itemName) <= 0 then
				local itemName = v:GetSValueByKey("name")
				if self.m_CommitType == "group" then
					local itemgroups = DataTools.GetItemGroup(k)
					itemName = itemgroups.name
				end
				amountTable[k].itemName = itemName
				amountTable[k].amount = 0
			end
			local amount = v:GetSValueByKey("amount")

			local item = {}
			item.id = v:GetSValueByKey("id")
			item.amount = amount
			item.data = v
			table.insert(amountTable[k].list, item)

			itemCount = itemCount + amount
			amountTable[k].amount = amountTable[k].amount + amount
		end
	end

	if itemCount > 0 then
		for k,v in pairs(self.m_NeedItem) do
			local amount = amountTable[k].amount or 0
			if amount < v.amount then
				g_NotifyCtrl:FloatMsg(string.format("#G%s[-]数量不足#G%s[-]个，无法提交任务", amountTable[k].itemName, v.amount))
				return
			end
		end

		local bIsHasQuality = false
		local oItemName = ""
		local commitList = {}
		for k,item in pairs(amountTable) do
			local needCount = self.m_NeedItem[k].amount or 1
			for _,v in ipairs(item.list) do
				local out = v.amount > needCount
				local amount = out and needCount or v.amount
				needCount = needCount - v.amount
				local t = {
					id = v.id,
					amount = amount,
				}
				if v.data:IsEquip() then
					if v.data:GetSValueByKey("itemlevel") >= self.m_YibaoEquipQuality then
						oItemName = v.data:GetSValueByKey("name")
						bIsHasQuality = true
					end
				else
					if v.data:GetSValueByKey("itemlevel") >= self.m_YibaoDrugQuality then
						oItemName = v.data:GetSValueByKey("name")
						bIsHasQuality = true
					end
				end
				table.insert(commitList, t)
				if out then
					break
				end
			end
		end
		if self.m_IsYibaoCommit and bIsHasQuality then
			local windowConfirmInfo = {
				msg = "#D#G"..oItemName.."#n品质较高，少侠你确定当作任务物品提交？",
				title = "提示",
				okCallback = function () 
					netother.C2GSCallback(self.m_Sessionidx, nil, commitList)
					self.m_RecordTable = nil
					self:CloseView()
				end,
				cancelCallback = function () 
					
				end,
				okStr = "确认",
				cancelStr = "取消",
				color = Color.white,
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
		else
			netother.C2GSCallback(self.m_Sessionidx, nil, commitList)
			self.m_RecordTable = nil
			self:CloseView()
		end
	else
		g_NotifyCtrl:FloatMsg("未选择提交物品")
	end
end

function CTaskCommitItemView.OnHideView(self)
	g_TaskCtrl.m_HelpOtherTaskData = {}
end

return CTaskCommitItemView