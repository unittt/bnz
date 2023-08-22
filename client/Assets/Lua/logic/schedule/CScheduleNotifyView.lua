local CScheduleNotifyView =  class("CScheduleNotifyView", CViewBase)

function CScheduleNotifyView.ctor(self, cb)
	-- body  
	CViewBase.ctor(self, "UI/Schedule/ScheduleNotifyView.prefab", cb) 
	self.m_ScheduleInfo = nil
	self.m_JoinBtnCB = nil
	self.m_DeleyTimer = nil
end

function CScheduleNotifyView.OnCreateView(self)
	self.m_NameSpr = self:NewUI(1, CSprite)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_MainTexture = self:NewUI(3, CTexture)
	self.m_StopWatch = self:NewUI(4, CLabel)
	self.m_ScheduleTime = self:NewUI(5, CLabel)
	self.m_LimitGrade = self:NewUI(6, CLabel)
	self.m_DropScrollView = self:NewUI(7, CScrollView)
	self.m_DropGrid = self:NewUI(8, CGrid)
	self.m_DropItemClone = self:NewUI(9, CBox)
	self.m_JoinBtn  = self:NewUI(10, CButton)
	self.m_ContentObj = self:NewUI(11, CObject)

	self:InitContent()
end

function CScheduleNotifyView.InitContent(self)
	self.m_ContentObj:SetActive(false)
	-- body
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_JoinBtn:AddUIEvent("click", callback(self, "OnJoinBtn"))
end

function CScheduleNotifyView.OnJoinBtn(self)
	-- body
	if self.m_JoinBtnCB then
		self.m_JoinBtnCB()
		self:OnClose()
	end
end

function CScheduleNotifyView.SetNotifyViewInfo(self, notifyinfo)
	-- body
	local scheduleDic = data.scheduledata.SCHEDULE

	self.m_ScheduleInfo = scheduleDic[notifyinfo.scheduleid]

	self.m_NameSpr:SetSpriteName(notifyinfo.namespr)

	self.m_ScheduleTime:SetText("活动时间:"..self.m_ScheduleInfo.activetime)

	self.m_LimitGrade:SetText("等级≥"..self.m_ScheduleInfo.level)

	local droplist = self.m_DropGrid:GetChildList()

	local rewardlist = self.m_ScheduleInfo.rewardlist

	for i=1,#rewardlist  do
		local box = nil
		local t = string.split(rewardlist[i], ":")
		local itemData = DataTools.GetItemData(t[1])
		if  i>#droplist then
			box = self.m_DropItemClone:Clone()
			box:SetGroup(self.m_DropGrid:GetInstanceID())
			self.m_DropGrid:AddChild(box)
			box.m_icon = box:NewUI(1, CSprite)
			box.m_num = box:NewUI(2, CLabel)
			box.m_qua = box:NewUI(3, CSprite)
		else
			box = droplist[i]
		end
		if itemData then
			box.m_icon:SpriteItemShape(itemData.icon)
			box.m_qua:SetItemQuality(itemData.quality)
		end
		box:AddUIEvent("click", callback(self, "OnDropInfo",box ,t[1]))
	end

	self.m_DropItemClone:SetActive(false)

	self.m_DropGrid:Reposition()
	
	if self.m_ScheduleInfo.texture == "" then
		printerror("警告:请策划配置活动：" .. self.m_ScheduleInfo.name .. "的美术图片，未配置情况下使用默认图片！配置表：https://nsvn.cilugame.com/H7/doc/trunk/daobiao/excel/schedule/schedule.xlsx")
	end
	local sTextureName = "Texture/Schedule/"..self.m_ScheduleInfo.texture..".png"

	g_ResCtrl:LoadAsync(sTextureName, callback(self, "SetTexture"))

	self:StopWatch(notifyinfo.time)

	self.m_JoinBtnCB = notifyinfo.joinbtncb
end

function CScheduleNotifyView.StopWatch(self, time)

	if self.m_DeleyTimer then
		Utils.DelTimer(self.m_DeleyTimer)
	end

	local  function func()
		-- body
		if time == 0 then
			self:CloseView()
			return false
		else
			local view = CScheduleNotifyView:GetView()
			if view then
				if self.m_ScheduleInfo.id == 1018 then
					view.m_StopWatch:SetText(time.."秒后开启")
				else
					view.m_StopWatch:SetText(time.."秒")
				end
				time = time - 1
				return true
			else
				return false
			end
		end
	end

	self.m_DeleyTimer = Utils.AddTimer(func, 1 ,0)

end
function CScheduleNotifyView.OnDropInfo(self, box, itemID)
	-- body
	local config = { widget = box }

	g_WindowTipCtrl:SetWindowItemTip(itemID, config)

end



function CScheduleNotifyView.SetTexture(self, prefab, errcode)
	if prefab then
		self.m_MainTexture:SetMainTexture(prefab)

	else
		print(errcode)

	end
	self.m_ContentObj:SetActive(true)
end


return CScheduleNotifyView