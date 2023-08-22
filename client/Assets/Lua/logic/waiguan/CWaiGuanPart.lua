local CWaiGuanPart = class("CWaiGuanPart", CPageBase)

function CWaiGuanPart.ctor(self, cb)

	CPageBase.ctor(self, cb)
	
end

function CWaiGuanPart.OnInitPage(self)

	 self.m_TagGrid = self:NewUI(1, CGrid)
	 self.m_ClothesGrid = self:NewUI(2, CGrid)
	 self.m_ClothesItem = self:NewUI(3, CClothesBox)
	 self.m_ColorSelectGrid = self:NewUI(4, CGrid)
	 self.m_ColorItem = self:NewUI(5, CColorBox)
	 self.m_RanseBtn = self:NewUI(6, CSprite)
	 self.m_ConsumeItem = self:NewUI(7, CRanseConsumeBox)
	 self.m_StateLabel = self:NewUI(8, CLabel)
	 self.m_TipsBtn = self:NewUI(9,CSprite)
	 self.m_BuyBtn = self:NewUI(10, CSprite)
	 self.m_ActorTexture = self:NewUI(11, CActorTexture)
	 self.m_Name = self:NewUI(12, CLabel)
	 self.m_BtnState = self:NewUI(13, CLabel)
	 self.m_LeftNode = self:NewUI(14, CObject)

	self:InitContent()	
	
end


function CWaiGuanPart.InitContent(self)

	self.m_RanseBtn:AddUIEvent("click", callback(self, "OnClickRanseBtn"))
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnClickBuyBtn"))
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClickTipBtn"))

	g_WaiGuanCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))

	self:GetClotherInfo()

end


function CWaiGuanPart.ChangeClothes(self, id)
	
	if self.m_ActorTexture == nil then 
		return
	end 

end


function CWaiGuanPart.PreViewRanse(self)

	if self.m_CurColorInfo then 

		local ranseInfo = {}

		if self.m_CurColorInfo.isDefault then 
			ranseInfo[define.Ranse.PartType.clothes] = Color.New(1,1,1,1)
			ranseInfo[define.Ranse.PartType.other] = Color.New(1,1,1,1)
			ranseInfo[define.Ranse.PartType.pant] = Color.New(1,1,1,1)
		else
			ranseInfo[define.Ranse.PartType.clothes] = self.m_CurColorInfo.ranseColor[define.Ranse.PartType.clothes]
			ranseInfo[define.Ranse.PartType.other] = self.m_CurColorInfo.ranseColor[define.Ranse.PartType.other]
			ranseInfo[define.Ranse.PartType.pant] = self.m_CurColorInfo.ranseColor[define.Ranse.PartType.pant]
		end 

		self.m_ActorTexture:Ranse(ranseInfo) 

	end 

end

function CWaiGuanPart.PreViewShiZhuang(self)
	
 	local model_info = table.copy(g_AttrCtrl.model_info)
    model_info.rendertexSize = 1.1
    model_info.horse = nil 
    model_info.ranse_shizhuang = self.m_CurColorInfo.id
    model_info.shizhuang = self.m_CurSzInfo.szId
	self.m_ActorTexture:ChangeShape(model_info)

end

function CWaiGuanPart.RefreshShiZhuang(self)

	for k, v in ipairs(self.m_ClothesData) do
		if v.isUse then 
			local model_info = table.copy(g_AttrCtrl.model_info)
			if v.isDefaultSz then
				model_info.rendertexSize = 1.1
				model_info.horse = nil
				model_info.shizhuang = nil
				model_info.ranse_shizhuang = nil
			else	
				model_info.shizhuang = v.szId
				model_info.ranse_shizhuang = v.curColor
				model_info.rendertexSize = 1.1
				model_info.horse = nil 
			end
			self.m_ActorTexture:ChangeShape(model_info)
		end 
	end 

end

function CWaiGuanPart.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.WaiGuan.Event.AllClothesInfo  then 

		self.m_ClothesData = oCtrl.m_EventData

		self:RefreshAllClothes()

		self:SelectUsingSz()

		self:RefreshColorGrid()

		self:SelectUsingColor()
	
		self:RefreshConsumeBox()

		self:RefreshName()

		self:RefreshState()

		self:RefreshShiZhuang()	

	end

	if oCtrl.m_EventID == define.WaiGuan.Event.RefreshClothesInfo then 

		self.m_ClothesData = oCtrl.m_EventData
		self:RefreshAllClothes()
		self:RefreshShiZhuang()	
		self:RefreshColorGrid()
		self:RefreshState()

	end

end

function CWaiGuanPart.OnAttrEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Attr.Event.Change then
		 self:RefreshConsumeBox()
	end 

end

function CWaiGuanPart.RefreshAll(self)
	-- body
end

--请求数据
function CWaiGuanPart.GetClotherInfo(self)
	
	g_WaiGuanCtrl:C2GSGetAllSZInfo()

end

--选中正在使用的时装
function CWaiGuanPart.SelectUsingSz(self)
	
	local index = nil
	for k, v in ipairs(self.m_ClothesData) do 
		if v.isUse then 
			index = k
			self.m_CurSzInfo = v
			break
		end 
	end 

	local item = self.m_ClothesGrid:GetChild(index)

	if item then
		item:ForceSelected(true)
	end

end


--刷新所有衣服
function CWaiGuanPart.RefreshAllClothes(self)

	if self.m_ClothesData == nil then 
		return
	end 

	for k, v in ipairs(self.m_ClothesData) do

		local box = self.m_ClothesGrid:GetChild(k)
		if box == nil then 
			box = self.m_ClothesItem:Clone()
			box:SetActive(true) 
			self.m_ClothesGrid:AddChild(box)
		end

		box:SetInfo(v)

		box:AddUIEvent("click", callback(self, "ClickClothes", v))

	end 
end

function CWaiGuanPart.ClickClothes(self, info)
	
	self.m_CurSzInfo = info

	self:RefreshColorGrid()

	self.m_ColorSelectGrid:SetActive(not info.isDefaultSz)

	self:SelectUsingColor()

	--消耗项
	if info.isDefaultSz then 
		self.m_ConsumeItem:SetActive(false)
		self.m_RanseBtn:SetActive(false)
		self.m_LeftNode:SetActive(false)
	else
		self.m_LeftNode:SetActive(true)
		if self.m_CurColorInfo.isUnLock then 
			self.m_ConsumeItem:SetActive(false)
			self.m_RanseBtn:SetActive(false)
		else
			self.m_ConsumeItem:SetActive(true)
			self.m_RanseBtn:SetActive(true)
		end 

	end 

	self:RefreshName()

	self:RefreshState()

	if info.isUnLock and (not self:IsSzExpired(info)) then 
	    
		g_WaiGuanCtrl:C2GSSetSZ(info.szId)

	else
		self:PreViewShiZhuang()
	end  


end

function CWaiGuanPart.IsSzExpired(self, szInfo)

	if szInfo.isDefaultSz then 
		return false
	end 

	if szInfo.isForever == 1 then 
		return false
	end
	
	local interval = szInfo.time - g_TimeCtrl:GetTimeS()
	if interval <= 0 then 
		return true
	end 

	return false

end

function CWaiGuanPart.SelectUsingColor(self)

	if self.m_CurSzInfo.colorList == nil then
		return
	end 

	local index = nil
	for k, v in ipairs(self.m_CurSzInfo.colorList) do 	
		if v.isUse then 
			index = k
			self.m_CurColorInfo = v
			break
		end 
	end

	for k, item in ipairs(self.m_ColorSelectGrid:GetChildList()) do 
		if k == index then 
			item:ForceSelected(true)
		else
			item:ForceSelected(false)
		end 
	end 

end


--创建颜色格子
function CWaiGuanPart.RefreshColorGrid(self)
	
	if self.m_CurSzInfo.colorList == nil then 
		return
	end 

	self.m_ColorSelectGrid:HideAllChilds()

	for k, v in ipairs(self.m_CurSzInfo.colorList) do

		local box = self.m_ColorSelectGrid:GetChild(k)
		if box == nil then 
			box = self.m_ColorItem:Clone()
			box:SetActive(true) 
			self.m_ColorSelectGrid:AddChild(box)
		end

		box:SetInfo(v)
		box:SetActive(true)
		box:AddUIEvent("click", callback(self, "ClickColor", v))

	end 

end

function CWaiGuanPart.ClickColor(self, info)
	
	self.m_CurColorInfo = info

	if info.isUnLock then 

		if self.m_CurSzInfo.isUnLock and  not(self:IsSzExpired(self.m_CurSzInfo)) then
			g_WaiGuanCtrl:C2GSSetSZColor(self.m_CurSzInfo.szId, info.id)
		end

		self.m_ConsumeItem:SetActive(false)
		self.m_RanseBtn:SetActive(false)

	else

		self.m_ConsumeItem:SetActive(true)
		self.m_RanseBtn:SetActive(true)

	end 

	self:PreViewRanse()
	
	self:RefreshConsumeBox()

end


--刷新消耗
function CWaiGuanPart.RefreshConsumeBox(self)

	if not self.m_CurColorInfo  or not self.m_CurColorInfo.consume  then
		return
	end 

	local consumeInfo = {}
	consumeInfo.id = self.m_CurColorInfo.consume.id
    consumeInfo.iconId = DataTools.GetItemData(self.m_CurColorInfo.consume.id, "OTHER").icon
    consumeInfo.needCount = self.m_CurColorInfo.consume.count
    consumeInfo.hadCount =  g_ItemCtrl:GetBagItemAmountBySid(self.m_CurColorInfo.consume.id)
	self.m_ConsumeItem:SetInfo(consumeInfo)

end

--刷新解锁状态
function CWaiGuanPart.RefreshState(self)

	if self.m_CurSzInfo == nil then 
		return
	end 

	if self.m_CurSzInfo.isDefaultSz then 

		self.m_StateLabel:SetText("永久")
		g_TimeCtrl:DelTimer(self)

	else
		
		self.m_StateLabel:SetActive(true)
		if self.m_CurSzInfo.isUnLock then 

			if self.m_CurSzInfo.isForever > 0 then 
				self.m_StateLabel:SetText("永久")
				g_TimeCtrl:DelTimer(self)

			else 

				local leftTime = self.m_CurSzInfo.time - g_TimeCtrl:GetTimeS()

				local cb = function (time)
		        
			        if not time then 
			            self.m_StateLabel:SetText("过期")
			        else
			            self.m_StateLabel:SetText(time)
			        end 

		    	end

		    	g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)

			end 

		else
			self.m_StateLabel:SetText("未解锁")
			self.m_BtnState:SetText("解锁")
			g_TimeCtrl:DelTimer(self)
		end 

	end


end

function CWaiGuanPart.RefreshName(self)
	
	self.m_Name:SetText(self.m_CurSzInfo.name)

end

function CWaiGuanPart.OnClickRanseBtn(self)

	self:JudgeLackItem()
	if g_QuickGetCtrl.m_IsLackItem then
		return
	end

	local windowConfirmInfo = {
        msg = "确定解锁此颜色，并且应用此颜色？",
        title = "染色",
        okCallback = function ()

            g_WaiGuanCtrl:C2GSSZRanse(self.m_CurSzInfo.szId, self.m_CurColorInfo.id)

        end,
        cancelCallback = function ()
        end,
    }

    
    g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo, function (oView)
       --todo
    end)

end

function CWaiGuanPart.JudgeLackItem(self)

	local itemlist ={}
	local data = self.m_ConsumeItem.m_consumeInfo
 	if data.hadCount <data.needCount then
 		local t = {sid = data.id, count = data.hadCount, amount = data.needCount}
 		table.insert(itemlist, t)
 	end
	g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
    	g_WaiGuanCtrl:C2GSSZRanse(self.m_CurSzInfo.szId, self.m_CurColorInfo.id, 1)
	end)
end

function CWaiGuanPart.OnClickTipBtn(self)
	
	local id = define.Instruction.Config.WaiGuan
    if data.instructiondata.DESC[id] ~= nil then 

        local content = {
            title = data.instructiondata.DESC[id].title,
            desc  = data.instructiondata.DESC[id].desc
        }

        g_WindowTipCtrl:SetWindowInstructionInfo(content)

    end 

end

function CWaiGuanPart.OnClickBuyBtn(self)
	
	if self.m_CurSzInfo  == nil then 
		 g_NotifyCtrl:FloatMsg("请先选择时装！")   
		return
	end 

	if self.m_CurSzInfo.isDefaultSz or  self.m_CurSzInfo.isForever > 0 then 
		 g_NotifyCtrl:FloatMsg("该时装已经永久拥有！")  
		 return
	end 


	CClothesBuyView:ShowView(function (oView)
		oView:SetInfo(self.m_CurSzInfo, self.m_CurColorInfo)
	end)

end


return CWaiGuanPart