local CItemExtraBox = class("CItemExtraBox", CBox)

function CItemExtraBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_CItem = nil
	self.m_ContentBg = self:NewUI(1, CSprite)
	self.m_ItemBox = self:NewUI(2, CItemBaseBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_IntroductionLabel = self:NewUI(4, CLabel)
	self.m_DescTable = self:NewUI(5, CTable)	
	self.m_DesLabelClone = self:NewUI(6, CLabel)
	self.m_LineClone = self:NewUI(7, CSprite)
end

function CItemExtraBox.SetInitBox(self, citem)
	self.m_CItem = citem
	self:SetItemInfo()
end

function CItemExtraBox.SetItemInfo(self)
	-- self.m_IconSprite:SetAtlas("")
	self.m_ItemBox:SetBagItem(self.m_CItem)
	self.m_ItemBox:SetEnableTouch(false)
	self.m_ItemBox:SetAmountText(0)
	local iQuality = self.m_CItem:GetQuality()
	local textName = string.format(data.colorinfodata.ITEM[iQuality].color, self.m_CItem:GetItemName())
	self.m_NameLabel:SetRichText(textName, nil, nil, true)
	self.m_IntroductionLabel:SetText(self.m_CItem:GetCValueByKey("introduction"))
	self:SetItemInfoList()
	self.m_DescTable:Reposition()
	self:ContentBgReposition(155, 394)
end

function CItemExtraBox.SetItemInfoList(self)
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
		oLabel:SetRichText(des, nil, nil, true)
		oLabel:SetActive(true)
		oLine:SetActive(true)
	end

	local description = self.m_CItem:GetCValueByKey("description")
	if type(description) == "table" then
		for i,v in ipairs(description) do
			createDes(i*2-1, v)
		end
	elseif type(description) == "string" then
		createDes(1, description)
	end
end

function CItemExtraBox.ContentBgReposition(self, bgHeight, bgWidth)
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
	self.m_ContentBg:SetSize(bgWidth, bgHeight + height + Mathf.Abs(vLocalPos.y))
end

return CItemExtraBox