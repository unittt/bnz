module(...)
--auto generate data
FUYUAN_REWARD={
	[1]={amount=5,bind=0,idx=10001,ratio=10000,sid=[[11092]],sys=0,},
	[2]={amount=5,bind=0,idx=10002,ratio=1000,sid=[[11099]],sys=0,},
	[3]={
		amount=1,
		bind=0,
		idx=10002,
		ratio=1000,
		sid=[[11191]],
		sys=1079,
	},
	[4]={amount=1,bind=0,idx=10002,ratio=100,sid=[[11187]],sys=1079,},
	[5]={amount=1,bind=0,idx=10002,ratio=400,sid=[[11077]],sys=1079,},
	[6]={amount=1,bind=0,idx=10002,ratio=2000,sid=[[10079]],sys=0,},
	[7]={amount=3,bind=0,idx=10002,ratio=2000,sid=[[10001]],sys=0,},
	[8]={amount=1,bind=0,idx=10002,ratio=1300,sid=[[12140]],sys=0,},
	[9]={amount=2,bind=0,idx=10002,ratio=500,sid=[[11176]],sys=1079,},
	[10]={amount=5,bind=0,idx=10002,ratio=100,sid=[[10197]],sys=1079,},
	[11]={amount=1,bind=0,idx=10002,ratio=100,sid=[[11184]],sys=1079,},
	[12]={amount=1,bind=0,idx=10002,ratio=1300,sid=[[12120]],sys=0,},
	[13]={amount=1,bind=0,idx=10002,ratio=200,sid=[[12958]],sys=1079,},
}

TEXT_DES={
	[1]={
		des=[[三界祥瑞，天降福缘宝箱散落于神州各地，静待有缘人开启]],
		id=1,
	},
	[2]={
		des=[[你拥有@个福缘钥匙，是否花费*#cur_1开启&次宝箱]],
		id=2,
	},
}

CONFIG={
	[1]={
		box_num=[[num/100+50]],
		map_pool={
			[1]=102000,
			[2]=203000,
			[3]=201000,
			[4]=204000,
			[5]=202000,
			[6]=101000,
		},
		npc=1001,
		open_item=11190,
		random_reward=10002,
		reward=1001,
		store_id=301038,
		ten_discount=9,
	},
}
