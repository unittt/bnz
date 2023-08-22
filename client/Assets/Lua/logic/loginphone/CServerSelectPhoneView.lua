local CServerSelectPhoneView = class("CServerSelectPhoneView", CViewBase)

function CServerSelectPhoneView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/SelectServerView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CServerSelectPhoneView.OnCreateView(self)
	self.m_TypeScrollView = self:NewUI(1, CScrollView)
	self.m_TypeGrid = self:NewUI(2, CGrid)
	self.m_RoleTypeBox = self:NewUI(3, CBox)
	self.m_TuijianTypeBox = self:NewUI(4, CBox)
	self.m_TypeBoxClone = self:NewUI(5, CBox)
	self.m_RightScrollView = self:NewUI(6, CScrollView)
	self.m_RoleGrid = self:NewUI(7, CGrid)
	self.m_RoleBoxClone = self:NewUI(8, CBox)
	self.m_ServerTable = self:NewUI(9, CTable)
	self.m_ServerBoxClone = self:NewUI(10, CBox)
	self.m_CloseBtn = self:NewUI(11, CButton)
	self.m_BeforeBtn = self:NewUI(12, CButton)

	self.m_SelectTypeIndex = 0
	self.m_LastGrid = nil
	self.m_LastServerSp = nil
	self.m_LastIndex = nil
	self.m_LastServerIndex = nil
	self.m_DefaultSelectServer = nil
	self.m_DefaultSelectIndex = nil

	self.m_BeforeIndex = 999999
	self.m_BeforeBtn:SetName(tostring(self.m_BeforeIndex))
	self.m_BeforeList = g_ServerPhoneCtrl:GetBeforeServerList()
	
	self:InitContent()
end

function CServerSelectPhoneView.InitContent(self)
	self.m_TypeBoxClone:SetActive(false)
	self.m_RoleBoxClone:SetActive(false)
	self.m_ServerBoxClone:SetActive(false)
	if next(self.m_BeforeList) then
		self.m_BeforeBtn:SetActive(true)
	else
		self.m_BeforeBtn:SetActive(false)
	end

	if next(g_ServerPhoneCtrl:GetRoleList()) then
		self.m_RoleTypeBox:SetGroup(self.m_TypeScrollView:GetInstanceID())
		self.m_RoleTypeBox:NewUI(3, CObject):SetActive(true)
	else
		self.m_RoleTypeBox:SetGroup(self.m_TypeScrollView:GetInstanceID()-1)
		self.m_RoleTypeBox:NewUI(3, CObject):SetActive(false)
	end
	if next(g_ServerPhoneCtrl:GetTuijianServerList()) then
		self.m_TuijianTypeBox:SetGroup(self.m_TypeScrollView:GetInstanceID())
		self.m_TuijianTypeBox:NewUI(3, CObject):SetActive(true)
	else
		self.m_TuijianTypeBox:SetGroup(self.m_TypeScrollView:GetInstanceID()-1)
		self.m_TuijianTypeBox:NewUI(3, CObject):SetActive(false)
	end
	self.m_BeforeBtn:SetGroup(self.m_TypeScrollView:GetInstanceID())

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClickClose"))
	self.m_RoleTypeBox:AddUIEvent("click", callback(self, "OnClickRoleTypeBox"))
	self.m_TuijianTypeBox:AddUIEvent("click", callback(self, "OnClickTuijianTypeBox"))
	self.m_BeforeBtn:AddUIEvent("click", callback(self, "OnClickBeforeBtn"))

	g_ServerPhoneCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CServerSelectPhoneView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Login.Event.ServerListSuccess then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Login.Event.UpdateGSRole then
		self:RefreshUI()
	end
end

function CServerSelectPhoneView.RefreshUI(self)
	self.m_IsClickLoginGame = false
	g_UploadDataCtrl:SetDotUpload("16")
	self:SetTypeList()
	self:SetSelectTab()
end

function CServerSelectPhoneView.SetSelectTab(self)
	local dServer
	if g_LoginPhoneCtrl.m_IsPC then
		dServer = IOTools.GetClientData("loginphone_pc_server")
	else
		dServer = g_LoginPhoneCtrl:GetLocalServerAndRoleData() --(g_LoginPhoneCtrl:GetLoginPhoneServerData() and {g_LoginPhoneCtrl:GetLoginPhoneServerData().server} or {nil} )[1]
	end
	if dServer and dServer.id then
		local server = g_ServerPhoneCtrl:GetServerOrderDataById(dServer.id)
		local tuijianList = g_ServerPhoneCtrl:GetTuijianServerList()
		if server and server.id ~= tuijianList[1].id then
			if g_ServerPhoneCtrl:IsNewArea() then
				local oTypeBoxList = self.m_TypeGrid:GetChildList()
				for k,v in pairs(oTypeBoxList) do
					if table.index(server.area, v.m_Data) then
						self:OnClickTypeBox(v, v.m_Data)
						break
					end
				end
			else
				local serverindex = server.serverindex
				local oTypeBox
				for k,v in pairs(self.m_TypeGrid:GetChildList()) do
					if v.m_Data[1] <= serverindex and serverindex <= v.m_Data[2] then
						oTypeBox = v
						break
					end
				end
				self:OnClickTypeBox(oTypeBox, oTypeBox.m_Data)
			end
		else
			self:ShowTuijianTypeBox()
		end
	else
		self:ShowTuijianTypeBox()
	end
end

function CServerSelectPhoneView.SetTypeList(self)
	local typeList = g_ServerPhoneCtrl:GetServerTypeList()
	if not typeList or not next(typeList) then
		return
	end
	local optionCount = #typeList
	local GridList = self.m_TypeGrid:GetChildList() or {}
	local oTypeBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oTypeBox = self.m_TypeBoxClone:Clone(false)
				-- self.m_TypeGrid:AddChild(oOptionBtn)
			else
				oTypeBox = GridList[i]
			end
			self:SetTypeBox(oTypeBox, typeList[i])
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

	self.m_TypeGrid:Reposition()
	self.m_TypeScrollView:ResetPosition()
end

function CServerSelectPhoneView.SetTypeBox(self, oTypeBox, oData)
	oTypeBox:SetActive(true)
	oTypeBox:SetGroup(self.m_TypeScrollView:GetInstanceID())
	oTypeBox.m_Data = oData
	oTypeBox.m_NameLbl = oTypeBox:NewUI(1, CLabel)
	oTypeBox.m_SelNameLbl = oTypeBox:NewUI(2, CLabel)

	if g_ServerPhoneCtrl:IsNewArea() then
		oTypeBox:SetName(tostring(self.m_BeforeIndex - oData))
		local name = g_ServerPhoneCtrl:GetServerTypeName(oData)
		oTypeBox.m_NameLbl:SetText(name)
		oTypeBox.m_SelNameLbl:SetText(name)
	else
		oTypeBox:SetName(tostring(self.m_BeforeIndex - oData[2]/20))
		local resultStr = string.printInChinese(oData[2]/20)
		oTypeBox.m_NameLbl:SetText(resultStr.."区")
		oTypeBox.m_SelNameLbl:SetText(resultStr.."区")
	end
	
	oTypeBox:AddUIEvent("click", callback(self, "OnClickTypeBox", oTypeBox, oData))

	self.m_TypeGrid:AddChild(oTypeBox)
	self.m_TypeGrid:Reposition()
end

function CServerSelectPhoneView.SetRoleList(self)
	local roleList = g_ServerPhoneCtrl:GetRoleList()
	table.print(roleList, "CServerSelectPhoneView.SetRoleList")
	local optionCount = #roleList
	local GridList = self.m_RoleGrid:GetChildList() or {}
	local oRoleBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRoleBox = self.m_RoleBoxClone:Clone(false)
				-- self.m_RoleGrid:AddChild(oOptionBtn)
			else
				oRoleBox = GridList[i]
			end
			self:SetRoleBox(oRoleBox, roleList[i])
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

	self.m_RoleGrid:Reposition()
	self.m_RightScrollView:ResetPosition()
end

function CServerSelectPhoneView.SetRoleBox(self, oRoleBox, oData)
	oRoleBox:SetActive(true)
	oRoleBox.m_IconSp = oRoleBox:NewUI(1, CSprite)
	oRoleBox.m_LevelLbl = oRoleBox:NewUI(2, CLabel)
	oRoleBox.m_SchoolIcon = oRoleBox:NewUI(3, CSprite)
	oRoleBox.m_NameLbl = oRoleBox:NewUI(4, CLabel)
	oRoleBox.m_ServerNameLbl = oRoleBox:NewUI(5, CLabel)
	oRoleBox.m_ServerStateSp = oRoleBox:NewUI(6, CSprite)

	oRoleBox.m_IconSp:SpriteAvatar(oData.icon)
	oRoleBox.m_LevelLbl:SetText(oData.grade)
	oRoleBox.m_SchoolIcon:SetSpriteName(tostring(data.schooldata.DATA[oData.school].icon))
	oRoleBox.m_NameLbl:SetText(oData.name)
	oRoleBox.m_ServerNameLbl:SetText(oData.servername) --oData.serverindex.."-"..
	local serverState = 0
	if oData.state then
		serverState = oData.state
	end
	oRoleBox.m_ServerStateSp:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(serverState))
	
	oRoleBox:AddUIEvent("click", callback(self, "OnClickRoleBox", oData))

	self.m_RoleGrid:AddChild(oRoleBox)
	self.m_RoleGrid:Reposition()
end

function CServerSelectPhoneView.SetServerList(self, serverList)
	local optionCount = math.ceil(#serverList/2)
	local TableList = self.m_ServerTable:GetChildList() or {}
	local oServerBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #TableList then
				oServerBox = self.m_ServerBoxClone:Clone(false)
				-- self.m_ServerTable:AddChild(oOptionBtn)
			else
				oServerBox = TableList[i]
			end
			self:SetServerBox(serverList, oServerBox, i)
		end

		if #TableList > optionCount then
			for i=optionCount+1,#TableList do
				TableList[i]:SetActive(false)
			end
		end
	else
		if TableList and #TableList > 0 then
			for _,v in ipairs(TableList) do
				v:SetActive(false)
			end
		end
	end

	self.m_ServerTable:Reposition()
	self.m_RightScrollView:ResetPosition()
end

function CServerSelectPhoneView.SetServerBox(self, serverList, oServerBox, oData)
	oServerBox:SetActive(true)
	oServerBox.m_ServerBoxLeft = oServerBox:NewUI(1, CBox)
	oServerBox.m_ServerBoxRight = oServerBox:NewUI(2, CBox)
	oServerBox.m_Grid = oServerBox:NewUI(3, CGrid)
	oServerBox.m_RoleBoxClone = oServerBox:NewUI(4, CBox)
	oServerBox.m_ServerBg = oServerBox:NewUI(5, CSprite)
	oServerBox.m_RoleBoxClone:SetActive(false)
	oServerBox.m_ServerBg:SetActive(false)

	oServerBox.m_ServerBoxLeft:ForceSelected(false)
	oServerBox.m_ServerBoxRight:ForceSelected(false)
	oServerBox.m_Grid:SetActive(false)

	local leftIndex = oData*2 - 1
	local rightIndex = oData*2
	if serverList[leftIndex] then
		oServerBox.m_ServerBoxLeft:SetActive(true)
		local newSp = oServerBox.m_ServerBoxLeft:NewUI(1, CSprite)
		local stateSp = oServerBox.m_ServerBoxLeft:NewUI(2, CSprite)
		local serverNameLbl = oServerBox.m_ServerBoxLeft:NewUI(3, CLabel)
		local iconSp = oServerBox.m_ServerBoxLeft:NewUI(4, CSprite)
		local levelLbl = oServerBox.m_ServerBoxLeft:NewUI(5, CLabel)
		local schoolSp = oServerBox.m_ServerBoxLeft:NewUI(6, CSprite)
		local oBox = oServerBox.m_ServerBoxLeft:NewUI(7, CObject)
		local selserverNameLbl = oServerBox.m_ServerBoxLeft:NewUI(8, CLabel)
		local hunfuSp = oServerBox.m_ServerBoxLeft:NewUI(9, CSprite)
		newSp:SetActive(false)
		if serverList[leftIndex].new and serverList[leftIndex].new == 1 then
			newSp:SetActive(true)
		end
		--混服标签
		hunfuSp:SetActive(false)
		if serverList[leftIndex].platform and serverList[leftIndex].platform == "0" then
			hunfuSp:SetActive(true)
		end
		local serverState = 0
		if serverList[leftIndex].state then
			serverState = serverList[leftIndex].state
		end
		stateSp:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(serverState))
		serverNameLbl:SetColor(Color.white)
		selserverNameLbl:SetColor(Color.white)
		local timeStr = ""
		if serverList[leftIndex].opentime and tonumber(serverList[leftIndex].opentime) and tonumber(serverList[leftIndex].opentime) > 0 then
			timeStr = "\n[FF0000]"..os.date("%m-%d %H:%M", tonumber(serverList[leftIndex].opentime)).."开启[-]"
		end
		serverNameLbl:SetText("[244B4E]"..serverList[leftIndex].name.."[-]"..timeStr) --..serverList[leftIndex].serverindex.."-"
		selserverNameLbl:SetText("[BD5733]"..serverList[leftIndex].name.."[-]"..timeStr) --..serverList[leftIndex].serverindex.."-"
		oBox:SetActive(false)

		--默认选中一个服务器，现在是推荐服务器列表的第一个或之前存储记录里面的的服务器
		if self.m_DefaultSelectServer then
			if self.m_DefaultSelectServer.id == serverList[leftIndex].id then
				oServerBox.m_ServerBoxLeft:SetSelected(true)

				if self.m_LastGrid and not Utils.IsNil(self.m_LastGrid) then
					self.m_LastGrid:SetActive(false)
					self.m_LastGrid = nil
				end
				if self.m_LastServerSp and not Utils.IsNil(self.m_LastServerSp) then
					self.m_LastServerSp:SetActive(false)
					self.m_LastServerSp = nil
				end
				oServerBox.m_Grid:SetActive(true)
				oServerBox.m_ServerBg:SetActive(true)
				local list = {}
				if serverList[leftIndex] and serverList[leftIndex].role and next(serverList[leftIndex].role) then
					for k,v in pairs(serverList[leftIndex].role) do
						list[k] = v
					end
				end
				-- if #list < 3 then
				-- 	table.insert(list, {id = -1})
				-- end
				self:SetServerRoleList(oServerBox.m_Grid, oServerBox.m_RoleBoxClone, list, serverList[leftIndex])
				if #list > 3 then
					oServerBox.m_ServerBg:SetHeight(168)
				else
					oServerBox.m_ServerBg:SetHeight(83)
				end
				self.m_LastGrid = oServerBox.m_Grid
				self.m_LastServerSp = oServerBox.m_ServerBg
				self.m_LastIndex = leftIndex

				self.m_DefaultSelectIndex = leftIndex
				-- UITools.MoveToTarget(self.m_RightScrollView, oServerBox)
			end
		end
	else
		oServerBox.m_ServerBoxLeft:SetActive(false)
	end
	if serverList[rightIndex] then
		oServerBox.m_ServerBoxRight:SetActive(true)
		local newSp = oServerBox.m_ServerBoxRight:NewUI(1, CSprite)
		local stateSp = oServerBox.m_ServerBoxRight:NewUI(2, CSprite)
		local serverNameLbl = oServerBox.m_ServerBoxRight:NewUI(3, CLabel)
		local iconSp = oServerBox.m_ServerBoxRight:NewUI(4, CSprite)
		local levelLbl = oServerBox.m_ServerBoxRight:NewUI(5, CLabel)
		local schoolSp = oServerBox.m_ServerBoxRight:NewUI(6, CSprite)
		local oBox = oServerBox.m_ServerBoxRight:NewUI(7, CObject)
		local selserverNameLbl = oServerBox.m_ServerBoxRight:NewUI(8, CLabel)
		local hunfuSp = oServerBox.m_ServerBoxRight:NewUI(9, CSprite)
		newSp:SetActive(false)
		if serverList[rightIndex].new and serverList[rightIndex].new == 1 then
			newSp:SetActive(true)
		end
		--混服标签
		hunfuSp:SetActive(false)
		if serverList[rightIndex].platform and serverList[rightIndex].platform == "0" then
			hunfuSp:SetActive(true)
		end
		local serverState = 0
		if serverList[rightIndex].state then
			serverState = serverList[rightIndex].state
		end
		
		stateSp:SetSpriteName(g_ServerPhoneCtrl:GetServerStateSpriteName(serverState))
		serverNameLbl:SetColor(Color.white)
		selserverNameLbl:SetColor(Color.white)
		local timeStr = ""
		if serverList[rightIndex].opentime and tonumber(serverList[rightIndex].opentime) and tonumber(serverList[rightIndex].opentime) > 0 then
			timeStr = "\n[FF0000]"..os.date("%m-%d %H:%M", tonumber(serverList[rightIndex].opentime)).."开启[-]"
		end
		serverNameLbl:SetText("[244B4E]"..serverList[rightIndex].name.."[-]"..timeStr) --..serverList[rightIndex].serverindex.."-"
		selserverNameLbl:SetText("[BD5733]"..serverList[rightIndex].name.."[-]"..timeStr) --..serverList[rightIndex].serverindex.."-"
		oBox:SetActive(false)

		--默认选中一个服务器，现在是推荐服务器列表的第一个或之前存储记录里面的的服务器
		if self.m_DefaultSelectServer then
			if self.m_DefaultSelectServer.id == serverList[rightIndex].id then
				oServerBox.m_ServerBoxRight:SetSelected(true)

				if self.m_LastGrid and not Utils.IsNil(self.m_LastGrid) then
					self.m_LastGrid:SetActive(false)
					self.m_LastGrid = nil
				end
				if self.m_LastServerSp and not Utils.IsNil(self.m_LastServerSp) then
					self.m_LastServerSp:SetActive(false)
					self.m_LastServerSp = nil
				end
				oServerBox.m_Grid:SetActive(true)
				oServerBox.m_ServerBg:SetActive(true)
				local list = {}
				if serverList[rightIndex] and serverList[rightIndex].role and next(serverList[rightIndex].role) then
					for k,v in pairs(serverList[rightIndex].role) do
						list[k] = v
					end
				end
				-- if #list < 3 then
				-- 	table.insert(list, {id = -1})
				-- end
				self:SetServerRoleList(oServerBox.m_Grid, oServerBox.m_RoleBoxClone, list, serverList[rightIndex])
				if #list > 3 then
					oServerBox.m_ServerBg:SetHeight(168)
				else
					oServerBox.m_ServerBg:SetHeight(83)
				end
				self.m_LastGrid = oServerBox.m_Grid
				self.m_LastServerSp = oServerBox.m_ServerBg
				self.m_LastIndex = rightIndex

				self.m_DefaultSelectIndex = rightIndex
				-- UITools.MoveToTarget(self.m_RightScrollView, oServerBox)
			end
		end
	else
		oServerBox.m_ServerBoxRight:SetActive(false)
	end
	
	oServerBox.m_ServerBoxLeft:SetGroup(self.m_RightScrollView:GetInstanceID())
	oServerBox.m_ServerBoxRight:SetGroup(self.m_RightScrollView:GetInstanceID())
	oServerBox.m_ServerBoxLeft:AddUIEvent("click", callback(self, "OnClickServerBox", serverList, oServerBox, oData, leftIndex, oServerBox.m_ServerBoxLeft))
	oServerBox.m_ServerBoxRight:AddUIEvent("click", callback(self, "OnClickServerBox", serverList, oServerBox, oData, rightIndex, oServerBox.m_ServerBoxRight))

	self.m_ServerTable:AddChild(oServerBox)
	self.m_ServerTable:Reposition()
end

function CServerSelectPhoneView.SetServerRoleList(self, oGrid, oBoxClone, oList, serverData)
	local function Init(obj, idx)
		local oBox = CBox.New(obj)
		return oBox
	end
	oGrid:InitChild(Init)
	oGrid:Clear()
	local optionCount = #oList
	local GridList = oGrid:GetChildList() or {}
	local oRoleBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oRoleBox = oBoxClone:Clone(false)
				-- oGrid:AddChild(oOptionBtn)
			else
				oRoleBox = GridList[i]
			end
			self:SetServerRoleBox(oGrid, oRoleBox, oList[i], serverData)
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

	oGrid:Reposition()
end

function CServerSelectPhoneView.SetServerRoleBox(self, oGrid, oRoleBox, oData, serverData)
	oRoleBox:SetActive(true)
	oRoleBox.m_RoleBox = oRoleBox:NewUI(1, CBox)
	oRoleBox.m_AddBox = oRoleBox:NewUI(2, CBox)
	oRoleBox.m_NameLbl = oRoleBox.m_RoleBox:NewUI(1, CLabel)
	oRoleBox.m_IconSp = oRoleBox.m_RoleBox:NewUI(2, CSprite)
	oRoleBox.m_LevelLbl = oRoleBox.m_RoleBox:NewUI(3, CLabel)
	oRoleBox.m_SchoolIcon = oRoleBox.m_RoleBox:NewUI(4, CSprite)
	oRoleBox.m_DescLbl = oRoleBox.m_RoleBox:NewUI(5, CLabel)
	oRoleBox.m_DeleteNotifySp = oRoleBox.m_RoleBox:NewUI(6, CSprite)
	oRoleBox.m_DeleteBtn = oRoleBox.m_RoleBox:NewUI(7, CButton)

	if oData.pid == -1 then
		oRoleBox.m_RoleBox:SetActive(false)
		oRoleBox.m_AddBox:SetActive(true)
	else
		oRoleBox.m_RoleBox:SetActive(true)
		oRoleBox.m_AddBox:SetActive(false)
		
		oRoleBox.m_NameLbl:SetText(oData.name)
		oRoleBox.m_IconSp:SpriteAvatar(oData.icon)
		oRoleBox.m_LevelLbl:SetText(oData.grade)
		oRoleBox.m_DeleteNotifySp:SetActive(false)
		oRoleBox.m_DeleteBtn:SetActive(false)
		oRoleBox.m_NameLbl:SetActive(true)
		oRoleBox.m_DescLbl:SetActive(true)
		oRoleBox.m_SchoolIcon:SetSpriteName(tostring(data.schooldata.DATA[oData.school].icon))		
	end
	
	oRoleBox.m_DeleteBtn:AddUIEvent("click", callback(self, "OnClickServerRoleBoxDeleteBtn", oData, serverData))
	oRoleBox.m_RoleBox:AddUIEvent("click", callback(self, "OnClickServerRoleBox", oData, serverData))
	oRoleBox.m_AddBox:AddUIEvent("click", callback(self, "OnClickServerRoleBox", oData, serverData))
	oRoleBox.m_RoleBox:AddUIEvent("dragstart", callback(self, "OnDragServerRoleBoxStart", oRoleBox))
	oRoleBox.m_RoleBox:AddUIEvent("drag", callback(self, "OnDragServerRoleBox", oRoleBox))
	oRoleBox.m_RoleBox:AddUIEvent("dragend", callback(self, "OnDragServerRoleBoxEnd", oGrid, oRoleBox))

	oGrid:AddChild(oRoleBox)
	oGrid:Reposition()
end

-------------以下是点击事件------------

function CServerSelectPhoneView.OnClickClose(self)
	g_UploadDataCtrl:SetDotUpload("18")
	self:OnClose()
end

function CServerSelectPhoneView.OnClickRoleTypeBox(self)
	if next(g_ServerPhoneCtrl:GetRoleList()) then
		--重置ui
		if self.m_LastServerIndex ~= -1 then
			self.m_LastGrid = nil
			self.m_LastServerSp = nil
			self.m_LastIndex = nil
		end
		self.m_SelectTypeIndex = -1
		self.m_RoleTypeBox:SetSelected(true)
		self.m_RoleGrid:SetActive(true)
		self.m_ServerTable:SetActive(false)
		self:SetRoleList()

		self.m_LastServerIndex = -1
	else
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.NoRole].content)
	end
end

function CServerSelectPhoneView.OnClickTuijianTypeBox(self)
	if next(g_ServerPhoneCtrl:GetTuijianServerList()) then
		if self.m_LastServerIndex ~= 0 then
			self.m_LastGrid = nil
			self.m_LastServerSp = nil
			self.m_LastIndex = nil
		end
		self:ShowTuijianTypeBox()
		self.m_LastServerIndex = 0
	else
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.NoCommendServer].content)
	end
end

function CServerSelectPhoneView.ShowTuijianTypeBox(self)
	self.m_SelectTypeIndex = 0
	self.m_TuijianTypeBox:SetSelected(true)
	self.m_RoleGrid:SetActive(false)
	self.m_ServerTable:SetActive(true)
	local tuijianList = g_ServerPhoneCtrl:GetTuijianServerList()
	self.m_DefaultSelectServer = tuijianList[1]
	self:SetServerList(tuijianList)

	if self.m_DefaultSelectIndex and self.m_DefaultSelectIndex > 6 then
		local moveindex = self.m_DefaultSelectIndex
		if moveindex%2 == 0 then
			moveindex = moveindex - 1
		end
		if self.m_ServerTable:GetChild((moveindex+1)/2 - 2) then
			UITools.MoveToTarget(self.m_RightScrollView, self.m_ServerTable:GetChild((moveindex+1)/2 - 2))
		end
	end
end

--点击先锋体验区
function CServerSelectPhoneView.OnClickBeforeBtn(self)
	if not next(self.m_BeforeList) then
		return
	end
	if self.m_LastServerIndex ~= -2 then
		self.m_LastGrid = nil
		self.m_LastServerSp = nil
		self.m_LastIndex = nil
	end
	self:ShowBeforeServerList()
	self.m_LastServerIndex = -2	
end

function CServerSelectPhoneView.ShowBeforeServerList(self)
	self.m_SelectTypeIndex = -2
	self.m_BeforeBtn:SetSelected(true)
	self.m_RoleGrid:SetActive(false)
	self.m_ServerTable:SetActive(true)
	self:SetServerList(self.m_BeforeList)
end

function CServerSelectPhoneView.OnClickTypeBox(self, oTypeBox, oData)
	local typeIndex = g_ServerPhoneCtrl:IsNewArea() and oData or oData[1]
	if self.m_LastServerIndex ~= typeIndex then
		self.m_LastGrid = nil
		self.m_LastServerSp = nil
		self.m_LastIndex = nil
	end
	if self.m_SelectTypeIndex ~= typeIndex then
		self.m_SelectTypeIndex = typeIndex
		oTypeBox:SetSelected(true)
		self.m_RoleGrid:SetActive(false)
		self.m_ServerTable:SetActive(true)
		if g_LoginPhoneCtrl.m_IsPC then
			local dServer = IOTools.GetClientData("loginphone_pc_server")
			if dServer and dServer.id then
				self.m_DefaultSelectServer = dServer
			end
		else
			local dServer = g_LoginPhoneCtrl:GetLocalServerAndRoleData() --(g_LoginPhoneCtrl:GetLoginPhoneServerData() and {g_LoginPhoneCtrl:GetLoginPhoneServerData().server} or {nil} )[1]
			if dServer and dServer.id then
				self.m_DefaultSelectServer = dServer
			end
		end
		self:SetServerList(g_ServerPhoneCtrl:GetServerListByIndex(oData))

		if self.m_DefaultSelectIndex and self.m_DefaultSelectIndex > 6 then
			local moveindex = self.m_DefaultSelectIndex
			if moveindex%2 == 0 then
				moveindex = moveindex - 1
			end
			if self.m_ServerTable:GetChild((moveindex+1)/2 - 2) then
				UITools.MoveToTarget(self.m_RightScrollView, self.m_ServerTable:GetChild((moveindex+1)/2 - 2))
			end
		end
	end
	self.m_LastServerIndex = typeIndex
end

function CServerSelectPhoneView.OnClickRoleBox(self, oData)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OnClickSelectServer, 1) then
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OnClickSelectServer, 1, 2)
	local serverData = g_ServerPhoneCtrl:GetServerOrderDataById(oData.server) --oData.now_server or 

	-- local list = {server = serverData, role = oData}
	-- g_LoginPhoneCtrl:SetLoginPhoneServerData(list)
	g_LoginPhoneCtrl:SetPhoneChooseInfo(serverData, oData)
	--重要，标识不是重连的连接
	g_LoginPhoneCtrl.m_IsReconnect = false
	g_LoginPhoneCtrl:ConnnectPhoneServer(serverData.ip, serverData.ports, serverData)
	g_UploadDataCtrl:SetDotUpload("17")
	-- if not self.m_IsClickLoginGame then	
	-- 	self.m_IsClickLoginGame = true
	-- end
end

function CServerSelectPhoneView.OnClickServerBox(self, serverList, oServerBox, oData, index, oSelectBox)
	if self.m_LastIndex ~= index then		
		if self.m_LastGrid and not Utils.IsNil(self.m_LastGrid) then
			self.m_LastGrid:SetActive(false)
			self.m_LastGrid = nil
		end
		if self.m_LastServerSp and not Utils.IsNil(self.m_LastServerSp) then
			self.m_LastServerSp:SetActive(false)
			self.m_LastServerSp = nil
		end
		oServerBox.m_Grid:SetActive(true)
		oServerBox.m_ServerBg:SetActive(true)
		local list = {}
		if serverList[index] and serverList[index].role and next(serverList[index].role) then
			for k,v in pairs(serverList[index].role) do
				list[k] = v
			end
		end
		-- if #list < 3 then
		-- 	table.insert(list, {id = -1})
		-- end
		self:SetServerRoleList(oServerBox.m_Grid, oServerBox.m_RoleBoxClone, list, serverList[index])
		if #list > 3 then
			oServerBox.m_ServerBg:SetHeight(168)
		else
			oServerBox.m_ServerBg:SetHeight(83)
		end
		self.m_LastGrid = oServerBox.m_Grid
		self.m_LastServerSp = oServerBox.m_ServerBg
		self.m_LastIndex = index
	else
		if self.m_LastGrid and not Utils.IsNil(self.m_LastGrid) then
			self.m_LastGrid:SetActive(false)
			self.m_LastGrid = nil

			if self.m_LastServerSp and not Utils.IsNil(self.m_LastServerSp) then
				self.m_LastServerSp:SetActive(false)
				self.m_LastServerSp = nil
			end
		else
			oServerBox.m_Grid:SetActive(true)
			oServerBox.m_ServerBg:SetActive(true)
			local list = {}
			if serverList[index] and serverList[index].role and next(serverList[index].role) then
				for k,v in pairs(serverList[index].role) do
					list[k] = v
				end
			end
			-- if #list < 3 then
			-- 	table.insert(list, {id = -1})
			-- end
			self:SetServerRoleList(oServerBox.m_Grid, oServerBox.m_RoleBoxClone, list, serverList[index])
			if #list > 3 then
				oServerBox.m_ServerBg:SetHeight(168)
			else
				oServerBox.m_ServerBg:SetHeight(83)
			end		
			self.m_LastGrid = oServerBox.m_Grid
			self.m_LastServerSp = oServerBox.m_ServerBg
		end
	end
	oSelectBox:SetSelected(true)
	g_LoginPhoneCtrl:SetSelectdSeverState(serverList[index].state)
	self.m_ServerTable:Reposition()

	--ui显示优化
	if index > 6 then
		--7 8 对应 2
		--9 10 对应 3
		local moveindex = index
		if index%2 == 0 then
			moveindex = moveindex - 1
		end
		if self.m_ServerTable:GetChild((moveindex+1)/2 - 2) then
			UITools.MoveToTarget(self.m_RightScrollView, self.m_ServerTable:GetChild((moveindex+1)/2 - 2))
		end
	end
end

function CServerSelectPhoneView.OnClickServerRoleBoxDeleteBtn(self, oData, serverData)
	local windowInputInfo = {
		des = "[63432c]角色删除后无法恢复，请谨慎操作",
		title = "角色删除",
		defaultText = "请输入要删除的角色ID",
		inputLimit = 20,
		cancelCallback = function () end,
		okCallback = function (oInput)
			if not oInput then
				return
			end
			local inputStr = oInput:GetText()
			if not inputStr or inputStr == "" then
				g_NotifyCtrl:FloatMsg("请输入要删除的角色ID")
				return true
			end
			if not tonumber(inputStr) or not table.index(g_ServerPhoneCtrl.m_ServerRolePidList, tonumber(inputStr)) then
				g_NotifyCtrl:FloatMsg("ID错误无法删除")
				return true
			end
			g_ServerPhoneCtrl:UpdateDeleteRoleData(tonumber(inputStr))
		end,
	}
	g_WindowTipCtrl:SetWindowInput(windowInputInfo)
end

function CServerSelectPhoneView.OnClickServerRoleBox(self, oData, serverData)
	if g_CountdownTimerCtrl:GetRecord(g_CountdownTimerCtrl.Type.OnClickSelectServer, 2) then
		return
	end
	g_CountdownTimerCtrl:AddRecord(g_CountdownTimerCtrl.Type.OnClickSelectServer, 2, 2)
	if g_LoginPhoneCtrl.m_IsPC then
		IOTools.SetClientData("loginphone_pc_server", serverData)
		--重要，标识不是重连的连接
		g_LoginPhoneCtrl.m_IsReconnect = false
		g_LoginPhoneCtrl:ConnnectServer(serverData.ip, serverData.ports, serverData)
	else
		-- local list = {server = serverData, role = oData}
		-- g_LoginPhoneCtrl:SetLoginPhoneServerData(list)
		if oData.pid == -1 and g_ServerPhoneCtrl:GetServerRoleCount(serverData.id) >= 3 then
			g_NotifyCtrl:FloatMsg("您在同一服务器拥有的角色不能超过3个哦")
			return
		end
		g_LoginPhoneCtrl:SetPhoneChooseInfo(serverData, oData)
		--重要，标识不是重连的连接
		g_LoginPhoneCtrl.m_IsReconnect = false
		g_LoginPhoneCtrl:ConnnectPhoneServer(serverData.ip, serverData.ports, serverData)
	end
	g_UploadDataCtrl:SetDotUpload("17")
	-- if not self.m_IsClickLoginGame then	
	-- 	self.m_IsClickLoginGame = true
	-- end
end

function CServerSelectPhoneView.OnDragServerRoleBoxStart(self, oRoleBox, obj)
	oRoleBox.m_IsShowDelete = false
end

function CServerSelectPhoneView.OnDragServerRoleBox(self, oRoleBox, obj, moveDelta)
	if moveDelta.x < 0 then
		oRoleBox.m_IsShowDelete = true
	else
		oRoleBox.m_IsShowDelete = false
	end
end

function CServerSelectPhoneView.OnDragServerRoleBoxEnd(self, oGrid, oRoleBox, obj)
	if oRoleBox.m_IsShowDelete then
		local GridList = oGrid:GetChildList() or {}
		for k,v in pairs(GridList) do
			v.m_DeleteNotifySp:SetActive(false)
			v.m_DeleteBtn:SetActive(false)
			v.m_NameLbl:SetActive(true)
			v.m_DescLbl:SetActive(true)
		end
		oRoleBox.m_DeleteNotifySp:SetActive(false)
		oRoleBox.m_DeleteBtn:SetActive(true)
		oRoleBox.m_NameLbl:SetActive(false)
		oRoleBox.m_DescLbl:SetActive(false)
	else		
		oRoleBox.m_DeleteNotifySp:SetActive(false)
		oRoleBox.m_DeleteBtn:SetActive(false)
		oRoleBox.m_NameLbl:SetActive(true)
		oRoleBox.m_DescLbl:SetActive(true)
	end
end

return CServerSelectPhoneView