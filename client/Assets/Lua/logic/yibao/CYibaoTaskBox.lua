local CYibaoTaskBox = class("CYibaoTaskBox", CBox)

function CYibaoTaskBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_IconSp = self:NewUI(1, CSprite)
	self.m_CountLbl = self:NewUI(2, CLabel)
	self.m_RedPointSp = self:NewUI(3, CSprite)
	self.m_DoneSp = self:NewUI(4, CSprite)
	self.m_NameLbl = self:NewUI(5, CLabel)
end

--type 1:主任务,2:探险,3:寻物,4:互动
function CYibaoTaskBox.SetMyselfContent(self, oData)
	-- local taskconfig = DataTools.GetTaskData(oData.taskid)
	-- printc("CYibaoTaskBox.SetMyselfContent", oData.taskid)
	local type = 4
	if g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid) then
		type = g_YibaoCtrl:GetMyselfDoingInfoByTaskid(oData.taskid).yibao_kind
	else
		type = oData.data.yibao_kind
	end
	if type == 4 then
		self:SetInteractionContent(oData)
	elseif type == 2 then
		self:SetStarContent(oData)
	elseif type == 3 then
		self:SetItemContent(oData)
	end
end

function CYibaoTaskBox.SetStarContent(self, oData)
	self.m_CountLbl:SetActive(false)
	self.m_RedPointSp:SetActive(false)
	self.m_IconSp:SetActive(false)
	if oData.state == "done" then
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data:GetSValueByKey("name"))
	end
end

function CYibaoTaskBox.SetItemContent(self, oData)
	local needitem
	self.m_CountLbl:SetActive(true)
	if oData.state == "done" then
		needitem = oData.data.needitem
		self.m_CountLbl:SetActive(false)	
		self.m_RedPointSp:SetActive(false)
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		needitem = oData.data:GetSValueByKey("needitem")
		-- table.print(needitem, "CYibaoTaskBox.SetItemContent needitem")
		self.m_CountLbl:SetText(g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid).."/"..needitem[1].amount)
		
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data:GetSValueByKey("name"))
		if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
			self.m_RedPointSp:SetActive(true)
		else
			self.m_RedPointSp:SetActive(false)
		end
	end
	self.m_IconSp:SetActive(true)
	-- printc("self.m_IconSp", oData.taskid, ",", DataTools.GetItemData(needitem[1].itemid).icon)
	self.m_IconSp:SpriteItemShape(DataTools.GetItemData(needitem[1].itemid).icon)
end

function CYibaoTaskBox.SetInteractionContent(self, oData)
	self.m_CountLbl:SetActive(false)
	self.m_RedPointSp:SetActive(false)
	self.m_IconSp:SetActive(false)
	if oData.state == "done" then
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data:GetSValueByKey("name"))
	end
end

function CYibaoTaskBox.SetMyselfPrizeBox(self)
	self.m_RedPointSp:SetActive(false)
	self.m_DoneSp:SetActive(false)
	local myselfData = g_YibaoCtrl:GetMyselfYibaoTaskData()
	self.m_CountLbl:SetText(table.count(g_YibaoCtrl.m_YibaoMyselfDoneInfo).."/"..#myselfData)
end

-------------------别人的taskbox的信息-----------------

--type 1:主任务,2:探险,3:寻物,4:互动
function CYibaoTaskBox.SetOtherContent(self, oData)
	-- local taskconfig = DataTools.GetTaskData(oData.taskid)
	-- printc("CYibaoTaskBox.SetOtherContent", oData.taskid)
	local type = oData.data.yibao_kind

	if type == 4 then
		self:SetOtherInteractionContent(oData)
	elseif type == 2 then
		self:SetOtherStarContent(oData)
	elseif type == 3 then
		self:SetOtherItemContent(oData)
	end
end

function CYibaoTaskBox.SetOtherStarContent(self, oData)
	self.m_CountLbl:SetActive(false)
	self.m_RedPointSp:SetActive(false)
	self.m_IconSp:SetActive(false)
	if oData.state == "done" then
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	end
end

function CYibaoTaskBox.SetOtherItemContent(self, oData)
	local needitem = oData.data.needitem
	self.m_CountLbl:SetActive(true)
	if oData.state == "done" then		
		self.m_CountLbl:SetActive(false)	
		self.m_RedPointSp:SetActive(false)
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		-- table.print(needitem, "CYibaoTaskBox.SetItemContent needitem")
		self.m_CountLbl:SetText(g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid).."/"..needitem[1].amount)
		
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
		if g_ItemCtrl:GetBagItemAmountBySid(needitem[1].itemid) >= needitem[1].amount then
			self.m_RedPointSp:SetActive(true)
		else
			self.m_RedPointSp:SetActive(false)
		end
	end
	self.m_IconSp:SetActive(true)
	self.m_IconSp:SpriteItemShape(DataTools.GetItemData(needitem[1].itemid).icon)
end

function CYibaoTaskBox.SetOtherInteractionContent(self, oData)
	self.m_CountLbl:SetActive(false)
	self.m_RedPointSp:SetActive(false)
	self.m_IconSp:SetActive(false)
	if oData.state == "done" then
		self.m_DoneSp:SetActive(true)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	else
		self.m_DoneSp:SetActive(false)
		self.m_NameLbl:SetColor(Color.white)
		self.m_NameLbl:SetText("#D"..oData.data.name)
	end
end

function CYibaoTaskBox.SetOtherPrizeBox(self)
	self.m_RedPointSp:SetActive(false)
	self.m_DoneSp:SetActive(false)
	local otherData = g_YibaoCtrl:GetOtherYibaoTaskData()
	self.m_CountLbl:SetText(table.count(g_YibaoCtrl.m_YibaoOtherDoneInfo).."/"..#otherData)
end

return CYibaoTaskBox