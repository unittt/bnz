local CTaskItemQuickUseView = class("CTaskItemQuickUseView", CViewBase)

function CTaskItemQuickUseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/QuickUseView.prefab", cb)
end

function CTaskItemQuickUseView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_FunctionBtn = self:NewUI(4, CButton)
	self.m_NameBtn = self:NewUI(5, CLabel)
	self.m_ItemBorderSpr = self:NewUI(6, CSprite)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FunctionBtn:AddUIEvent("click", callback(self, "OnClickFunction"))

	self.m_CallBack = nil

	self.m_CountLeftTime = 0
end

function CTaskItemQuickUseView.OnClickFunction(self)
	if self.m_CountTimer then
		Utils.DelTimer(self.m_CountTimer)
		self.m_CountTimer = nil
	end
	self.m_CountLeftTime = 0
	if self.m_CallBack then
		self.m_CallBack()
	end
	self:CloseView()
end

function CTaskItemQuickUseView.SetQuickUseTaskItem(self, taskThing, taskItem, func, countTime)
	self.m_CallBack = func
	self.m_IconSprite:SpriteItemShape(taskItem.icon)
	self.m_NameLabel:SetText(taskItem.name)
	self.m_ItemBorderSpr:SetItemQuality(taskItem.quality or 0)
	self.m_NameBtn:SetText("使用")
	self.m_NameBtn:SetSpacingX(15)

	if countTime and countTime >= 0 then
		if countTime == 0 then
			self.m_NameBtn:SetText("使用")
			self.m_NameBtn:SetSpacingX(15)
			self:OnClickFunction()
			self:CloseView()
		elseif countTime > 0 then
			if self.m_CountTimer then
				Utils.DelTimer(self.m_CountTimer)
				self.m_CountTimer = nil
			end
			local function count()
				if Utils.IsNil(self) then
					return false
				end
				self.m_CountLeftTime = self.m_CountLeftTime - 1
				self.m_NameBtn:SetText("使用("..self.m_CountLeftTime..")")
				self.m_NameBtn:SetSpacingX(2)
				if self.m_CountLeftTime <= 0 then
			        self.m_CountLeftTime = 0
			        self.m_NameBtn:SetText("使用("..self.m_CountLeftTime..")")
			        self.m_NameBtn:SetSpacingX(2)
			        self:OnClickFunction()
			        return false
			    end
				return true
			end
			self.m_CountLeftTime = countTime + 1
			self.m_CountTimer = Utils.AddTimer(count, 1, 0)
		end
	end

	if self.m_QuickItemTimer then
		Utils.DelTimer(self.m_QuickItemTimer)
		self.m_QuickItemTimer = nil
	end
	local function check()
		if CTaskHelp.IsSpecityCurMap(taskThing.map_id) then
			if CTaskHelp.IsTwoPointInRadiusThing(taskThing) then
				return true
			else
				printc("主角没有到达配置的坐标")
			end
		end
		if self.m_CountTimer then
			Utils.DelTimer(self.m_CountTimer)
			self.m_CountTimer = nil
		end
		self.m_CountLeftTime = 0
		self:CloseView()
		return false
	end
	self.m_QuickItemTimer = Utils.AddTimer(check, 0.5, 0)
end

return CTaskItemQuickUseView