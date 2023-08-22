local CRecentPart = class("CRecentPart", CPageBase)

function CRecentPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_MaxItem = 30

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CRecentItem)
	self.m_ItemClone:SetActive(false)
	self.m_EmptyGo = self:NewUI(3,CObject)
	self.m_EmptyLbl = self:NewUI(4,CLabel)
	self.m_SpiritBox = self:NewUI(5, CBox)
	self.m_SpiritBoxClickWidget = self.m_SpiritBox:NewUI(4, CWidget)
	
	self.m_SpiritBoxClickWidget:AddUIEvent("click", callback(self, "OnClickSpiritBox"))
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOpenSysEvent"))
	self:InitContent()
end

--初始化执行，也可以被调用
function CRecentPart.InitContent(self)
	self:CheckSpiritBox()

	self.m_SortIndex = 900000
	self.m_ItemGrid:Clear()
	self.m_RecentList = table.slice(g_FriendCtrl.m_Friend["recent"], 1, g_FriendCtrl.m_RecentLimit)
	for i = 1, g_FriendCtrl.m_RecentLimit do
		local pid = self.m_RecentList[i]
		if pid then
			local oItem = self:CreateItem(pid)
			if oItem then
				self.m_ItemGrid:AddChild(oItem)
				oItem.m_GameObject.name = tostring(self.m_SortIndex)
				self.m_SortIndex = self.m_SortIndex + 1
			end
		end
	end
	self.m_ItemGrid:Reposition()
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

--协议通知返回，主要是增加或删除item
function CRecentPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Update then
		self:UpdateFrdItem(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Friend.Event.DelRecent then
		self:RemoveItem(oCtrl.m_EventData)

	elseif oCtrl.m_EventID == define.Friend.Event.AddRecent then
		self:TopItem(oCtrl.m_EventData)
	end
end

function CRecentPart.OnOpenSysEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SysOpen.Event.Login or oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:CheckSpiritBox()
	end
end

--精灵相关
function CRecentPart.CheckSpiritBox(self)
	self.m_SpiritBox:SetActive(g_SpiritCtrl:GetOpenState())
end

function CRecentPart.OnClickSpiritBox(self)
	if Utils.IsPC() or g_LoginPhoneCtrl.m_IsQrPC then
		UnityEngine.Application.OpenURL(g_SpiritCtrl:GetUrl())
	else
		CSpiritInfoView:ShowView(function (oView)
			oView:RefreshUI()
		end)
	end
end

--刷新最近联系人part的empty介绍界面
function CRecentPart.RefreshEmpty(self,list)
	if next(list) then
		self.m_EmptyGo:SetActive(false)
	else
		if g_SpiritCtrl:GetOpenState() then
			self.m_EmptyGo:SetActive(false)
		else
			self.m_EmptyGo:SetActive(true)
			local InsStr = data.frienddata.FRIENDTEXT[define.Friend.Text.RecentIns].content
			self.m_EmptyLbl:SetText(InsStr)
		end
	end
end

--其他地方调用ShowSubPage("recent")的时候每次都会执行这个函数，否则就是执行HidePage的函数
function CRecentPart.OnShowPage(self)
	self:RefreshItems()
end

--刷新一遍最近联系人item的信息
function CRecentPart.RefreshItems(self)
	local itemList = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(itemList) do
		if oItem and oItem.m_ID then
			oItem:SetPlayer(oItem.m_ID)
		end
	end
end

--这个函数的作用是根据聊天信息对最近联系人的item操作以及更新item聊天红点,只能更新一个pid对应的item
function CRecentPart.RefreshNotify(self, pid)
	if not self:IsInit() then
		return
	end
	local iAmount = g_TalkCtrl:GetNotify(pid)
	if iAmount > 0 then
		self:TopItem(pid)
	else
		self:DelNotify(pid)
	end
end

function  CRecentPart.DelNotify(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	for k, oItem in pairs(list) do
		if oItem.m_ID == pid then
			oItem:SetMsgAmount(0)
		end
	end
end

--传入一个id list，更新每个最近联系人item的信息
function CRecentPart.UpdateFrdItem(self, frdList)
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

--下边的函数是增加或删除最近联系人的item

function CRecentPart.TopItem(self, pid)
	self:RemoveItem(pid)
	self:AddItem(pid)
end

function CRecentPart.AddItem(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	if #list > self.m_MaxItem then
		local delItem = self.m_ItemGrid:GetChild(#list)
		self.m_ItemGrid:RemoveChild(delItem)
	end

	local oItem = self:CreateItem(pid)
	self.m_ItemGrid:AddChild(oItem)
	oItem:SetAsFirstSibling()
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

function CRecentPart.CreateItem(self, pid)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	-- printc("创建recent item的notify通知数量",pid," |",g_TalkCtrl:GetNotify(pid))
	oItem:SetMsgAmount(g_TalkCtrl:GetNotify(pid))
	oItem.m_ID = pid
	oItem.m_Button:AddUIEvent("click", callback(self, "ShowTalk", pid))
	return oItem
end

function CRecentPart.RemoveItem(self, pid)
	local list = self.m_ItemGrid:GetChildList()
	local removeItem = nil
	for k, oItem in pairs(list) do
		if oItem.m_ID == pid then
			removeItem = oItem
			break
		end
	end
	if removeItem then
		self.m_ItemGrid:RemoveChild(removeItem)
	end
	self:RefreshEmpty(self.m_ItemGrid:GetChildList())
end

--点击最近联系人item进入聊天界面
function CRecentPart.ShowTalk(self, v)
	self.m_ParentView:ShowTalk(v)
end

--下边的暂时没有使用
function CRecentPart.Sort(a, b)
	return a.m_ID < b.m_ID
end

return CRecentPart