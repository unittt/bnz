module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={
			args={sound_path={soundpath=[[Audio/Sound/War/shan.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.1,
		},
		[2]={
			args={action_name=[[attack5]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.1,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/wjgy3.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.3,
		},
		[4]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.3,
		},
		[5]={
			args={shake_dis=0.1,shake_rate=10,shake_time=0.5,},
			func_name=[[ShakeScreen]],
			start_time=0.3,
		},
		[6]={
			args={
				alive_time=2,
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_122_att/Prefabs/Skill_eff_122_att_05.prefab]],
					preload=false,
				},
				effect_dir_type=[[backward]],
				effect_pos={base_pos=[[vic]],depth=0.7,relative_angle=0,relative_dis=0,},
				excutor=[[vicobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.6,
		},
		[7]={args={},func_name=[[End]],start_time=0.7,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
