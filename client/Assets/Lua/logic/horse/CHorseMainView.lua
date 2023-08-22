local CHorseMainView = class("CHorseMainView", CViewBase)
function CHorseMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseMainView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHorseMainView.OnCreateView(self)
	self.m_TabBtnGrid = self:NewUI(1, CTabGrid)
    self.m_CloseBtn = self:NewUI(2, CButton)
    self.m_AttrPart = self:NewPage(3, CHorseAttrPart)
    self.m_Title = self:NewUI(4, CSprite)
    self.m_UpgradePart = self:NewPage(5, CHorseUpgradePart)
    self.m_DetailPart = self:NewPage(6, CHorseDetailPart)
	self.m_EmptyHint = self:NewUI(7, CLabel)
	self.m_TongYuPart = self:NewPage(8, CHorseTongYuPart)

	g_GuideCtrl:AddGuideUI("horseview_close_btn", self.m_CloseBtn)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSysOpenEvent"))

    self:InitContent()
end

function CHorseMainView.InitContent(self)
	self.m_EmptyHint:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- 分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)
	self.m_PartInfoList = {
		{title = "坐骑属性", part = self.m_AttrPart, icon = "h7_zuoqishuxing"},
		{title = "坐骑升级", part = self.m_UpgradePart, icon = "h7_zuoqishengji"},
		{title = "坐骑图鉴", part = self.m_DetailPart, icon = "h7_zuoqitujian"},
		{title = "坐骑统御", part = self.m_TongYuPart, icon = "h7_zuoqitongyu"},
	}
	for i,v in ipairs(self.m_PartInfoList) do

		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
		v.btn:SetActive(true)

	end
    self:ShowSubPageByIndex(1)
    self.m_TabBtnGrid:GetChild(1):SetSelected(true)
    self.m_CurSelectIndex = 1

    self:CheckSystemOpen()
    g_SysUIEffCtrl:DelSysEff("RIDE_SYS")
end

function CHorseMainView.CheckSystemOpen(self)
	
	for k, v in ipairs(self.m_TabBtnGrid:GetChildList()) do 
		--升级按钮
		if k == 2 then
			if g_OpenSysCtrl:GetOpenSysState(define.System.RideUpgrade) then 
				v:SetActive(true)
			else
				v:SetActive(false)
			end 
		end 
		--统御按钮
		if k == 4 then 
			if g_OpenSysCtrl:GetOpenSysState(define.System.RideTongYu) then 
				v:SetActive(true)
			else
				v:SetActive(false)
			end
		end 
	end 

	self.m_TabBtnGrid:Reposition()

end

function CHorseMainView.OnSysOpenEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:CheckSystemOpen()
	end

end


function CHorseMainView.OnAttrEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Attr.Event.Change then
       self:CheckSystemOpen()
    end

end

function CHorseMainView.ShowSubPageByIndex(self, tabIndex)

	if not g_HorseCtrl:IsHadHorse() then
		if (tabIndex == 1) or (tabIndex == 2) or (tabIndex == 4) then 
			self.m_EmptyHint:SetActive(true)
			self.m_AttrPart:SetActive(false)
			self.m_UpgradePart:SetActive(false)
			self.m_DetailPart:SetActive(false)
			self.m_TongYuPart:SetActive(false)
		else
			self.m_EmptyHint:SetActive(false)
			self.m_TabBtnGrid:GetChild(tabIndex):SetSelected(true)
			local args = self.m_PartInfoList[tabIndex]
			self.m_Title:SetSpriteName(args.icon)
			CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
		end
		self.m_CurSelectIndex = tabIndex  
	else
		self.m_TabBtnGrid:GetChild(tabIndex):SetSelected(true)
		local args = self.m_PartInfoList[tabIndex]
		self.m_Title:SetSpriteName(args.icon)
		self.m_CurSelectIndex = tabIndex	
		CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
	end 

end


function CHorseMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex then
		tabIndex = 1
	end
	self:ShowSubPageByIndex(tabIndex)
end

function CHorseMainView.ChooseDetailPartHorse(self, id)
	self.m_DetailPart:ChooseHorse(id)
end

function CHorseMainView.CloseView(self)

	CViewBase.CloseView(self)
	g_HorseCtrl:SetCurSelHorseId()
	
end

function CHorseMainView.OnShowView(self)
	
	CViewBase.OnShowView(self)
	self.m_TongYuPart:ClearSelectEffect()

end

return CHorseMainView