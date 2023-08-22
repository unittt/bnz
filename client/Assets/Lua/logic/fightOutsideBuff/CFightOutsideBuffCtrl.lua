local CFightOutsideBuffCtrl = class("CFightOutsideBuffCtrl", CCtrlBase)


--登录时收到的buff数据
function CFightOutsideBuffCtrl.GS2CLoginState(self, stateList)
	--[[    optional uint32 state_id = 1;          //状态id
    optional uint32 time = 2;               //剩余时间
    optional string name = 3;            
    optional string desc = 4;
    repeated  StateAttr data =5;]]
    
    if stateList ~= nil then 

    	self.m_buffDataList = {}

		for k , v in pairs(stateList) do 

			self:AddState(v)

		end

	self:Sort(self.m_buffDataList)

	self:OnEvent(define.FightOutsideBuff.Event.StateChange, self)
	

    end 

end



--排序
function CFightOutsideBuffCtrl.Sort(self)

	local sortFun = function (a, b)
		
		return tonumber(a.weight) < tonumber(b.weight)  

	end

	table.sort(self.m_buffDataList, sortFun)
end

function CFightOutsideBuffCtrl.AddState(self, state)

	if self.m_buffDataList ~= nil then 

		local buffData = {}
		local config = data.buffStatedata.buffState[state.state_id]
		if config ~= nil then 

			buffData.time = state.time
			buffData.attrList = state.data
			buffData.hide = state.hide
			buffData.id = config.id
			buffData.des = config.desc
			buffData.icon = config.icon
			buffData.name = config.name
			buffData.weight = config.weight
			buffData.remainTime = config.remainTime
			buffData.isNeedBtn = config.isNeedBtn
			buffData.type = config.type
			
			table.insert(self.m_buffDataList,buffData) 
		end

	self:Sort()
	end 
	
end

function CFightOutsideBuffCtrl.RemoveState(self, stateId)

	if self.m_buffDataList ~= nil then

		for k ,v in ipairs(self.m_buffDataList) do 

			if v.id == stateId then 

				table.remove(self.m_buffDataList, k)

			end 

		end 

		self:Sort()

	end 	

end

function  CFightOutsideBuffCtrl.RefreshState(self, state)


	
	if self.m_buffDataList ~= nil then 

		for k ,v in ipairs(self.m_buffDataList) do 

			if v.id == state.state_id then 
				
				local data = self.m_buffDataList[k]
				data.time = state.time
				data.attrList = state.data

			end 

		end 

	end 


end


function CFightOutsideBuffCtrl.GS2CAddState(self, state)
	
	self:AddState(state)
	self:OnEvent(define.FightOutsideBuff.Event.StateChange, self)

end

function CFightOutsideBuffCtrl.GS2CRemoveState(self, stateId)
	
	self:RemoveState(stateId)
	self:OnEvent(define.FightOutsideBuff.Event.StateChange, self)

end

function CFightOutsideBuffCtrl.GS2CRefreshState(self, state)
	
	self:RefreshState(state)
	self:OnEvent(define.FightOutsideBuff.Event.StateChange, self)

end

function CFightOutsideBuffCtrl.GS2CAddBaoShi(self, count, sliver)
	
	self.m_BaoshiduData = {}
	self.m_BaoshiduData.count = count
	self.m_BaoshiduData.sliver = sliver

	CBaoshiduView:ShowView()
		
end

function CFightOutsideBuffCtrl.GetBaoShiRemainCount(self)
	
	if self.m_buffDataList ~= nil then 
		for k ,v in ipairs(self.m_buffDataList) do 
			if v.id == 1003 then 
				local data = self.m_buffDataList[k]
				if data.attrList[1] then 
					local value = data.attrList[1].value
					return value
				end
			end
		end 
	end 

end

function CFightOutsideBuffCtrl.C2GSClickState(self, stateId)
	if stateId == 1004 then
		-- 1004 双倍，数据表：buffStatedata.buffState[1004]
		g_ScheduleCtrl:C2GSRewardDoublePoint(function ()
			netstate.C2GSClickState(stateId)
		end)
	else
		netstate.C2GSClickState(stateId)
	end
end


return CFightOutsideBuffCtrl