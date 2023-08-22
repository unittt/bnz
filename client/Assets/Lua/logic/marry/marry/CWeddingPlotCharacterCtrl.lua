local CWeddingPlotCharacterCtrl = class("CWeddingPlotCharacterCtrl", CPlotCharacterCtrl)

function CWeddingPlotCharacterCtrl.ctor(self, dCharInfo, oWalker, elapsedTime)
    CPlotCharacterCtrl.ctor(self, dCharInfo, oWalker, elapsedTime)
end

function CWeddingPlotCharacterCtrl.GetModelInfo(self, dCharInfo)
    -- 是否是婚礼主角
    local iNpcId = dCharInfo.npcId
    local bProtagonist = iNpcId == 1 or iNpcId == 2
    if bProtagonist then
        local dModel = g_MarryPlotCtrl:GetProtagonistShapeData(iNpcId)
        local sName = g_MarryPlotCtrl:GetProtagonistName(iNpcId)
        local sTitle = g_MarryPlotCtrl:GetProtagonistTitle(iNpcId)
        self.m_Walker:SetName(sName)
        self.m_Walker:SetNormalTitleHud(900, sTitle)
        return dModel
    else
        return CPlotCharacterCtrl.GetModelInfo(self, dCharInfo)
    end
end

function CWeddingPlotCharacterCtrl.GetTalkContent(self, oTalkAction)
    local sText = oTalkAction.content
    local sBridegroom = g_MarryPlotCtrl:GetProtagonistName(1)
    local sBride = g_MarryPlotCtrl:GetProtagonistName(2)
    sText = string.gsub(sText, "#BridegroomName", string.format("#G%s#n", sBridegroom))
    sText = string.gsub(sText, "#BrideName", string.format("#G%s#n", sBride))
    return sText
end

function CWeddingPlotCharacterCtrl.HideWalker(self)
    CPlotCharacterCtrl.HideWalker(self)
    if self.m_Walker then
        self.m_Walker:ClearAllTitleHuds()
    end
end

function CWeddingPlotCharacterCtrl.ClearChatMsg(self)
    if self.m_Walker then
        self.m_Walker:DelHud("chat")
    end
end

return CWeddingPlotCharacterCtrl