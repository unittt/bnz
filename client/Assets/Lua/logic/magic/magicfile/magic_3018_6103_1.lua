module(...)
--magic editor build
DATA={
	atk_stophit=true,
	cmds={
		[1]={args={alive_time=0.5,shot=true,show=true,},func_name=[[Name]],start_time=0,},
		[2]={
			args={action_name=[[attack1]],bak_action_name=[[attack1]],excutor=[[atkobj]],},
			func_name=[[PlayAction]],
			start_time=0.35,
		},
		[3]={
			args={sound_path={soundpath=[[Audio/Sound/War/syfs2.ogg]],},},
			func_name=[[PlaySound]],
			start_time=0.8,
		},
		[4]={
			args={
				alive_time=2,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0.65,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_205_hit/Prefabs/Skill_eff_205_hit.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=1,relative_angle=12.5,relative_dis=20,},
				excutor=[[atkobj]],
				move_time=1.2,
			},
			func_name=[[ShootEffect]],
			start_time=0.8,
		},
		[5]={
			args={
				alive_time=2,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0.65,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_205_hit/Prefabs/Skill_eff_205_hit.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=1,relative_angle=-20,relative_dis=20,},
				excutor=[[atkobj]],
				move_time=1.2,
			},
			func_name=[[ShootEffect]],
			start_time=0.8,
		},
		[6]={
			args={
				alive_time=2,
				begin_pos={base_pos=[[atk]],depth=0,relative_angle=0,relative_dis=0.65,},
				delay_time=0,
				ease_type=[[Linear]],
				effect={
					is_cached=true,
					magic_layer=[[center]],
					path=[[Effect/Magic/Skill_eff_205_hit/Prefabs/Skill_eff_205_hit.prefab]],
					preload=false,
				},
				end_pos={base_pos=[[vic]],depth=1,relative_angle=-2.5,relative_dis=20,},
				excutor=[[atkobj]],
				move_time=1.2,
			},
			func_name=[[ShootEffect]],
			start_time=0.8,
		},
		[7]={
			args={
				consider_hight=false,
				damage_follow=true,
				face_atk=true,
				hurt_delta=0,
				play_anim=true,
				shot=true,
			},
			func_name=[[VicHitInfo]],
			start_time=1.25,
		},
		[8]={args={},func_name=[[End]],start_time=2.34,},
	},
	group_cmds={},
	pre_load_res={},
	run_env=[[war]],
	type=1,
	wait_goback=true,
}
