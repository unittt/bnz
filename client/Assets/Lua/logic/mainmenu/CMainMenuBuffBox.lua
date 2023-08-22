local CMainMenuBuffBox = class("CMainMenuBuffBox", CBox)

function CMainMenuBuffBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BuffBoxGrid = self:NewUI(1, CGrid)
	self.m_BuffBoxClone = self:NewUI(2, CSprite)
	self.m_BoxArea = self:NewUI(3, CWidget)
	self.m_BuffBoxClone:SetActive(false)
	self:InitContent()


end

function CMainMenuBuffBox.InitContent(self)

	g_FightOutsideBuffCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBuffEvent"))
	self:InitBuffBox()

end

function CMainMenuBuffBox.OnBuffEvent(self, oCtrl)
	

	if oCtrl.m_EventID == define.FightOutsideBuff.Event.StateChange then 

		self:InitBuffBox()
		
	end


end

function CMainMenuBuffBox.InitBuffBox(self)

	if g_FightOutsideBuffCtrl.m_buffDataList ~= nil then 

		self:HideAllBuffIcon()

		local buffList = {}
		local hadInsertExpBuff = false

		for k , v in ipairs(g_FightOutsideBuffCtrl.m_buffDataList) do 

			if v.hide ~= "1" then 
				if v.type == 1 then
					-- 喜糖buff
					if v.id == 1010 then
						table.insert(buffList, v)
					elseif not hadInsertExpBuff then 
						table.insert(buffList, v)
						hadInsertExpBuff = true
					end 
				else
					table.insert(buffList, v)
				end
			end 

		end 

		for k , v in ipairs(buffList) do 

			if k <= 3 then 

				local box = self.m_BuffBoxGrid:GetChild(k)
				if box == nil then 
					box = self.m_BuffBoxClone:Clone()
					self.m_BuffBoxGrid:AddChild(box)					
				end 

				box:SetActive(true)
				box:SetSpriteName(v.icon)
				box:SetColor(Color.New(1,1,1,1))
				self:HandleGrayIcon(box, v)

			end 
	
		end 

		self.m_BoxArea:AddUIEvent("click", callback(self, "OnClickBuffdBtn"))

	end 

end

--处理按钮颜色
function CMainMenuBuffBox.HandleGrayIcon(self, box, data)
	
	if data.id == 1003 or data.id == 1004 then 

		if data.attrList[1] ~= nil then 

			if data.attrList[1].value == 0 then 

				box:SetColor(Color.New(0,0,0,1))

			else

				box:SetColor(Color.New(1,1,1,1))

			end 

		end 

	end 


end

function CMainMenuBuffBox.OnClickBuffdBtn(self)
	
	CFightOutsideBuffView:ShowView()

end

function CMainMenuBuffBox.HideAllBuffIcon(self)
	
	for k ,v in pairs(self.m_BuffBoxGrid:GetChildList()) do 

		v:SetActive(false)

	end 

end

return CMainMenuBuffBox