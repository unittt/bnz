local CItemSetAttrView = class("CItemSetAttrView", CViewBase)

function CItemSetAttrView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemSetAttrView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
end

function CItemSetAttrView.OnCreateView(self)
	self.m_CurLvL = self:NewUI(1, CLabel)
	self.m_NextLvL = self:NewUI(2, CLabel)
	self.m_CurAttrTable = self:NewUI(3, CTable)
	self.m_NextAttrTable = self:NewUI(4, CTable)
	self.m_CurAttrLClone = self:NewUI(5, CLabel)
	self.m_NextAttrLClone = self:NewUI(6, CLabel)
	self.m_UpgradeL = self:NewUI(7, CLabel)
	self.m_StrengthBtn = self:NewUI(8, CButton)
	self.m_BgSpr = self:NewUI(9, CSprite)

	self:InitContent()
end

function CItemSetAttrView.InitContent(self)
	self.m_CurAttrLClone:SetActive(false)
	self.m_NextAttrLClone:SetActive(false)
	self.m_StrengthBtn:SetActive(g_OpenSysCtrl:GetOpenSysState(define.System.Forge))
	self.m_StrengthBtn:AddUIEvent("click", callback(self, "OnClickStrengthen"))
	g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
	self:InitMasterInfo()
end

function CItemSetAttrView.InitMasterInfo(self)
	self.m_MasterInfo = g_ItemCtrl:GetStrengthMasterInfo()
	self:RefreshAll()
end

function CItemSetAttrView.RefreshAll(self)
	local iCurLv = self.m_MasterInfo.data and self.m_MasterInfo.data.all_strength_level or 0
	local iNextLv = self.m_MasterInfo.nextdata and self.m_MasterInfo.nextdata.all_strength_level or 0
	local sText = string.format("当前强化%d级装备%d/6", iNextLv, self.m_MasterInfo.upgradeneed)
	self.m_UpgradeL:SetText(sText)
	self:RefreshAttrTable(self.m_CurLvL, self.m_CurAttrTable, self.m_CurAttrLClone, self.m_MasterInfo.data, iCurLv)
	self:RefreshAttrTable(self.m_NextLvL, self.m_NextAttrTable, self.m_NextAttrLClone, self.m_MasterInfo.nextdata, iNextLv)
end

function CItemSetAttrView.RefreshAttrTable(self, oLvL, oTable, oCloneL, dData, iLv)
	oLvL:SetText(iLv.."级")
	oTable:Clear()
	local dAttrData = data.attrnamedata.DATA
	if dData then
		local func = loadstring("return "..dData.strength_effect)
		local attrDict = func()
		for k,v in pairs(attrDict) do
			local oLabel = oCloneL:Clone()
			oLabel:SetActive(true)
			oLabel:SetText(dAttrData[k].name.."+"..v)
			oTable:AddChild(oLabel)
		end
		oTable:Reposition()
	end 
end

function CItemSetAttrView.HideButton(self)
	self.m_StrengthBtn:SetActive(false)
	local w,h = self.m_BgSpr:GetSize()
	self.m_BgSpr:SetSize(w, 330)
end

function CItemSetAttrView.OnClickStrengthen(self)
	CForgeMainView:ShowView(
		function(oView)
			oView:ShowSubPageByIndex(oView:GetPageIndex("Strengthen"))
		end
	)
	self:CloseView()
end

return CItemSetAttrView