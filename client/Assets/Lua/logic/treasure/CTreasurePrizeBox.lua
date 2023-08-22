local CTreasurePrizeBox = class("CTreasurePrizeBox", CBox)

function CTreasurePrizeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_Panel = self:NewUI(1, CPanel)
	self.m_WrapObj = self:NewUI(2,CObject)
end

--设置目标数字和转动圈数
function CTreasurePrizeBox.SetEachNum(self, prizenum, prizetime, oStrength, isUpDirection)
	local time = prizetime or 1

	-- self.m_WrapObj:SetLocalPos(Vector3.New(0, 100*prizenum, 0))
	-- self.m_Panel:GetComponent(classtype.SpringPanel).target = Vector3.New(0, 100*prizenum, 0)
	-- NGUI.SpringPanel.Begin(self.m_Panel.m_GameObject, Vector3.New(0,-100*self:GetTotalTurnCount(prizenum, 0),0), oStrength or 2)
	
	--大于1圈
	if time > 0 then
		if isUpDirection then
			local num = self:GetTotalTurnCountUpDirection(prizenum, time)
			NGUI.SpringPanel.Begin(self.m_Panel.m_GameObject, Vector3.New(0,100*num,0), oStrength or 2)
		else
			local num = self:GetTotalTurnCount(prizenum, time)
			NGUI.SpringPanel.Begin(self.m_Panel.m_GameObject, Vector3.New(0,-100*num,0), oStrength or 2)
		end

		local oPanel = self.m_Panel:GetComponent(classtype.SpringPanel)
		oPanel.onFinished = function ()
			-- printc("gggggggggggggggggg", prizenum)
			if self.m_Callback then
				self.m_Callback()
			end
		end
	else
		self.m_WrapObj:SetLocalPos(Vector3.New(0, 100*prizenum, 0))
	end
end

--暂时不起作用
function CTreasurePrizeBox.Reset(self)
	NGUI.SpringPanel.Begin(self.m_Panel.m_GameObject, Vector3.New(0, 100*10 ,0), 100)
end

--获取转动的循环数，每次循环panel-100，传一个目标数字和一个转动的圈数
function CTreasurePrizeBox.GetTotalTurnCount(self, targetnum, time)
	if targetnum == 0 then
		targetnum = 10
	end
	local list = {9,8,7,6,5,4,3,2,1,0}
	if targetnum >= 5 then
		return list[targetnum]+time*10
	else
		return list[targetnum]+time*10
	end
end

function CTreasurePrizeBox.GetTotalTurnCountUpDirection(self, targetnum, time)
	if targetnum == 0 then
		targetnum = 10
	end
	local list = {1,2,3,4,5,6,7,8,9,0}
	if targetnum >= 5 then
		return list[targetnum]+time*10
	else
		return list[targetnum]+time*10
	end
end

function CTreasurePrizeBox.SetLabelColor(self,color)
	local sublist = self.m_WrapObj.m_GameObject:GetComponentsInChildren(classtype.UILabel)
	for i = 1, sublist.Length do
		sublist[i-1].color = color
	end
end

return CTreasurePrizeBox