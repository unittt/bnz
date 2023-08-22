local CTeamerPart = class("CTeamerPart", CPageBase)

function CTeamerPart.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemClone = self:NewUI(2, CTeamerItem)
	self.m_ItemClone:SetActive(false)
	
	self.m_EmptyGo = self:NewUI(6,CObject)
	self.m_EmptyLbl = self:NewUI(7,CLabel)
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	
	self:InitContent()
end

--初始化执行，也可被调用
function CTeamerPart.InitContent(self)
	-- self.m_ItemGrid:Clear()
	-- self.m_TeamerList = g_FriendCtrl.m_Friend["teamer"]
	-- table.print(self.m_TeamerList)
	-- self.m_ItemGrid:Clear()
	-- for k, pid in pairs(self.m_TeamerList) do
	-- 	local frdobj =  g_FriendCtrl:GetFriend(pid)
	-- 	if frdobj then
	-- 		self:CreateItem(pid)
	-- 	end
	-- end
	-- self.m_ItemGrid:Reposition()
	-- self:RefreshEmpty(self.m_TeamerList)

	self:ResortGrid()
end

--协议通知返回
function CTeamerPart.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.UpdateTeam then
		self:ResortGrid()
	end
end

--刷新队伍part的empty介绍界面
function CTeamerPart.RefreshEmpty(self,list)
	if next(list) then
		self.m_EmptyGo:SetActive(false)
	else
		self.m_EmptyGo:SetActive(true)
		local InsStr = data.frienddata.FRIENDTEXT[define.Friend.Text.TeamIns].content
		self.m_EmptyLbl:SetText(InsStr)
	end
end

--下边是对最近队伍item增加或删除

function CTeamerPart.CreateItem(self, pid)
	local oItem = self.m_ItemClone:Clone()
	oItem:SetActive(true)
	oItem:SetPlayer(pid)
	self.m_ItemGrid:AddChild(oItem)
end

function CTeamerPart.ResortGrid(self)
	self.m_TeamerList = g_FriendCtrl.m_Friend["teamer"]
	local optionCount = #self.m_TeamerList
	local GridList = self.m_ItemGrid:GetChildList() or {}
	local oTeamBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTeamBox = self.m_ItemClone:Clone(false)
			else
				oTeamBox = GridList[i]
			end
			oTeamBox:SetActive(true)
			oTeamBox:SetPlayer(self.m_TeamerList[i])
			self.m_ItemGrid:AddChild(oTeamBox)
			self.m_ItemGrid:Reposition()
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

	self.m_ItemGrid:Reposition()
	self:RefreshEmpty(self.m_TeamerList)
end

--暂时没有使用
function CTeamerPart.ShowTalk(self)
	
end

return CTeamerPart