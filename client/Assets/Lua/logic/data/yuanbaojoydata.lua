module(...)
--auto generate data
BAOXIANGREWARD={
	[1]={degree=100,index=1,reward=1001,},
	[2]={degree=200,index=2,reward=1002,},
	[3]={degree=500,index=3,reward=1003,},
	[4]={degree=1000,index=4,reward=1004,},
	[5]={degree=2000,index=5,reward=1005,},
}

PRIZEREWARD={
	[1]={
		amount=1,
		bind=1,
		chuanwen=0,
		itemsid=[[10156]],
		name=[[法宝精华]],
		pos=1,
		rare=0,
		ratio=[[2000]],
		sort=4,
	},
	[2]={
		amount=15,
		bind=1,
		chuanwen=0,
		itemsid=[[10031]],
		name=[[还童丹]],
		pos=2,
		rare=0,
		ratio=[[1000]],
		sort=6,
	},
	[3]={
		amount=10,
		bind=1,
		chuanwen=0,
		itemsid=[[11099]],
		name=[[坐骑金丹]],
		pos=3,
		rare=0,
		ratio=[[700]],
		sort=7,
	},
	[4]={
		amount=2,
		bind=1,
		chuanwen=0,
		itemsid=[[10169]],
		name=[[神器精华]],
		pos=4,
		rare=0,
		ratio=[[500]],
		sort=8,
	},
	[5]={
		amount=1,
		bind=1,
		chuanwen=1093,
		itemsid=[[11176]],
		name=[[神兽之灵]],
		pos=5,
		rare=100,
		ratio=[[200]],
		sort=5,
	},
	[6]={
		amount=1,
		bind=1,
		chuanwen=1093,
		itemsid=[[10164]],
		name=[[星辰沙]],
		pos=6,
		rare=100,
		ratio=[[300]],
		sort=9,
	},
	[7]={
		amount=1,
		bind=1,
		chuanwen=1093,
		itemsid=[[11190]],
		name=[[福缘钥匙]],
		pos=7,
		rare=100,
		ratio=[[200]],
		sort=13,
	},
	[8]={
		amount=2,
		bind=1,
		chuanwen=0,
		itemsid=[[10169]],
		name=[[神器精华]],
		pos=8,
		rare=0,
		ratio=[[500]],
		sort=14,
	},
	[9]={
		amount=1,
		bind=1,
		chuanwen=0,
		itemsid=[[10155]],
		name=[[法宝碎片]],
		pos=9,
		rare=0,
		ratio=[[1000]],
		sort=10,
	},
	[10]={
		amount=5,
		bind=1,
		chuanwen=0,
		itemsid=[[10031]],
		name=[[还童丹]],
		pos=10,
		rare=0,
		ratio=[[2000]],
		sort=11,
	},
	[11]={
		amount=5,
		bind=1,
		chuanwen=0,
		itemsid=[[11099]],
		name=[[坐骑金丹]],
		pos=11,
		rare=0,
		ratio=[[1600]],
		sort=12,
	},
	[12]={
		amount=1,
		bind=1,
		chuanwen=1096,
		itemsid=[[1004(Value=20)]],
		name=[[20%奖池]],
		pos=12,
		rare=1,
		ratio=[[0]],
		sort=1,
	},
	[13]={
		amount=1,
		bind=1,
		chuanwen=1095,
		itemsid=[[1004(Value=30)]],
		name=[[30%奖池]],
		pos=13,
		rare=2,
		ratio=[[0]],
		sort=3,
	},
	[14]={
		amount=1,
		bind=1,
		chuanwen=1094,
		itemsid=[[1004(Value=50)]],
		name=[[50%奖池]],
		pos=14,
		rare=3,
		ratio=[[0]],
		sort=2,
	},
}

CONFIG={
	[1]={
		gameday=7,
		goldcoin_cost1=20,
		goldcoin_cost10=200,
		goldcoin_init=10000,
		goldcoin_ratio=[[math.floor(value*20/100)]],
		hditem=10160,
		item_cost1=1,
		item_cost10=10,
		item_ratio=[[math.floor(2*amount)]],
		mail=2057,
		point=1,
		record_limit=20,
	},
}

TEXT={
	[1001]={
		choose={},
		content=[[包裹空间不足，请先整理]],
		id=1001,
		seconds=0.0,
		type=1002,
	},
	[1002]={
		choose={},
		content=[[消耗狂欢令×#amount个 ]],
		id=1002,
		seconds=0.0,
		type=1002,
	},
	[1003]={
		choose={},
		content=[[非绑定元宝不足，是否充值]],
		id=1003,
		seconds=0.0,
		type=1002,
	},
}