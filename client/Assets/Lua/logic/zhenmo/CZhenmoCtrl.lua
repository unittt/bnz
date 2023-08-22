local CZhenmoCtrl = class("CZhenmoCtrl", CCtrlBase)

function CZhenmoCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:Clear()
end

function CZhenmoCtrl.Clear(self)
	self.m_CurLayer = nil
	self.m_IsNewDay = false
	self.m_ZhenmoLayers = {}
end

-- 刷新镇魔塔关卡数据
function CZhenmoCtrl.GS2CZhenmoRefresh(self, layers, is_newday)

	if not next(layers) then
		self.m_ZhenmoLayers = {}
	end

	for i, v in ipairs(layers) do
		self.m_ZhenmoLayers[v.layer] = v
	end

	self.m_IsNewDay = (is_newday == 1)

end

function CZhenmoCtrl.GS2CZhenmoSpecialReward(self, rewards, isOpen, warTime)
	if isOpen == 1 then
		CZhenmoRewardView:ShowView(function(oView)
			oView:SetRewardInfo(rewards, warTime)
		end)
	else
		local oView = CZhenmoRewardView:GetView()
		if oView then
			oView:OnClose()
		end
	end
end

function CZhenmoCtrl.OpenZhenmoView(self)	
	CZhenmoView:ShowView()
end

function CZhenmoCtrl.IsInZhenmoTask(self)
	local dScene = data.zhenmodata.SCENE
	
	for k, v in pairs(dScene) do
		if g_MapCtrl.m_MapID == v.map_id then
			return true
		end
	end
	
	return false
end

function CZhenmoCtrl.SetZhenmoLayer(self, layerId)
	self.m_CurLayer = layerId
end

function CZhenmoCtrl.IsLayerComplete(self, layerId)
	local layerinfo = self:GetLayerById(layerId)

	if not layerinfo then
		return false
	end

	if layerinfo.complete == 1 then
		return true
	else
		return false
	end
end

--判断是否为重复挑战
function CZhenmoCtrl.IsLayerRePlay(self, layerId)
	local layerinfo = self:GetLayerById(layerId)
	if not layerinfo then
		return false
	end

	local stage = layerinfo.reward or 0 
	if stage == 5 then
		return true
	else
		return false
	end
end

-- 获取UI要显示的关卡信息
function CZhenmoCtrl.GetLayersInfo(self)
	local dConfig = data.zhenmodata.CONFIG

	local layerInfo = {}
	local grade = g_AttrCtrl.grade
	local layers = self:GetZhenmoLayerConfig()

	for i, v in ipairs(layers) do
		local dLayer = table.copy(v) 
		local sLayer = self:GetLayerById(v.layer_id)

		local taskCount = #dLayer.task_list
		local reward = sLayer and sLayer.reward or 0
		local bComplate = sLayer and sLayer.complete or 0

		dLayer.levelInfo = string.format("%s/%s", reward, taskCount)
		dLayer.bComplate = (bComplate == 1)  --该层已通关

		dLayer.bLayerComplete = reward >= taskCount  --每次挑战是否通关

		if g_AttrCtrl.grade < dLayer.player_level then
			dLayer.bPlay = false
		else
			dLayer.bPlay = true
		end

		table.insert(layerInfo, dLayer)
	end

	return layerInfo
end

function CZhenmoCtrl.GetLayerById(self, id)
	for i, v in pairs(self.m_ZhenmoLayers) do
		if v.layer == id then
			return v
		end
	end
end

-- 获取镇魔塔配置信息，并排序
function CZhenmoCtrl.GetZhenmoLayerConfig(self)
	local dConfig = data.zhenmodata.CONFIG

	local config = {}
	for i, v in pairs(dConfig) do
		table.insert(config, v)
	end

	table.sort(config, function(a, b)
		return a.layer_id < b.layer_id
	end)

	return config
end

return CZhenmoCtrl