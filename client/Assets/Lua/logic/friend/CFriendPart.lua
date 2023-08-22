local CFriendPart = class("CFriendPart", CPageBase)

function CFriendPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CFriendItem)
	self.m_ItemClone:SetActive(false)
	
	self.m_EmptyGo = self:NewUI(6,CObject)
	self.m_EmptyLbl = self:NewUI(7,CLabel)
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:InitContent()
end

--初始化执行，也可被调用
function CFriendPart.InitContent(self)
	self:RefreshFriendGrid()
end

--协议通知返回，主要就是增加或删除好友
function CFriendPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:OnFrdUpdate(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.Del then
		self:OnFrdDel(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.Add then
		-- printc("CFriendPart添加好友协议返回")
		-- table.print(oCtrl.m_EventData,"添加好友协议返回")
		self:OnFrdAdd(oCtrl.m_EventData)
	end
end

----------------------ui refresh---------------------------------
function CFriendPart.RefreshFriendGrid(self)
	self.m_ItemGrid:Clear()
	local frdlist = g_FriendCtrl:GetMyFriend()		
	table.sort(frdlist, g_FriendCtrl.Sort)

	if self.m_LoadTimer then
        Utils.DelTimer(self.m_LoadTimer)
        self.m_LoadTimer = nil
    end
    self.m_LoadIndex = 1
    self.m_LoadTimer = Utils.AddTimer(callback(self, "LoadFriend", frdlist), 0.03, 0) 
	self:RefreshEmpty(#frdlist <= 0)
end

function CFriendPart.LoadFriend(self, frdlist)
	if Utils.IsNil(self) then
		return
	end
	for i=1, 6 do
		local iPid = frdlist[self.m_LoadIndex]
		if iPid then
			local oItem = self.m_ItemClone:Clone()
			oItem:SetGroup(self.m_ItemGrid:GetInstanceID())
			self:SetItemData(oItem, iPid)
			self.m_ItemGrid:AddChild(oItem)
		end
		self.m_LoadIndex = self.m_LoadIndex + 1
		if self.m_LoadIndex > #frdlist then
			self.m_ItemGrid:Reposition()
			return false
		end
	end
	self.m_ItemGrid:Reposition()
	return true
end

--刷新好友part的empty介绍界面
function CFriendPart.RefreshEmpty(self, bEmpty)
	if not bEmpty then
		self.m_EmptyGo:SetActive(false)
	else
		self.m_EmptyGo:SetActive(true)
		local InsStr = data.frienddata.FRIENDTEXT[define.Friend.Text.FriendIns].content
		self.m_EmptyLbl:SetText(InsStr)
	end
end

--遍历一遍，刷新好友列表信息
function CFriendPart.ResortGrid(self)
	local frdlist = g_FriendCtrl:GetMyFriend()
	table.sort(frdlist, g_FriendCtrl.Sort)
	for i, pid in pairs(frdlist) do
		local oItem = self.m_ItemGrid:GetChild(i)
		if oItem then
			self:SetItemData(oItem, pid)
		end
	end
end

--设置其中一个item的信息
function CFriendPart.SetItemData(self, oItem, pid)
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	oItem.m_Button:AddUIEvent("click", callback(self, "ShowTalk", pid))
	oItem.m_ExpandBtn:AddUIEvent("click", callback(self, "OpenFriend", pid))
end

--下边函数就是增加或删除好友item

function CFriendPart.AddFriendItems(self, frdList)
	for i = 1, #frdList do
		local oItem = self.m_ItemClone:Clone()
		oItem:SetGroup(self.m_ItemGrid:GetInstanceID())
		self.m_ItemGrid:AddChild(oItem)
	end
	self:ResortGrid()
	self:RefreshEmpty(#g_FriendCtrl:GetMyFriend() <= 0)
end

function CFriendPart.DelFriendItems(self, frdList)
	local itemList = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(itemList) do
		if table.index(frdList, oItem.m_ID) then
			self.m_ItemGrid:RemoveChild(oItem)
		end
	end
	self:RefreshEmpty(#g_FriendCtrl:GetMyFriend() <= 0)
end

------------------------click event--------------------------------
--点击好友item进入聊天界面
function CFriendPart.ShowTalk(self, pid)
	self.m_ParentView:ShowTalk(pid)
end

--点击打开人物信息界面
function CFriendPart.OpenFriend(self, pid)
	netplayer.C2GSGetPlayerInfo(pid)
end

function CFriendPart.OnFrdUpdate(self, frdList)
	self:ResortGrid()
end

function CFriendPart.OnFrdAdd(self, frdList)
	self:AddFriendItems(frdList)
end

function CFriendPart.OnFrdDel(self, frdList)
	self:DelFriendItems(frdList)
end

return CFriendPart