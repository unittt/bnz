#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

namespace GamePlot
{
	public class PlotAnimationAction:PlotAction
	{
		public string clip;
		public int selectedIndex = 0;
	    public bool loop;
	    public int loopTime;
	    public bool isResume = true;
        public float stopTime = 0f;

		#if UNITY_EDITOR
		public static string[] AniOptions = {
            "attack1",
            "attack2",
            "attack3",
            "defend",
            "die",
            "hit",
            "hit1",
            "hit2",
            "hitCrit",
            "idleCity",
            "idleRide",
            "idleWar",
            "magic",
            "run",
            "runWar",
            "show",
            "walk",
            "marryBaitang",
            "marryHug",
            "marryKiss",
        };    	

		public override string GetOptionName(){
			return string.IsNullOrEmpty(clip)?"动画名":this.clip;
		}
		
		public override bool IsPoint() {
			return true;
		}
		
		protected override void DrawProperty(){
			base.DrawProperty();
			this.selectedIndex = EditorGUILayout.Popup("动作类型",selectedIndex, AniOptions,GUILayout.MaxWidth(250f));
			this.clip = AniOptions[this.selectedIndex];
			this.loop =  EditorGUILayout.Toggle("是否循环：", this.loop, GUILayout.Width(100f));
			EditorGUI.BeginDisabledGroup(!this.loop);
            this.loopTime = EditorGUILayout.IntField("循环次数:", this.loopTime);
            EditorGUI.EndDisabledGroup();
            this.isResume = EditorGUILayout.Toggle("动画恢复：", this.isResume, GUILayout.Width(100f));
            this.stopTime = EditorGUILayout.FloatField("停止时间：", this.stopTime, GUILayout.Width(250f));
		}
		#endif
	}
}