using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
    public class CameraSizeAction:PlotAction
    {
        public float size = 3.5f;
        
#if UNITY_EDITOR
        public override string GetOptionName(){
            return "相机尺寸";
        }
        
        protected override void DrawProperty(){
            base.DrawProperty();
            this.size = EditorGUILayout.FloatField(new GUIContent("相机尺寸(2D)：","默认3.5"),this.size);
        }
#endif
    }
}