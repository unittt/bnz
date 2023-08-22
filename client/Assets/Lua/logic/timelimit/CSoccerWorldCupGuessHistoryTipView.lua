local CSoccerWorldCupGuessHistoryTipView = class("CSoccerWorldCupGuessHistoryTipView", CViewBase)

function CSoccerWorldCupGuessHistoryTipView.ctor(self, cb)
    CViewBase.ctor(self, "UI/TimeLimit/SoccerWorldCupGuessHistoryTipView.prefab", cb)
    self.m_DepthType = "Dialog"
end

function CSoccerWorldCupGuessHistoryTipView.OnCreateView(self)
    self.m_SoccerWorldCupGuessHistoryTipBox = self:NewUI(1, CSoccerWorldCupGuessHistoryTipBox)
	self.m_BoxGrid = self:NewUI(2, CGrid)
	self.m_TitleText = self:NewUI(3, CLabel)

    self:InitContent()
end

function CSoccerWorldCupGuessHistoryTipView.InitContent(self)
    self:RefreshAll()

    g_UITouchCtrl:TouchOutDetect(self, callback(self, "OnClose"))
end

function CSoccerWorldCupGuessHistoryTipView.RefreshAll(self)
    self:HideAllBoxs()

    if g_SoccerWorldCupGuessHistoryTipCtrl.m_History ~= nil and table.count(g_SoccerWorldCupGuessHistoryTipCtrl.m_History) > 0 then
        local historyTable = g_SoccerWorldCupGuessHistoryTipCtrl.m_History
        local historyList = table.dict2list(historyTable, "id", false)

        table.sort(historyList, 
            function(l, r) 
                if l.create_time == r.create_time then
                    return l.id < r.id
                elseif l.create_time < r.create_time then
                    return true
                else
                    return false
                end
            end)
            
        for i, v in ipairs(historyList) do
            local box = self.m_BoxGrid:GetChild(i)
            if box == nil then 
                box = self.m_SoccerWorldCupGuessHistoryTipBox:Clone()
                self.m_BoxGrid:AddChild(box)
            end
            box:SetHitorySingle(v)
            box:SetActive(true)
        end
    end
end

function CSoccerWorldCupGuessHistoryTipView.HideAllBoxs(self)
    local boxList = self.m_BoxGrid:GetChildList()
    if #boxList ~= 0 then 
        for k, v in pairs(boxList) do 
            v:SetActive(false)
        end 
    end 
end

return CSoccerWorldCupGuessHistoryTipView