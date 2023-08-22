module(...)
--auto generate data
TEXT={
	[1001]={
		choose={},
		content=[[背包中道具不足]],
		count_time=0,
		default_id=0,
		id=1001,
		seconds=0.0,
		type=1003,
	},
	[1002]={
		choose={},
		content=[[道具不允许拍卖]],
		count_time=0,
		default_id=0,
		id=1002,
		seconds=0.0,
		type=1003,
	},
	[1003]={
		choose={},
		content=[[成功上架#name]],
		count_time=0,
		default_id=0,
		id=1003,
		seconds=0.0,
		type=1003,
	},
	[1004]={
		choose={},
		content=[[已到上拍上限]],
		count_time=0,
		default_id=0,
		id=1004,
		seconds=0.0,
		type=1003,
	},
	[1005]={
		choose={},
		content=[[价格设置不在范围内]],
		count_time=0,
		default_id=0,
		id=1005,
		seconds=0.0,
		type=1003,
	},
	[1006]={
		choose={},
		content=[[当前时段不能上架拍品]],
		count_time=0,
		default_id=0,
		id=1006,
		seconds=0.0,
		type=1003,
	},
	[1007]={
		choose={},
		content=[[未达到服务器开放等级]],
		count_time=0,
		default_id=0,
		id=1007,
		seconds=0.0,
		type=1003,
	},
	[1008]={
		choose={},
		content=[[当前不支持该道具拍卖]],
		count_time=0,
		default_id=0,
		id=1008,
		seconds=0.0,
		type=1003,
	},
	[2001]={
		choose={},
		content=[[宠物栏中没有该宠物]],
		count_time=0,
		default_id=0,
		id=2001,
		seconds=0.0,
		type=1003,
	},
	[2002]={
		choose={},
		content=[[该宠物不允许拍卖]],
		count_time=0,
		default_id=0,
		id=2002,
		seconds=0.0,
		type=1003,
	},
	[2003]={
		choose={},
		content=[[出战宠物不允许上架]],
		count_time=0,
		default_id=0,
		id=2003,
		seconds=0.0,
		type=1003,
	},
	[2004]={
		choose={},
		content=[[宠物携带等级大于当前服务器等级10级]],
		count_time=0,
		default_id=0,
		id=2004,
		seconds=0.0,
		type=1003,
	},
	[2005]={
		choose={},
		content=[[当前不支持该宠物拍卖]],
		count_time=0,
		default_id=0,
		id=2005,
		seconds=0.0,
		type=1003,
	},
	[3001]={
		choose={},
		content=[[成功下架#name]],
		count_time=0,
		default_id=0,
		id=3001,
		seconds=0.0,
		type=1003,
	},
	[3002]={
		choose={},
		content=[[拍品不存在]],
		count_time=0,
		default_id=0,
		id=3002,
		seconds=0.0,
		type=1003,
	},
	[3003]={
		choose={},
		content=[[拍品已被设置代理竞价，无法下架]],
		count_time=0,
		default_id=0,
		id=3003,
		seconds=0.0,
		type=1003,
	},
	[3004]={
		choose={},
		content=[[拍品已有人出价，无法下架]],
		count_time=0,
		default_id=0,
		id=3004,
		seconds=0.0,
		type=1003,
	},
	[3005]={
		choose={},
		content=[[拍品无法下架]],
		count_time=0,
		default_id=0,
		id=3005,
		seconds=0.0,
		type=1003,
	},
	[4001]={
		choose={},
		content=[[拍品不存在]],
		count_time=0,
		default_id=0,
		id=4001,
		seconds=0.0,
		type=1003,
	},
	[4002]={
		choose={},
		content=[[拍品禁止出价]],
		count_time=0,
		default_id=0,
		id=4002,
		seconds=0.0,
		type=1003,
	},
	[4003]={
		choose={},
		content=[[拍品价格类型异常]],
		count_time=0,
		default_id=0,
		id=4003,
		seconds=0.0,
		type=1003,
	},
	[4004]={
		choose={},
		content=[[当前最新价格为#amount#money，请重新出价]],
		count_time=0,
		default_id=0,
		id=4004,
		seconds=0.0,
		type=1003,
	},
	[4005]={
		choose={},
		content=[[出价成功]],
		count_time=0,
		default_id=0,
		id=4005,
		seconds=0.0,
		type=1003,
	},
	[4006]={
		choose={},
		content=[[不能对自己上拍的物品出价]],
		count_time=0,
		default_id=0,
		id=4006,
		seconds=0.0,
		type=1003,
	},
	[4007]={
		choose={},
		content=[[不能重复出价]],
		count_time=0,
		default_id=0,
		id=4007,
		seconds=0.0,
		type=1003,
	},
	[4008]={
		choose={},
		content=[[已设置代理竞价，不能设置竞价]],
		count_time=0,
		default_id=0,
		id=4008,
		seconds=0.0,
		type=1003,
	},
	[5001]={
		choose={},
		content=[[身上#money不足，无法出价]],
		count_time=0,
		default_id=0,
		id=5001,
		seconds=0.0,
		type=1003,
	},
	[5002]={
		choose={},
		content=[[不能比当前代理价格小]],
		count_time=0,
		default_id=0,
		id=5002,
		seconds=0.0,
		type=1003,
	},
	[5003]={
		choose={},
		content=[[出价不能小于当前价格110%]],
		count_time=0,
		default_id=0,
		id=5003,
		seconds=0.0,
		type=1003,
	},
	[5004]={
		choose={},
		content=[[代理设置成功，预祝旗开得胜]],
		count_time=0,
		default_id=0,
		id=5004,
		seconds=0.0,
		type=1003,
	},
	[5005]={
		choose={},
		content=[[未对当前商品设置代理竞价]],
		count_time=0,
		default_id=0,
		id=5005,
		seconds=0.0,
		type=1003,
	},
	[5006]={
		choose={},
		content=[[当前商品状态无法取消代理竞价]],
		count_time=0,
		default_id=0,
		id=5006,
		seconds=0.0,
		type=1003,
	},
	[5007]={
		choose={},
		content=[[当前商品无法设置代理竞价]],
		count_time=0,
		default_id=0,
		id=5007,
		seconds=0.0,
		type=1003,
	},
	[5008]={
		choose={},
		content=[[无法对自己上拍的物品设置代理竞价]],
		count_time=0,
		default_id=0,
		id=5008,
		seconds=0.0,
		type=1003,
	},
	[5009]={
		choose={},
		content=[[您当前已是最高价]],
		count_time=0,
		default_id=0,
		id=5009,
		seconds=0.0,
		type=1003,
	},
	[5010]={
		choose={},
		content=[[出价失败,请重新出价]],
		count_time=0,
		default_id=0,
		id=5010,
		seconds=0.0,
		type=1003,
	},
	[6001]={
		choose={},
		content=[[拍品无法提现]],
		count_time=0,
		default_id=0,
		id=6001,
		seconds=0.0,
		type=1003,
	},
	[7001]={
		choose={},
		content=[[拍品不存在]],
		count_time=0,
		default_id=0,
		id=7001,
		seconds=0.0,
		type=1003,
	},
	[7002]={
		choose={},
		content=[[拍品无法提取]],
		count_time=0,
		default_id=0,
		id=7002,
		seconds=0.0,
		type=1003,
	},
	[8001]={
		choose={},
		content=[[拍品已过期]],
		count_time=0,
		default_id=0,
		id=8001,
		seconds=0.0,
		type=1003,
	},
	[8002]={
		choose={},
		content=[[你确定要对#O#item#n出价#amount竞拍吗？]],
		count_time=0,
		default_id=0,
		id=8002,
		seconds=0.0,
		type=1001,
	},
	[8003]={
		choose={},
		content=[[请先选中拍卖品]],
		count_time=0,
		default_id=0,
		id=8003,
		seconds=0.0,
		type=1003,
	},
	[8004]={
		choose={},
		content=[[预览期不可出价]],
		count_time=0,
		default_id=0,
		id=8004,
		seconds=0.0,
		type=1003,
	},
}

ITEMINFO={
	[1]={
		amount=1,
		announce=1080,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=1,
		is_open=1,
		item_name=[[神兽元灵]],
		money_type=3,
		price=30000,
		show_time=0,
		sid=11192,
		slv=40,
		sub_id=0,
		sub_name=[[宠物]],
		up_time=[[0-0-11 20:00]],
		week=[[]],
	},
	[2]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=2,
		is_open=1,
		item_name=[[三、四级宠物装备]],
		money_type=1,
		price=0,
		show_time=0,
		sid=102,
		slv=40,
		sub_id=0,
		sub_name=[[宠物]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
	[3]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=3,
		is_open=0,
		item_name=[[风云令]],
		money_type=3,
		price=400,
		show_time=0,
		sid=11143,
		slv=40,
		sub_id=0,
		sub_name=[[头衔]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
	[4]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=4,
		is_open=1,
		item_name=[[护符]],
		money_type=3,
		price=0,
		show_time=0,
		sid=103,
		slv=40,
		sub_id=0,
		sub_name=[[宠物]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
	[5]={
		amount=1,
		announce=1080,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=5,
		is_open=0,
		item_name=[[九幽令]],
		money_type=3,
		price=1000,
		show_time=0,
		sid=11183,
		slv=40,
		sub_id=0,
		sub_name=[[头衔]],
		up_time=[[]],
		week=[[6 20:00]],
	},
	[6]={
		amount=1,
		announce=1080,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=6,
		is_open=1,
		item_name=[[青鸾元神]],
		money_type=3,
		price=6000,
		show_time=0,
		sid=11105,
		slv=40,
		sub_id=0,
		sub_name=[[坐骑]],
		up_time=[[]],
		week=[[5 20:00]],
	},
	[7]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=7,
		is_open=0,
		item_name=[[风云令]],
		money_type=3,
		price=400,
		show_time=0,
		sid=11143,
		slv=40,
		sub_id=0,
		sub_name=[[头衔]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
	[8]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=8,
		is_open=1,
		item_name=[[龙魂秘宝]],
		money_type=3,
		price=300,
		show_time=0,
		sid=10035,
		slv=40,
		sub_id=0,
		sub_name=[[宠物]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
	[9]={
		amount=1,
		announce=0,
		attr=[[{}]],
		auction_time=2,
		auction_type=1,
		cat_id=0,
		cat_name=[[道具]],
		id=9,
		is_open=1,
		item_name=[[风云令]],
		money_type=3,
		price=0,
		show_time=0,
		sid=104,
		slv=40,
		sub_id=0,
		sub_name=[[头衔]],
		up_time=[[0-0-0 20:00]],
		week=[[]],
	},
}

