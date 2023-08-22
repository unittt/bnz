local CItemWHTipsMainBox = class("CItemWHTipsMainBox", CBox)

function CItemWHTipsMainBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_CallBack = cb
	self.m_CItem = nil

	self.m_MainContenBg = self:NewUI(1, CSprite)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_IntroductionLabel = self:NewUI(4, CLabel)
	self.m_DesLabelClone = self:NewUI(5, CLabel)
	self.m_DescTable = self:NewUI(6, CTable)
	self.m_CenterBtn = self:NewUI(7, CButton)
	self.m_LineClone = self:NewUI(8, CSprite)
	self.m_QualitySprite = self:NewUI(9, CSprite)
	self.m_PersonalSpr = self:NewUI(10,	CSprite)
	self.m_StallFlagSpr = self:NewUI(11, CSprite)
end

function CItemWHTipsMainBox.SetInitBox(self, citem, btntype)
	self.BtnNameList = {
		[define.Item.CellType.BagCell] = "存入仓库",
		[define.Item.CellType.WHCell] = "取回包裹",
	}
	self.m_CItem = citem
	self.m_BtnType = btntype
	self.m_CenterBtn:AddUIEvent("click", callback(self, "CallBack"))
end

function CItemWHTipsMainBox.SetItemInfo(self)
	self.m_IconSprite:SpriteItemShape(self.m_CItem:GetCValueByKey("icon"))
	local quality = self.m_CItem:GetQuality()
	local textName = string.format(data.colorinfodata.ITEM[quality].color, self.m_CItem:GetItemName())
	self.m_NameLabel:SetRichText(textName, nil, nil, true)
	self.m_IntroductionLabel:SetText(self.m_CItem:GetCValueByKey("introduction"))
	self.m_CenterBtn:SetText(self.BtnNameList[self.m_BtnType])
	self.m_QualitySprite:SetItemQuality(quality)
	self.m_PersonalSpr:SetActive(self.m_CItem:IsBinding())
	self.m_StallFlagSpr:SetActive(self.m_CItem:IsGainByStall())
end

function CItemWHTipsMainBox.OnShowBox(self)
	self:SetItemInfo()
	self:SetItemInfoList()
	self.m_DescTable:Reposition()
	self:ContentBgReposition(240, 394)
	self.m_CenterBtn:ResetAndUpdateAnchors()
end

function CItemWHTipsMainBox.SetItemInfoList(self)
	local tableList = self.m_DescTable:GetChildList()

	local function createDes(index, des)
		local oLabel = nil
		local oLine = nil
		if index > #tableList then
			oLabel = self.m_DesLabelClone:Clone()
			oLine = self.m_LineClone:Clone()
			self.m_DescTable:AddChild(oLabel)
			self.m_DescTable:AddChild(oLine)
		else	
			oLabel = tableList[index]
			oLine = tableList[index + 1]
		end
		--对一些description进行特殊处理，如根据宝图item数据设置地图坐标描述
		local function SetLabel(sText)
			local itemsid = self.m_CItem:GetSValueByKey("sid")
			if itemsid == define.Treasure.Config.Item5 or itemsid == define.Treasure.Config.Item4 then
				local treasureInfo = g_ItemViewCtrl:GetTreasureInfo(self.m_CItem)
				local sInfo = DataTools.GetSceneNameByMapId(treasureInfo.treasure_mapid)
				oLabel:SetRichText(string.format(sText,sInfo), nil, nil, true)
			else
				oLabel:SetRichText(sText.."[-]", nil, nil, true)
			end
		end
		SetLabel(des)
		oLabel:SetActive(true)
		oLine:SetActive(true)
	end

	local description = self.m_CItem:GetCValueByKey("description")
	local itemsid = self.m_CItem:GetSValueByKey("sid")
	if (itemsid >= 10046 and itemsid <=10050) or (itemsid >= 10058 and itemsid <= 10064) then

	    local effectDes = "#G"..g_ItemViewCtrl:ShowDragDes(self.m_CItem)
		local str1 = string.sub(effectDes, 1, string.find(effectDes, ",")-1)
		local str2 = string.sub(effectDes, string.find(effectDes, "\n"), -1)
		local effDes = str1..str2  --不显示类型部分的说明
       description = {effDes, description}

	end
	if type(description) == "table" then
		for i,v in ipairs(description) do
			createDes(i*2-1,v)
		end
	elseif type(description) == "string" then
		createDes(1, self:GetItemDesc())
	end
end

function CItemWHTipsMainBox.GetItemDesc(self)
	local sDesc = self.m_CItem:GetCValueByKey("description")
	if self.m_CItem:IsGemStone() then
		local list = self.m_CItem:GetGemStoneAttr()
		if not list then
			return sDesc
		end
		local sAttr = "[8FF2E2]宝石属性[-]\n"
		for i,dAttr in ipairs(list) do
			sAttr = string.format("%s  [c8fff1]%s +%d[-]    ", sAttr, dAttr.attrname, dAttr.value)
		end
		sDesc = sAttr.."\n\n"..sDesc
	end
	return sDesc
end

function CItemWHTipsMainBox.ContentBgReposition(self, bgHeight, bgWidth)
	local tList = self.m_DescTable:GetChildList()
	local oLastChild = tList[#tList]
	local vLocalPos, width, height
	if oLastChild ~= nil then
		vLocalPos = oLastChild:GetLocalPos()
		width,height = oLastChild:GetSize()
	else
		vLocalPos = Vector3.New(0, 0, 0) 
		height = 0
	end
	self.m_MainContenBg:SetSize(bgWidth, bgHeight + height + Mathf.Abs(vLocalPos.y))
end

function CItemWHTipsMainBox.CallBack(self)
	if self.m_BtnType == define.Item.CellType.BagCell then
		self:PutInStore()
	elseif self.m_BtnType == define.Item.CellType.WHCell then
		self:PutInBackBox()
	end
end

--存入仓库
function CItemWHTipsMainBox.PutInStore(self)
	self:CloseCallBack()
	g_ItemCtrl.C2GSWareHouseWithStore(g_ItemCtrl.m_RecordWHIndex, self.m_CItem:GetSValueByKey("id"))
end

--从仓库取出
function CItemWHTipsMainBox.PutInBackBox(self)
	self:CloseCallBack()
	g_ItemCtrl.C2GSWareHouseWithDraw(g_ItemCtrl.m_RecordWHIndex, self.m_CItem:GetSValueByKey("pos"))
end

function CItemWHTipsMainBox.CloseCallBack(self)
	if self.m_CallBack ~= nil then
		self.m_CallBack()
	end
end

return CItemWHTipsMainBox