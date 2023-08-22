using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace GamePlot
{
    //UI特效实体
    public class PlotUIEffectEntity: PlotEntity
    {
        public string folderName;
        public string name;
        public string remark;

        public Vector3 pos = Vector3.zero;

        public bool isRotate = false;
        public Vector3 rotate = Vector3.zero;

        public bool isScale = false;
        public Vector3 scale = Vector3.one;

        public bool isSetOrder = false;
        public int sortingOrder = 0;


#if UNITY_EDITOR
        public override string GetOptionName(){
            return string.Format("UI特效:{0}",this.name);
        }

        protected override void DrawProperty(){
            base.DrawProperty();
            this.name = EditorGUILayout.TextField("特效名：",this.name);
            this.folderName = EditorGUILayout.TextField("目录名：",this.folderName);
            this.remark = EditorGUILayout.TextField("备注：", this.remark);
            
            this.pos = EditorGUILayout.Vector3Field("位置：",this.pos);

            this.isRotate = EditorGUILayout.Toggle("旋转：", this.isRotate, GUILayout.Width(100f));
            EditorGUI.BeginDisabledGroup(!this.isRotate);
            this.rotate = EditorGUILayout.Vector3Field("旋转：", this.rotate);
            EditorGUI.EndDisabledGroup();
            
            this.isScale = EditorGUILayout.Toggle("缩放：", this.isScale, GUILayout.Width(100f));
            EditorGUI.BeginDisabledGroup(!this.isScale);
            this.scale = EditorGUILayout.Vector3Field("缩放：", this.scale);
            EditorGUI.EndDisabledGroup();

            this.isSetOrder = EditorGUILayout.Toggle("sortingOrder：", this.isSetOrder, GUILayout.Width(100f));
            EditorGUI.BeginDisabledGroup(!this.isSetOrder);
            this.sortingOrder = EditorGUILayout.IntField("sortingOrder：", this.sortingOrder);
            EditorGUI.EndDisabledGroup();
        }
#endif
    }
}