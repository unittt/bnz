local CHorseDetailPart = class("CHorseDetailPart", CPageBase)

function CHorseDetailPart.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_ShowCondition = {player_level = "玩家等级", ride_level = "坐骑等级"}
	self.m_RideList = {}
end

function CHorseDetailPart.OnInitPage(self)
	self.m_HorseMapItem = self:NewUI(1, CHorseMapItem)
	self.m_ItemGrid = self:NewUI(2, CGrid)
	--self.m_Name = self:NewUI(3, CLabel)
	self.m_AttrGrid = self:NewUI(4, CGrid)
	self.m_AttrClone = self:NewUI(5, CLabel)
	self.m_ConditionGrid = self:NewUI(6, CGrid)
	self.m_ConditionClone = self:NewUI(7, CHorseActiveConditionBox)
	self.m_WuXunBtn = self:NewUI(8, CSprite)
	self.m_YuanBaoBtn = self:NewUI(9, CSprite)
	self.m_SkillNode = self:NewUI(10, CGrid)
	self.m_SkillItem = self:NewUI(11, CHorseSkillItem)
	self.m_TianfuNode = self:NewUI(12, CObject)
	self.m_BtnGrid = self:NewUI(13, CGrid)
	self.m_HorseName = self:NewUI(14, CLabel)
	self.m_HorseUseTime = self:NewUI(15, CLabel)
	self.m_HorseTexture = self:NewUI(16, CActorTexture)
	self.m_ActiveGrid = self:NewUI(17, CGrid)
	self.m_ActiveBox = self:NewUI(18, CHorseBuyBox)
	self.m_SpecialActiveBtn = self:NewUI(19, CSprite)
	self.m_ScrollView = self:NewUI(20, CScrollView)
	self.m_ActiveNode = self:NewUI(21, CObject)
	self.m_SpecialActiveText = self:NewUI(22, CLabel)

	self:InitContent()
end

function CHorseDetailPart.InitContent(self)

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnRefreshItem"))
	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	
	self:RefreshHorseMapItemList()

	self.m_ItemGrid:GetChild(1):SetSelected(true)

	local horseId =  self.m_ItemGrid:GetChild(1).m_Id

	self:OnClickHorseMapItem(horseId)

	self.m_WuXunBtn:AddUIEvent("click", callback(self, "OnClickWuXunActive"))
	self.m_YuanBaoBtn:AddUIEvent("click", callback(self, "OnClickYuanBaoActive"))
	self.m_SpecialActiveBtn:AddUIEvent("click", callback(self, "OnClicSpecialActive"))

end

function CHorseDetailPart.RefreshHorseMapItemList(self)
	
	local info = data.ridedata.RIDEINFO
	self.m_ItemGrid:HideAllChilds()
	local i = 1
	for k, v in pairs(info) do 
		local item = self.m_ItemGrid:GetChild(i)
		if item == nil then
			item = self.m_HorseMapItem:Clone()	
			self.m_ItemGrid:AddChild(item)	
		end
		item:SetData(v, callback(self, "OnClickHorseMapItem"))
		item:SetActive(true)
		i = i + 1
	end 

	self.m_ItemGrid:Reposition()

end

function CHorseDetailPart.RefreshActiveNode(self)
	
	if self.m_SelectHorseData then 
		local id = self.m_SelectHorseData.id
		local isForever = g_HorseCtrl:IsHorseActiveForever(id)
		self.m_ActiveNode:SetActive(not isForever)
	end 
	
end

function CHorseDetailPart.OnClickHorseMapItem(self, horseId, item)
	
	self.m_CurSelItem = item
	self.m_SelectHorseData = data.ridedata.RIDEINFO[horseId]
	self:RefreshAll()
	self:ForceSelecte()

end

function CHorseDetailPart.RefreshAll(self)
	
	self:RefreshHorseMapItemList()
	self:RefreshName()
	self:RefreshAttr()
	self:RefreshSkillIcon()
	self:RefreshBtn()
	self:RefreshHorseTexture()
	self:RefreshRemainTime()
	self:RefreshActiveNode()
	
end

function CHorseDetailPart.ForceSelecte(self)
	
	if self.m_WuXunBtn:GetActive() then 
		self.m_WuXunBtn:ForceSelected(true)
		self:OnClickWuXunActive()
	end 

end


--刷新名字
function CHorseDetailPart.RefreshName(self)
	
	self.m_HorseName:SetText(self.m_SelectHorseData.name)

end


function CHorseDetailPart.RefreshHorseTexture(self)
	
	local horseData = self.m_SelectHorseData

	local model_info =  table.copy(g_AttrCtrl.model_info)
 	model_info.rendertexSize = 1.8
 	model_info.horse = horseData.id
 	self.m_HorseTexture:ChangeShape(model_info)


end

function CHorseDetailPart.RefreshRemainTime(self)

	local horseId = self.m_SelectHorseData.id
	if not g_HorseCtrl:IsHorseActive(horseId) then 
		self.m_HorseUseTime:SetActive(false)
		return
	end 

	self.m_HorseUseTime:SetActive(true)

	local horse = g_HorseCtrl:GetHorseById(horseId)

	if not horse then 
		return
	end

	if  horse.left_time == -1 then 
	    g_TimeCtrl:DelTimer(self)
	    self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]永久[-]")
	else
	    local cb = function (time)
	        if not time then 
	            self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]过期[-]")
	        else
	            self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]" .. time .. "[-]")
	        end 
	    end
	    g_TimeCtrl:StartCountDown(self, horse.left_time, 1, cb)

	end

end

function CHorseDetailPart.RefreshBtn(self)

	if self:IsSpecialActive() then 
		self.m_ActiveGrid:SetActive(false)
		self.m_YuanBaoBtn:SetActive(false)
		self.m_WuXunBtn:SetActive(false)
		self.m_SpecialActiveBtn:SetActive(true)
		local activeText = self.m_SelectHorseData.activeText
		self.m_SpecialActiveText:SetText(activeText)
	else
		self.m_ActiveGrid:SetActive(true)
		self.m_YuanBaoBtn:SetActive(true)
		self.m_WuXunBtn:SetActive(true)
		self.m_SpecialActiveBtn:SetActive(false)
	end 
	
end

--刷新属性
function CHorseDetailPart.RefreshAttr(self)
	
	local attrList = self.m_SelectHorseData.attr
	self.m_AttrGrid:HideAllChilds()
	local i = 1
	for k, v in pairs(attrList) do 
		local item = self.m_AttrGrid:GetChild(i)
		if item == nil then
			item = self.m_AttrClone:Clone()	
			self.m_AttrGrid:AddChild(item)	
		end
		if string.find(k, "seal") then
			item:SetText(v.name .. ":" .. tonumber(v.val)*10)
		elseif string.find(k, "critical") then
			item:SetText( v.name .. ":".. v.val.."%")
		else
			item:SetText( v.name .. ":".. v.val )
		end
		
		item:SetActive(true)
		i = i + 1
	end 

end

--刷新技能icon
function CHorseDetailPart.RefreshSkillIcon(self)
	
	local horseData = self.m_SelectHorseData

	if not next(horseData.talent) then 
		self.m_SkillNode:HideAllChilds()
		self.m_TianfuNode:SetActive(false)
		return
	end 

	self.m_TianfuNode:SetActive(true)

	for k, v in ipairs(horseData.talent) do 

		local item = self.m_SkillNode:GetChild(k)
		if item == nil then 
			item = self.m_SkillItem:Clone()
			item:SetActive(true)
			self.m_SkillNode:AddChild(item)
		end 

		item:SetActive(true)
		local skillInfo = data.ridedata.SKILL[v]
		local info = {}
		info.config = skillInfo
		item:SetInfo(info)

		item:AddUIEvent("click", callback(self, "OnShowSkillTips", item))
		
	end 

end


function CHorseDetailPart.OnShowSkillTips(self, item)

    if not item then 
		return
	end 

    local info = item:GetInfo()

    local config = info.config

    local args = {
        widget= item,
        side = enum.UIAnchor.Side.Top,
        icon = config.icon,
        name = config.name,
        desc = config.desc,
    }
    g_WindowTipCtrl:SetWindowSkillTip(args)

end

function CHorseDetailPart.OnRefreshItem(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddBagItem or 
	oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		if self.m_SelectHorseData then
			self:RefreshHorseMapItemList()
		end
	end
end

function CHorseDetailPart.OnCtrlEvent(self, oCtrl)

	if oCtrl.m_EventID == define.Horse.Event.HorseAttrChange or  oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo or 
	    oCtrl.m_EventID == define.Horse.Event.AddHorse then
	    self:RefreshAll()
	end

end

--武勋激活 6
function CHorseDetailPart.OnClickWuXunActive(self)
	
	self:ActiveHorse(6)

end

--元宝激活 3
function CHorseDetailPart.OnClickYuanBaoActive(self)

	self:ActiveHorse(3)

end


--激活
function CHorseDetailPart.ActiveHorse(self, activeType)
	
	--刷新激活选项
	self:RefreshActiveItems(activeType)

end

function CHorseDetailPart.RefreshActiveItems(self, activeType)

	local horseData = self.m_SelectHorseData

    local id = horseData.id
    
    local buyinfo = g_HorseCtrl:GetActiveConsumeListByType(id, activeType)

  	self.m_ActiveGrid:HideAllChilds()

    table.sort(buyinfo, function (a, b)
        if a.id < b.id then 
            return true
        else
            return false 
        end 
    end)

    for k, v in ipairs(buyinfo) do 

        local item = self.m_ActiveGrid:GetChild(k) 
        if not item then 
            item = self.m_ActiveBox:Clone()
            item:SetActive(true)
            self.m_ActiveGrid:AddChild(item)
        end 

        item:SetName(tostring(v.id))

        local info = {}

        if v.valid_day == -1 then 
            info.validDay = -1
        else
            info.validDay = v.valid_day
        end 

        info.consumeType = v.cost_money[1].type
        info.icon = v.cost_money[1].icon
        info.count = v.cost_money[1].cnt
        info.id = v.id
        item:SetInfo(info, callback(self, "OnClickActive"))
        item:SetActive(true)

    end 

    self.m_ActiveGrid:Reposition()

end

function CHorseDetailPart.OnClickActive(self, info)

	local hadCount = 0
	local needCount = 0
    if info.consumeType == 3 then
        hadCount = g_AttrCtrl:GetGoldCoin()
        needCount = info.count
        if needCount >  hadCount then
            -- CNpcShopMainView:ShowView(function(oView) oView:ShowSubPageByIndex(oView:GetPageIndex("Recharge")) end) 
            g_NotifyCtrl:FloatMsg("元宝不足！")
			g_ShopCtrl:ShowChargeView()
            return
        end

    elseif info.consumeType == 6 then 
    	hadCount = g_AttrCtrl.wuxun
    	needCount = info.count
    	if needCount >  hadCount then
    	    g_NotifyCtrl:FloatMsg("武勋不足！")
    	    return
    	end
    end 

    g_HorseCtrl:C2GSBuyRideUseTime(info.id)

end

function CHorseDetailPart.IsSpecialActive(self)
	
	if self.m_SelectHorseData.activeType > 0 then 
		return true
	end 

end

--特殊激活
function CHorseDetailPart.OnClicSpecialActive(self)

	if self.m_SelectHorseData.activeType == 1 then
		local tip = g_HorseCtrl:GetTextTip(1049)
		local windowConfirmInfo = {
			title = "特殊坐骑",
			msg	= tip,
			okCallback = callback(g_ShopCtrl, "ShowChargeView"),
            -- function()
			-- 	CNpcShopMainView:ShowView(function (oView)
			-- 		oView:ShowSubPageByIndex(3)
			-- 		oView.m_RechargePart:RebateCallBack()
			-- 	end)
			-- end,	
			pivot = enum.UIWidget.Pivot.Center,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	
	elseif self.m_SelectHorseData.activeType == 2 then 
		CFuncNotifyMainView:ShowView(function (oView)
			oView:RefreshUI(g_GuideHelpCtrl.m_RideGuideIndex)
		end)

	elseif  self.m_SelectHorseData.activeType == 3 then 
		local tip = g_HorseCtrl:GetTextTip(1050)
		local windowConfirmInfo = {
			title = "特殊坐骑",
			msg	= tip,	
			pivot = enum.UIWidget.Pivot.Center,
			thirdStr = "确定",
			thirdCallback = function ( ... )
			end,
			style = CWindowComfirmView.Style.Single,

		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	elseif  self.m_SelectHorseData.activeType == 4 then 
		local isOpen = g_ZeroBuyCtrl:CheckIsZeroBuyOpen()
		if isOpen then 
			CZeroBuyView:ShowView(function (oView)
				oView:OnClickFlyBtn()
			end)
		else
			local tip = g_HorseCtrl:GetTextTip(1048)
			g_NotifyCtrl:FloatMsg(tip)
		end 
	end 
	

end

function CHorseDetailPart.OnClickTryRideBtn(self)
	CHorseRideView:ShowView(function (oView)
		oView:SetInfo(self.m_SelectHorseData.id)
	end)
end

function CHorseDetailPart.OnShowTips(self, id, item)
    local skill = data.ridedata.SKILL[id]
    local formula1 = string.gsub(skill.formula1, "level", g_HorseCtrl.grade)
	local val1 = loadstring("return "..formula1)
	local cur = string.gsub(skill.des, "#1", val1)
	local formula2 = string.gsub(skill.formula2, "level", g_HorseCtrl.grade)	
	local val2 = loadstring("return "..formula2)
    cur = string.gsub(cur, "#2", val2) 
    local args = {
        widget= item,
        side = enum.UIAnchor.Side.Top,
        icon = skill.icon,
        name = skill.name,
        --introduction = skill.des
        description = cur,
    }
    g_WindowTipCtrl:SetWindowSkillTip(args)
end

function CHorseDetailPart.ChooseHorse(self, horseId)
	horseId = tonumber(horseId)
	local itemList = self.m_ItemGrid:GetChildList()
	for k, v in ipairs(itemList) do 
		if v.m_Id == horseId then
			v:ForceSelected(true)
			self.m_SelectHorseData = data.ridedata.RIDEINFO[horseId]
			self:RefreshAll()
			self:OnClickHorseMapItem(horseId, v)
		end 
	end 

	self:AdjustMapItemPos()

end

function CHorseDetailPart.AdjustMapItemPos(self)
	
	local fun = function ()
		if self.m_CurSelItem then
			UITools.MoveToTarget(self.m_ScrollView, self.m_CurSelItem)
			self.m_ScrollView:RestrictWithinBounds(true)
		end 
	end

	Utils.AddTimer(fun, 0, 0)

end


return CHorseDetailPart