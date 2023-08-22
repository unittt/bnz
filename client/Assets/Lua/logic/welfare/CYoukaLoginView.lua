local CYoukaLoginView = class("CYoukaLoginView", CViewBase)

function CYoukaLoginView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/YoukaLoginView.prefab", cb)
	-- self.m_DepthType = "Fourth"
	self.m_ExtendClose = "Shelter"
    self.m_GroupName = "main"
    self.m_RewardTypeDes = {}
end

function CYoukaLoginView.OnCreateView(self)
	-- body
	self.m_TipSpr = self:NewUI(1, CSprite)
	self.m_DesSpr = self:NewUI(2, CSprite)
	self.m_PowSpr = self:NewUI(3, CSprite)
	self.m_DayGrid = self:NewUI(4, CGrid)
	self.m_RewardCell = self:NewUI(5, CBox)
	self.m_CloseBtn = self:NewUI(6, CButton)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshUI"))

	g_GuideCtrl:AddGuideUI("youkaview_close_btn", self.m_CloseBtn)

	self:InitContent()
end

function CYoukaLoginView.InitContent(self)
	if  not next (g_WelfareCtrl.m_ColorfulData) then
		self:CloseView()
		return
	end
	local index = 0
	local len = table.count(g_WelfareCtrl.m_ColorfulData)
	for k,v in pairs(g_WelfareCtrl.m_ColorfulData) do
		if v.val == 1 or v.val == 2 then
			if tonumber(string.sub(v.key,string.len(v.key),string.len(v.key)))> index then
				local temp  = tonumber(string.sub(v.key,string.len(v.key),string.len(v.key)))
				if temp>index then
					index = temp
				end
			end
		end
	end
	local YoukaReward = table.copy(data.welfaredata.LOGIN)
	local RewardListDic = table.copy(data.rewarddata.WELFARE)
	local daylist =  self.m_DayGrid:GetChildList()
	if index == 1 then
		self.m_TipSpr:SetLocalPos(Vector3.New(-155, 18, 0))
		self.m_DesSpr:SetLocalPos(Vector3.New(-22.7, -28, 0))
		self.m_PowSpr:SetLocalPos(Vector3.New(181.7, -30, 0))
	elseif index == 2 then
		self.m_TipSpr:SetLocalPos(Vector3.New(-155, 11.4, 0))
		self.m_DesSpr:SetLocalPos(Vector3.New(-90.1, -28, 0))
		self.m_PowSpr:SetLocalPos(Vector3.New(182, -30, 0))
	else 
		self.m_TipSpr:SetLocalPos(Vector3.New(-137.9, 11, 0))
		self.m_DesSpr:SetLocalPos(Vector3.New(-47.1, -28, 0))
		self.m_PowSpr:SetLocalPos(Vector3.New(153.2, -30, 0))
	end

	self.m_TipSpr:SetSpriteName(YoukaReward["login_gift_"..index].daydes)
	self.m_DesSpr:SetSpriteName(YoukaReward["login_gift_"..index].rewarddes)
	self.m_PowSpr:SetSpriteName(YoukaReward["login_gift_"..index].rewardname)
	
	self.m_DesSpr:MakePixelPerfect()
	local w,h = self.m_DesSpr:GetSize()
	self.m_DesSpr:SetSize(w,40)

	self.m_PowSpr:MakePixelPerfect()
	w,h = self.m_PowSpr:GetSize()
	self.m_PowSpr:SetSize(w,40)

	self.m_TipSpr:MakePixelPerfect()
	w,h = self.m_TipSpr:GetSize()
	self.m_TipSpr:SetSize(w,40)

	for i,v in pairs(YoukaReward) do
		if string.len(v.idxspr) >0 then
			table.insert(self.m_RewardTypeDes,{gift = v.gift, des = v.idxspr} )
		end
	end
	for i=1,table.count(YoukaReward)  do
		local key = YoukaReward["login_gift_"..i].gift
		local reward = RewardListDic[key]
		local oBox = nil
		if i > #daylist  then
			oBox = self.m_RewardCell:Clone()
			oBox:SetActive(true)
			-- oBox:SetGroup(self.m_DayGrid:GetInstanceID())
			self.m_DayGrid:AddChild(oBox)
			oBox.petTex = oBox:NewUI(1, CActorTexture)
			oBox.headSpr = oBox:NewUI(2, CSprite)
			oBox.dayLab = oBox:NewUI(3, CLabel)
			oBox.grid = oBox:NewUI(4, CGrid)
			oBox.item = oBox:NewUI(5, CBox)
			oBox.btn = oBox:NewUI(6, CButton)
			oBox.btnLab = oBox:NewUI(7, CLabel)
			oBox.itemdes = oBox:NewUI(8, CLabel)
			oBox.fluorescence =  oBox:NewUI(9, CSprite)
			oBox.dayLab:SetText("第#mark_"..i.."天")
			self:CreateItemInfo(oBox, reward)
			if i == 1 then
				g_GuideCtrl:AddGuideUI("eightlogin_get_btn", oBox.btn)
			end
			oBox.btn:AddUIEvent("click", callback(self, "OnReceiveItem", "login_gift_"..i, i))
		else
			oBox = daylist[i]
		end
		if g_WelfareCtrl.m_ColorfulData then
			for _,v in ipairs(g_WelfareCtrl.m_ColorfulData) do
				if "login_gift_"..i ==v.key and v.val == 1 then --可以领取
					oBox.btn:SetSpriteName("h7_an_2")
					oBox.headSpr:SetSpriteName("h7_fengling")
					oBox.headSpr:MakePixelPerfect()
					oBox.btnLab:SetText("领取")
					oBox.fluorescence:SetActive(true)
				end
				if "login_gift_"..i == v.key and v.val == 2 then --已领取
					oBox.btn:SetSpriteName("h7_an_5")
					oBox.headSpr:SetSpriteName("h7_fengling_1")
					oBox.headSpr:MakePixelPerfect()
					oBox.btnLab:SetText("已领取")
					oBox.fluorescence:SetActive(false)
       				oBox.btn:GetComponent(classtype.BoxCollider).enabled = false
					oBox.btn:SetGrey(true)
					oBox.btn:SetColor(Color.RGBAToColor("000000FF"))
				end
				if "login_gift_"..i == v.key and v.val == 0  then --不可领取
					oBox.btnLab:SetText("领取")
					oBox.headSpr:SetSpriteName("h7_fengling_1")
					oBox.headSpr:MakePixelPerfect()
					oBox.btn:SetSpriteName("h7_an_5")
					oBox.fluorescence:SetActive(false)
				end
			end
		end
	end
end

function CYoukaLoginView.OnReceiveItem(self, info, i)
	if i == 1 then
		g_GuideHelpCtrl.m_IsEightLoginGetClick = true
	end
	nethuodong.C2GSRewardWelfareGift("login", info)
end


function CYoukaLoginView.CreateItemInfo(self, oBox, dInfo)
	-- body
	for i,v in ipairs(self.m_RewardTypeDes) do
		if dInfo.id ==  v.gift then
            oBox.itemdes:SetText(v.des)
		end 
	end
	local datatable = {}
	for k,v in pairs(dInfo) do
		if k =="gold" and tonumber(v)>0 then
			local temp = {sid = 1001, amount = v, dtype = "sprite"} 
			table.insert(datatable, temp)
		elseif  k =="silver" and tonumber(v)>0 then
			local temp = {sid = 1002, amount = v , dtype = "sprite"} 
			table.insert(datatable, temp)
		elseif k =="goldcoin" and tonumber(v)>0 then
			local temp = {sid = 1003, amount = v , dtype = "sprite"} 
			table.insert(datatable, temp)
		elseif k =="partner" and v~=nil then
			local temp = {sid = v, amount = 1, dtype = "partner"} 
			table.insert(datatable, temp)
		elseif k =="item" and next(v) then
			for i,v in ipairs(v) do
				v.dtype = "sprite"
				table.insert(datatable, v)
			end
		elseif  k=="summon" and next(v)  then
			for i,v in ipairs(v) do
				v.dtype = "summon"
				table.insert(datatable, v)
			end
		elseif k == "ride" and v~= nil then
			local temp = {sid = tonumber(v), dtype = "ride"}
			table.insert(datatable, temp)
		end
	end
	local itemlist = oBox.grid:GetChildList()
	for i,v in ipairs(datatable) do
		if v.dtype == "sprite" then
			local oItem = nil
			if i > #itemlist then
				oItem = oBox.item:Clone()
				oItem:SetActive(true)
				oItem:SetGroup(oBox.grid:GetInstanceID())
				oBox.grid:AddChild(oItem)
				oItem.icon = oItem:NewUI(1, CSprite)
				oItem.amount = oItem:NewUI(2, CLabel)
				oItem.kuang =  oItem:NewUI(3, CSprite)
				local oItemData
				if v.sid > 10000 then
				  	oItemData= DataTools.GetItemData(v.sid)
				else
					local sid = DataTools.GetItemFiterResult(v.sid , g_AttrCtrl.roletype, g_AttrCtrl.sex)
					oItemData= DataTools.GetItemData(sid)
				end
				oItem.icon:SpriteItemShape(oItemData.icon)
				oItem.kuang:SetItemQuality(g_ItemCtrl:GetQualityVal( oItemData.id, oItemData.quality or 0 ) )
				oItem.amount:SetText(v.amount)
				oItem.icon:AddUIEvent("click", callback(self, "OnItemClick", oItem, oItemData.id))
			else
				oItem = itemlist[i]
			end
			-- oBox.petTex:SetActive(false)
		end
	end
	--伙伴
	for i,v in ipairs(datatable) do
		if v.dtype =="partner" and tonumber(v.sid) then
			oBox.grid:SetActive(false)
            local dPartnerData = data.partnerdata.INFO[tonumber(v.sid)]
            dPartnerData.rendertexSize = 1.5
            oBox.petTex:ChangeShape(dPartnerData)
            oBox.petTex:AddUIEvent("click", callback(self, "OnPartnerClick", v.sid))
		end
	end
	--宠物
	for i,v in ipairs(datatable) do
		if v.dtype =="summon" and tonumber(v.sid) then
			oBox.grid:SetActive(false)
            local dSummonrData = data.summondata.INFO[tonumber(v.sid)]
            dSummonrData.rendertexSize = 1.7
            oBox.petTex:ChangeShape(dSummonrData)
            oBox.petTex:AddUIEvent("click", callback(self, "OnSummonClick", v.sid))
		end
	end
	--坐骑
	for i,v in ipairs(datatable) do
		if v.dtype == "ride" and tonumber(v.sid) then
			oBox.grid:SetActive(false)
            local dRideData = data.ridedata.RIDEINFO[tonumber(v.sid)]
            dRideData.rendertexSize = 1.7
            dRideData.rotate = Vector3.New(0, 60, 0)
           -- modelInfo: {rotate(旋转)， pos(模型的局部坐标）, rendertexSize(渲染的大小) }
            oBox.petTex:ChangeShape(dRideData)
            oBox.petTex:AddUIEvent("click", callback(self, "OnRideClick", v.sid))
		end
	end

end

function CYoukaLoginView.OnItemClick(self, oItemm, sid)
	-- body
	local config = {widget = oItemm}
	g_WindowTipCtrl:SetWindowItemTip(sid, config)
end

function CYoukaLoginView.OnPartnerClick(self, sid)
	local pbdata = {}
	pbdata.pid = g_AttrCtrl.pid
	local partner = data.partnerdata.INFO[tonumber(sid)]
	local attr = table.copy(data.partnerdata.PROP[tonumber(sid)])
	local grownum =  data.partnerdata.POINT[tonumber(sid)]
	local skill =  data.partnerdata.SKILLUNLOCK[tonumber(sid)]
	local upperdata = data.partnerdata.UPPERLIMIT[tonumber(sid)]
	local level = 1
	local quality = partner.quality
	local currpartner = {}
	-- cure_power 
	----基本属性啊
	for k,v in pairs(attr) do
		local formula = string.gsub(v, "level", 1)
		formula = string.gsub(formula, "quality", quality)
		local func = loadstring("return " .. formula)
       	local val = func()
       	currpartner[k] = string.sub(val,1,2)
	end
	currpartner.model_info = {color = { [1] = 0}, shape = partner.shape }
	currpartner.name = partner.name
	currpartner.exp = 0
	currpartner.grade = 1
	currpartner.type = partner.type
	currpartner.sid = tonumber(sid)
	currpartner.quality = quality
	currpartner.upper = upperdata[1].upper
	----------速度啊
	local formula =  string.gsub(attr["speed"], "level", 1)
	formula = string.gsub(formula, "quality", quality)
	local func = loadstring("return " .. formula)
    currpartner.speed = func()
    ---------------技能啊
	currpartner.skill = {}
	for _,v in pairs(skill[1].unlock_skill) do
		table.insert(currpartner.skill, {level = 1, sk =v})
	end
	table.insert(currpartner.skill, {level = 1, sk = skill[40].unlock_skill[1]})
	table.insert(currpartner.skill, {level = 1, sk = skill[45].unlock_skill[1]})
	table.insert(currpartner.skill, {level = 1, sk = skill[60].unlock_skill[1]})
	

	pbdata.partnerdata = currpartner
	local oView = CPartnerLinkView:ShowView(function(oView)
		-- body
		oView:SetPartner(pbdata)
	end)
	-- self:CloseView()

end

function CYoukaLoginView.OnRideClick(self, sid)
	-- body
	if g_OpenSysCtrl:GetOpenSysState("RIDE_SYS") then
		local oView = CHorseMainView:ShowView(function (oView)
			-- body
			oView:ShowSpecificPart(3)
			oView:ChooseDetailPartHorse(sid)
		end)
	else
		local str = data.welfaredata.TEXT[1006].content
		local sysop = data.opendata.OPEN["RIDE_SYS"].p_level
		local sys = data.opendata.OPEN["RIDE_SYS"].name
		str = string.gsub(str,"#grade",tostring(sysop))
		str = string.gsub(str,"#name",sys)
		g_NotifyCtrl:FloatMsg(str)
		-- g_NotifyCtrl:FloatMsg("坐骑系统"..data.opendata.OPEN.RIDE_SYS.p_level.."级开发，赶快升级吧！")
	end
end

function CYoukaLoginView.RefreshUI(self, oCtrl)
	-- body
	if oCtrl.m_EventID ==  define.WelFare.Event.UpdataColorLamp then
		self:InitContent()
	end
end

function CYoukaLoginView.OnSummonClick(self, sid)
	if g_OpenSysCtrl:GetOpenSysState("SUMMON_SYS") then
		 g_SummonCtrl:ShowSummonLinkView(sid, 15)
	else
		local str = data.welfaredata.TEXT[1006].content
		local sysop = data.opendata.OPEN["SUMMON_SYS"].p_level
		local sys = data.opendata.OPEN["SUMMON_SYS"].name
		str = string.gsub(str,"#grade",tostring(sysop))
		str = string.gsub(str,"#name",sys)
		g_NotifyCtrl:FloatMsg(str)
	end
end

return CYoukaLoginView