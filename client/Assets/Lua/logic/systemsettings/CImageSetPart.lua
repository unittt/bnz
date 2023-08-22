local CImageSetPart = class("CImageSetPart", CPageBase)

function CImageSetPart.ctor(self, obj)

	CPageBase.ctor(self, obj)

	self.AllOptions = {
		{
			name = "同屏人数",
			options = {{name = "隐藏"}, {name = "少"}, {name = "中"},{name = "多"},},
			fun = "SameScreen",
			recommendIdx = g_SystemSettingsCtrl:GetCpuLv() + 1,
		},
		{
			name = "武器特效",
			options = {{name = "隐藏"}, {name = "低"}, {name = "中"},{name = "高"},},
			fun = "WeaponEffect",
			recommendIdx = g_SystemSettingsCtrl:GetRenderLv() + 1,
		},
		{
			name = "坐骑特效",
			options = {{name = "隐藏"}, {name = "低"}, {name = "中"},{name = "高"},},
			fun = "RideEffect",
			recommendIdx = g_SystemSettingsCtrl:GetRenderLv() + 1,

		},
		{
			name = "翅膀特效",
			options = {{name = "隐藏"}, {name = "低"}, {name = "中"},{name = "高"},},
			fun = "WingEffect",
			recommendIdx = g_SystemSettingsCtrl:GetRenderLv() + 1,
		},
		{
			name = "场景特效",
			options = {{name = "隐藏"}, {name = "低", hide = true}, {name = "中", hide = true},{name = "显示"},},
			fun = "SceneEffect",
		}

	}

end

function CImageSetPart.OnInitPage(self)

	self.m_Grid = self:NewUI(1, CGrid)
	self.m_CloneGroup = self:NewUI(2, CBox)

	self:InitContent()

	self:RefreshSelect()
	
end

function CImageSetPart.RefreshSelect(self)
	
	for k, v in ipairs(self.AllOptions) do 
		local index = 1
		if v.fun == "SameScreen" then 
			index = g_SystemSettingsCtrl:GetSameScreenLv() + 1
			self:SetOptionSelect(k, index)
		elseif v.fun == "WeaponEffect" then 
			index = g_SystemSettingsCtrl:GetWeaponEffectLv() + 1
			self:SetOptionSelect(k, index)
		elseif v.fun == "RideEffect" then 
			index = g_SystemSettingsCtrl:GetRideEffectLv() + 1
			self:SetOptionSelect(k, index)
		elseif v.fun == "WingEffect" then 
			index = g_SystemSettingsCtrl:GetWingEffectLv() + 1
			self:SetOptionSelect(k, index)
		elseif v.fun == "SceneEffect" then 
			local state =  g_SystemSettingsCtrl:GetSceneEffectState()
			if state then 
				self:SetOptionSelect(k, 4)
			else
				self:SetOptionSelect(k, 1)
			end  
		end 
	end 

end

function CImageSetPart.InitContent(self)

	for k, v in ipairs(self.AllOptions) do
		local groupItem = self.m_Grid:GetChild(k) 
		if not groupItem then 
			groupItem = self.m_CloneGroup:Clone()
			groupItem:SetActive(true)
			self.m_Grid:AddChild(groupItem)
		end 
		self:InitGroupItem(groupItem, v)
	end 
	
end

function CImageSetPart.InitGroupItem(self, groupItem, info)

	groupItem.option = groupItem:NewUI(1, CBox)
	groupItem.name = groupItem:NewUI(2, CLabel)
	groupItem.grid = groupItem:NewUI(3, CGrid)
	groupItem.name:SetText(info.name)
	for k, v in ipairs(info.options) do 
		local option = groupItem.grid:GetChild(k)
		if not option then 
			option = groupItem.option:Clone()
			option:SetActive(true)
			groupItem.grid:AddChild(option)
		end 

		self:InitOption(option, v, k, info, groupItem.grid:GetInstanceID())
	end 
end

function CImageSetPart.InitOption(self, op, value, index, info, idx)
	
	op.name = op:NewUI(1, CLabel)
	op.recommend = op:NewUI(2, CSprite)
	op.icon = op:NewUI(3, CSprite)
	op.icon:SetGroup(idx)
	op.name:SetText(value.name)
	op.icon:AddUIEvent("click", callback(self, info.fun, index, info.recommendIdx, info.name))
	op:SetActive(not value.hide)
	if info.recommendIdx then 
		if info.recommendIdx == index then
			op.recommend:SetActive(true)
		end 
	end 
	
end

function CImageSetPart.SetOptionSelect(self, type, index)
	
	local groupItem = self.m_Grid:GetChild(type)
	local option = groupItem.grid:GetChild(index)
	option.icon:ForceSelected(true)

end

function CImageSetPart.SetOptionRecommend(self, type, index)
	
	local groupItem = self.m_Grid:GetChild(type)
	local option = groupItem.grid:GetChild(index)
	option.recommend:SetActive(true)

end

function CImageSetPart.ConfirmUI(self, index, effectName, cb)
	
	local tip1 = "当前机器性能较低，选择#lv档位的#effect可能导致游戏严重卡顿，是否继续？"
	local tip2 = "您将关闭游戏中所有#effect的显示，是否继续？"
	local tip = ""
	if index > 1 then
		tip1 = string.gsub(tip1, "#lv", tostring(index-1))
		tip1 = string.gsub(tip1, "#effect", effectName)
		tip = tip1
	else
		tip2 = string.gsub(tip2, "#effect", effectName)
		tip = tip2
	end 
	local windowConfirmInfo = {
	    msg = tip,
	    okCallback = function()
	    	if cb then 
	    		cb()
	    	end 
	    end,
	    cancelCallback = function()
	    	self:RefreshSelect()
	    end ,   
	    okStr = "确认",
	    cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end


function CImageSetPart.SameScreen(self, index, recommendIdx, groupName)
	
	local cb = function ()
		g_SystemSettingsCtrl:SetSameScreenLv(index - 1)
	end
	
	if index == 1 then 
		self:ConfirmUI(index, "同屏玩家", cb)
	else
		cb()
	end
	
end

function CImageSetPart.SceneEffect(self, index, recommendIdx, groupName)
	
	local cb = function ()
		g_SystemSettingsCtrl:SaveSceneLv(index - 1)
	end

	if index == 1 then 
		self:ConfirmUI(index, groupName, cb)
	else
		cb()
	end
	

end

function CImageSetPart.WeaponEffect(self, index, recommendIdx, groupName)
	
	local cb = function ()
		g_SystemSettingsCtrl:SaveWeaponLv(index - 1)
	end

	if (index > recommendIdx) or index == 1 then 
		self:ConfirmUI(index, groupName, cb)
	else
		cb()
	end
	
end

function CImageSetPart.RideEffect(self, index, recommendIdx, groupName)
	
	local cb = function ()
		g_SystemSettingsCtrl:SaveRideLv(index - 1)
	end

	if (index > recommendIdx) or index == 1 then  
		self:ConfirmUI(index, groupName, cb)
	else
		cb()
	end

end

function CImageSetPart.WingEffect(self, index, recommendIdx, groupName)
	
	local cb = function ()
		g_SystemSettingsCtrl:SaveWingLv(index - 1)
	end

	if (index > recommendIdx) or index == 1 then 
		self:ConfirmUI(index, groupName, cb)
	else
		cb()
	end
	

end


return CImageSetPart