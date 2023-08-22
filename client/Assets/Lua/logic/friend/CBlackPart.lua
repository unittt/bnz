local CBlackPart = class("CBlackPart", CPageBase)

--好友黑名单

function CBlackPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_MaxItem = 30
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CBlackFrdItem)
	self.m_ItemClone:SetActive(false)
	
	self.m_EmptyGo = self:NewUI(6,CObject)
	self.m_EmptyLbl = self:NewUI(7,CLabel)
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:InitContent()
end

--初始化执行，也可被调用
function CBlackPart.InitContent(self)
	self.m_ItemGrid:Clear()
	self.m_BlackList = table.slice(g_FriendCtrl.m_Friend["black"], 1, 20)
	for i = 1, 20 do
		local pid = self.m_BlackList[i]
		if pid then
			local oItem = self:CreateItem(pid)
			if oItem then
				self.m_ItemGrid:AddChild(oItem)
			end
		end
	end
	self.m_ItemGrid:Reposition()
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

--协议通知返回
function CBlackPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFrdItem(oCtrl.m_EventData)

	elseif oCtrl.m_EventID == define.Friend.Event.AddBlack then
		self:AddBlackItems(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.DelBlack then
		self:DelItems(oCtrl.m_EventData)
	end
end

--刷新黑名单part的empty介绍界面
function CBlackPart.RefreshEmpty(self,list)
	if next(list) then
		self.m_EmptyGo:SetActive(false)
	else
		self.m_EmptyGo:SetActive(true)
		local InsStr = data.frienddata.FRIENDTEXT[define.Friend.Text.BlackIns].content
		self.m_EmptyLbl:SetText(InsStr)
	end
end

--遍历一遍，对黑名单item的信息更新
function CBlackPart.UpdateFrdItem(self, frdList)
	if not frdList then
		return
	end
	local itemList = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(itemList) do
		if oItem and table.index(frdList, oItem.m_ID) then
			oItem:SetPlayer(oItem.m_ID)
		end
	end
end

--下边是对黑名单item增加或删除

function CBlackPart.AddBlackItems(self, blackList)
	for k, pid in pairs(blackList) do
		self:AddItem(pid)
	end
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

function CBlackPart.TopItem(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	local removeItem = nil
	for k, oItem in pairs(list) do
		if oItem.m_ID == pid then
			removeItem = oItem
		end
	end
	
	if removeItem then
		self.m_ItemGrid:RemoveChild(removeItem)
	end
	self:AddItem(pid)
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

function CBlackPart.AddItem(self, pid)
	local oItem = self:CreateItem(pid)
	self.m_ItemGrid:AddChild(oItem)
	oItem:SetAsFirstSibling()
end

function CBlackPart.CreateItem(self, pid)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	oItem.m_ID = pid
	oItem.m_Button:AddUIEvent("click", callback(self, "DelBlack", pid))
	return oItem
end

function CBlackPart.DelItems(self, frdList)
	local itemList = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(itemList) do
		if table.index(frdList, oItem.m_ID) then
			self.m_ItemGrid:RemoveChild(oItem)
		end
	end
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

--点击黑名单上的删除按钮
function CBlackPart.DelBlack(self, pid)
	local name = ""
	local frdobj = g_FriendCtrl:GetFriend(pid)
	if frdobj then
		name = frdobj.name
	end
	g_FriendCtrl:ApplyDelBlackFriend(pid, name)
end

return CBlackPart