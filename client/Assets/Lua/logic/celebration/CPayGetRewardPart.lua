CPayGetRewardPart = class("CPayGetRewardPart", CPageBase)

function CPayGetRewardPart.ctor(self, cb)
	-- body
	CPageBase.ctor(self,cb)
end

function CPayGetRewardPart.OnInitPage(self)
	-- body
	self.m_PetPex = self:NewUI(1, CActorTexture)
	self.m_PetBtn = self:NewUI(2, CButton)
	self.m_RiddlePex = self:NewUI(3, CActorTexture)
	self.m_RiddleBtn = self:NewUI(4, CButton)
	
	
	self.m_RiddlePex:AddUIEvent("click", callback(self, "OnRiddle")) 
	self.m_RiddleBtn:AddUIEvent("click", callback(self, "OnRiddleBtn")) --充值
	self.m_PetPex:AddUIEvent("click", callback(self, "OnPetTex"))
	self.m_PetBtn:AddUIEvent("click", callback(self, "OnPetBtn"))   --充值返利     
	
	self:InitContent()
end

function CPayGetRewardPart.InitContent(self)
	--写死的,只是看看啦
	local dRideData = data.ridedata.RIDEINFO[1005]
	dRideData.rendertexSize = 1.6
    self.m_RiddlePex:ChangeShape(dRideData)

	local dPetData = data.summondata.INFO[5002]
	dPetData.rendertexSize = 0.8
    self.m_PetPex:ChangeShape(dPetData)
end

function CPayGetRewardPart.OnPetTex(self)  --跳转图鉴
	-- body
	local oView = CSummonMainView:ShowView(function(oView)
	 	-- body
	 	oView:ShowSubPageByIndex(3)
	 	oView.m_DetailPart:SetSelSummon(data.summondata.INFO[5002], true)
	 	end
	 )
 end

function CPayGetRewardPart.OnPetBtn(self) -- 充值返利
	-- body
	 	CNpcShopMainView:ShowView(
		function (oView)
			-- body
			oView:ShowSubPageByIndex(3)
			oView.m_RechargePart:RebateCallBack()
		end
		)

end

function CPayGetRewardPart.OnRiddle(self)
	-- body
	if g_OpenSysCtrl:GetOpenSysState("RIDE_SYS") then
		local oView = CHorseMainView:ShowView(function (oView)
			-- body
			oView:ShowSpecificPart(3)
			oView:ChooseDetailPartHorse(1005)
		end)
	else
		local str = data.welfaredata.TEXT[1006].content
		local sysop = data.opendata.OPEN["RIDE_SYS"].p_level
		local sys = data.opendata.OPEN["RIDE_SYS"].name
		str = string.gsub(str,"#grade",tostring(sysop))
		str = string.gsub(str,"#name",sys)
		g_NotifyCtrl:FloatMsg(str)
	end
end

function CPayGetRewardPart.OnRiddleBtn(self)  --充值
	-- body
	local oView = CNpcShopMainView:ShowView(
	function (oView )
		-- body
		oView:ShowSubPageByIndex(3)
	end
	)
end

return CPayGetRewardPart