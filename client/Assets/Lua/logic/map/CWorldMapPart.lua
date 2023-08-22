local CWorldMapPart = class("CWorldMapPart", CPageBase)

function CWorldMapPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CWorldMapPart.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SwitchBtn = self:NewUI(2, CButton)
	self.m_PlayerIcon = self:NewUI(3, CSprite)
	self.m_CitysGrid = self:NewUI(4, CGrid)
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchMapBtn"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	
	self.m_PlayerIconOffset = Vector3.New(-8, 40, 0)
	self:InitWorldMapView()
	self.m_MapLock = false
end

function CWorldMapPart.OnClose(self)
	self.m_ParentView:CloseView()
end

function CWorldMapPart.OnSwitchMapBtn(self)
	self.m_ParentView:ShowMapSpecificPart(2, true)
end

function CWorldMapPart.OnMapEvent(self, oCtrl)
	self:ResetPlayerPos()
end

function CWorldMapPart.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData then
			if oCtrl.m_EventData.dAttr.icon ~= oCtrl.m_EventData.dPreAttr.icon then
				self:ResetPlayerIcon()
			end
		end
	end
end

-- InitViwe
function CWorldMapPart.InitWorldMapView(self)
	self:InitCityBtn()
	self:ResetPlayerPos()
	self:ResetPlayerIcon()
end

function CWorldMapPart.InitCityBtn(self)
	local function initCity(obj, index)
		local oCityBtn = CButton.New(obj)
		local mapID = tonumber(string.split(oCityBtn:GetName(), '%_')[2])
		if not mapID then
			printerror("地图命名格式错误")
		end
		if not CMapMainView.cityDataDic[mapID] then
			CMapMainView.cityDataDic[mapID] = {id = mapID, pos = oCityBtn:GetLocalPos()}
		end

		oCityBtn:SetGroup(self.m_CitysGrid:GetInstanceID())
		oCityBtn:AddUIEvent("click", function ()
			if self.m_MapLock then
				return
			end
			self.m_MapLock = true

			local function delay()
				self.m_MapLock = false
				if g_MapCtrl:IsInOrgMatchMap() then
					g_NotifyCtrl:FloatMsg("此场景插翅难飞")
					return
				end
				g_MapCtrl:C2GSClickWorldMap(mapID)
				self.m_ParentView:CloseView()
				return false
			end
			Utils.AddTimer(delay, 0.05, 0.4)
		end)
		return oCityBtn
	end
	self.m_CitysGrid:InitChild(initCity)
end

function CWorldMapPart.ResetPlayerPos(self)
	local curMapID = g_MapCtrl:GetMapID()
	local mapInfo = self.m_ParentView:GetCityData(curMapID)
	local vPos = mapInfo.pos + self.m_PlayerIconOffset
	self.m_PlayerIcon:SetLocalPos(vPos)
end

function CWorldMapPart.ResetPlayerIcon(self)
	self.m_PlayerIcon:SpriteAvatar(g_AttrCtrl.icon)
end

function CWorldMapPart.SetPos(self, obj, index)
	local vPos = pos[index]
	if vPos then
		obj:SetLocalPos(Vector3.New(vPos.x, vPos.y, vPos.z))
	end
end

return CWorldMapPart