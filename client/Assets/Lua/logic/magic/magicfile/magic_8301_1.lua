module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={sound_path={soundpath=[[Audio/Sound/War/jhjz1.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0,
		},
		[3]={
			args={
				alive_time=1.5,
				effect={
					is_cached=true,
					path=[[Effect/Magic/Skill_eff_117_att/Prefabs/Skill_eff_117_att.prefab]],
				},
				effect_dir_type=[[empty]],
				effect_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[atkobj]],
			},
			func_name=[[StandEffect]],
			start_time=0.15,
		},
		[4]={
			args={action_name=[[magic]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.29,
		},
		[5]={
			args={
				alive_time=1.3,
				effect={
					is_cached=false,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_117_hit/Prefabs/Skill_eff_117_hit.prefab]],
					preload=false,
				},
				effect_dir_type=[[forward]],
				effect_pos={base_pos=[[vic]],depth=0,relative_angle=0,relative_dis=0,},
				excutor=[[vicobjs]],
			},
			func_name=[[StandEffect]],
			start_time=0.7,
		},
		[6]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=0.7,
		},
		[7]={
			args={sound_path={soundpath=[[Audio/Sound/War/jhjz2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.7,
		},
		[8]={args={},func_name=[[End]],start_time=1,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}