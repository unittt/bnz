local CLingxiPointView = class("CLingxiPointView", CViewBase)

function CLingxiPointView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Lingxi/LingxiPointView.prefab", cb)
	--界面设置
	self.m_DepthType = "Fourth"
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
end

function CLingxiPointView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CBox)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_BgSp = self:NewUI(5, CSprite)
	self.m_ContentObj = self:NewUI(6, CObject)
	self.m_BaseObj = self:NewUI(7, CObject)
	
	self:InitContent()
end

function CLingxiPointView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self:SetPointList()

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CLingxiPointView.SetPointList(self)
	local optionCount = #data.lingxidata.USEPOS
	local GridList = self.m_Grid:GetChildList() or {}
	local oPointBox
	if optionCount > 0 then
		for i=1,optionCount do
			if i > #GridList then
				oPointBox = self.m_BoxClone:Clone(false)
				-- self.m_Grid:AddChild(oOptionBtn)
			else
				oPointBox = GridList[i]
			end
			self:SetPointBox(oPointBox, data.lingxidata.USEPOS[i])
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

	self.m_BgSp:SetHeight(80 + (120* #data.lingxidata.USEPOS/2))

	self.m_Grid:Reposition()
	self.m_ScrollView:ResetPosition()

	if #data.lingxidata.USEPOS <= 2 then
		local oLocalPos1 = self.m_ContentObj:GetLocalPos()
		self.m_ContentObj:SetLocalPos(Vector3.New(oLocalPos1.x, oLocalPos1.y-110, oLocalPos1.z))
		local oLocalPos2 = self.m_BaseObj:GetLocalPos()
		self.m_BaseObj:SetLocalPos(Vector3.New(oLocalPos2.x, oLocalPos2.y-110, oLocalPos2.z))
	end
end

function CLingxiPointView.SetPointBox(self, oPointBox, oData)
	oPointBox:SetActive(true)
	oPointBox.m_IconTex = oPointBox:NewUI(1, CTexture)
	oPointBox.m_PointLbl = oPointBox:NewUI(2, CLabel)
	oPointBox.m_GouSp = oPointBox:NewUI(3, CSprite)
	oPointBox.m_GouSp:SetActive(false)

	local sTextureName = "Texture/Task/h7_map_"..oData.map..".png"
	g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetMapTexture", oPointBox.m_IconTex))

	if oData.id <= #data.lingxidata.USEPOS - 2 then
		oPointBox.m_GouSp:SetActive(true)
	end

	local oMapInfo = DataTools.GetSceneDataByMapId(oData.map)
	oPointBox.m_PointLbl:SetText(oMapInfo.scene_name.."\n("..math.floor(oData.pos_x+0.5)..","..math.floor(oData.pos_y+0.5)..")")

	oPointBox:AddUIEvent("click", callback(self, "OnClickPointBox", oData))

	self.m_Grid:AddChild(oPointBox)
	self.m_Grid:Reposition()
end

function CLingxiPointView.SetMapTexture(self, oTex, prefab, errcode)
	if prefab then
		oTex:SetMainTexture(prefab)
	end
end

function CLingxiPointView.OnClickPointBox(self, oData)
	CItemMainView:CloseView()
	self:CloseView()
	local function onFinish()
		local oItem = g_ItemCtrl:GetBagItemListBySid(11159)[1]
		if oItem and not oItem:IsEquiped() then
			g_ItemCtrl:AddQuickUseData(oItem)
		end
	end
	local oPos = Vector3.New(oData.pos_x, oData.pos_y, 0)
	g_MapTouchCtrl:CrossMapPos(oData.map, oPos, nil, define.Walker.Npc_Talk_Distance, onFinish)
end

return CLingxiPointView