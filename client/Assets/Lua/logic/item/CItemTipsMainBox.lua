local CItemTipsMainBox = class("CMainViewPart", CBox)

function CItemTipsMainBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_Callback = cb
	self.m_CItem = nil
	self.m_ContentBg = self:NewUI(1, CSprite)
	self.m_ItemBox = self:NewUI(2, CItemBaseBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_IntroductionLabel = self:NewUI(4, CLabel)
	self.m_DesLabelClone = self:NewUI(5, CLabel)
	self.m_DescTable = self:NewUI(6, CTable)
	self.m_LineClone = self:NewUI(7, CSprite)
	self.m_BtnNode = self:NewUI(8, CWidget)
	self.m_BtnBox = self:NewUI(9, CItemButtonBox, true, function()
		CItemTipsView:CloseView()
	end)
	self.m_TempBagBtn =self:NewUI(10,CButton)
	self.m_PersonalSpr = self:NewUI(11, CSprite)
	self.m_CurrencySpr = self:NewUI(12, CSprite)
	self.m_StallFlagSpr = self:NewUI(13, CSprite)

	self.m_TempBagBtn:SetActive(false)
	self.m_PersonalSpr:SetActive(false)

end
--临时背包=============================
function CItemTipsMainBox.SetItemTips(self, oItem)
	self.m_CItem = oItem
	self.m_TempBagBtn:SetActive(true)
	self.m_TempBagBtn:AddUIEvent("click",callback(self,"OnClickSendMsg",oItem))
	self:SetItemInfo()
	self:SetItemInfoList()
	self.m_DescTable:Reposition()
	self:ContentBgReposition(240, 394)
end

function CItemTipsMainBox.OnClickSendMsg(self, oItem)
	nettempitem.C2GSTranToItemBag(oItem.m_ID)
end
--=======================================================
function CItemTipsMainBox.SetInitBox(self, citem, hitExtend)
	self.m_CItem = citem
	self.m_PersonalSpr:SetActive(citem:IsBinding())
	self.m_StallFlagSpr:SetActive(citem:IsGainByStall())
	self:SetItemInfo()
	if self.m_BtnBox:GetActive() then
		self.m_BtnBox:SetInitBox(citem)
		self.m_BtnBox:SetParentNode(self.m_BtnNode)
	end
	self:OnShowBox(hitExtend)
end

function CItemTipsMainBox.SetItemInfo(self)
	self.m_ItemBox:SetBagItem(self.m_CItem)
	self.m_ItemBox:SetEnableTouch(false)
	self.m_ItemBox:SetAmountText(0)
	local quality = self.m_CItem:GetQuality()
	local sName = self.m_CItem:GetItemName()
	local textName = string.format(data.colorinfodata.ITEM[quality].color, sName)
	self.m_NameLabel:SetRichText(textName, nil, nil, true)
	local introduction = string.gsub(self.m_CItem:GetCValueByKey("introduction"), "；", ",")  --分号替换为英文逗号
	self.m_IntroductionLabel:SetText(introduction)
	self:SetLocalPos(Vector3.New(-235, 184, 0))
end

function CItemTipsMainBox.OnShowBox(self, hitExtend)
	self:SetItemInfoList(hitExtend)
	self:CreateSalePrice()
	self.m_DescTable:Reposition()
	self:ContentBgReposition(240, 394)
end

function CItemTipsMainBox.SetItemInfoList(self, hitExtend)
	self.m_DescTable:Clear()
	local tableList = self.m_DescTable:GetChildList()
	local function createDes(index,des)
		local itemDes = nil
  		local oline = nil 
 		if index > #tableList then
 			itemDes = self.m_DesLabelClone:Clone()
 			oline = self.m_LineClone:Clone()
 			self.m_DescTable:AddChild(itemDes)
 			self.m_DescTable:AddChild(oline)
 		else
 			itemDes = tableList[index]
 			oline = tableList[index+1]
 		end

		--对一些description进行特殊处理，如根据宝图item数据设置地图坐标描述
		local function SetLabel(sText)
			local itemsid = self.m_CItem:GetSValueByKey("sid")
			if itemsid == define.Treasure.Config.Item5 or itemsid == define.Treasure.Config.Item4 then
				local treasureInfo = g_ItemViewCtrl:GetTreasureInfo(self.m_CItem)
				local sInfo = DataTools.GetSceneNameByMapId(treasureInfo.treasure_mapid)
				itemDes:SetRichText(string.format(sText,sInfo), nil, nil, true)
			else
				itemDes:SetRichText(sText.."[-]", nil, nil, true)
			end
		end
		SetLabel(des)
		itemDes:SetActive(true)
		oline:SetActive(true)
	end
    --table.print(self.m_CItem.m_SData,"物品信息：")
	local description = g_ItemCtrl:GetItemDesc(self.m_CItem.m_SID, self.m_CItem)--self.m_CItem:GetCValueByKey("description")
	local itemsid = self.m_CItem:GetSValueByKey("sid")
	
	--根据策划要求，宠物增加寿命的item显示面板不能有品质信息，而包裹面板里要显示item的品质信息
	if (itemsid >= 10046 and itemsid <=10050 ) or (itemsid >= 10058 and itemsid <= 10064) then
		if not hitExtend then
			local effectDes = "#G"..g_ItemViewCtrl:ShowDragDes(self.m_CItem)
			local str1 = string.sub(effectDes, 1, string.find(effectDes, ",")-1)
			local str2 = string.sub(effectDes, string.find(effectDes, "\n"), -1)
			local effDes = str1..str2  --不显示类型部分的说明
			description = {effDes,description}
		end
	end

	local oFuZhuan = g_SkillCtrl:GetFuZhuanDesc(self.m_CItem)
	if oFuZhuan then
		description = oFuZhuan
	end

    if type(description) == "table" then 
   		for i,v in ipairs(description) do 
			createDes(i*2-1, v)
   		end
   	elseif type(description) =="string" then
   		createDes(1,self:GetItemDesc())
    end 
end

function CItemTipsMainBox.GetItemDesc(self)
	local sDesc = g_ItemCtrl:GetItemDesc(self.m_CItem.m_SID, self.m_CItem)
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

function CItemTipsMainBox.CreateSalePrice(self)
	local iBuyPrice = self.m_CItem:GetSValueByKey("guild_buy_price")
	if not iBuyPrice or iBuyPrice == 0 then
		return
	end
	local oLabel = self.m_DesLabelClone:Clone()
	local oLine = self.m_LineClone:Clone()
	local oCurrency = self.m_CurrencySpr:Clone()

	oCurrency:SetActive(true)
	oCurrency:SetParent(oLabel.m_Transform)
	oCurrency:SetLocalPos(Vector3.New(105, 0, 0))
	oLabel:SetText("购买价格：  "..iBuyPrice)
	oLabel:SetActive(true)
	oLine:SetActive(true)
	self.m_DescTable:AddChild(oLabel)
	self.m_DescTable:AddChild(oLine)
end

function CItemTipsMainBox.ContentBgReposition(self, bgHeight, bgWidth)
	local tableList = self.m_DescTable:GetChildList()
	local oLastChild = tableList[#tableList]
	local vLocalPos = Vector3.zero
	local height = 0
	if oLastChild then
		vLocalPos = oLastChild:GetLocalPos()
		local _, h = oLastChild:GetSize()
		height = h
	end
	self.m_ContentBg:SetSize(bgWidth, bgHeight + height + Mathf.Abs(vLocalPos.y))
end

--显示获取途径按钮
function CItemTipsMainBox.ShowGainWayBtn(self)
	self.m_BtnBox:SetCenterButton("获得途径", callback(self, "OnGainWayBtnCB"))
	self.m_BtnBox:ShowCenterBtn(true)
end

function CItemTipsMainBox.OnGainWayBtnCB(self)
	local oView = CItemTipsView:GetView()
	if oView then
		oView:OpenGainWayView()
	end
end

function CItemTipsMainBox.HideButton(self)
	self.m_BtnNode:SetAnchor("bottomAnchor",0, 0)
	self.m_BtnBox:SetActive(false)
	local w,h = self:GetSize()
	h = h - 50 
	self:SetSize(w, h)
end

return CItemTipsMainBox