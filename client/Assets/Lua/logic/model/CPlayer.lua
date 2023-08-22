local CPlayer = class("CPlayer", CMapWalker)

function CPlayer.ctor(self)
	CMapWalker.ctor(self)
	
	self.m_Eid = nil --场景中唯一的ID
	self.m_Pid = nil --角色ID
	self.m_Icon = nil
	self.m_Followers ={} --跟随宠物列表
	self.m_CheckTimer = nil
	self.m_IsInWaterPoint = false
	self.m_IsUsing = true
	self.treasureconvoy_tag = nil
	self.m_HudDoneListener = callback(self, "HudDone")
	if g_MapCtrl:IsInWaterMap() then
		self.m_CheckTimer = Utils.AddTimer(callback(self, "Check"), 0.1, 0)
	end
end

function CPlayer.Reset(self)
	CMapWalker.Reset(self)
	self.m_Eid = nil --场景中唯一的ID
	self.m_Pid = nil --角色ID
	self.m_Icon = nil
	self.m_Followers ={}

	self.m_IsInWaterPoint = false

	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
	end
	self.m_CheckTimer = nil
	self.m_CreateTime = nil
	self.treasureconvoy_tag = nil
end

function CPlayer.Destroy(self)
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	CMapWalker.Destroy(self)
end

function CPlayer.CheckInWaterPointArea(self)
	--这里是设置脚底挂点的角度
	-- if self.m_IsFlyWaterProgress then
	-- 	self.m_FootTransObj:SetLocalRotation(Quaternion.Euler(0, self.m_Actor.m_Transform.localEulerAngles.y + 120, 0))
	-- else
	-- 	self.m_FootTransObj:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	-- end
	
	local isInWaterPoint = g_MapCtrl:CheckInWaterPointArea(self)
	if isInWaterPoint ~= self.m_IsInWaterPoint then
		self.m_IsInWaterPoint = isInWaterPoint
	end
end

function CPlayer.Check(self, dt)
	if not g_MapCtrl:IsInWaterMap() then
		return
	end
	if  self:IsTriggerWaterRun() then 
		self:CheckInWaterPointArea()
	end 
	return true
end

function CPlayer.OnTouch(self)
	if g_MapCtrl:IsInOrgMatchMap() then
		if self.m_OrgId ~= g_AttrCtrl.org_id then
			nethuodong.C2GSOrgWarStartFight(self.m_Pid)
			return
		end
	end
	if self:IsInConvoyTask() then 
		g_MiBaoConvoyCtrl:TryRob(self.m_Pid)
		return
	end 
	local oView = CMainMenuView:GetView()
	if oView then
		oView.m_Center:ShowPlayerAvatar(self.m_Pid)
	end
	g_GuessRiddleCtrl:TouchPlayer(self.m_Pid, self:GetPos())
end

function CPlayer.SetName(self, name, color)
	-- local colorinfo = data.namecolordata.DATA[1]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	CMapWalker.SetName(self, name, color, define.RoleColor.Player)
	--self, nameColor .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod
end

function CPlayer.IsInConvoyTask(self)

	if self.treasureconvoy_tag == 1 then 
		return true
	end 
	return false

end 

function CPlayer.HudDone(self, sType)

	if self:IsInConvoyTask() then 
		if sType == "convoyTag" or sType == "fight" then 
			self:HideHudByType(sType, false)
		else
			self:HideHudByType(sType, true)
		end  
	end  
	
end 

function CPlayer.SetConvoyTag(self)

	self:TryHideAllHud(true)
	self:AddBindObj("convoyTag") 
	
end 

function CPlayer.DelConvoyTag(self)

	self:DelBindObj("convoyTag", true)
	self:TryHideAllHud(false)

end 

function CPlayer.SetUsing(self, isUsing)
	CMapWalker.SetUsing(self, isUsing)
	if isUsing then
		if not self.m_CheckTimer then
			self.m_CheckTimer = Utils.AddTimer(callback(self, "Check"), 0.1, 0)
		end
	end
end
return CPlayer