local MarryDebug = {}

MarryDebug.SimulateWedding = function(self, iShape1, iShape2, bMy, iType)
    local protoData = self:GetWeddingData(iShape1, iShape2, bMy, iType)
    netmarry.GS2CMarryWedding(protoData)
end

MarryDebug.GetWeddingData = function(self, iShape1, iShape2, bMy, iType)
    if bMy == nil then
        bMy = true
    end
    local groom = {
        pid = bMy and g_AttrCtrl.pid or 2,
        name = g_AttrCtrl.name, -- "groom。",
        grade = 60,
        school = 6,
        sex = 1,
        model_info = {
            shape = iShape1 or 1131,
        },
    }
    local bride = {
        pid = g_MarryCtrl:GetPartnerPid() or 0,
        name = g_MarryCtrl:GetProtagonistName(2) or "bride。",
        grade = 60,
        school = 6,
        sex = 2,
        model_info = {
            shape = iShape2 or 1172,
        },
    }
    local weddingData = {
        marry_no = 5,
        player1 = groom,
        player2 = bride,
        marry_type = iType or 3,
        wedding_time = g_TimeCtrl:GetTimeS(),
        wedding_sec = 2,
    }
    return weddingData
end

return MarryDebug