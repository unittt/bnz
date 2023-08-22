
// **********************************************************************
//	Copyright (C), 2011-2015, CILU Game Company Tech. Co., Ltd. All rights reserved
//	Work:		For H1 Project With .cs
//  FileName:	GameDescriptionModel.cs
//  Version:	Beat R&D

//  CreatedBy:	_Alot
//  Date:		2016.01.15
//	Modify:		__

//	Url:		http://www.cilugame.com/

//	Description:
//	This program files for detailed instructions to complete the main functions,
//	or functions with other modules interface, the output value of the range,
//	between meaning and parameter control, sequence, independence or dependence relations
// **********************************************************************

using UnityEngine;
using System.Collections.Generic;

//using AppDto;

public class GameDescriptionModel : IModuleModel{
    public void Dispose()
    {
        
    }
    

	

    //xxj begin
	//private Dictionary<int, FunTooltip> _funTooltipDic = null;
	//private Dictionary<int, Dictionary<int, FunTooltip>> _funTooltipDicDic = new Dictionary<int, Dictionary<int, FunTooltip>>();

	//public Dictionary<int, FunTooltip> GetFunTooltipDic() {
	//	if (_funTooltipDic == null) {
	//		_funTooltipDic = DataCache.getDicByCls<FunTooltip>();
	//	}
	//	return _funTooltipDic;
	//}

	//public Dictionary<int, FunTooltip> GetFunTooltipDicByMainID(int mainID) {
	//	Dictionary<int, FunTooltip> tAddDic = new Dictionary<int, FunTooltip>();

	//	if (mainID > 0) {
	//		if (_funTooltipDicDic.ContainsKey(mainID)) {
	//			return _funTooltipDicDic [mainID];
	//		}

	//		Dictionary<int, FunTooltip> tFunTooltipDic = GetFunTooltipDic();
	//		if (tFunTooltipDic.ContainsKey(mainID)) {
	//			foreach (FunTooltip funTooltip in tFunTooltipDic.Values) {
	//				if (funTooltip.parentId == mainID) {
	//					tAddDic.Add(funTooltip.id, funTooltip);
	//				}
	//			}
	//		}
	//		_funTooltipDicDic.Add(mainID, tAddDic);
	//	}

	//	return tAddDic;
	//}

	//public FunTooltip GetFunTooltipByID(int id) {
	//	Dictionary<int, FunTooltip> tFunTooltipDic = GetFunTooltipDic();
	//	return tFunTooltipDic[id];
	//}
    //xxj end
}

