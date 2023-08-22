local CTaskPickItem = class("CTaskPickItem", CMapWalker)

function CTaskPickItem.ctor(self)
	CMapWalker.ctor(self)

	self.m_PickInfo = nil -- {pickid, name, pos_info}
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, 150, 0))
end

function CTaskPickItem.OnTouch(self)
	-- TODO >>> 点到DynamicPick
end

function CTaskPickItem.Trigger(self)
	CMapWalker.Trigger(self)
	local pickid = self.m_PickInfo.pickid
	local taskList = g_TaskCtrl:GetPickAssociatedTaskList(pickid)
	if taskList and #taskList > 0 then
		local oTask = taskList[1]
		CTaskHelp.ClickTaskLogic(oTask)
	end
end

function CTaskPickItem.SetName(self, name, color)
	-- local colorinfo = data.namecolordata.DATA[3]
	-- local nameColor = color or ("["..colorinfo.color.."]")
	CMapWalker.SetNpcName(self, name, color, define.RoleColor.DynamicNPC)
	--self, nameColor .. name, colorinfo.style, Color.RGBAToColor(colorinfo.style_color), colorinfo.blod
end

return CTaskPickItem