local CSummonRanseCtrl = class("CSummonRanseCtrl", CCtrlBase)

function CSummonRanseCtrl.ctor(self)

	CCtrlBase.ctor(self)

end

function CSummonRanseCtrl.GS2COpenRanSe(self, data)
    
    CSummonRanseView:ShowView()


end

function CSummonRanseCtrl.C2GSSummonRanse(self, summonId, colorId, flag)
	
	netsummon.C2GSSummonRanse(summonId, colorId, flag)

end


function CSummonRanseCtrl.C2GSGetSummonRanse(self, summonId)
	
	--netsummon.C2GSGetSummonRanse(summonId)

end

function CSummonRanseCtrl.GetSummonRanseInfo(self, summonId)
	
	local config = data.summondata.INFO[summonId]
    local shape = config.shape
    local summonRanseInfo = data.ransedata.SUMMON[shape]
    return summonRanseInfo

end

return CSummonRanseCtrl