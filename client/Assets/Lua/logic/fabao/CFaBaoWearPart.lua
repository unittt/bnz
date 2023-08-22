local CFaBaoWearPart = class("CFaBaoWearPart", CPageBase)

function CFaBaoWearPart.ctor(self, obj)
	CPageBase.ctor(self, obj)

	self.m_SelIndex = 0 --选择未穿戴法宝
	self.m_SelFaBao = nil --选择已穿戴法宝
	self.m_FaBaoPatchCount = 0 --碎片数量
end

function CFaBaoWearPart.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_WearGrid = self:NewUI(2, CGrid)
	self.m_ItemWearClone = self:NewUI(3, CBox)
	self.m_ScoreL = self:NewUI(4, CLabel)
	self.m_FaBaoCell = self:NewUI(5, CBox)
	self.m_FaBaoScroll = self:NewUI(6, CScrollView)
	self.m_FaBaoGrid = self:NewUI(7, CGrid)
	self.m_AttrInfoBox = self:NewUI(8, CFaBaoAttrBox)

	self.m_MakeBtn = self:NewUI(9, CButton)
	self.m_DesginatedMakeBtn = self:NewUI(10, CButton)
	self.m_DeComposeBtn = self:NewUI(11, CButton)
	self.m_WearBtn = self:NewUI(12, CButton)
	self.m_PromoteBtn = self:NewUI(13, CButton)
	self.m_UnWearBtn = self:NewUI(14, CButton)
	self.m_DevelopBtn = self:NewUI(15, CButton)

	self:InitContent()
end

function CFaBaoWearPart.OnShowPage(self)
	CPageBase.OnShowPage(self)

	self:UpdateFabaoScore()
	self:InitFaBaoPatch()
end

function CFaBaoWearPart.InitContent(self)
	self:InitModel()
	self:InitBtns()
	self:RefreshFaBao()
	self:RefreshWears()

	g_FaBaoCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFaBaoEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemEvent"))
end

function CFaBaoWearPart.UpdateFabaoScore(self)
	local score = g_FaBaoCtrl:GetFaBaoScore()
	self.m_ScoreL:SetText(score)
end

-- 玩家模型
function CFaBaoWearPart.InitModel(self)
	if g_AttrCtrl.model_info.horse and g_AttrCtrl.model_info.horse ~= 0 then
		g_AttrCtrl.model_info.size = data.ridedata.RIDEINFO[g_AttrCtrl.model_info.horse].size
		local dInfo = table.copy(g_AttrCtrl.model_info)
		local model_info =   table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 2
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = -25
		self.m_ActorTexture:SetLocalPos(lp)
	else
		local model_info =  table.copy(g_AttrCtrl.model_info)
	    model_info.rendertexSize = 1.4
		self.m_ActorTexture:ChangeShape(model_info)
		local lp = self.m_ActorTexture:GetLocalPos()
		lp.y = 9
		self.m_ActorTexture:SetLocalPos(lp)
	end
end

-- 法宝碎片
--法宝碎片与未穿戴的法宝共用self.m_FaBaoCell进行初始化
function CFaBaoWearPart.InitFaBaoPatch(self)
	self.m_FaBaoPatch = self.m_FaBaoCell:Clone()
	self.m_FaBaoPatch.m_Icon = self.m_FaBaoPatch:NewUI(1, CSprite)
	self.m_FaBaoPatch.m_Count = self.m_FaBaoPatch:NewUI(2, CLabel)
	self.m_FaBaoPatch.m_QualitySpr = self.m_FaBaoPatch:NewUI(3, CSprite)

	local sid = data.fabaodata.COMBINE[1].itemsid
	self.m_FaBaoPatchCount = g_ItemCtrl:GetBagItemAmountBySid(sid)

	local itemdata = DataTools.GetItemData(sid)
	self.m_FaBaoPatch.m_Icon:SpriteItemShape(itemdata.icon)
	self.m_FaBaoPatch.m_QualitySpr:SetItemQuality(itemdata.quality)
	self.m_FaBaoPatch.m_Count:SetText(self.m_FaBaoPatchCount)

	self.m_FaBaoPatch:AddUIEvent("click", callback(self, "OnFaBaoPatchClick"))

	local groupId = self:GetInstanceID()
	self.m_FaBaoPatch:SetGroup(groupId)
    self.m_FaBaoPatch:SetActive(true)
    self.m_FaBaoPatch:SetParent(self.m_Transform)
end

-- 拥有但未穿戴的法宝
function CFaBaoWearPart.RefreshFaBao(self)
	local FaBaolist = g_FaBaoCtrl:GetFaBaoUnWear()
	local count = 4 --默认4格
	if table.count(FaBaolist) > 4 then
		count = table.count(FaBaolist)
	end

	self.m_FaBaoGrid:Clear()
	for i = 1, count do
		local oFaBao = self.m_FaBaoGrid:GetChild(i)
		if oFaBao == nil then
			oFaBao = self.m_FaBaoCell:Clone()
			oFaBao.m_Icon = oFaBao:NewUI(1, CSprite)
			oFaBao.m_Level = oFaBao:NewUI(2, CLabel)
			--oFaBao.m_QualitySpr = oFaBao:NewUI(3, CSprite)

			local groupId = self:GetInstanceID()
			oFaBao:SetGroup(groupId)
			
			oFaBao:SetActive(true)	
			oFaBao:SetLocalPos(Vector3.zero)
			self.m_FaBaoGrid:AddChild(oFaBao)
		end
		local fabao = FaBaolist[i]
		if fabao then
			local dInfo = data.fabaodata.INFO[fabao.fabao]
			local level = fabao.level or 0
			oFaBao.m_Icon:SpriteItemShape(dInfo.icon)
			oFaBao.m_Level:SetText(level > 0 and (level.."级") or "")
			-- todo --
			oFaBao:AddUIEvent("click", callback(self, "OnFaBaoClick", i, fabao))
			-- 法宝数量 --
		end
	end
	self.m_FaBaoGrid:Reposition()
	self.m_FaBaoScroll:ResetPosition()
end

-- 已穿戴法宝
function CFaBaoWearPart.RefreshWears(self)

	local FaBaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	local groupId = self:GetInstanceID()
	local wearlist = g_FaBaoCtrl:GetFaBaoWearCount()

	self.m_WearGrid:Clear()
	for i = 1, #wearlist do
		local oWear = self.m_WearGrid:GetChild(i)
		if oWear == nil then
			oWear = self.m_ItemWearClone:Clone()

			oWear.m_IconSpr = oWear:NewUI(1, CSprite)
			oWear.m_OpenGrade = oWear:NewUI(2, CLabel)
			oWear.m_Level = oWear:NewUI(3, CLabel)

			oWear:SetGroup(groupId)
			oWear:SetActive(true)
			self.m_WearGrid:AddChild(oWear)
		end

		local fabao = FaBaolist[i]
		if fabao then
			local dInfo = data.fabaodata.INFO[fabao.fabao]
			local level = fabao.level or 0
			oWear.m_IconSpr:SetActive(true)
			oWear.m_IconSpr:SpriteItemShape(dInfo.icon)
			oWear.m_Level:SetText(level > 0 and (level.."级") or "")
			oWear:AddUIEvent("click", callback(self, "OnWearClick", i, fabao))
		end
		local grade = wearlist[i].grade
		if g_AttrCtrl.grade < grade then
			oWear.m_IconSpr:SetActive(false)
			oWear.m_OpenGrade:SetText(grade.."级开启")
		end
	end
	self.m_WearGrid:Reposition()
end

function CFaBaoWearPart.InitBtns(self)
	self.m_BtnList = {
		[1] = self.m_MakeBtn,
		[2] = self.m_DesginatedMakeBtn,
		[3] = self.m_DeComposeBtn,
		[4] = self.m_WearBtn,
		[5] = self.m_PromoteBtn,
		[6] = self.m_UnWearBtn,
		[7] = self.m_DevelopBtn,
	}
	self.m_MakeBtn:AddUIEvent("click", callback(self, "OnMake"))
	self.m_DesginatedMakeBtn:AddUIEvent("click", callback(self, "OnDesginatedMake"))
	self.m_DeComposeBtn:AddUIEvent("click", callback(self, "OnDeCompose"))
	self.m_WearBtn:AddUIEvent("click", callback(self, "OnWear"))
	self.m_PromoteBtn:AddUIEvent("click", callback(self, "OnPromote"))
	self.m_UnWearBtn:AddUIEvent("click", callback(self, "OnUnWear"))
	self.m_DevelopBtn:AddUIEvent("click", callback(self, "OnPromote"))

	local FaBaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	if #FaBaolist > 0 then
		self.m_DevelopBtn:SetActive(true)
	end
end

-- 管理合成、指定合成、分解、穿戴、卸下、培养按钮
function CFaBaoWearPart.ShowButton(self, iType)
	if iType == 1 then
		for i, v in ipairs(self.m_BtnList) do
			v:SetActive(i >= 5)
		end
	elseif iType == 2 then
		for i, v in ipairs(self.m_BtnList) do
			v:SetActive(i > 2 and i < 5)	
		end
	else
		for i, v in ipairs(self.m_BtnList) do
			v:SetActive(i <= 2)	
		end
	end
	self.m_DevelopBtn:SetActive(false)
end

function CFaBaoWearPart.OnWearClick(self, idx, fabaoInfo)
	self.m_SelIndex = 0

	if self.m_SelFaBao and self.m_SelFaBao.id == fabaoInfo.id then
		return
	end

	self.m_SelFaBao = fabaoInfo
	self:ShowButton(define.FaBao.Type.WearFabao)
	self.m_AttrInfoBox:SetAttrInfo(fabaoInfo.id)

	self.m_WearGrid:GetChild(idx):SetSelected(true)
end

function CFaBaoWearPart.OnFaBaoClick(self, idx, fabaoInfo)

	self.m_SelFaBao = nil

	if self.m_SelIndex == idx then
		return
	end
	self.m_SelIndex = idx

	self.m_FaBaoGrid:GetChild(idx):SetSelected(true)
	self:ShowButton(define.FaBao.Type.Fabao)
	self.m_AttrInfoBox:SetAttrInfo(fabaoInfo.id)
end

function CFaBaoWearPart.OnFaBaoPatchClick(self)
	self.m_SelIndex = 0  -- 重置未穿戴法宝选择
	self.m_SelFaBao = nil  -- 重置法已穿戴宝选择
 
	self.m_FaBaoPatch:SetSelected(true)
	self:ShowButton(define.FaBao.Type.FaBaoPatch)

	if self.m_FaBaoPatchCount <= 0 then
		self:ShowGainWayView()
	end
end

function CFaBaoWearPart.ShowGainWayView(self)
	local sid = data.fabaodata.COMBINE[1].itemsid
	g_WindowTipCtrl:SetWindowGainItemTip(sid, function ()
	    local oView = CItemTipsView:GetView()
	    UITools.NearTarget(self.m_FaBaoPatch, oView.m_MainBox, enum.UIAnchor.Side.Top, Vector2.New(0, 10))
	end)
end

-- function CFaBaoWearPart.CheckFaBaoPatchCount(self)
-- 	local sid = data.fabaodata.COMBINE[1].itemsid
-- 	local count = g_ItemCtrl:GetBagItemAmountBySid(sid)
-- 	local needAmount = data.fabaodata.COMBINE[1].amount
-- 	if count < needAmount then
-- 		local itemlist = {{sid = sid,  count = count, amount= needAmount}}
-- 		g_QuickGetCtrl:CurrLackItemInfo(itemlist, {}, nil, function()
-- 			netfabao.C2GSCombineFaBao(1)
-- 		end)
-- 	else
-- 		netfabao.C2GSCombineFaBao(1)
-- 	end
-- end

--合成
function CFaBaoWearPart.OnMake(self)
	local dtext = data.fabaodata.TEXT[1001].content
	local msg = "[63432C]"..dtext
	local args = {
            msg = msg,
            title = "提示",
            color = Color.white,
            okCallback = function ()
            	netfabao.C2GSCombineFaBao(1)
            end,
        }
    g_WindowTipCtrl:SetWindowConfirm(args)
end

--指定合成
function CFaBaoWearPart.OnDesginatedMake(self)
	CFaBaoMakeView:ShowView()
end

--分解
function CFaBaoWearPart.OnDeCompose(self)
	local FaBaolist = g_FaBaoCtrl:GetFaBaoUnWear()
	local faBao = FaBaolist[self.m_SelIndex]
	if not faBao then
		g_NotifyCtrl:FloatMsg("请选择法宝")
		return
	end

	local text = data.fabaodata.TEXT[1005].content

	local fname = data.fabaodata.INFO[faBao.fabao].name
	local itemsid = data.fabaodata.DECOMPOSE[1].itemsid
	local itemdata = DataTools.GetItemData(itemsid)
	local itemname = itemdata.name

	local msg = string.gsub(text, "#item", fname, 1)
	msg = string.gsub(msg, "#item", itemname, 1)
	msg = string.gsub(msg, "1", faBao.level, 1)
	local args = {
            msg = "[63432C]"..msg,
            title = "提示",
            color = Color.white,
            okCallback = function ()
                netfabao.C2GSDeComposeFaBao(faBao.id)
            end,
        }
    g_WindowTipCtrl:SetWindowConfirm(args)
end

--穿戴
function CFaBaoWearPart.OnWear(self)
	local FaBaolist = g_FaBaoCtrl:GetFaBaoUnWear()
	local FaBao = FaBaolist[self.m_SelIndex]
	if FaBao then
		local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
		local bOnWear = false --已穿戴
		for i, v in ipairs(fabaolist) do
			if v.fabao == FaBao.fabao then
				bOnWear = true
				break
			end
		end

		if bOnWear then
			local text = data.fabaodata.TEXT[1004].content
			local fname = data.fabaodata.INFO[FaBao.fabao].name
			local msg = string.gsub(text, "#item", fname)

			local args = {
			 	msg = "[63432C]"..msg,
            	title = "提示",
            	color = Color.white,
            	okCallback = function()
            		netfabao.C2GSWieldFaBao(FaBao.id)
            	end
			}
			g_WindowTipCtrl:SetWindowConfirm(args)
		else
			netfabao.C2GSWieldFaBao(FaBao.id)
		end
	else
		g_NotifyCtrl:FloatMsg("请选择法宝")
	end
end

--卸下
function CFaBaoWearPart.OnUnWear(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	if #fabaolist <= 0 then
		g_NotifyCtrl:FloatMsg("目前没有佩戴的法宝")
		return 
	end
	if self.m_SelFaBao == nil then 
		g_NotifyCtrl:FloatMsg("请选择法宝")
		return 
	end

	local id = self.m_SelFaBao.id
	netfabao.C2GSUnWieldFaBao(id)
end

function CFaBaoWearPart.OnPromote(self)
	local fabaolist = g_FaBaoCtrl:GetFaBaoOnWear()
	if #fabaolist <= 0 then
		g_NotifyCtrl:FloatMsg("目前没有佩戴的法宝")
		return 
	end
	CFaBaoView:ShowView(function(oView)
		oView:ShowSubPageByIdx(2)
	end)
end

function CFaBaoWearPart.OnFaBaoEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FaBao.Event.RefreshFaBaolist then
		self:UpdateFabaoScore()
		self:RefreshFaBao()
		self:RefreshWears()
		self.m_SelIndex = 0 
		self.m_SelFaBao = nil 
	elseif  oCtrl.m_EventID == define.FaBao.Event.RefreshFaBaoInfo then
		self:RefreshWears()
	elseif oCtrl.m_EventID == define.FaBao.Event.RefrershFaBaoPatch then
		local sid = data.fabaodata.COMBINE[1].itemsid
		local faBaoPatchCount = g_ItemCtrl:GetBagItemAmountBySid(sid)
		if faBaoPatchCount > 0 then
			self.m_FaBaoPatch.m_Count:SetText(faBaoPatchCount)
		else
			self.m_FaBaoPatch.m_Count:SetText("")
		end
	end
end

function CFaBaoWearPart.OnItemEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		local sid = oCtrl.m_EventData:GetSValueByKey("sid")
		self:ResetFabaoPatch(sid)
	elseif oCtrl.m_EventID == define.Item.Event.ItemAmount then
		local sid = oCtrl.m_EventData
		self:ResetFabaoPatch(sid)
	end
end

function CFaBaoWearPart.ResetFabaoPatch(self, sid)
	local itemsid = data.fabaodata.COMBINE[1].itemsid
	if sid == itemsid then
		local faBaoPatchCount = g_ItemCtrl:GetBagItemAmountBySid(sid)
		self.m_FaBaoPatch.m_Count:SetText(faBaoPatchCount)
	end
end

return CFaBaoWearPart