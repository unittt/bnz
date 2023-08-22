local CZhenmoView = class("CZhenmoView", CViewBase)

function CZhenmoView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Zhenmo/ZhenmoMainView.prefab", cb)

	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"

	self.m_SelLayerId = nil
	self.m_TexturePath = "Texture/Zhenmo/%s.png"
end

function CZhenmoView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_LayerScroll = self:NewUI(2, CScrollView)
	self.m_LayerGrid = self:NewUI(3, CGrid)
	self.m_LayerBoxClone = self:NewUI(4, CBox)

	self.m_EmptyPart = self:NewUI(5, CObject)
	self.m_EmptyL = self:NewUI(6, CLabel)

	self.m_Reward = self:NewUI(7, CObject)
	self.m_RewardScroll = self:NewUI(8, CScrollView)
	self.m_RewardGrid = self:NewUI(9, CGrid)
	self.m_RewardBoxClone = self:NewUI(10, CBox)

	self.m_Btn = self:NewUI(11, CButton)
	self.m_AnimBtn = self:NewUI(12, CButton)

	self:InitContent()
end

function CZhenmoView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_Btn:AddUIEvent("click", callback(self, "OnBtnClick"))
	self.m_AnimBtn:AddUIEvent("click", callback(self, "OnAnimClick"))

	self:CreatLayers()
	self:CreatRewards()
end

function CZhenmoView.CreatLayers(self)
	local layerInfo = g_ZhenmoCtrl:GetLayersInfo()

	for i, v in ipairs(layerInfo) do
		local oLayer = self.m_LayerGrid:GetChild(i)
		if oLayer == nil then
			oLayer = self.m_LayerBoxClone:Clone()

			oLayer.m_Texture = oLayer:NewUI(1, CTexture)
			oLayer.m_BossNameL = oLayer:NewUI(2, CLabel)
			oLayer.m_Level = oLayer:NewUI(3, CLabel)
			oLayer.m_SuggestL = oLayer:NewUI(4, CLabel)
			oLayer.m_DescL = oLayer:NewUI(5, CLabel)
			oLayer.m_MaskSpr = oLayer:NewUI(6, CSprite)
			oLayer.m_MaskL = oLayer:NewUI(7, CLabel)
			oLayer.m_Mask2L = oLayer:NewUI(8, CLabel)
			oLayer.m_NameBg = oLayer:NewUI(9, CSprite)

			if not v.bPlay then
				oLayer.m_MaskSpr:SetActive(true)
				oLayer.m_NameBg:SetSpriteName("h7_shilian_1")
				oLayer.m_MaskL:SetText(string.format("%d级开启", v.player_level))
				oLayer.m_Mask2L:SetText(string.format("%d级开启", v.player_level))
			else
				oLayer.m_MaskSpr:SetActive(false)
				oLayer.m_NameBg:SetSpriteName("h7_shilian_2")
			end

			oLayer:SetGroup(self.m_LayerGrid:GetInstanceID())
			oLayer:AddUIEvent("click", callback(self, "OnLayerClick", i, v))

			oLayer:SetActive(true)
			self.m_LayerGrid:AddChild(oLayer)
		end

		oLayer.m_BossNameL:SetText(v.boss_name)
		oLayer.m_Level:SetText(string.format("通关: %s", v.levelInfo))
		oLayer.m_SuggestL:SetText(string.format("建议%s级挑战", v.server_level))
		oLayer.m_DescL:SetText(v.desc)

		local dTexture = string.format(self.m_TexturePath, v.texture_name)
		g_ResCtrl:LoadAsync(dTexture, function(tex, errcode)
			if tex then
				oLayer.m_Texture:SetMainTexture(tex)
			else
				print(errcode)
			end
		end)
	end

	self.m_LayerGrid:AddChild(self.m_EmptyPart)

	self.m_LayerGrid:Reposition()
	self.m_LayerScroll:ResetPosition()

	self:SetDefaultSelect()
	self:ShowAnimBtn()
end

-- 默认显示关卡界面
function CZhenmoView.SetDefaultSelect(self)
	local layerInfo = g_ZhenmoCtrl:GetLayersInfo()
	if layerInfo[1].bPlay == false then
		self.m_SelLayerId = layerInfo.layer_id
		g_ZhenmoCtrl:SetZhenmoLayer(layerInfo.layer_id)
		return
	end

	local dx = self.m_LayerGrid:GetCellSize()

	for i=#layerInfo, 1, -1 do
		local layer = layerInfo[i]
		if not layer.bLayerComplete and layer.bPlay then
			local idx = i --标记所选中的层
			if g_ZhenmoCtrl.m_IsNewDay and i > 1 then
				idx = idx - 1
			end
			local oLayer = self.m_LayerGrid:GetChild(idx)
			if oLayer then
				oLayer:SetSelected(true)
				self.m_SelLayerId = layerInfo[idx].layer_id
			end

			local temp = math.clamp(i, 2, 5)
			local newX = -(temp - 2)*dx
			self.m_LayerScroll:MoveRelative(Vector3.New(newX, 0, 0))  --scrollview划动进度
			-- Utils.AddTimer(function()
			-- 	self.m_LayerScroll:MoveRelative(Vector3.New(newX, 0, 0))  --scrollview划动进度
			-- end, 0, 0)
			return
		end
	end

	--全部通关,选第1层
	self:SetFirstLayerSelect()
end

function CZhenmoView.SetFirstLayerSelect(self)
	local layerInfo = g_ZhenmoCtrl:GetLayersInfo()
	local id = layerInfo[1].layer_id
	self.m_SelLayerId = id
	g_ZhenmoCtrl:SetZhenmoLayer(id)
	local oLayer = self.m_LayerGrid:GetChild(1)
	if oLayer then
		oLayer:SetSelected(true)
	end
end

function CZhenmoView.CreatRewards(self)

	if not self.m_SelLayerId then
		return
	end

	self.m_RewardGrid:Clear()
	local dConfig = data.zhenmodata.CONFIG[self.m_SelLayerId]

	local rewardlist = dConfig.itemlist
	for i, v in ipairs(rewardlist) do
		local dReward = DataTools.GetReward("ZHENMO", v)
		local oReward = self.m_RewardGrid:GetChild(i)
		if oReward == nil then
			oReward = self.m_RewardBoxClone:Clone()

			oReward.m_Icon = oReward:NewUI(1, CSprite)
			oReward.m_Quality = oReward:NewUI(2, CSprite)
			oReward.m_CountL = oReward:NewUI(3, CLabel)

			oReward:AddUIEvent("click", callback(self, "OnItemClick", i, dReward.sid))
			oReward:SetActive(true)
			self.m_RewardGrid:AddChild(oReward) 
		end

		local itemdata = DataTools.GetItemData(dReward.sid)
		oReward.m_Icon:SpriteItemShape(itemdata.icon)
		oReward.m_Quality:SetItemQuality(itemdata.quality)
		oReward.m_CountL:SetText(dReward.amount)
	end

	self.m_RewardGrid:Reposition()
	self.m_RewardScroll:ResetPosition()

end

function CZhenmoView.OnLayerClick(self, idx, layerInfo)
	if self.m_SelLayerId == layerInfo.layer_id then
		return
	end
	self.m_SelLayerId = layerInfo.layer_id
	g_ZhenmoCtrl:SetZhenmoLayer(layerInfo.layer_id)
	local oLayer = self.m_LayerGrid:GetChild(idx)
	oLayer:SetSelected(true)
	self:CreatRewards()
	self:ShowAnimBtn()
end

function CZhenmoView.ShowAnimBtn(self)
	local bShow = g_ZhenmoCtrl:IsLayerComplete(self.m_SelLayerId)
	self.m_AnimBtn:SetActive(bShow)
end

function CZhenmoView.OnBtnClick(self)
	local opendata = DataTools.GetViewOpenData("ZHENMO")

	if self.m_SelLayerId == nil or g_AttrCtrl.grade < opendata.p_level then
		local msg = string.format("请提升到%s级再来", opendata.p_level)
		g_NotifyCtrl:FloatMsg(msg)
		return
	end

	local bCompleted = g_ZhenmoCtrl:IsLayerComplete(self.m_SelLayerId)
	local bRePlay = g_ZhenmoCtrl:IsLayerRePlay(self.m_SelLayerId)
	--printc("bRePlay ========================== "..tostring(bRePlay))
	if bCompleted and bRePlay then
		local msg = data.zhenmodata.TEXT[1003].content
		local args = {
			msg = msg,
			okCallback = function()
				self:EnterLayer()
			end,
		}

		g_WindowTipCtrl:SetWindowConfirm(args)
	else
		self:EnterLayer()
	end
end

function CZhenmoView.EnterLayer(self)
	nettask.C2GSZhenmoEnterLayer(self.m_SelLayerId)
	self:CloseView()
end

function CZhenmoView.OnAnimClick(self)
	if self.m_SelLayerId == nil then
		g_NotifyCtrl:FloatMsg("请选择关卡")
		return
	end

	if not g_ZhenmoCtrl:IsLayerComplete(self.m_SelLayerId) then
		g_NotifyCtrl:FloatMsg("通关后可观看剧情动画")
		return
	end

	local dConfig = data.zhenmodata.CONFIG
	local anim = dConfig[self.m_SelLayerId].anim

	nettask.C2GSZhenmoPlayAnim(anim)
end

function CZhenmoView.OnItemClick(self, idx, sid)
	local oItem = self.m_RewardGrid:GetChild(idx)

	local args = {
		widget = oItem,
	}
	g_WindowTipCtrl:SetWindowItemTip(sid, args)
end


return CZhenmoView