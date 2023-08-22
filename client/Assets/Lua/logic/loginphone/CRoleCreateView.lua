local CRoleCreateView = class("CRoleCreateView", CViewBase)

function CRoleCreateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/RoleCreateNewView.prefab", cb)
	--界面设置
	-- self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"

	self.m_RoleNameSpHashList = {1, 4, 6, 3, 2, 5}
	self.m_RoleBoxActualTypeList = {2, 4, 1, 5, 6, 3}
	self.m_RoleBoxPosList = {Vector3.New(-27.9, 290.5, 0), Vector3.New(-7, 179.1, 0), Vector3.New(10, 68, 0), Vector3.New(11.8, -56.6, 0), Vector3.New(-6.2, -173, 0), Vector3.New(-26.6, -290.8, 0)}
	self.m_RoleIconSortList = {}--{2, 4, 1, 5, 6, 3}
	for k,v in ipairs(data.roletypedata.DATA) do
		self.m_RoleIconSortList[k] = v.iconsort
	end
	self.m_SchoolSpHashList = {"03", "09", "05", "07", "11", "01"}
	self.m_SchoolLightSpHashList = {"04", "10", "06", "08", "12", "02"}
end

function CRoleCreateView.OnCreateView(self)
	self.m_RandomNameBtn = self:NewUI(1, CButton)
	self.m_BackServerBtn = self:NewUI(2, CButton)
	self.m_CreateBtn = self:NewUI(3, CButton)
	self.m_NameInput = self:NewUI(4, CInput)
	self.m_SchoolGrid = self:NewUI(5, CGrid)
	self.m_SchoolItemClone = self:NewUI(6, CBox)
	self.m_SchoolBg = self:NewUI(7, CObject)
	self.m_RoleScrollView = self:NewUI(8, CScrollView)
	self.m_RoleGrid = self:NewUI(9, CGrid)
	self.m_RoleIconClone = self:NewUI(10, CBox)
	self.m_BackRoleBtn = self:NewUI(11, CButton)
	self.m_RoleBox = self:NewUI(12, CBox)
	self.m_NotifySp = self:NewUI(13, CSprite)
	-- self.m_SchoolNotifySp = self:NewUI(14, CSprite)
	self.m_RoleNameTexture = self:NewUI(15, CSprite)
	self.m_RaceLbl = self:NewUI(16, CLabel)
	self.m_RaceDescLbl = self:NewUI(17, CLabel)
	self.m_RaceBox = self:NewUI(18, CBox)
	self.m_SchoolNotifySp = self:NewUI(19, CSprite)
	self.m_SchoolContentBox = self:NewUI(20, CBox)
	self.m_SchoolLbl = self:NewUI(21, CLabel)
	self.m_SchoolDescLbl = self:NewUI(22, CLabel)
	self.m_SkillDescLbl = self:NewUI(23, CLabel)
	self.m_SkillGrid = self:NewUI(24, CGrid)
	self.m_SkillBoxClone = self:NewUI(25, CBox)
	self.m_NoSelectLbl = self:NewUI(26, CLabel)
	self.m_RaceSp = self:NewUI(27, CSprite)
	self.m_BgTex = self:NewUI(28, CTexture)
	self.m_SchoolAttrSp = self:NewUI(29, CSprite)
	self:InitRoleBox()

	self.m_NameInput.m_UIInput.caretColor = Color.New(1, 1, 1, 0.8)
	self.m_MinNameChar = 4
	self.m_AllowList = {}
	table.copy(data.randomnamedata.SPECITY, self.m_AllowList)
	table.insert(self.m_AllowList, "*")
	self.m_UsedNameCache = {}
	self.m_SelectRoleConfigId = nil
	self.m_SelectedSchoolId = nil
	self.m_IsSameName = false
	self.m_SchoolSkillList = {}
	
	self:InitContent()

	g_UploadDataCtrl:CreateRoleUpload({click = "OpenRoleCreateView"})
end

function CRoleCreateView.InitRoleBox(self)
	--m_RoleBoxList绑定某个角色
	self.m_RoleBoxList = {}
	for i=1, #data.roletypedata.DATA do
		self.m_RoleBoxList[i] = self.m_RoleBox:NewUI(i, CBox)
		self.m_RoleBoxList[i].m_IconSp = self.m_RoleBoxList[i]:NewUI(1, CSprite)
		self.m_RoleBoxList[i].m_SelectSp = self.m_RoleBoxList[i]:NewUI(2, CSprite)
		self.m_RoleBoxList[i].m_NameLbl = self.m_RoleBoxList[i]:NewUI(3, CLabel)
		self.m_RoleBoxList[i]:ForceSelected(false)
		-- self.m_RoleBoxList[i].m_IconSp:SetGrey(true)
	end
	for k,v in ipairs(self.m_RoleBoxActualTypeList) do
		self.m_RoleBoxList[v]:SetLocalPos(self.m_RoleBoxPosList[self.m_RoleIconSortList[k]])
	end
end

function CRoleCreateView.OnSelectRoleBox(self, roleconfigid)
	for k,v in ipairs(data.roletypedata.DATA) do
		local oRoleIcon = self.m_RoleBoxList[self.m_RoleBoxActualTypeList[v.roletype]]
		oRoleIcon:ForceSelected(false)
		-- oRoleIcon.m_IconSp:SetGrey(true)
	end
	self.m_RoleBoxList[self.m_RoleBoxActualTypeList[roleconfigid]]:ForceSelected(true)
	-- self.m_RoleBoxList[self.m_RoleIconSortList[roleconfigid]].m_IconSp:SetGrey(false)
	-- self.m_RoleBoxList[data.roletypedata.DATA[roleconfigid].iconsort]:ForceSelected(true)
	-- self.m_RoleBoxList[data.roletypedata.DATA[roleconfigid].iconsort].m_IconSp:SetGrey(false)
end

function CRoleCreateView.InitContent(self)
	if g_LoginPhoneCtrl:IsShenhePack() then
		self.m_BgTex:SetActive(true)
		local sPath = "Textures/loginBG"
		g_ResCtrl:LoadStreamingAssetsTexture(sPath, function (prefab, errcode)
			self.m_BgTex:SetMainTexture(prefab)
		end)
	end
	
	self.m_SchoolItemClone:SetActive(false)
	self.m_RoleIconClone:SetActive(false)
	self.m_SkillBoxClone:SetActive(false)

	self:SetNameForbiddenChars()

	self.m_RandomNameBtn:AddUIEvent("click", callback(self, "OnRandomName"))
	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnCreateRole"))
	self.m_BackServerBtn:AddUIEvent("click", callback(self, "BackServer"))
	self.m_BackRoleBtn:AddUIEvent("click", callback(self, "OnBackRole"))
	self.m_NameInput:AddUIEvent("change", callback(self, "CheckValidChar"))
	self.m_NameInput:AddUIEvent("select", callback(self, "OnFocusInput"))
	self.m_RoleNameTexture:AddUIEvent("drag", callback(self, "OnActorDrag"))

	g_LoginPhoneCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_RoleCreateScene:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlRoleCreateEvent"))
end

function CRoleCreateView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Login.Event.RoleCreateRandomName then
		g_UploadDataCtrl:CreateRoleUpload({click = "RoleFail"})
		--暂时屏蔽随机名字的规则
		-- self.m_IsSameName = true
		--不会立即刷新名字
		-- self:RandomName()
	end
end

function CRoleCreateView.OnCtrlRoleCreateEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Login.Event.ShowActor then
		if oCtrl.m_EventData == -1 then
			for k,v in pairs(self.m_RoleGrid:GetChildList()) do
				v:GetComponent(classtype.BoxCollider).enabled = false
			end

			for k,v in pairs(self.m_RoleBoxList) do
				v:GetComponent(classtype.BoxCollider).enabled = false
			end
		else
			for k,v in pairs(self.m_RoleGrid:GetChildList()) do
				v:GetComponent(cOnClickBack.BoxCollider).enabled = true
			end

			for k,v in pairs(self.m_RoleBoxList) do
				v:GetComponent(classtype.BoxCollider).enabled = true
			end
		end
	elseif oCtrl.m_EventID == define.Login.Event.SelectActor then
		if oCtrl.m_EventData == -1 then
			self:RefreshUI()
		else
			self:ShowActorUI(oCtrl.m_EventData)
		end
	elseif oCtrl.m_EventID == define.Login.Event.ShowRoleCreateName then
		if g_RoleCreateScene.m_IsShowingActor then
			self.m_RoleNameTexture:SetActive(false)
		else
			self.m_RoleNameTexture:SetActive(true)
			local tween = self.m_RoleNameTexture:GetComponent(classtype.TweenAlpha)
			tween.enabled = true
			self.m_RoleNameTexture:SetAlpha(0)
			tween.from = 0
			tween.to = 1
			tween.duration = 2
			tween:ResetToBeginning()
			-- tween.delay = define.Task.Time.MoveDown
			tween:PlayForward()
		end
	end
end

function CRoleCreateView.RefreshUI(self)
	self.m_UsedNameCache = {}
	self.m_SelectRoleConfigId = nil
	self.m_SelectedSchoolId = nil
	self:OnShowSchoolContent(self.m_SelectedSchoolId)
	self:SetRoleBoxList()
	self.m_CreateBtn:SetActive(false)
	self.m_NameInput:SetActive(false)
	self.m_SchoolGrid:SetActive(false)
	self.m_SchoolBg:SetActive(false)
	-- self.m_RoleNameTexture:SetMainTexture()
	self.m_RoleNameTexture:SetActive(false)
	self.m_BackServerBtn:SetActive(true)
	self.m_BackRoleBtn:SetActive(false)
	self.m_RaceBox:SetActive(false)
	self.m_SchoolContentBox:SetActive(false)
end

function CRoleCreateView.SetNotifySpEffect(self)
	local tween = self.m_NotifySp:GetComponent(classtype.TweenAlpha)
	tween.enabled = true
	self.m_NotifySp:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = 1
	tween:ResetToBeginning()
	-- tween.delay = define.Task.Time.MoveDown
	tween:PlayForward()
end

function CRoleCreateView.SetSchoolNotifySpEffect(self)
	local tween = self.m_SchoolNotifySp:GetComponent(classtype.TweenAlpha)
	tween.enabled = true
	self.m_SchoolNotifySp:SetAlpha(1)
	tween.from = 1
	tween.to = 0
	tween.duration = 1
	tween:ResetToBeginning()
	-- tween.delay = define.Task.Time.MoveDown
	tween:PlayForward()
end

function CRoleCreateView.ShowActorUI(self, roleconfigid)	
	self.m_CreateBtn:SetActive(true)
	self.m_NameInput:SetActive(true)
	self.m_SchoolGrid:SetActive(true)
	self.m_SchoolBg:SetActive(true)
	-- self.m_RoleNameTexture:SetActive(true)
	self.m_BackServerBtn:SetActive(true)
	self.m_BackRoleBtn:SetActive(false)
	self.m_RaceBox:SetActive(true)
	self.m_SchoolContentBox:SetActive(true)
	if self.m_SelectRoleConfigId ~= roleconfigid then
		g_UploadDataCtrl:CreateRoleUpload({click = "OnClickRole_"..roleconfigid})
	end
	self.m_SelectRoleConfigId = roleconfigid
	local sTextureName = "Texture/Login/"..self:GetRoleNameTextureName(roleconfigid)..".png"
	-- g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))
	self.m_RoleNameTexture:SetSpriteName("h7_mz_0"..self.m_RoleNameSpHashList[roleconfigid])
	self:RandomName()
	self:SetSchoolList(roleconfigid)
	self:OnSelectRoleBox(roleconfigid)
	-- self.m_RaceLbl:SetText(data.roletypedata.DATA[roleconfigid].racename)
	local oRaceName = data.roletypedata.DATA[roleconfigid].racename
	if oRaceName == "人族" then
		self.m_RaceSp:SetSpriteName("h7_zuqun_03")
	elseif oRaceName == "仙族" then
		self.m_RaceSp:SetSpriteName("h7_zuqun_02")
	else
		self.m_RaceSp:SetSpriteName("h7_zuqun_01")
	end
	self.m_RaceDescLbl:SetText(data.roletypedata.DATA[roleconfigid].racedesc)

	local oSchoolIndex = Utils.RandomInt(1, #data.roletypedata.DATA[roleconfigid].school)
	local oItem = self.m_SchoolGrid:GetChild(oSchoolIndex)
	if oItem then
		self:OnClickSchoolBox(oItem, oItem.m_Info)
	end
end

function CRoleCreateView.SetTexture(self, prefab, errcode)
	if prefab then
		self.m_RoleNameTexture:SetMainTexture(prefab)
	else
		print(errcode)
	end
end

function CRoleCreateView.GetRoleNameTextureName(self, roleconfigid)
	if roleconfigid == 1 then
		return "h7_name_6"
	elseif roleconfigid == 2 then
		return "h7_name_3"
	elseif roleconfigid == 3 then
		return "h7_name_5"
	elseif roleconfigid == 4 then
		return "h7_name_2"
	elseif roleconfigid == 5 then
		return "h7_name_1"
	elseif roleconfigid == 6 then
		return "h7_name_4"
	else
		return "h7_name_6"
	end
end

function CRoleCreateView.SetRoleBoxList(self)
	for k,v in ipairs(data.roletypedata.DATA) do
		local oRoleIcon = self.m_RoleBoxList[self.m_RoleBoxActualTypeList[v.roletype]]
		local iconSp = oRoleIcon:NewUI(1, CSprite)
		local selectSp = oRoleIcon:NewUI(2, CSprite)
		local oNameLbl = oRoleIcon:NewUI(3, CLabel)
		-- iconSp:SetSpriteName("h7_ren_"..v.shape)
		oNameLbl:SetText(v.desc)
		-- iconSp:SetGrey(true)
		if v.isactive == 1 then
			oRoleIcon:SetGroup(self:GetInstanceID()-1)
			selectSp:SetActive(false)			
		else
			oRoleIcon:SetGroup(self:GetInstanceID())
			selectSp:SetActive(true)
		end
		oRoleIcon:ForceSelected(false)
		oRoleIcon:AddUIEvent("click", callback(self, "OnClickRoleIconBox", v.roletype))
	end
end

function CRoleCreateView.SetSchoolList(self, roleconfigid)
	local list = {}
	table.copy(data.roletypedata.DATA[roleconfigid].school, list)
	-- table.insert(list, -1)
	local optionCount = #list
	self.m_SchoolGrid:Clear()
	local GridList = self.m_SchoolGrid:GetChildList() or {}
	local oSchoolBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSchoolBox = self.m_SchoolItemClone:Clone(false)
				-- self.m_SchoolGrid:AddChild(oOptionBtn)
			else
				oSchoolBox = GridList[i]
			end
			self:SetSchoolBox(oSchoolBox, list[i])
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

	self.m_SchoolGrid:Reposition()

	--去掉默认选中门派
	-- if self.m_SelectedSchoolId then
	-- 	local oItem = self.m_SchoolGrid:GetChild(1)
	-- 	self:OnClickSchoolBox(oItem, data.roletypedata.DATA[roleconfigid].school[1])
	-- end
end

function CRoleCreateView.SetSchoolBox(self, oSchoolBox, oData)
	oSchoolBox:SetActive(true)
	oSchoolBox.m_SchoolSprite = oSchoolBox:NewUI(1, CSprite)
	oSchoolBox.m_SelectSchoolSprite = oSchoolBox:NewUI(2, CSprite)
	oSchoolBox.m_SchoolNameSp = oSchoolBox:NewUI(3, CSprite)
	if oData ~= -1 then
		oSchoolBox:SetGroup(self.m_SchoolGrid:GetInstanceID())
	end
	oSchoolBox.m_Info = oData
	if oData == -1 then       
    else        
        -- 门派图标\名称
        oSchoolBox.m_SchoolSprite:SetSpriteName("h7_menpai_"..self.m_SchoolSpHashList[oData]) --:SpriteSchool(oData + 500)
        oSchoolBox.m_SelectSchoolSprite:SetSpriteName("h7_menpai_"..self.m_SchoolLightSpHashList[oData]) --:SpriteSchool(oData + 500)
        oSchoolBox.m_SchoolNameSp:SetSpriteName("h7_menpaimc_"..oData)
        oSchoolBox.m_SchoolNameSp:MakePixelPerfect()
        -- local schoolInfo = DataTools.GetSchoolInfo(oData)
        -- self.m_SchoolLabel:SetText(schoolInfo.name)
        -- self.m_DescLbl:SetText(schoolInfo.desc)
    end
	oSchoolBox:AddUIEvent("click", callback(self, "OnClickSchoolBox", oSchoolBox, oData))

	self.m_SchoolGrid:AddChild(oSchoolBox)
	self.m_SchoolGrid:Reposition()
end

function CRoleCreateView.SetSchoolSkillList(self, oSchoolId)
	local oSchoolConfig = DataTools.GetSchoolInfo(oSchoolId)
	self.m_SchoolSkillList = oSchoolConfig.skilllist
	local optionCount = #self.m_SchoolSkillList
	local GridList = self.m_SkillGrid:GetChildList() or {}
	local oSkillBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oSkillBox = self.m_SkillBoxClone:Clone(false)
				-- self.m_SkillGrid:AddChild(oOptionBtn)
			else
				oSkillBox = GridList[i]
			end
			self:SetSchoolSkillBox(oSkillBox, self.m_SchoolSkillList[i], i)
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

	self.m_SkillGrid:Reposition()
	-- self.m_ScrollView:ResetPosition()
end

function CRoleCreateView.SetSchoolSkillBox(self, oSkillBox, oData, oIndex)
	oSkillBox:SetActive(true)
	oSkillBox.m_IconSp = oSkillBox:NewUI(1, CSprite)
	oSkillBox.m_SelectIconSp = oSkillBox:NewUI(2, CSprite)

	oSkillBox.m_SkillData = oData
	oSkillBox:SetGroup(self.m_SchoolContentBox:GetInstanceID())
	oSkillBox.m_IconSp:SpriteSkill(data.skilldata.SCHOOL[oData].icon)
	-- oSkillBox.m_SelectIconSp:SpriteSkill(data.skilldata.SCHOOL[oData].icon)
	
	oSkillBox:AddUIEvent("click", callback(self, "OnClickSkillBox", oData, oIndex))

	self.m_SkillGrid:AddChild(oSkillBox)
	self.m_SkillGrid:Reposition()
end

function CRoleCreateView.SetNameForbiddenChars(self)
	self.m_NameInput:SetForbidChars({" ", "%"})
end

---------------以下是点击事件-------------------

function CRoleCreateView.OnRandomName(self)
	g_UploadDataCtrl:SetDotUpload("21")
	g_UploadDataCtrl:CreateRoleUpload({click = "OnRandomNameUI"})
	self:RandomName()
end

function CRoleCreateView.RandomName(self)
	local function getone()
		local first = table.randomvalue(data.randomnamedata.FIRST)
		local last = ""
		local iSex = data.roletypedata.DATA[self.m_SelectRoleConfigId].sex
		if iSex == define.Sex.Male then
			last = table.randomvalue(data.randomnamedata.MALE)
		else
			last = table.randomvalue(data.randomnamedata.FEMALE)
		end
		if self.m_IsSameName then
			--插入多少个特殊字段，最多3个
			local numlist = {1, 2, 3}

			local totalstr = ""
			--字符总数
			local totalcount = 0
			local speciallist = {}
			--插入到哪个位置:1, 2, 3
			local poslist = {1, 2, 3}
			--每个特殊字段包含多少个字符，最多4个
			local countlist = {1, 2, 3, 4}
			--特殊字段的字符总数最多4个

			for i=1, table.randomvalue(numlist) do
				local count = table.randomvalue(countlist)
				totalcount = totalcount + count
				if totalcount > 4 then
					break
				end
				local str = ""
				for i=1, count do
					str = str..table.randomvalue(data.randomnamedata.SPECITY)
				end
				local list = {count = count, str = str}
				table.insert(speciallist, list)
			end
			-- table.print(speciallist, "speciallist")
			local eachposstr = {"", "", ""}
			for k,v in ipairs(speciallist) do
				local key = table.randomkey(poslist)
				local pos = poslist[key]
				table.remove(poslist, key)
				eachposstr[pos] = v.str
			end
			return eachposstr[1]..first..eachposstr[2]..last..eachposstr[3]
		else
			return first..last
		end
	end
	local iMax = 10
	local sName = nil
	for i = 1, iMax + 1 do
		local sOne = getone()
		if not self.m_UsedNameCache[sOne] then
			self.m_UsedNameCache[sOne] = true
			sName = sOne
			break
		end
		if i == iMax then
			self.m_UsedNameCache = {}
		end
	end
	if not sName then
		sName = "一个名字"
	end
	-- sName = "一个名字一个名字"
	self.m_NameInput:SetText(g_MaskWordCtrl:ReplaceMaskWord(sName, true))
end

function CRoleCreateView.OnCreateRole(self)
	local sName = self.m_NameInput:GetText()
	if #sName <= 0 then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.NoName].content)
		DOTween.DOShakePosition(self.m_NameInput.m_Transform, 1, 2, 10, 90, false, true)
		self:SetNotifySpEffect()
		return
	elseif #sName < self.m_MinNameChar and #sName > 0 then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.ShortName].content)
		DOTween.DOShakePosition(self.m_NameInput.m_Transform, 1, 2, 10, 90, false, true)
		self:SetNotifySpEffect()
		return
	end
	if g_MaskWordCtrl:IsContainMaskWord(sName) then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.MaskName].content)
		DOTween.DOShakePosition(self.m_NameInput.m_Transform, 1, 2, 10, 90, false, true)
		self:SetNotifySpEffect()
		return
	end
	
	if string.isIllegalInverse(sName, {"#"}) == false then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.SpecialName].content)
		DOTween.DOShakePosition(self.m_NameInput.m_Transform, 1, 2, 10, 90, false, true)
		self:SetNotifySpEffect()
		return
	end

	if not self.m_SelectedSchoolId then
		g_NotifyCtrl:FloatMsg(data.logindata.TEXT[define.Login.Text.SelectSchool].content)
		self:SetSchoolNotifySpEffect()
		return
	end

	if g_RoleCreateScene.m_IsShowingRoleCreateScene or g_RoleCreateScene.m_IsShowingActor or not g_RoleCreateScene.m_RoleCreateScene then
		return
	end

	local function roleCreate()
		local iRoleType = data.roletypedata.DATA[self.m_SelectRoleConfigId].roletype
		local oServerKey = nil
		if g_LoginPhoneCtrl.m_PhoneChooseInfo.server then
			oServerKey = g_LoginPhoneCtrl.m_PhoneChooseInfo.server.id
			if g_ServerPhoneCtrl:IsNewArea() then
				oServerKey = g_LoginPhoneCtrl.m_PhoneChooseInfo.server.linkserver
			end
		end
		printc("创建角色: school = " .. self.m_SelectedSchoolId .. ", roleType = " .. iRoleType, "Name = "..sName, "oServerKey = ", oServerKey)
		g_LoginPhoneCtrl:C2GSCreateRole(iRoleType, sName, self.m_SelectedSchoolId, oServerKey)
	end
	roleCreate()

	g_UploadDataCtrl:CreateRoleUpload({click = "OnCreateRoleUI"})
	g_UploadDataCtrl:SetDotUpload("21")
end

function CRoleCreateView.BackServer(self)
	g_AudioCtrl:StopSolo()
	self:CloseView()
	g_RoleCreateScene:OnDestroyScene()
	g_LoginPhoneCtrl:ResetAllData()
	if g_LoginPhoneCtrl.m_IsPC then
		CLoginPhoneView:ShowView(function (oView)
			oView:RefreshUI()
			oView:ShowPCMainUI()
			oView.m_AccountBox:SetActive(false)
		end)
	else
		CLoginPhoneView:ShowView(function (oView)
			oView:RefreshUI()
			--这里是在有中心服的数据情况下
			if g_LoginPhoneCtrl.m_IsQrPC then
				g_ServerPhoneCtrl:OnEvent(define.Login.Event.ServerListSuccess)
			end
		end)
		
	end
end

function CRoleCreateView.OnBackRole(self)
	-- g_AudioCtrl:StopSolo()
	-- if g_LoginPhoneCtrl.m_RoleCreateScene then
	-- 	printc("m_CameraPathAnimator2 reserve")
	-- 	-- g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator2:Stop()
	-- 	g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator4.animationMode = 0
	-- 	g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator4:Seek(0)
	-- 	-- g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator2:Reverse()
	-- 	g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator4:Play()
	-- 	g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator4.AnimationFinishedEvent = callback(self, "OnCameraPathAnimator2ReverseFinish")

	-- 	if g_LoginPhoneCtrl.m_RoleCreateScene.m_LastShowActorId then
	-- 		g_LoginPhoneCtrl.m_RoleCreateScene:ResetActorInfo(g_LoginPhoneCtrl.m_RoleCreateScene.m_LastShowActorId)
	-- 	end
		
	-- 	g_UploadDataCtrl:CreateRoleUpload({click = "OnClickBack"})
	-- end
end

function CRoleCreateView.OnCameraPathAnimator2ReverseFinish(self)
	-- g_LoginPhoneCtrl.m_RoleCreateScene.m_CameraPathAnimator4:Stop()
	-- printc("OnCameraPathAnimator2ReverseFinish")
end

function CRoleCreateView.OnClickRoleIconBox(self, roletype)
	if g_RoleCreateScene.m_IsShowingRoleCreateScene or g_RoleCreateScene.m_IsShowingActor or not g_RoleCreateScene.m_RoleCreateScene then
		return
	end
	if data.roletypedata.DATA[roletype].isactive == 1 then
		g_NotifyCtrl:FloatMsg("角色暂未开放哦")
		return
	end
	g_RoleCreateScene:ShowOneActor(roletype)
	-- self.m_RoleGrid:GetChild(roletype):ForceSelected(true)
	self:OnSelectRoleBox(roletype)
end

function CRoleCreateView.OnClickSchoolBox(self, oSchoolBox, oData)
	if oData == -1 or oData == self.m_SelectedSchoolId then
		return
	end
	g_UploadDataCtrl:SetDotUpload("22")
	g_UploadDataCtrl:CreateRoleUpload({click = "OnClickSchool_"..oData})

	self.m_SelectedSchoolId = oData
	oSchoolBox:ForceSelected(true)
	self:OnShowSchoolContent(oData)	
end

function CRoleCreateView.OnShowSchoolContent(self, oSchoolId)
	if oSchoolId then
		local schoolInfo = DataTools.GetSchoolInfo(oSchoolId)
	    -- self.m_SchoolLbl:SetText(schoolInfo.name)
	    self.m_SchoolLbl:SetText("")
	    self.m_SchoolAttrSp:SetSpriteName(self:GetSchoolAttrSpName(oSchoolId))
	    self.m_SchoolAttrSp:MakePixelPerfect()
	    self.m_SchoolDescLbl:SetText("擅长："..schoolInfo.desc)
	    self.m_NoSelectLbl:SetText("")
	    self.m_SkillGrid:SetActive(true)
	    self:SetSchoolSkillList(oSchoolId)
	    self:SkillSelectOne(1)
	else
		self.m_SchoolLbl:SetText("请选择")
		self.m_SchoolAttrSp:SetSpriteName("empty")
		self.m_SchoolDescLbl:SetText("")
		self.m_NoSelectLbl:SetText("请通过上方的图标，选择你要加入的门派")
		self.m_SkillGrid:SetActive(false)
		self.m_SkillDescLbl:SetText("")
	end
end

function CRoleCreateView.GetSchoolAttrSpName(self, oSchoolType)
	local oList = {"menpaiwenzi_13", "menpaiwenzi_18", "menpaiwenzi_11", "menpaiwenzi_03", "menpaiwenzi_21", "menpaiwenzi_06"}
	return oList[oSchoolType]
end

function CRoleCreateView.OnClickSkillBox(self, oData, oIndex)
	self:SkillSelectOne(oIndex)
end

function CRoleCreateView.SkillSelectOne(self, oIndex)
	local oChild = self.m_SkillGrid:GetChild(oIndex)
	if oChild then
		oChild:SetSelected(true)
	end
	self:SkillOnShowEachByIndex(oIndex)
end

function CRoleCreateView.SkillOnShowEachByIndex(self, oIndex)
	if not self.m_SchoolSkillList[oIndex] then
		return
	end
	local oSkillData = self.m_SchoolSkillList[oIndex]
	self.m_SkillDescLbl:SetText(data.skilldata.SCHOOL[oSkillData].rolecreatedesc)
end

function CRoleCreateView.CheckValidChar(self)
	local sName = self.m_NameInput:GetText()
	if g_MaskWordCtrl:IsContainMaskWord(sName) then
		self.m_NameInput.m_UIInput.activeTextColor = Color.New(1, 0, 0, 1)
		-- if Utils.IsPC() then
		-- 	self.m_NameInput.m_UIInput.isSelected = true
		-- end
		-- g_NotifyCtrl:FloatMsg("有屏蔽字")
	else
		self.m_NameInput.m_UIInput.activeTextColor = Color.New(1, 1, 1, 1)
		-- if Utils.IsPC() then
		-- 	self.m_NameInput.m_UIInput.isSelected = true
		-- end
		-- g_NotifyCtrl:FloatMsg("没有屏蔽字")
	end
	self.m_NameInput.m_UIInput:UpdateLabel()
end

function CRoleCreateView.OnFocusInput(self)
	if self.m_NameInput.m_UIInput.isSelected then
		g_UploadDataCtrl:SetDotUpload("21")
	end
end

function CRoleCreateView.OnActorDrag(self, obj, moveDelta)
	local oActor = g_RoleCreateScene.m_CurRoleCreatePlayer
	if not oActor then
		return
	end
	-- oActor:Rotate(Vector3.New(0, - moveDelta.x * 3, 0))
end

return CRoleCreateView