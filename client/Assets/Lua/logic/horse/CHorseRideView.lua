local CHorseRideView = class("CHorseRideView", CViewBase)
function CHorseRideView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Horse/HorseRideView.prefab", cb)
	self.m_DepthType = "Dialog"
    self.m_GroupName = "main"
    self.m_ExtendClose = "Black"
end

function CHorseRideView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
    self.m_HorseName = self:NewUI(2, CLabel)
    self.m_HorseTexture = self:NewUI(3, CActorTexture)
    self.m_ActiveBtn = self:NewUI(4, CButton)
    self.m_ConditionGrid = self:NewUI(5, CGrid)
    self.m_ItemClone = self:NewUI(6, CHorseActiveConditionBox)
    self.m_Des = self:NewUI(7, CLabel)
    self:InitContent()
end

function CHorseRideView.InitContent(self)
    self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
    self.m_ActiveBtn:AddUIEvent("click", callback(self, "OnActiveBtn"))
end

function CHorseRideView.SetInfo(self, id)

    self.m_CurSelId = id
    self.m_HorseData = data.ridedata.RIDEINFO[id]
    local model_info =  table.copy(g_AttrCtrl.model_info)
 	model_info.rendertexSize = 1.8
 	model_info.horse = id
    self.m_HorseTexture:ChangeShape(model_info)
    self.m_HorseName:SetText(self.m_HorseData.name)

    self.m_ActiveBtn:SetActive(true)

end

function CHorseRideView.SetConditionInfo(self, data)

	local conditionList = {}

	--玩家等级
	if data.player_level ~= 0 then 
		local item = {}
		item.name = "玩家等级："
		item.condition = data.player_level
		item.type = "playeLv"
		table.insert(conditionList, item)
	end
	--坐骑等级
	if data.ride_level ~= 0 then 
		local item = {}
		item.name = "坐骑等级："
		item.condition = data.ride_level
		item.type = "RideLv"
		table.insert(conditionList, item)
	end 
	--物品
	if #data.activate_item ~= 0 then 
		for k, v in pairs(data.activate_item) do 
			local item = {}
			item.count = v.cnt
			item.type = "item"
			item.id = v.itemid
			table.insert(conditionList, item)
		end 
	end 

	--创建
	self.m_ConditionGrid:HideAllChilds()

	for k, v in ipairs(conditionList) do 
		local item = self.m_ConditionGrid:GetChild(k)
		if item == nil then
			item = self.m_ItemClone:Clone()
			item:SetActive(true)	
			self.m_ConditionGrid:AddChild(item)	
		end

		item:SetInfo(v)
		item:SetActive(true)	

	end

end

function CHorseRideView.OnActiveBtn(self)

	if self.m_HorseData.activeType == 1 then

        local windowConfirmInfo = {
            title = "特殊坐骑",
            msg = "翻云鲤为特殊坐骑，充值返利可获取，是否前往？",
            okCallback = callback(g_ShopCtrl, "ShowChargeView", function(oView)
                oView.m_RechargePart:RebateCallBack()
            end),
            pivot = enum.UIWidget.Pivot.Center,
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	elseif self.m_HorseData.activeType == 2 then 
			CFuncNotifyMainView:ShowView(function (oView)
				oView:RefreshUI(g_GuideHelpCtrl.m_RideGuideIndex)
			end)
	elseif  self.m_HorseData.activeType == 3 then 
		local windowConfirmInfo = {
			title = "特殊坐骑",
			msg	= "青鸾为特殊坐骑，可以通过拍卖获得，请留意拍卖信息。",	
			pivot = enum.UIWidget.Pivot.Center,
			thirdStr = "确定",
			thirdCallback = function ( ... )
			end,
			style = CWindowComfirmView.Style.Single,

		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	else
	    CHorseBuyView:ShowView(function (oView)
			oView:SetInfo(self.m_CurSelId)
		end)
	end 

    self:OnClose()

end

return CHorseRideView