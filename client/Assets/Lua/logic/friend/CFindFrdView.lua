local CFindFrdView = class("CFindFrdView", CViewBase)

function CFindFrdView.ctor(self, cb)
	CViewBase.ctor(self, "UI/friend/FindFriendView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CFindFrdView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_FrdIcons = {}
	for i=3, 10 do
		local icon = self:NewUI(i, CBox)
		icon.m_Title = icon:NewUI(1, CLabel)
		icon.m_Name = icon:NewUI(2, CLabel)
		icon.m_Spr = icon:NewUI(3, CSprite)
		icon.m_AddBtn = icon:NewUI(4, CButton)
		table.insert(self.m_FrdIcons, icon)
	end
	self.m_RefreshBtn = self:NewUI(11, CButton)
	self.m_FindBtn = self:NewUI(12, CButton)
	self.m_FindFrdScrollView = self:NewUI(13, CScrollView)
	self.m_FindFrdGrid = self:NewUI(14, CGrid)
	self.m_FindFrdBoxClone = self:NewUI(15, CBox)
	self.m_FindFrdBoxClone:SetActive(false)

	for i = 1, 8 do
		self.m_FrdIcons[i]:SetActive(false)
	end
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_RefreshBtn:AddUIEvent("click", callback(self, "DoRefresh"))
	self.m_FindBtn:AddUIEvent("click", callback(self, "FindFriend"))
	
	g_FriendCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFriendEvent"))
	self:DoRefresh()
end

function CFindFrdView.OnClose(self)
	g_FriendCtrl.m_LastRecommend = nil
	CViewBase.OnClose(self)
end

function CFindFrdView.OnFriendEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Friend.Event.Add then
		--printc("CFindFrdView添加好友协议返回")
		self:OnFrdAdd()
	end
end

function CFindFrdView.GetTypeTitle(self, iType)
	--1是二度好友，2是帮派，3是本市，3是门派
	local title = nil
	if iType == 1 then
		title = "好友推荐"
	elseif iType == 2 then
		title = "同帮派"
	elseif iType == 3 then
		title = g_AttrCtrl.position --"同一地区"
	elseif iType == 4 then
		title = "强力人士"
	else
		title = "新好友推荐"
	end
	return title
end

function CFindFrdView.DoRefresh(self)
	local list = g_FriendCtrl:GetRecommendFriends()

	if not next(list) then
		g_NotifyCtrl:FloatMsg("请稍后再寻找新朋友")
		return
	end

	-- for i = 1, 8 do
	-- 	local icon = self.m_FrdIcons[i]
	-- 	local frdobj = list[i]
	-- 	if frdobj then
	-- 		icon:SetActive(true)
	-- 		icon.m_ID = frdobj.pid
	-- 		icon.m_Name:SetText(frdobj.name)
	-- 		icon.m_Title:SetText(self:GetTypeTitle(tonumber(frdobj.type)))
	-- 		icon.m_Spr:SpriteAvatar(frdobj.shape)
	-- 		icon.m_AddBtn:AddUIEvent("click", callback(self, "AddFriend", frdobj.pid))
	-- 	else
	-- 		icon:SetActive(false)
	-- 	end
	-- end
	self:SetFindFrdList(list)
end

function CFindFrdView.OnFrdAdd(self)
	-- for k, obj in pairs(self.m_FrdIcons) do
	-- 	if obj and g_FriendCtrl:IsMyFriend(obj.m_ID) then
	-- 		obj:SetActive(false)
	-- 	end
	-- end

	local oList = self.m_FindFrdGrid:GetChildList() or {}
	for k,v in ipairs(oList) do
		if g_FriendCtrl:IsMyFriend(v.m_ID) then
			v:SetActive(false)
		end
	end
	self.m_FindFrdGrid:Reposition()
end

function CFindFrdView.FindFriend(self)
	local sName = self.m_Input:GetText()
	if sName == "" then
		g_NotifyCtrl:FloatMsg(data.frienddata.FRIENDTEXT[define.Friend.Text.SearchFriendNull].content)
	else
		netfriend.C2GSFindFriend(tonumber(sName), sName)
	end
end

function CFindFrdView.AddFriend(self, pid)
	-- netfriend.C2GSApplyAddFriend(pid)
	-- netfriend.C2GSFindFriend(tonumber(sName), sName)
	netplayer.C2GSNameCardInfo(pid)
end

function CFindFrdView.SetFindFrdList(self, list)
	local optionCount = #list
	local GridList = self.m_FindFrdGrid:GetChildList() or {}
	local oFindFrdBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oFindFrdBox = self.m_FindFrdBoxClone:Clone(false)
				-- self.m_FindFrdGrid:AddChild(oOptionBtn)
			else
				oFindFrdBox = GridList[i]
			end
			self:SetFindFrdBox(oFindFrdBox, list[i])
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

	self.m_FindFrdGrid:Reposition()
	self.m_FindFrdScrollView:ResetPosition()
end

function CFindFrdView.SetFindFrdBox(self, oFindFrdBox, oData)
	oFindFrdBox:SetActive(true)
	oFindFrdBox.m_NameLbl = oFindFrdBox:NewUI(1, CLabel)
	oFindFrdBox.m_IconSp = oFindFrdBox:NewUI(2, CSprite)
	oFindFrdBox.m_DescLbl = oFindFrdBox:NewUI(3, CLabel)
	oFindFrdBox.m_BgSp = oFindFrdBox:NewUI(4, CSprite)
	oFindFrdBox.m_AddBtn = oFindFrdBox:NewUI(5, CButton)
	oFindFrdBox.m_GradeLbl = oFindFrdBox:NewUI(6, CLabel)
	oFindFrdBox.m_SchoolSp = oFindFrdBox:NewUI(7, CSprite)

	oFindFrdBox.m_ID = oData.pid
	oFindFrdBox.m_NameLbl:SetText(oData.name)
	oFindFrdBox.m_DescLbl:SetText(self:GetTypeTitle(tonumber(oData.type)))
	oFindFrdBox.m_IconSp:SpriteAvatar(oData.icon)
	oFindFrdBox.m_GradeLbl:SetText((oData.grade or 0).."级")
	oFindFrdBox.m_SchoolSp:SpriteSchool(oData.school)

	oFindFrdBox.m_IconSp:AddUIEvent("click", callback(self, "AddFriend", oData.pid))
	oFindFrdBox.m_AddBtn:AddUIEvent("click", callback(self, "OnAddFriend", oData.pid))

	self.m_FindFrdGrid:AddChild(oFindFrdBox)
	self.m_FindFrdGrid:Reposition()
end

function CFindFrdView.OnAddFriend(self, oPid)
	if oPid == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("不能添加自己为好友!")
		return
	end
	if g_FriendCtrl:IsMyFriend(oPid) then
		g_NotifyCtrl:FloatMsg("对方已经是您的好友了!")
		return
	end
	netfriend.C2GSApplyAddFriend(oPid)
end

return CFindFrdView
