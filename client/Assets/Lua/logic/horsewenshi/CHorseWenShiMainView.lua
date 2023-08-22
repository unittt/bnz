local CHorseWenShiMainView = class("CHorseWenShiMainView", CViewBase)

function CHorseWenShiMainView.ctor(self, cb)

	CViewBase.ctor(self, "UI/Horse/WenShiMainView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"

end

function CHorseWenShiMainView.OnCreateView(self)

	self.m_TabBtnGrid = self:NewUI(1, CTabGrid)
    self.m_CloseBtn = self:NewUI(2, CButton)
    self.m_FusionPart = self:NewPage(3, CWenShiFusionPart)
    self.m_WashPart = self:NewPage(4, CWenShiWashPart)
   -- self.m_UpgradePart = self:NewPage(5, CHorseUpgradePart)

	--g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	--g_OpenSysCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSysOpenEvent"))

    self:InitContent()

end

function CHorseWenShiMainView.InitContent(self)
	--self.m_EmptyHint:SetActive(false)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	-- 分页按钮
	local function init(obj, idx)
		local oBtn = CButton.New(obj, false, false)
		oBtn:SetGroup(self.m_TabBtnGrid:GetInstanceID())
		return oBtn
	end
	self.m_TabBtnGrid:InitChild(init)
	self.m_PartInfoList = {
		{title = "融合", part = self.m_FusionPart, icon = "h7_zuoqishuxing"},
		{title = "洗练", part = self.m_WashPart, icon = "h7_zuoqishengji"},
	}
	for i,v in ipairs(self.m_PartInfoList) do

		v.btn = self.m_TabBtnGrid:GetChild(i)
		v.btn:AddUIEvent("click", callback(self, "ShowSubPageByIndex", i))
		v.btn:SetActive(true)

	end
    self:ShowSubPageByIndex(1)
    self.m_TabBtnGrid:GetChild(1):SetSelected(true)

    -- self:CheckSystemOpen()
    -- g_SysUIEffCtrl:DelSysEff("RIDE_SYS")
end

function CHorseWenShiMainView.CheckSystemOpen(self)
	
	for k, v in ipairs(self.m_TabBtnGrid:GetChildList()) do 

		if k == 2 then 
			if g_OpenSysCtrl.m_SysOpenList[define.System.RideUpgrade] then 
				v:SetActive(true)
			else
				v:SetActive(false)
			end 
		end 
		
	end 

	self.m_TabBtnGrid:Reposition()

end

function CHorseWenShiMainView.OnSysOpenEvent(self, oCtrl)
	
	if oCtrl.m_EventID == define.SysOpen.Event.Change then
		self:CheckSystemOpen()
	end

end


function CHorseWenShiMainView.OnAttrEvent(self, oCtrl)

    if oCtrl.m_EventID == define.Attr.Event.Change then
       self:CheckSystemOpen()
    end

end

function CHorseWenShiMainView.ShowSubPageByIndex(self, tabIndex)

	local id = g_HorseCtrl:GetHorseSortIdByIdx(1)
	if id == nil and (tabIndex == 1 or tabIndex == 2) then
		--self.m_EmptyHint:SetActive(true)
		-- self.m_AttrPart:SetActive(false)
		-- self.m_UpgradePart:SetActive(false)
		-- self.m_DetailPart:SetActive(false)
		return
	else
		--self.m_EmptyHint:SetActive(false)
	end
	self.m_TabBtnGrid:GetChild(tabIndex):SetSelected(true)
	local args = self.m_PartInfoList[tabIndex]
	--self.m_Title:SetSpriteName(args.icon)
	CGameObjContainer.ShowSubPageByIndex(self, tabIndex)
end


function CHorseWenShiMainView.ShowSpecificPart(self, tabIndex)
	if not tabIndex then
		tabIndex = 1
	end
	self:ShowSubPageByIndex(tabIndex)
end

function CHorseWenShiMainView.OpenWashPart(self, id)
	
	self:ShowSpecificPart(2)
	self.m_WashPart:ForceSelectWenShiItem(id)

end

function CHorseWenShiMainView.OpenFusionPart(self, id)
	
	self:ShowSpecificPart(1)
	self.m_FusionPart:SelectMainWenShi(id)

end

function CHorseWenShiMainView.CloseView(self)
	CViewBase.CloseView(self)
end

return CHorseWenShiMainView