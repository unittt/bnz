local CLinkInfoCtrl = class("CLinkInfoCtrl")

function CLinkInfoCtrl.ctor(self)
	self.m_ItemInfo = {}
	self.m_SummonInfo = {}
	self.m_PartnerInfo = {}
	self.m_AttrCardInfo = {}
	self.m_TitleInfo = {}
end

----------------------道具相关-------------------------

--执行链接的具体函数，这里是获取道具信息
function CLinkInfoCtrl.GetItemInfo(self, pid, itemID)
	if self.m_ItemInfo[pid] then
		if self.m_ItemInfo[pid][itemID] then
			if g_TimeCtrl:GetTimeS() - self.m_ItemInfo[pid][itemID]["lastctime"] < 10 then
				self:ShowItemInfo(self.m_ItemInfo[pid][itemID])
				return
			end
		end
	end
	netplayer.C2GSPlayerItemInfo(pid, itemID)
end

function CLinkInfoCtrl.RefreshItemInfo(self, pid, data)
	local itemID = data["id"]
	if itemID then
		if not self.m_ItemInfo[pid] then
			self.m_ItemInfo[pid] = {}
		end
		self.m_ItemInfo[pid][itemID] = CItem.New(data)
		self.m_ItemInfo[pid][itemID]["lastctime"] = g_TimeCtrl:GetTimeS()
		self:ShowItemInfo(self.m_ItemInfo[pid][itemID])
	end
end

function CLinkInfoCtrl.ShowItemInfo(self, data)
	CItemTipsView:ShowView(function(oView)
		oView:SetItem(data)
		oView:HideBtns()
		if data:IsEquip() then
			oView.m_EquipBox.m_RightBtn:SetActive(false)
			oView.m_EquipBox.m_LeftBtn:SetActive(false)
		end
	end)
end

--------------------宠物相关----------------------

--执行链接的具体函数，这里是获取宠物信息
function CLinkInfoCtrl.GetSummonInfo(self, pid, sid, isIgnoreTime)
	if not self.m_SummonInfo[pid] then
		self.m_SummonInfo[pid] = {}
	end
	if not self.m_SummonInfo[pid][sid] then
		self.m_SummonInfo[pid][sid] = {}
	end
	
	if not isIgnoreTime then
		if next(self.m_SummonInfo[pid][sid]) then
			if g_TimeCtrl:GetTimeS() - self.m_SummonInfo[pid][sid]["lastctime"] < 60 then
				self:ShowSummonInfo(self.m_SummonInfo[pid][sid])
				return
			end
		end
	end
	netplayer.C2GSPlayerSummonInfo(pid, sid)
end

function CLinkInfoCtrl.RefreshSummonInfo(self, pid, data)
	local summonID = data["id"]
	if summonID then
		-- data["time"] = self.m_SummonInfo[pid][summonID]["time"]
		self.m_SummonInfo[pid][summonID] = data
		self.m_SummonInfo[pid][summonID]["lastctime"] = g_TimeCtrl:GetTimeS()
		self:ShowSummonInfo(self.m_SummonInfo[pid][summonID])
	end
end

function CLinkInfoCtrl.ShowSummonInfo(self, data)
	CSummonLinkView:ShowView(function(oView)
		oView:SetSummon(data)
	end)
end

--------------------伙伴相关----------------------

--执行链接的具体函数，这里是获取伙伴信息
function CLinkInfoCtrl.GetPartnerInfo(self, pid, sid, itime)
	if not self.m_PartnerInfo[pid] then
		self.m_PartnerInfo[pid] = {}
	end
	if not self.m_PartnerInfo[pid][sid] then
		self.m_PartnerInfo[pid][sid] = {}
	end
	
	if next(self.m_PartnerInfo[pid][sid]) then
		if g_TimeCtrl:GetTimeS() - self.m_PartnerInfo[pid][sid]["lastctime"] < 60 then
			self:ShowPartnerInfo(self.m_PartnerInfo[pid][sid])
			return
		end
	end
	netplayer.C2GSPlayerPartnerInfo(pid, sid)
end

function CLinkInfoCtrl.GS2CPlayerPartnerInfo(self, pbdata)
	local pid = pbdata.pid
	local partnerID = pbdata.partnerdata.id
	if partnerID and partnerID ~= 0 then
		-- data["time"] = self.m_PartnerInfo[pid][partnerID]["time"]
		self.m_PartnerInfo[pid][partnerID] = pbdata
		self.m_PartnerInfo[pid][partnerID]["lastctime"] = g_TimeCtrl:GetTimeS()
		self:ShowPartnerInfo(self.m_PartnerInfo[pid][partnerID])
	end
end

function CLinkInfoCtrl.ShowPartnerInfo(self, pbdata)
	CPartnerLinkView:ShowView(function(oView)
		oView:SetPartner(pbdata)
	end)
end

-----------------人物名片相关---------------------

--获取名片信息
function CLinkInfoCtrl.GetAttrCardInfo(self, pid)
	if self.m_AttrCardInfo[pid] then	
		if g_TimeCtrl:GetTimeS() - self.m_AttrCardInfo[pid]["lastctime"] < 60 and pid ~= g_AttrCtrl.pid then
			self:ShowAttrCardInfo(self.m_AttrCardInfo[pid])
			return
		end
	end
	netplayer.C2GSNameCardInfo(pid)
end

--刷新名片信息
function CLinkInfoCtrl.RefreshAttrCardInfo(self, data)
	if data then
		self.m_AttrCardInfo[data.pid] = data
		self.m_AttrCardInfo[data.pid]["lastctime"] = g_TimeCtrl:GetTimeS()
		self:ShowAttrCardInfo(self.m_AttrCardInfo[data.pid])
	end
end

function CLinkInfoCtrl.GetSelfAttrCardInfo(self)
	return self.m_AttrCardInfo[g_AttrCtrl.pid]
end

function CLinkInfoCtrl.GetAttrCardByPid(self, pid)
	return self.m_AttrCardInfo[pid]
end

--缓存数据
function CLinkInfoCtrl.SaveAttrCardInfo(self, pid, data)
	if self.m_AttrCardInfo[pid] == nil then 
		self.m_AttrCardInfo[pid] = {}
	end 
	self.m_AttrCardInfo[pid].isupvote = 1 --已经点赞
	if self.m_AttrCardInfo[pid].upvote_amount == nil then
		self.m_AttrCardInfo[pid].upvote_amount = 0	 
	end
	self.m_AttrCardInfo[pid].upvote_amount = self.m_AttrCardInfo[pid].upvote_amount + data --点赞加1
end

--显示名片
function CLinkInfoCtrl.ShowAttrCardInfo(self, data)
	local view = CCardLikeListView:GetView()
	local moodsView = CMoodsRankView:GetView()
	if view then 
		view:OnClose() --关闭点赞列表界面
	end
	if moodsView then 
		moodsView:OnClose()	--关闭点赞排行界面
	end 
	CAttrCardLinkView:ShowView(function(oView)
		if data.pid == g_AttrCtrl.pid then --判断是否自己点击自己名片 
			oView:SetSelfCardInfo(data)
		else
			oView:SetCardLinkInfo(data)
		end
	end)
end

function CLinkInfoCtrl.UpvotePlayerAdd(self)
	if self.m_CurAttrCardLinkView then 
		self.m_CurAttrCardLinkView:MoodsAdd()
	end 
end

function CLinkInfoCtrl.RfreshMyCardInfo(self)
	local dInfo = self.m_AttrCardInfo[g_AttrCtrl.pid]
	if not dInfo then
		return
	end
	for k,v in pairs(dInfo) do
		if g_AttrCtrl[k] and g_AttrCtrl[k] ~= v then
			dInfo[k] = g_AttrCtrl[k]
		end
	end
	printc("RfreshMyCardInfo")
	table.print()
end

-----------------人物称谓相关---------------------
function CLinkInfoCtrl.ShowTitleInfo(self, name, tid)
	CTitleLinkView:ShowView(function (oView)
		oView:ResbuildDescList(name, tid)
	end)
end

return CLinkInfoCtrl

