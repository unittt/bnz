local CAttrPointPart = class("CAttrPointPart", CPageBase)

function CAttrPointPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_WashPointItemId = 10004	
end

function CAttrPointPart.OnInitPage(self)
	self.m_AddPointTitleLabel = self:NewUI(1, CLabel)
	self.m_OtherPlanObj = self:NewUI(2, CObject)
	self.m_PlanGrid = self:NewUI(3, CGrid)
	self.m_UsePlanBtn = self:NewUI(4, CButton)
	self.m_PotentialLabel = self:NewUI(5, CLabel)
	self.m_ItemNumLabel = self:NewUI(6, CLabel)
	self.m_SliderGrid = self:NewUI(7, CGrid)
	self.m_EnterAddBtn = self:NewUI(8, CButton)
	self.m_WashAllBtn = self:NewUI(9, CButton, true, false)
	self.m_TipsLabel = self:NewUI(10, CLabel)
	self.m_MorePlanIcon = self:NewUI(11, CSprite)
	self.m_MorePlan = self:NewUI(12, CObject)
	self.m_PlanBtnGrid = self:NewUI(13, CGrid)
	self.m_UseLabel = self:NewUI(14, CLabel)
	self.m_ItemIconSprite = self:NewUI(15, CSprite)
	self.m_AllPointGrep = self:NewUI(16, CSprite)
	self.m_MorePlanBtn = self:NewUI(17, CButton, true, false)
	self.m_RecommendBtn = self:NewUI(18, CButton, true, false)
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))	
	self.m_MorePlanBtn:AddUIEvent("click", callback(self, "OpenMorePlan"))
	self.m_UsePlanBtn:AddUIEvent("click", callback(self, "UsePlanCallBack"))
	self.m_EnterAddBtn:AddUIEvent("click", callback(self, "EnterAddPoint"))
	self.m_WashAllBtn:AddUIEvent("click", callback(self, "WashAllPointCallBack"))
	self.m_RecommendBtn:AddUIEvent("click", callback(self, "RecommendBtnCallBack"))
	self:InitData()	
	self:UpdateData(g_AttrCtrl.m_PlanInfolist, g_AttrCtrl.g_SelectedPlan)
	self:SetView()
	--默认选中方案1
	self.m_SelectPlan = g_AttrCtrl.g_SelectedPlan	--当前选择方案
 	self:ChangePlan(g_AttrCtrl.g_SelectedPlan, false)
	self:SetBaseInfo()
 	self:RefreshSliderInfo("All", self.m_AddPointPlanList[g_AttrCtrl.g_SelectedPlan])	
 	self:RefreshMainPart()
 	self:RefreshWashAllBtn()
end

--------------------------------------------------------
function CAttrPointPart.InitData(self)
	--加点界面属性
	self.m_SliderList = {}				--加点后的一级属性
	self.m_BaseSliderList = {}			--加点前的一级属性
	self.m_AddPointPlanList = {}		--可选方案
	self.m_RemainPoint = 0				--潜力点
	self.m_RealRemainPoint = 0			--用于显示界面上点数的刷新
	self.m_WashAllPoint = {}			--可洗点之和
	self.m_UsePlanId = 0
	self.m_KeyList = {"physique", "magic", "strength", "endurance", "agility"}
	self.m_AddPointNum = {	
		["physique"] = 0,
		["magic"] = 0,
		["strength"] = 0,
		["endurance"] = 0,
		["agility"] = 0,
		["plan_id"] = 0,
	}

	self.m_PlanAddPoint = {
		[1] = {
			max_hp = 0,
			max_mp = 0,
			phy_attack = 0,
			mag_attack = 0,
			phy_defense = 0,
			mag_defense = 0,
			speed = 0,
		},
		[2] = {
			max_hp = 0,
			max_mp = 0,
			phy_attack = 0,
			mag_attack = 0,
			phy_defense = 0,
			mag_defense = 0,
			speed = 0,
		},
		[3] = {
			max_hp = 0,
			max_mp = 0,
			phy_attack = 0,
			mag_attack = 0,
			phy_defense = 0,
			mag_defense = 0,
			speed = 0,
		},
	}

	self.m_AttrNameList = {max_hp = 1, max_mp = 2, phy_attack = 3, mag_attack = 4, phy_defense = 5, mag_defense = 6, speed = 7}
	self.m_ItemNumLabel:SetText(tostring(g_ItemCtrl:GetBagItemAmountBySid(self.m_WashPointItemId)))
	self.m_CAttrPointConfig = data.rolepointdata.ROLEPOINT
	self.m_LevelConfig = data.rolepointdata.LEVEL
	self.m_EquipItems = {}
end

function CAttrPointPart.UpdateData(self, infolist, planid)
	self.m_SliderList = {g_AttrCtrl.physique, g_AttrCtrl.magic, g_AttrCtrl.strength, g_AttrCtrl.endurance, g_AttrCtrl.agility,}
	self.m_AddPointPlanList = table.copy(infolist)
	self.m_SelectPlan = planid
	self.m_RemainPoint = infolist[planid].remain_point
	self:CalculateSliderBaseData(self.m_AddPointPlanList[planid])
	for i=1,#infolist do
		self:CalculateAllWashPoint(infolist[i], i)
	end
end

--清空洗点方案的缓存
function CAttrPointPart.ResetPlanAddPoint(self, idx)
	for k,v in pairs(self.m_PlanAddPoint[idx]) do		
		self.m_PlanAddPoint[idx][k] = 0
	end
end

--计算各个方案可洗点之和
function CAttrPointPart.CalculateAllWashPoint(self, infolist, planid)
	local iAllWashPoint = 0
	for k,v in pairs(infolist) do
		if k ~="plan_id" and k ~= "remain_point" then
			iAllWashPoint = iAllWashPoint + v
		end
	end
	self.m_WashAllPoint[planid] = iAllWashPoint
end

function CAttrPointPart.CalculateSliderBaseData(self, infolist)
	self.m_BaseSliderList = {
		g_AttrCtrl.physique - (infolist.physique or 0),
		g_AttrCtrl.magic - (infolist.magic or 0),
		g_AttrCtrl.strength - (infolist.strength or 0),
		g_AttrCtrl.endurance - (infolist.endurance or 0),
		g_AttrCtrl.agility - (infolist.agility or 0),
	}
end

function CAttrPointPart.SetAddPointNum(self, type, num)
	for k,v in pairs(self.m_AddPointNum) do
		if type == "nil" then
			self.m_AddPointNum[k] = 0
		elseif k == type then
			self.m_AddPointNum[k] = self:MathRound(num)
		end
	end
	self.m_AddPointNum["plan_id"] = self.m_SelectPlan
end

function CAttrPointPart.RefreshAttrPoint(self, data)
	self.m_SelectPlan = data.plan_id
	self.m_RemainPoint = data.remain_point
	self.m_AddPointPlanList[self.m_SelectPlan] = data
	self:RefreshSliderInfo("All", data)
	self:RefreshPlanAddPoint(self.m_SelectPlan)
	self:ChangePlan(self.m_SelectPlan)
end

function CAttrPointPart.RefreshWashPoint(self, data)
	local sName = data[2].prop_name
	self.m_RemainPoint = data[2].remain_point
	self.m_RealRemainPoint = data[2].remain_point
	self.m_AddPointPlanList[self.m_SelectPlan].remain_point = data[2].remain_point
	-- printc("=====洗点回调潜力点=====",self.m_RemainPoint)
	if self.m_AddPointPlanList[self.m_SelectPlan][sName] == 1 then
		self.m_AddPointPlanList[self.m_SelectPlan][sName] = self.m_AddPointPlanList[self.m_SelectPlan][sName] - 1
	else
		self.m_AddPointPlanList[self.m_SelectPlan][sName] = self.m_AddPointPlanList[self.m_SelectPlan][sName] - 2
	end
	-- self:CalculateAllWashPoint(self.m_AddPointPlanList)
	for i=1,#self.m_AddPointPlanList do
		self:CalculateAllWashPoint(self.m_AddPointPlanList[i], i)
	end

	self:RefreshSliderInfo("All", self.m_AddPointPlanList[self.m_SelectPlan])
	self:RefreshMainPart(self.m_RemainPoint)
end

--一级属性转化二级属性
function CAttrPointPart.Conversion(self, type, num, planid)
	local init = data.rolepointdata.INIT[1]
	for k,v in pairs(self.m_PlanAddPoint[planid]) do
		local sum = init[k]
		if k == "max_mp" then 
			sum = sum + g_AttrCtrl.grade*10 + 30
		else
			for j,c in pairs(self.m_CAttrPointConfig) do	
				if j == type then 
					sum = sum + (g_AttrCtrl[j]+num) * c[k] + 0.001 --避免浮点误差+0.001
				else
					sum = sum + (g_AttrCtrl[j]+self.m_AddPointNum[j]) * c[k] + 0.001
				end 
			end
		end	
		sum = (sum * (100 + g_AttrCtrl[k.."_ratio"] / 1000) / 100 + g_AttrCtrl[k.."_extra"] / 1000)
		local add = sum - math.floor(g_AttrCtrl[k]) --减去原来的值计算增加的值		
		self.m_PlanAddPoint[planid][k] = math.floor(add) 
	end
end

--获取导表公式
function CAttrPointPart.GetDataConfig(self, maintype, subtype)
	if not maintype then
		return 0
	end
	if subtype then
		return self.m_CAttrPointConfig[maintype][subtype] or 0
	else
		return self.m_CAttrPointConfig[maintype] or 0
	end
end

function CAttrPointPart.SetBaseInfo(self, dSub)	
	local tChildList = self.m_PlanGrid:GetChildList()
	local list = {"max_hp","max_mp","phy_attack","mag_attack","phy_defense","mag_defense","speed"}
	  local oItem = nil				
	  for i=1,#tChildList do
		oItem = tChildList[i]
		local iSub = dSub and dSub[list[i]] or 0
		oItem:SetInfo(g_AttrCtrl[list[i]] - iSub)
	end
end

function CAttrPointPart.OnCtrlEvent(self, oCtrl)	
	local sType = ""
	if oCtrl.m_EventID == define.Attr.Event.AddPoint then
		if oCtrl.m_EventData[1] == nil then
			return
		end
		sType = oCtrl.m_EventData[1]
		if sType == "All" then
			self:UpdateData(oCtrl.m_EventData[2], oCtrl.m_EventData[3])
		elseif sType == "OnePlan" then
			self:ResetPlanAddPoint(self.m_SelectPlan)	
			self:CalculateAllWashPoint(oCtrl.m_EventData[2], oCtrl.m_EventData[2].plan_id)
			self:RefreshAttrPoint(oCtrl.m_EventData[2])		
			self:RefreshWashAllBtn()
		elseif sType == "WashPoint" then
			self:ResetPlanAddPoint(self.m_SelectPlan)
			self:RefreshWashPoint(oCtrl.m_EventData)
			self:RefreshWashAllBtn()
		end
	elseif oCtrl.m_EventID == define.Attr.Event.Change then
		self.m_SliderList = {g_AttrCtrl.physique, g_AttrCtrl.magic, g_AttrCtrl.strength, g_AttrCtrl.endurance, g_AttrCtrl.agility}
		self:RefreshSliderInfo("Point")		
	end
	if  oCtrl.m_EventID == define.Attr.Event.GetSecondProp then 
		self:SetBaseInfo()
	end 
	g_AttrCtrl.m_PlanInfolist = self.m_AddPointPlanList
end

function CAttrPointPart.OnItemCtrlEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self.m_ItemNumLabel:SetText(tostring(g_ItemCtrl:GetBagItemAmountBySid(self.m_WashPointItemId)))		
	end
end

function CAttrPointPart.SetView(self)
	local function InitSlider(obj, idx)
		local oSliderItem = CAttrSliderBox.New(obj, function(data)
			self:SliderCallBack(data)
		end)
		return oSliderItem
	end
	self.m_SliderGrid:InitChild(InitSlider)
	local function InitItem(obj, idx)
		local oItem = CAttrPlanItemBox.New(obj)
		return oItem
	end
	self.m_PlanGrid:InitChild(InitItem)
	local function InitPlanBtn(obj, idx)
		local oPlanBtn = CButton.New(obj)	
		if g_AttrCtrl.grade < self.m_LevelConfig[idx].unlock_lev then
			oPlanBtn:SetSpriteName("h7_an_5")
			oPlanBtn:SetText("[5c6163]洗点方案"..idx.."[-]")
		else
			oPlanBtn:SetSpriteName("h7_an_4")
			oPlanBtn:SetText("[386D6F]洗点方案"..idx.."[-]")
		end
		oPlanBtn:AddUIEvent("click", callback(self, "ChangePlan", idx, true))
		return oPlanBtn
	end
	self.m_PlanBtnGrid:InitChild(InitPlanBtn)
	local data = DataTools.GetItemData(self.m_WashPointItemId)
	self.m_ItemIconSprite:SpriteItemShape(data.icon)
	self.m_ItemIconSprite:AddUIEvent("click", function()
		g_WindowTipCtrl:SetWindowGainItemTip(self.m_WashPointItemId)
	end)
end

--刷新方案加点属性
function CAttrPointPart.RefreshPlanAddPoint(self, planid)
	local oItem = nil
	local tData = self.m_PlanAddPoint[planid]
	local tChildList = self.m_PlanGrid:GetChildList()	
	local iAddPoint = 0
	for k,v in pairs(tData) do
		iAddPoint = v
		oItem = tChildList[self.m_AttrNameList[k]]
		oItem:RefreshAddLabel(iAddPoint)
	end
end

function CAttrPointPart.RefreshSliderInfo(self, stype, data)
	if data == nil and stype == "All" then 
		return 
	end
	local oSliderItem = nil
	for i = 1, 5 do
		oSliderItem = self.m_SliderGrid:GetChild(i)
		if stype == "All" then	--刷新整个slider
			oSliderItem:DelateData()
			oSliderItem:SetInfo({i, data[self.m_KeyList[i]], data.remain_point, self.m_BaseSliderList[i],
				self.m_WashAllPoint[self.m_UsePlanId], self.m_UsePlanId})
		elseif stype == "Point" then 	--刷新point
			oSliderItem:RefreshPoint(self.m_SliderList[i])
		end
	end
end

function CAttrPointPart.SliderCallBack(self, datalist)
	self:RefreshRemainPoint(datalist.changepoint)
	--self:Conversion(datalist.key, datalist.changepoint, self.m_SelectPlan) addpoint
	self:Conversion(datalist.key, datalist.addpoint, self.m_SelectPlan)
	self:RefreshPlanAddPoint(self.m_SelectPlan)
	self.m_RemainPoint = self.m_RemainPoint - datalist.changepoint
	-- printc("===剩余潜力点===",self.m_RemainPoint,"==改变量==",datalist.changepoint)
	self:RefreshSliderRound(datalist.idx)
	self:SetAddPointNum(datalist.key, datalist.addpoint)	
end

function CAttrPointPart.RefreshRemainPoint(self, ichange)
	self.m_RealRemainPoint = self.m_RealRemainPoint - (ichange or 0)
	self:RefreshMainPart(self.m_RealRemainPoint)
end

function CAttrPointPart.RefreshMainPart(self, point)		
	if point then
		self.m_PotentialLabel:SetText(string.format("%d", point))
	else
		self.m_PotentialLabel:SetText(string.format("%d", self.m_AddPointPlanList[self.m_UsePlanId].remain_point or 0))
	end
end

--根据剩余潜力点,即时刷新滑动条取值区间
function CAttrPointPart.RefreshSliderRound(self, idx)
	local oSliderItem = nil
	for i = 1, 5 do
		oSliderItem = self.m_SliderGrid:GetChild(i)
		oSliderItem:RefreshSliderRound(self.m_RemainPoint)
	end
end

function CAttrPointPart.RefreshPlanPreview(self, iPlan)
	--恢复上一个方案导致的属性变化
	local dSub = {}
	for k,v in pairs(self.m_AddPointPlanList[self.m_SelectPlan]) do
		self:Conversion(k, v, self.m_SelectPlan)
		self:SetAddPointNum(k, v)
	end
	for k,v in pairs(self.m_PlanAddPoint[self.m_SelectPlan]) do
		dSub[k] = v
	end

	--处理新方案导致的属性变化
	self:SetAddPointNum("nil")	
	for k,v in pairs(self.m_AddPointPlanList[iPlan]) do
		self:RefreshRemainPoint(v)
		self:Conversion(k, v, iPlan)
		self:SetAddPointNum(k, v)
	end
	for k,v in pairs(self.m_PlanAddPoint[iPlan]) do
		if dSub[k] then
			dSub[k] = dSub[k]-v
		else
			dSub[k] = -v
		end
	end
	self:SetAddPointNum("nil")	
	self:SetBaseInfo(dSub)
end

--更换方案
function CAttrPointPart.ChangePlan(self, index, bool)
	if g_AttrCtrl.grade < self.m_LevelConfig[index].unlock_lev then
		g_NotifyCtrl:FloatMsg(string.format("%d级解锁第%d套洗点方案",self.m_LevelConfig[index].unlock_lev, index))
		return
	end
	self.m_UsePlanId = index
	if self.m_SelectPlan == index then
		self.m_UseLabel:SetText("[1d8e00]方案已启用[-]")
		self.m_UsePlanBtn:SetActive(false)
		self.m_TipsLabel:SetActive(false)
		self.m_EnterAddBtn:SetActive(true)
		self.m_WashAllBtn:SetActive(true)
		self:ResetPlanAddPoint(index)
	else
		self.m_UseLabel:SetText("[A64E00]未启用[-]")
		self.m_UsePlanBtn:SetActive(true)
		self.m_TipsLabel:SetActive(true)
		self.m_EnterAddBtn:SetActive(false)
		self.m_WashAllBtn:SetActive(false)		
	end
	self.m_AddPointTitleLabel:SetText("[386D6FFF]洗点方案"..index.."[-]")	
	self.m_MorePlan:SetActive(false)
	self:SetAddPointNum("nil")
	if self.m_SelectPlan ~= index then
		self:RefreshPlanPreview(index)
	else
		self:RefreshPlanAddPoint(index)
		self:SetBaseInfo()
	end
	self:RefreshSliderInfo("All", self.m_AddPointPlanList[index])
	self:RefreshMainPart()
	self.m_RemainPoint = self.m_AddPointPlanList[index].remain_point or 0
	self.m_RealRemainPoint = self.m_AddPointPlanList[index].remain_point or 0
	self.m_MorePlanIcon:SetSpriteName("h7_jiang_1")
	self.m_MorePlanBtn:SetSpriteName("h7_an_4")
end

function CAttrPointPart.OpenMorePlan(self)
	local sSpriteName = ""
	if self.m_MorePlan:GetActive() == true then
		self.m_MorePlan:SetActive(false)
		sSpriteName = "h7_jiang_1"
		self.m_MorePlanBtn:SetSpriteName("h7_an_4")
		self.m_AddPointTitleLabel:SetText("[386D6FFF]洗点方案"..self.m_UsePlanId.."[-]")
	else
		self.m_MorePlan:SetActive(true)
		sSpriteName = "h7_sheng_1"
		self.m_MorePlanBtn:SetSpriteName("h7_an_3")
		self.m_AddPointTitleLabel:SetText("[bd5733]洗点方案"..self.m_UsePlanId.."[-]")	
	end
	self.m_MorePlanIcon:SetSpriteName(sSpriteName)
end

function CAttrPointPart.GetAllWashPoint(self)
	return self.m_WashAllPoint[self.m_SelectPlan]
end

function CAttrPointPart.RefreshWashAllBtn(self)
	if self:GetAllWashPoint() == 0 then
		self.m_AllPointGrep:SetActive(true)
	else
		self.m_AllPointGrep:SetActive(false)
	end
end

--数字四舍五入
function CAttrPointPart.MathRound(self, data)	
	local num = data * 100
	num = (num % 1 >= 0.5 and math.ceil(num/100)) or math.floor(num/100)
	-- num = math.floor(num / 100)
	return num 
end

--取整
function CAttrPointPart.ToInt(self, num)
	if math.ceil(num) == num then
		return num
	else
		return math.ceil(num) - 1
	end 
end

------------------网络交互----------------------------------------------------------

--使用方案
function CAttrPointPart.UsePlanCallBack(self)	
	netplayer.C2GSSelectPointPlan(self.m_UsePlanId)
end

--加点
function CAttrPointPart.EnterAddPoint(self)
	for k,v in pairs(self.m_AddPointNum) do
		if k ~= "plan_id" and v ~= 0 then
			netplayer.C2GSAddPoint(self.m_AddPointNum)
			return
		end
	end
	
end

--全部洗点
function CAttrPointPart.WashAllPointCallBack(self)
	if self:GetAllWashPoint() == 0 then
		g_NotifyCtrl:FloatMsg("=====没有可洗点=====")
		return
	end
	local data = {
	sid 		= 10005,
	title 		= "全部洗点",
	btnname		= "确定洗点",
	callback 	= function ()
		netplayer.C2GSWashAllPoint()
	end,
	}

	CWindowUsePropView:ShowView(function(oView)
		oView:SetWinInfo(data)
	end)
end

function CAttrPointPart.RecommendBtnCallBack(self)
	local zContent = {title = data.instructiondata.DESC[10008].title,desc = data.instructiondata.DESC[10008].desc}
	g_WindowTipCtrl:SetWindowInstructionInfo(zContent)
end

return CAttrPointPart