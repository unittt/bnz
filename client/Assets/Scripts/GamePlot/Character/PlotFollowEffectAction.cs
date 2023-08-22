#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

namespace GamePlot
{
	public class PlotFollowEffectAction:PlotAction
	{
		public string folderName = "Default";
		public string effPath;
		public bool loop;
		
		#if UNITY_EDITOR
		public override string GetOptionName(){
			return string.Format("特效:{0}",this.effPath);
		}
		
		protected override void DrawProperty(){
			base.DrawProperty();
			this.folderName = EditorGUILayout.TextField("目录名：",this.folderName);
			this.effPath = EditorGUILayout.TextField("特效名：",this.effPath);
			this.loop =  EditorGUILayout.Toggle("是否循环：", this.loop, GUILayout.Width(100f));
		}
		#endif
	}
}


