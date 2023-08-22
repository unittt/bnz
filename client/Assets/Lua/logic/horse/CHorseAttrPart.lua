local CHorseAttrPart = class("CHorseAttrPart", CPageBase)

function CHorseAttrPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	--一页的item数
	self.m_PageCount = 6 
end

function CHorseAttrPart.OnInitPage(self)

	self.m_ItemGrid = self:NewUI(1, CGrid)
	self.m_ItemCellClone = self:NewUI(2, CHorseItemBox)
	self.m_HorseTexture = self:NewUI(3, CActorTexture)
	self.m_SkillNode = self:NewUI(4, CGrid)
	self.m_SkillItem = self:NewUI(5, CHorseSkillItem)

	self.m_HorseName = self:NewUI(6, CLabel)
	self.m_AddHorseTimeBtn = self:NewUI(7, CButton)
	self.m_HorseUseTime = self:NewUI(8, CLabel)
	self.m_AttrGrid = self:NewUI(9, CGrid)
	self.m_RideBtn = self:NewUI(10, CButton)
	self.m_ItemScroll = self:NewUI(11, CScrollView)
	self.m_HorseSumScore   = self:NewUI(14, CLabel)
	self.m_HorseArrtLabel  = self:NewUI(15, CLabel)
	self.m_HorseDesLabel  = self:NewUI(16, CLabel)
	self.m_TianFuNode  = self:NewUI(17, CObject)
	self.m_ScrollView = self:NewUI(18, CScrollView)

	g_GuideCtrl:AddGuideUI("horse_ride_btn", self.m_RideBtn)

	self.m_HorseArrtLabel:SetActive(false)

	self:InitContent()

end

function CHorseAttrPart.InitContent(self)

	g_HorseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_AddHorseTimeBtn:AddUIEvent("click", callback(self, "OnBuyRide"))
	self.m_RideBtn:AddUIEvent("click", callback(self, "OnRide"))

	self:RefreshHorseGrid()

	g_HorseCtrl:C2GSGetRideInfo()

end

function CHorseAttrPart.OnShowPage(self)

	local rideId = g_HorseCtrl:GetCurSelHorseId()
	self:RefreshHorseGrid()
	if rideId then 
		local itemList = self.m_ItemGrid:GetChildList()
		for k, item in ipairs(itemList) do 
			if item:GetHorseId() == rideId then 
				item:ForceSelect()
				self:OnClickHorseItem(item)
				self.m_ItemGrid:Reposition()
				self.m_ScrollView:ResetPosition()
				UITools.MoveToTarget(self.m_ScrollView, item)
				g_HorseCtrl:SetCurSelHorseId(rideId)
				self.m_ScrollView:RestrictWithinBounds(true)
				break
			end 
		end 
	else
		self:SetHorseItemSelect()
	end  

end

function CHorseAttrPart.SetHorseItemSelect(self)

	local item = nil
	if g_HorseCtrl.m_CurUseHorseId ~= nil and g_HorseCtrl.m_CurUseHorseId ~= 0 then 
		for k , v in pairs(self.m_ItemGrid:GetChildList()) do 
			if v.m_HorseId == g_HorseCtrl.use_ride then 
				item = v
				break
			end 
		end 
	else
		item = self.m_ItemGrid:GetChild(1)
	end 

	if item then 
		item.m_ItemBox:SetSelected(true)
		self:OnClickHorseItem(item)
		self.m_ItemGrid:Reposition()
		self.m_ScrollView:ResetPosition()
		UITools.MoveToTarget(self.m_ScrollView, item)
		g_HorseCtrl:SetCurSelHorseId(item.m_HorseId)
		self.m_ScrollView:RestrictWithinBounds(true)
	end 

end

function CHorseAttrPart.RefreshHorseGrid(self)

	local horseIdList = g_HorseCtrl:GetHorseSortId()
	self.m_ItemGrid:HideAllChilds()
	for k,v in ipairs(horseIdList) do
		local item = self.m_ItemGrid:GetChild(k)
		if item == nil then
			item = self.m_ItemCellClone:Clone()	
			item:SetActive(true)
			self.m_ItemGrid:AddChild(item)	
		end
		--引导需要
		if v == g_GuideHelpCtrl:GetRide() then
			g_GuideCtrl:AddGuideUI("ride_selecttab_btn", item.m_ItemBox)
		end
		item:SetData(v, callback(self, "OnClickHorseItem"))
		item:SetActive(true)
	end

	local emptyItem = self.m_ItemGrid:GetChild(#horseIdList + 1)
	if emptyItem == nil then 
		emptyItem = self.m_ItemCellClone:Clone()
		emptyItem:SetActive(true)	
		self.m_ItemGrid:AddChild(emptyItem)	
	end 
	emptyItem:SetData(nil, callback(self, "OnClickHorseItem"))
	emptyItem:SetActive(true)

end

function CHorseAttrPart.OnClickHorseItem(self, item)

	local horseId = item:GetHorseId()

	if horseId then 
		self.m_CurSelItem = item
		self.m_CurHorseConfig = data.ridedata.RIDEINFO[horseId]
		self.m_CurHorseId = horseId
		g_HorseCtrl:SetCurSelHorseId(horseId)
		g_HorseCtrl:SetCurSelHorseItem(item)
		self:RefreshAll()
	else
		self:OnClickEmpty()
	end 

end

--刷新所有
function CHorseAttrPart.RefreshAll(self)

	self:RefreshIntroduce()
	self:RefreshHorseAttr()
	self:RefreshHorseUseTime()
	self:RefreshHorseName()
	self:Refresh3DShow()
	self:RefreshHorseSkill()
	self:RefreshHorseRideBtn()
	self:RefreshHorseDes()

end

--刷新坐骑介绍
function CHorseAttrPart.RefreshIntroduce(self)

	self.m_HorseSumScore:SetText("坐骑评分：".. g_HorseCtrl:GetSocreById(self.m_CurHorseId))

end

--刷新坐骑属性
function CHorseAttrPart.RefreshHorseAttr(self)

	local horseData = self.m_CurHorseConfig
	for k, v in pairs(self.m_AttrGrid:GetChildList()) do 
		v:SetActive(false)
	end 
	local i = 1

	for k,v in pairs(horseData.attr) do
		local item = self.m_AttrGrid:GetChild(i)
		if item == nil then 
			item = self.m_HorseArrtLabel:Clone()
			self.m_AttrGrid:AddChild(item)
		end
		if string.find(k, "seal") then
			item:SetText(v.name.."+"..tonumber(v.val)*10)
		elseif string.find(k, "critical") then
			item:SetText(v.name.."+"..v.val.."%")
		else
			item:SetText(v.name.."+"..v.val)
		end
		item:SetActive(true)
		i = i + 1
	end
end

--刷新描述
function CHorseAttrPart.RefreshHorseDes(self)
	
	self.m_HorseDesLabel:SetText(self.m_CurHorseConfig.desc)

end

--刷新坐骑技能
function CHorseAttrPart.RefreshHorseSkill(self)

	local horseData = self.m_CurHorseConfig

	if not next(horseData.talent) then 
		self.m_SkillNode:HideAllChilds()
		self.m_TianFuNode:SetActive(false)
		return
	end 

	self.m_TianFuNode:SetActive(true)

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

--3d显示 -- modelInfo: { shape（主模型）， horse， weapon， size， angle， pos, rendertexSize }
function CHorseAttrPart.Refresh3DShow(self)

	local horseData = self.m_CurHorseConfig

	if  g_HorseCtrl.m_CurUseHorseId == self.m_CurHorseId then

    	local model_info =  table.copy(g_AttrCtrl.model_info)
	 	model_info.rendertexSize = 1.8
	 	model_info.horse = self.m_CurHorseId
	 	self.m_HorseTexture:ChangeShape(model_info)
	else
		local model_info =  table.copy(g_AttrCtrl.model_info)
	 	model_info.rendertexSize = 1.8
	 	model_info.shape = nil
	 	model_info.horse = self.m_CurHorseId
	 	model_info.show_wing = nil
	 	model_info.follow_spirit = nil
	 	self.m_HorseTexture:ChangeShape(model_info)

	end

end

--刷新名字
function CHorseAttrPart.RefreshHorseName(self)

	self.m_HorseName:SetText(self.m_CurHorseConfig.name)

end

--刷新剩余时间
function CHorseAttrPart.RefreshHorseUseTime(self)

	local horse = g_HorseCtrl:GetHorseById(self.m_CurHorseId)

	if not horse then 
		return
	end

	local leftTime =  self.m_CurSelItem.m_LeftTime or  horse.left_time

	if horse.left_time == -1 then
		
		g_TimeCtrl:DelTimer(self)
		self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]永久[-]")
		self.m_AddHorseTimeBtn:SetActive(false)

	else
		self.m_AddHorseTimeBtn:SetActive(true)

		local cb = function (time)
            
            if not time then 
                self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]过期[-]")
            else
                self.m_HorseUseTime:SetText("[244B4EFF]剩余时间:[-][a64e00]" .. time .. "[-]")
            end 

        end

        g_TimeCtrl:StartCountDown(self, leftTime, 1, cb)

	end 

end

--刷新按钮
function CHorseAttrPart.RefreshHorseRideBtn(self)
	
	if g_HorseCtrl.use_ride == self.m_CurHorseId then
		self.m_RideBtn:SetText("下骑")
	else
		self.m_RideBtn:SetText("骑乘")
	end

end


function CHorseAttrPart.OnClickEmpty(self)
	Utils.AddTimer(function ()
		self.m_ParentView:ShowSubPageByIndex(3)
	end, 0, 0.2)
end

function CHorseAttrPart.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Horse.Event.AddHorse then
		self:RefreshHorseGrid()
		for k, v in pairs( self.m_ItemGrid:GetChildList()) do 
			local id = v:GetHorseId()
			if id then
				if id == self.m_CurHorseId then 
					v.m_ItemBox:ForceSelected(true)
				else
					v.m_ItemBox:ForceSelected(false)
				end 
			end 
		end 
	end
	if oCtrl.m_EventID == define.Horse.Event.UpdateRideInfo then
		if  g_HorseCtrl:IsUsingFlyRide() then 
			--g_SummonCtrl:SendIsFollow(g_SummonCtrl.m_FollowId, 2)
		end 
		self:RefreshHorseGrid()
		self:RefreshAll()

	end

	if oCtrl.m_EventID == define.Horse.Event.UseRide then
		if  g_HorseCtrl:IsUsingFlyRide() then 
--			g_SummonCtrl:SendIsFollow(g_SummonCtrl.m_FollowId, 2)
		end 
		self:Refresh3DShow()
		self:RefreshHorseRideBtn()
		self:RefreshHorseItemUseState()
	end
end

function CHorseAttrPart.RefreshHorseItemUseState(self)
	
	for k, v in ipairs(self.m_ItemGrid:GetChildList()) do 

		v:RefreshUseRideState()


	end 

end


function CHorseAttrPart.OnRide(self)

	if g_WarCtrl:IsWar() then 
		g_NotifyCtrl:FloatMsg(g_HorseCtrl:GetTextTip(1030))
		return
	end 

	local hero = g_MapCtrl:GetHero()
	if not hero then
		return
	end

	if g_MapCtrl:CheckIsInWaterLine(hero:GetPos()) then 
		g_NotifyCtrl:FloatMsg("请在可行走区域下坐骑")
		return
	end

	if g_MapCtrl:GetMapID() ==  507000 then
		g_NotifyCtrl:FloatMsg("画舫主人有令：因画舫场地较小，不得骑乘坐骑")
		return
	end
	if g_HorseCtrl.use_ride == self.m_CurHorseId then
		--下马
		local flyFinish = function ( ... )
			g_HorseCtrl:C2GSUseRide(self.m_CurSelId, 0)
		end

		local config = self.m_CurHorseConfig

        if config.flymap > 0 and hero:IsInFlyState() then 
        	
        	local oCam = g_CameraCtrl:GetMapCamera()
        	local oHero = g_MapCtrl:GetHero()
	       -- if oHero and (not oCam.curMap:IsWalkable(oHero:GetPos().x, oHero:GetPos().y) or g_MapCtrl:CheckIsInWaterLine(oHero:GetPos()) ) then
	        if oHero and not oCam.curMap:IsWalkable(oHero:GetPos().x, oHero:GetPos().y) then
	            g_NotifyCtrl:FloatMsg("请在可行走区域下坐骑")
	            return
	        end

            g_FlyRideAniCtrl:RequestFly(flyFinish)

        else

        	g_HorseCtrl:C2GSUseRide(self.m_CurSelId, 0)

        end 

	else
		local horse = g_HorseCtrl:GetHorseById(self.m_CurHorseId)
		if horse.left_time == 0 then
			g_NotifyCtrl:FloatMsg("该坐骑已过期！")
			return
		end

		local LandDone = function()
			g_HorseCtrl:C2GSUseRide(self.m_CurHorseId, 1)
		end

		if hero:IsInFlyState() then 
			g_FlyRideAniCtrl:RequestFly(LandDone)
		else
			g_HorseCtrl:C2GSUseRide(self.m_CurHorseId, 1)
		end  

	end
end

function CHorseAttrPart.OnBuyRide(self)

	local view = CHorseMainView:GetView()
	if view then 
		view:ShowSpecificPart(3)
		view:ChooseDetailPartHorse(self.m_CurHorseId)
	end 

end

function CHorseAttrPart.OnShowSkillTips(self, item)

 --    local formula1 = string.gsub(skill.formula1, "level", g_HorseCtrl.grade)
	-- local val1 = loadstring("return "..formula1)
	-- local cur = string.gsub(skill.des, "#1", val1)
	-- local formula2 = string.gsub(skill.formula2, "level", g_HorseCtrl.grade)	
	-- local val2 = loadstring("return "..formula2)
 --    cur = string.gsub(cur, "#2", val2) 
 --    local args = {
 --        widget= item,
 --        side = enum.UIAnchor.Side.Top,
 --        icon = skill.icon,
 --        name = skill.name,
 --        --introduction = skill.des
 --        description = cur,
 --    }

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
       -- introduction = skillLevel,
        desc = config.desc,
    }
    g_WindowTipCtrl:SetWindowSkillTip(args)

end

return CHorseAttrPart