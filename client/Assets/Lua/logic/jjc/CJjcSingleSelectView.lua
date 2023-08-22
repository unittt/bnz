local CJjcSingleSelectView = class("CJjcSingleSelectView", CViewBase)

function CJjcSingleSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Jjc/JjcSingleSelectView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "ClickOut"
end

function CJjcSingleSelectView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_HelpList = {}
	for i = 2, 5, 1 do
		table.insert(self.m_HelpList, self:NewUI(i, CJjcHelpBox))
	end
	self.m_SummonBox = self:NewUI(6, CJjcHelpBox)
	self.m_SelfZhenfaBox = self:NewUI(7, CBox)
	self.m_SelfZhenfaBox.m_IconSp = self.m_SelfZhenfaBox:NewUI(2, CSprite)
	self.m_SelfZhenfaBox.m_LevelLbl = self.m_SelfZhenfaBox:NewUI(3, CLabel)
	self.m_SelfZhenfaBox.m_NameLbl = self.m_SelfZhenfaBox:NewUI(8, CLabel)
	self.m_SelfZhenfaBox.m_SelectSp = self.m_SelfZhenfaBox:NewUI(9, CSprite)

	self.m_BuddyListBox = self:NewUI(8, CBox)
	self.m_BuddyListBox.m_ScrollView = self.m_BuddyListBox:NewUI(1, CScrollView)
	self.m_BuddyListBox.m_Grid = self.m_BuddyListBox:NewUI(2, CGrid)
	self.m_BuddyListBox.m_BoxClone = self.m_BuddyListBox:NewUI(3, CBox)
	self.m_BuddyListBox.m_Bg = self.m_BuddyListBox:NewUI(4, CSprite)

	self.m_ZhenfaListBox = self:NewUI(9, CBox)
	self.m_ZhenfaListBox.m_ScrollView = self.m_ZhenfaListBox:NewUI(1, CScrollView)
	self.m_ZhenfaListBox.m_Grid = self.m_ZhenfaListBox:NewUI(2, CGrid)
	self.m_ZhenfaListBox.m_BoxClone = self.m_ZhenfaListBox:NewUI(3, CBox)
	self.m_ZhenfaListBox.m_Bg = self.m_ZhenfaListBox:NewUI(4, CSprite)

	self.m_SummonListBox = self:NewUI(10, CBox)
	self.m_SummonListBox.m_ScrollView = self.m_SummonListBox:NewUI(1, CScrollView)
	self.m_SummonListBox.m_Grid = self.m_SummonListBox:NewUI(2, CGrid)
	self.m_SummonListBox.m_BoxClone = self.m_SummonListBox:NewUI(3, CBox)
	self.m_SummonListBox.m_Bg = self.m_SummonListBox:NewUI(4, CSprite)
	self.m_CloseSpr = self:NewUI(11, CButton)
	self:InitContent()
end

function CJjcSingleSelectView.InitContent(self)
	g_JjcCtrl.m_JjcMainBuddyClick = nil
	g_JjcCtrl.m_JjcMainSummonClick = nil

	self.m_BuddyListBox.m_BoxClone:SetActive(false)
	self.m_SummonListBox.m_BoxClone:SetActive(false)
	self.m_ZhenfaListBox.m_BoxClone:SetActive(false)
	self.m_ZhenfaListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(false)
	self.m_SummonListBox:SetActive(false)

	self.m_SummonBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickSummonBox"))
	self.m_SummonBox.m_DownBtn:AddUIEvent("click", callback(self, "OnClickSummonDown"))
	self.m_SummonBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddSummon"))
	for k, oBox in ipairs(self.m_HelpList) do
		oBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickBuddyBox", k))
		oBox.m_DownBtn:AddUIEvent("click", callback(self, "OnClickBuddyDown", k))
		oBox.m_SwapBtn:AddUIEvent("click", callback(self, "OnClickBuddySwap", k))
		oBox.m_AddBtn:AddUIEvent("click", callback(self, "OnClickAddBuddy", k))
	end
	self.m_SelfZhenfaBox.m_IconSp:AddUIEvent("click", callback(self, "OnClickChooseZhenfa"))
	self.m_CloseSpr:AddUIEvent("click", callback(self, "OnClose"))
	g_JjcCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_FormationCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFormationEvent"))

	self:RefreshUI()
end

--协议通知返回
function CJjcSingleSelectView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Jjc.Event.RefreshJJCMainUI then
		self:RefreshUI(true)

		if next(g_SummonCtrl.m_SummonsSort) then
			self:SetSummonListInfo(g_SummonCtrl.m_SummonsSort)
		end
		local oPartnerList = g_PartnerCtrl:GetPartnerDataList(true)
		if next(oPartnerList) then
			self:SetBuddyListInfo(oPartnerList)
		end
	end
end

function CJjcSingleSelectView.OnCtrlFormationEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Formation.Event.UpdateAllFormation then
		printc("CJjcSingleSelectView.OnCtrlFormationEvent")
		table.print(oCtrl.m_EventData, "CJjcSingleSelectView.OnCtrlFormationEvent")
		self:SetZhenfaListInfo(g_FormationCtrl:GetAllFormationInfo())
	end
end

function CJjcSingleSelectView.RefreshUI(self, isNotShowZhenfa)
	self.m_SummonBox:SetSummonBox(g_JjcCtrl.m_JjcMainSummonid, g_JjcCtrl.m_JjcMainSummonicon, g_JjcCtrl.m_JjcMainSummonlv)
	self:ResetAllBuddyBox()
	self:ResetSummonBox()
	self:SetZhenfaInfo()

	if not isNotShowZhenfa then
		if g_FormationCtrl:GetCurrentFmt() == 0 then
			netformation.C2GSAllFormationInfo()
		else
			local fmtlist = g_FormationCtrl:GetAllFormationInfo()
			self:SetZhenfaListInfo(fmtlist)
		end
		self.m_ZhenfaListBox:SetActive(true)
		self.m_SummonListBox:SetActive(false)
		self.m_BuddyListBox:SetActive(false)
		self:OnSelectHightLight(1)
	end
end

function CJjcSingleSelectView.ResetAllBuddyBox(self)
	g_JjcCtrl.m_JjcMainBuddyClick = nil
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcMainBuddyList[k] then
			oBox:SetBuddyBox(g_JjcCtrl.m_JjcMainBuddyList[k])
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcSingleSelectView.SetSelectBuddy(self, idx)
	if not g_JjcCtrl.m_JjcMainBuddyList[idx] or g_JjcCtrl.m_JjcMainBuddyClick then
		return
	end
	g_JjcCtrl.m_JjcMainBuddyClick = idx
	for k, oBox in ipairs(self.m_HelpList) do
		if g_JjcCtrl.m_JjcMainBuddyList[k] then
			if k == idx then
				oBox:DownBuddyState(g_JjcCtrl.m_JjcMainBuddyList[k])
			else
				oBox:SwapBuddyState(g_JjcCtrl.m_JjcMainBuddyList[k])
			end
		else
			oBox:AddBuddyState()
		end
	end
end

function CJjcSingleSelectView.ResetSummonBox(self)
	g_JjcCtrl.m_JjcMainSummonClick = nil
	self.m_SummonBox:SetSummonBox(g_JjcCtrl.m_JjcMainSummonid, g_JjcCtrl.m_JjcMainSummonicon, g_JjcCtrl.m_JjcMainSummonlv)
end

function CJjcSingleSelectView.SetSelectSummon(self)
	if g_JjcCtrl.m_JjcMainSummonClick then
		return
	end
	g_JjcCtrl.m_JjcMainSummonClick = 1
	self.m_SummonBox:DownSummonState(g_JjcCtrl.m_JjcMainSummonid, g_JjcCtrl.m_JjcMainSummonicon, g_JjcCtrl.m_JjcMainSummonlv)
end

function CJjcSingleSelectView.SetZhenfaInfo(self)
	local zhenfaConfig = data.formationdata.BASEINFO[g_JjcCtrl.m_JjcMainFmtid]
	local zhenfaStr
	self.m_SelfZhenfaBox.m_IconSp:SetSpriteName(zhenfaConfig.icon)
	if g_JjcCtrl.m_JjcMainFmtid == 1 then
		-- zhenfaStr = zhenfaConfig.name
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(false)
	else
		-- zhenfaStr = zhenfaConfig.name.." "..g_JjcCtrl.m_JjcMainFmtlv.."级"
		self.m_SelfZhenfaBox.m_LevelLbl:SetActive(true)
		self.m_SelfZhenfaBox.m_LevelLbl:SetText(g_JjcCtrl.m_JjcMainFmtlv.."级")
	end
	self.m_SelfZhenfaBox.m_NameLbl:SetText(zhenfaConfig.name)
end

function CJjcSingleSelectView.ResetAllTargetBuddyBox(self, oData)
	for k, oBox in ipairs(self.m_BuddyInfoBox.m_HelpList) do
		if oData[k] then
			oBox:SetBuddyBox(oData[k])
		else
			oBox:AddTargetBuddyState()
		end
	end
end

function CJjcSingleSelectView.SetZhenfaListInfo(self, oData)
	-- table.print(oData, "CJjcSingleSelectView.SetZhenfaListInfo")
	-- self.m_ZhenfaListBox:SetActive(true)
	-- UITools.NearTarget(self.m_SelfZhenfaBox.m_IconSp, self.m_ZhenfaListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -30, 0))
	self.m_ZhenfaListBox.m_Grid:Clear()

	if oData and next(oData) then
		local list = {}
		for k,v in pairs(oData) do
			if v.grade > 0 then
				table.insert(list, v)
			end
		end
		-- local width = 110
		-- if #list <= 3 then
		-- 	self.m_ZhenfaListBox.m_Bg:SetHeight(width * #list)
		-- 	self.m_ZhenfaListBox:SetHeight(width * #list)
		-- else
		-- 	self.m_ZhenfaListBox.m_Bg:SetHeight(width * 3)
		-- 	self.m_ZhenfaListBox:SetHeight(width * 3)
		-- end
		for k,v in ipairs(list) do
			self:AddZhenfaBox(v)
		end
	end

	self.m_ZhenfaListBox.m_Grid:Reposition()
	self.m_ZhenfaListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_ZhenfaListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0)

	-- g_UITouchCtrl:TouchOutDetect(self.m_ZhenfaListBox, callback(self.m_ZhenfaListBox, "SetActive", false))
end

function CJjcSingleSelectView.AddZhenfaBox(self, oZhenfa)
	local oZhenfaBox = self.m_ZhenfaListBox.m_BoxClone:Clone()
	
	oZhenfaBox:SetActive(true)
	oZhenfaBox.m_IconSp = oZhenfaBox:NewUI(1, CSprite)
	oZhenfaBox.m_nameLbl = oZhenfaBox:NewUI(2, CLabel)
	oZhenfaBox.m_UpBtn = oZhenfaBox:NewUI(3, CButton)
	local zhenfaConfig = data.formationdata.BASEINFO[oZhenfa.fmt_id]
	local zhenfaStr
	if oZhenfa.fmt_id == 1 then
		zhenfaStr = zhenfaConfig.name
	else
		zhenfaStr = zhenfaConfig.name.." "..oZhenfa.grade.."级"
	end
	oZhenfaBox.m_IconSp:SetSpriteName(zhenfaConfig.icon)
	oZhenfaBox.m_nameLbl:SetText(zhenfaStr)
	oZhenfaBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectZhenfa", oZhenfa))
	self.m_ZhenfaListBox.m_Grid:AddChild(oZhenfaBox)
	self.m_ZhenfaListBox.m_Grid:Reposition()
	-- self.m_ZhenfaListBox.m_ScrollView:CullContentLater()
end

function CJjcSingleSelectView.SetBuddyListInfo(self, oData, idx)
	-- self.m_BuddyListBox:SetActive(true)
	-- UITools.NearTarget(self.m_HelpList[idx].m_AddBtn, self.m_BuddyListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -18, 0))
	self.m_BuddyListBox.m_Grid:Clear()

	if oData and next(oData) then
		-- local width = 110
		-- if #oData <= 3 then
		-- 	self.m_BuddyListBox.m_Bg:SetHeight(width * #oData)
		-- 	self.m_BuddyListBox:SetHeight(width * #oData)
		-- else
		-- 	self.m_BuddyListBox.m_Bg:SetHeight(width * 3)
		-- 	self.m_BuddyListBox:SetHeight(width * 3)
		-- end

		for k,v in ipairs(oData) do
			self:AddBuddyBox(v)
		end
	end

	self.m_BuddyListBox.m_Grid:Reposition()
	self.m_BuddyListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_BuddyListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0)

	-- g_UITouchCtrl:TouchOutDetect(self.m_BuddyListBox, callback(self.m_BuddyListBox, "SetActive", false))
end

function CJjcSingleSelectView.AddBuddyBox(self, oBuddy)
	local oBuddyBox = self.m_BuddyListBox.m_BoxClone:Clone()
	
	oBuddyBox:SetActive(true)
	oBuddyBox.m_IconSprite = oBuddyBox:NewUI(1, CSprite)
	oBuddyBox.m_Quality = oBuddyBox:NewUI(2, CSprite)
	oBuddyBox.m_StartGrid = oBuddyBox:NewUI(3, CGrid)
	oBuddyBox.m_StartClone = oBuddyBox:NewUI(4, CSprite)
	oBuddyBox.m_NameLabel = oBuddyBox:NewUI(5, CLabel)
	oBuddyBox.m_GradeLabel = oBuddyBox:NewUI(6, CLabel)
	oBuddyBox.m_TypeSprite = oBuddyBox:NewUI(7, CSprite)
	oBuddyBox.m_FactionIcon = oBuddyBox:NewUI(8, CSprite)
	oBuddyBox.m_FactionName = oBuddyBox:NewUI(9, CLabel)
	oBuddyBox.m_TipSprite = oBuddyBox:NewUI(10, CSprite)
	oBuddyBox.m_UpBtn = oBuddyBox:NewUI(12, CButton)
	oBuddyBox.m_StartClone:SetActive(false)

	local partnerData = g_PartnerCtrl:GetRecruitPartnerDataByID(oBuddy.id)
	oBuddyBox.m_IconSprite:SpriteAvatar(oBuddy.shape)
	local quality = (partnerData and partnerData.quality or oBuddy.quality) - 1
	oBuddyBox.m_Quality:SetItemQuality(quality)
	oBuddyBox.m_NameLabel:SetText(oBuddy.name)
	local gradeStr = partnerData and partnerData.grade .. "级" or ""
	oBuddyBox.m_GradeLabel:SetText(gradeStr)
	-- local partnerType = DataTools.GetPartnerType(oBuddy.type)
	oBuddyBox.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[oBuddy.type])
	local schoolInfo = data.schooldata.DATA[oBuddy.school]
	oBuddyBox.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	oBuddyBox.m_FactionName:SetText(schoolInfo.name)
	local oIsInFight = g_JjcCtrl:GetIsJjcMainBuddyIsInFight(oBuddy.serverid)
	oBuddyBox.m_TipSprite:SetActive(oIsInFight)
	oBuddyBox.m_UpBtn:SetActive(not oIsInFight)
	self:SetStart(oBuddyBox, partnerData and partnerData.quality or 0)

	oBuddyBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectBuddy", oBuddy))
	self.m_BuddyListBox.m_Grid:AddChild(oBuddyBox)
	self.m_BuddyListBox.m_Grid:Reposition()
	-- self.m_BuddyListBox.m_ScrollView:CullContentLater()
end

function CJjcSingleSelectView.SetStart(self, oBox, count)
	local startBoxList = oBox.m_StartGrid:GetChildList()
	local startBox = nil
	for i=1,5 do
		if i > #startBoxList then
			startBox = oBox.m_StartClone:Clone()
			oBox.m_StartGrid:AddChild(startBox)
			startBox:SetActive(true)
		else
			startBox = startBoxList[i]
		end
		startBox:SetGrey(i > count)
	end
end

function CJjcSingleSelectView.SetSummonListInfo(self, oData)
	-- self.m_SummonListBox:SetActive(true)
	-- UITools.NearTarget(self.m_SummonBox.m_AddBtn, self.m_SummonListBox, enum.UIAnchor.Side.Bottom, Vector3.New(0, -13, 0))
	self.m_SummonListBox.m_Grid:Clear()

	if oData and next(oData) then
		-- local width = 110
		-- if #oData <= 3 then
		-- 	self.m_SummonListBox.m_Bg:SetHeight(width * #oData)
		-- 	self.m_SummonListBox:SetHeight(width * #oData)
		-- else
		-- 	self.m_SummonListBox.m_Bg:SetHeight(width * 3)
		-- 	self.m_SummonListBox:SetHeight(width * 3)
		-- end

		for k,v in ipairs(oData) do
			self:AddSummonBox(v)
		end
	end

	self.m_SummonListBox.m_Grid:Reposition()
	self.m_SummonListBox.m_ScrollView:ResetPosition()
	local function progress()
		self.m_SummonListBox.m_ScrollView:ResetPosition()
		return false
	end
	Utils.AddTimer(progress, 0, 0)

	-- g_UITouchCtrl:TouchOutDetect(self.m_SummonListBox, callback(self.m_SummonListBox, "SetActive", false))
end

function CJjcSingleSelectView.AddSummonBox(self, oSummon)
	local oSummonBox = self.m_SummonListBox.m_BoxClone:Clone()
	
	oSummonBox:SetActive(true)
	oSummonBox.m_IconSprite = oSummonBox:NewUI(1, CSprite)
	oSummonBox.m_Quality = oSummonBox:NewUI(2, CSprite)
	oSummonBox.m_StartGrid = oSummonBox:NewUI(3, CGrid)
	oSummonBox.m_StartClone = oSummonBox:NewUI(4, CSprite)
	oSummonBox.m_NameLabel = oSummonBox:NewUI(5, CLabel)
	oSummonBox.m_GradeLabel = oSummonBox:NewUI(6, CLabel)
	oSummonBox.m_TypeSprite = oSummonBox:NewUI(7, CSprite)
	oSummonBox.m_FactionIcon = oSummonBox:NewUI(8, CSprite)
	oSummonBox.m_FactionName = oSummonBox:NewUI(9, CLabel)
	oSummonBox.m_TipSprite = oSummonBox:NewUI(10, CSprite)
	oSummonBox.m_UpBtn = oSummonBox:NewUI(12, CButton)
	oSummonBox.m_StartGrid:SetActive(false)
	oSummonBox.m_StartClone:SetActive(false)
	oSummonBox.m_FactionIcon:SetActive(false)
	oSummonBox.m_FactionName:SetActive(false)

	oSummonBox.m_IconSprite:SpriteAvatar(oSummon.model_info.shape)
	-- local quality = (partnerData and partnerData.quality or oSummon.quality) - 1
	-- oSummonBox.m_Quality:SetItemQuality(quality)
	-- local nameStr = oSummon.name == oSummon.basename and oSummon.basename or oSummon.basename.."("..oSummon.name..")"
	oSummonBox.m_NameLabel:SetText(oSummon.name)
	local gradeStr = oSummon.grade .. "级" or ""
	oSummonBox.m_GradeLabel:SetText(gradeStr)
	-- oSummonBox.m_TypeSprite:SetSpriteName(CPartnerBox.typeSprName[oSummon.type])
	-- local schoolInfo = data.schooldata.DATA[oSummon.school]
	-- oSummonBox.m_FactionIcon:SpriteSchool(schoolInfo.icon)
	-- oSummonBox.m_FactionName:SetText(schoolInfo.name)
	if g_JjcCtrl.m_JjcMainSummonid == 0 then
		oSummonBox.m_TipSprite:SetActive(false)
	else
		oSummonBox.m_TipSprite:SetActive(g_JjcCtrl.m_JjcMainSummonid == oSummon.id)
	end
	-- self:SetStart(oSummonBox, partnerData and partnerData.upper or 0)

	oSummonBox.m_UpBtn:AddUIEvent("click", callback(self, "OnClickSelectSummon", oSummon))
	self.m_SummonListBox.m_Grid:AddChild(oSummonBox)
	self.m_SummonListBox.m_Grid:Reposition()
	-- self.m_SummonListBox.m_ScrollView:CullContentLater()
end

function CJjcSingleSelectView.OnSelectHightLight(self, index)
	self.m_SelfZhenfaBox.m_SelectSp:SetActive(false)
	self.m_SummonBox:NewUI(8, CSprite):SetActive(false)
	for k,v in ipairs(self.m_HelpList) do
		v:NewUI(8, CSprite):SetActive(false)
	end

	if index == 1 then
		self.m_SelfZhenfaBox.m_SelectSp:SetActive(true)
	elseif index == 2 then
		self.m_SummonBox:NewUI(8, CSprite):SetActive(true)
	elseif index >= 3 then
		self.m_HelpList[index - 2]:NewUI(8, CSprite):SetActive(true)
	end
end

-----------------以下为点击事件---------------

function CJjcSingleSelectView.OnClickChooseZhenfa(self)
	if g_FormationCtrl:GetCurrentFmt() == 0 then
		netformation.C2GSAllFormationInfo()
	else
		local fmtlist = g_FormationCtrl:GetAllFormationInfo()
		self:SetZhenfaListInfo(fmtlist)
	end
	self.m_ZhenfaListBox:SetActive(true)
	self.m_SummonListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(false)
	self:OnSelectHightLight(1)
end

function CJjcSingleSelectView.OnClickBuddyBox(self, idx)
	if g_JjcCtrl.m_JjcMainBuddyClick then
		if g_JjcCtrl.m_JjcMainBuddyClick == idx then
			self:ResetAllBuddyBox()
		end
	else
		self:SetSelectBuddy(idx)
	end

	local oPartnerList = g_PartnerCtrl:GetPartnerDataList(true)
	if next(oPartnerList) then
		self:SetBuddyListInfo(oPartnerList, idx)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoBuddy].content)
	end
	self.m_ZhenfaListBox:SetActive(false)
	self.m_SummonListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(true)
	self:OnSelectHightLight(idx+2)
end

function CJjcSingleSelectView.OnClickBuddyDown(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	for k,v in ipairs(list) do
		if k == idx then
			table.remove(list, k)
			break
		end
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSingleSelectView.OnClickBuddySwap(self, idx)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	local tempid = idlist[idx]
	idlist[idx] = idlist[g_JjcCtrl.m_JjcMainBuddyClick]
	idlist[g_JjcCtrl.m_JjcMainBuddyClick] = tempid
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSingleSelectView.OnClickAddBuddy(self, idx)
	local oPartnerList = g_PartnerCtrl:GetPartnerDataList(true)
	-- table.print(g_PartnerCtrl:GetPartnerDataList(), "CJjcSingleSelectView.OnClickAddBuddy")
	if next(oPartnerList) then
		self:SetBuddyListInfo(oPartnerList, idx)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoBuddy].content)
	end
	self.m_ZhenfaListBox:SetActive(false)
	self.m_SummonListBox:SetActive(false)
	self.m_BuddyListBox:SetActive(true)
	self:OnSelectHightLight(idx+2)
end

function CJjcSingleSelectView.OnClickSummonBox(self)
	if g_JjcCtrl.m_JjcMainSummonClick then
		self:ResetSummonBox()
	else
		self:SetSelectSummon()
	end

	if next(g_SummonCtrl.m_SummonsSort) then
		self:SetSummonListInfo(g_SummonCtrl.m_SummonsSort)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoSummon].content)
	end
	self.m_ZhenfaListBox:SetActive(false)
	self.m_SummonListBox:SetActive(true)
	self.m_BuddyListBox:SetActive(false)
	self:OnSelectHightLight(2)
end

function CJjcSingleSelectView.OnClickSummonDown(self)
	netjjc.C2GSSetJJCSummon(0)	
end

function CJjcSingleSelectView.OnClickAddSummon(self)
	table.print(g_SummonCtrl.m_SummonsSort, "CJjcSingleSelectView.OnClickAddSummon")
	if next(g_SummonCtrl.m_SummonsSort) then
		self:SetSummonListInfo(g_SummonCtrl.m_SummonsSort)
	else
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoSummon].content)
	end
	self.m_ZhenfaListBox:SetActive(false)
	self.m_SummonListBox:SetActive(true)
	self.m_BuddyListBox:SetActive(false)
	self:OnSelectHightLight(2)
end

function CJjcSingleSelectView.OnClickSelectZhenfa(self, oZhenfa)
	local isNotify = false
	if #self.m_ZhenfaListBox.m_Grid:GetChildList() <= 0 then
		isNotify = true
	elseif #self.m_ZhenfaListBox.m_Grid:GetChildList() == 1 and oZhenfa.fmt_id == 1 then
		isNotify = true
	end
	if isNotify then
		g_NotifyCtrl:FloatMsg(data.jjcdata.TEXT[define.Jjc.Text.NoZhenfa].content)
	end
	-- self.m_ZhenfaListBox:SetActive(false)
	netjjc.C2GSSetJJCFormation(oZhenfa.fmt_id)	
end

function CJjcSingleSelectView.OnClickSelectBuddy(self, oBuddy)
	-- self.m_BuddyListBox:SetActive(false)
	local list = {}
	for k,v in ipairs(g_JjcCtrl.m_JjcMainBuddyList) do
		list[k] = v
	end
	local idlist = {}
	for k,v in ipairs(list) do
		table.insert(idlist, v.id)
	end
	if table.index(idlist, oBuddy.serverid) then
		return
	end
	if #idlist >= 4 then
		g_NotifyCtrl:FloatMsg("上阵伙伴已满，请先下阵伙伴")
		return
	end
	if #idlist <= 3 then
		table.insert(idlist, oBuddy.serverid)
	end
	netjjc.C2GSSetJJCPartner(idlist)
end

function CJjcSingleSelectView.OnClickSelectSummon(self, oSummon)
	-- self.m_SummonListBox:SetActive(false)
	netjjc.C2GSSetJJCSummon(oSummon.id)	
end

return CJjcSingleSelectView