#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using AssetPipeline;
using System.IO;

public class ModelHue : MonoBehaviour
{
	public float sliderWidth = 150f;
	public float sliderHeight = 12f;
	public GameObject modelPrefab;

	private GameObject gameCam;
	private GameObject testCam;

	private GameObject exModel;
	private GameObject mainModel;

	private List<Vector4> _modelHueParams;
	private ModelHSV _modelHSV;
	private SkinnedMeshRenderer _modelRenderer;
	private bool _debugMode = false;
	private Transform _modelTrans;
	public float rotationSpeed = 5000f;
	private string _maskMatPath = "";
	private string _exMaskMatPath = "";
	private string _mutateMatPath = "";
	private string _curMatPath = "";

	//宠物配饰变色参数
	private ModelHSV _ornamentHSV;
	private List<Vector4> _ornamentHueParams;
	private bool showOrnamentParams;


	private string hairDefaultColor = "1|1-1-1-0,2|1-1-1-0,3|1-1-1-0,4|1-1-1-0,5|1-1-1-0,6|1-1-1-0,7|1-1-1-0,8|1-1-1-0,9|1-1-1-0";
	public string hairColorInfo;
	public string hairIndexLabel = string.Empty;
	private bool isLoadHairData;

	private string clothesDefaultColor = "1|1-1-1-0|1-1-1-0,2|1-1-1-0|1-1-1-0,3|1-1-1-0|1-1-1-0,4|1-1-1-0|1-1-1-0,5|1-1-1-0|1-1-1-0,6|1-1-1-0|1-1-1-0,7|1-1-1-0|1-1-1-0,8|1-1-1-0|1-1-1-0,9|1-1-1-0|1-1-1-0";
	public string clothesColorInfo;
	public string clothesIndexLabel = string.Empty;
	private bool isLoadClothesData;

	private string peiShiColorInfo;
	public string peiShiIndexLabel =  string.Empty;
	private bool isLoadpeiShiData;

	private string pantDefaultColor = "1|1-1-1-0,2|1-1-1-0,3|1-1-1-0,4|1-1-1-0,5|1-1-1-0,6|1-1-1-0,7|1-1-1-0,8|1-1-1-0,9|1-1-1-0";
	public string pantColorInfo;
	public string pantIndexLabel =  string.Empty;
	private bool isLoadPantData;

	private string summonDefaultColor = "1|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,2|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,3|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,4|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,5|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,6|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,7|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,8|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0,9|1-1-1-0|1-1-1-0|1-1-1-0|1-1-1-0";
	public string summonColorInfo;
	public string summonIndexLabel =  string.Empty;
	private bool isLoadsummonData;

	Dictionary<int, Vector4> hairColorDic = new Dictionary<int, Vector4> ();
	Dictionary<int, List<Vector4>> clothesColorDic = new Dictionary<int, List<Vector4>>();
	Dictionary<int, Vector4> peiShiColorDic = new Dictionary<int, Vector4> ();
	Dictionary<int, Vector4> pantColorDic = new Dictionary<int, Vector4> ();
	Dictionary<int, List<Vector4>> summonColorDic = new Dictionary<int, List<Vector4>>();



	int curHairKey = 1;
	int curClothesKey = 1;
	int curPantKey = 1;
	int curSummonKey = 1;

	void Start ()
	{
		gameCam = GameObject.Find ("GameCam");
		gameCam.SetActive (false);
		testCam = GameObject.Find ("TestCam");
		testCam.SetActive (true);

		GameObject model = NGUITools.AddChild (this.gameObject, modelPrefab);
		_modelTrans = model.transform;
		//替换模型材质为pet_xxx_mask
		string name = modelPrefab.name.Substring (5);
		_maskMatPath = string.Format ("Assets/GameRes/Model/Character/{0}/Materials/{1}", name, modelPrefab.name + "_mask.mat");
		_exMaskMatPath = string.Format ("Assets/GameRes/Model/Character/{0}/Materials/{1}", name, modelPrefab.name + "_ex_mask.mat");
		_mutateMatPath = string.Format ("Assets/GameRes/Model/Character/{0}/Materials/{1}", name, modelPrefab.name + "_mutate.mat");
		mainModel = _modelTrans.Find (modelPrefab.name).gameObject;
		if (mainModel != null) {
			_modelRenderer = mainModel.GetComponent<SkinnedMeshRenderer> ();
			_modelHSV = mainModel.gameObject.AddComponent<ModelHSV> ();
			ChangeModelMaterial (_maskMatPath);

			_modelHueParams = new List<Vector4> (4);
			for (int i = 0; i < 4; ++i) {
				_modelHueParams.Add (new Vector4 (1f, 1f, 1f, 0f));
			}
			_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams[3]);

			var exTrans = _modelTrans.Find (modelPrefab.name + "_ex");
				if (exTrans) {
					exModel = exTrans.gameObject;
			}
				
		} else {
			Debug.LogError ("模型节点命名错误，请检查");
		}

		Transform ornamentNode = _modelTrans.Find (modelPrefab.name + "_ornament");
		if (ornamentNode != null) {
			_ornamentHSV = ornamentNode.gameObject.AddComponent<ModelHSV> ();
			_ornamentHueParams = new List<Vector4> (3);
			for (int i = 0; i < 3; ++i) {
				_ornamentHueParams.Add (new Vector4 (0f, 1f, 1f, 0f));
			}
			_ornamentHSV.SetupHueShift (_ornamentHueParams [0], _ornamentHueParams [1], _ornamentHueParams [2], _ornamentHueParams [3]);
		}
	}

	void ChangeModelMaterial (string matPath)
	{
		Material mat = AssetDatabase.LoadAssetAtPath<Material> (matPath);
		if (mat != null) {
			_curMatPath = matPath;
			Debug.Log (mat);
			Debug.Log (_modelRenderer.gameObject.name);
			_modelRenderer.material = mat;
			Selection.activeTransform = _modelRenderer.transform;
		}
	}

	void Update ()
	{
		float rotate = -rotationSpeed * Input.GetAxis ("Mouse ScrollWheel") * Time.deltaTime;
		_modelTrans.Rotate (0f, rotate, 0f);
	}
		


	void OnGUI ()
	{
		if (_modelHSV == null)
			return;

		if (_ornamentHSV != null) {
			if (GUILayout.Button (showOrnamentParams ? "切换模型调色面板" : "切换配饰调色面板", GUILayout.Width ((sliderWidth+10)*3), GUILayout.Height (50f))) {
				showOrnamentParams = !showOrnamentParams;
			}
		}
		GUILayout.BeginHorizontal ();
		var curHueParams = showOrnamentParams ? _ornamentHueParams : _modelHueParams;
		for (int i = 0; i < 4; ++i)
		{
            GUILayout.BeginVertical ();
			float r = DrawSliderInfo ("红色通道", curHueParams [i].x, 6.0f);
			float g = DrawSliderInfo ("绿色通道", curHueParams [i].y, 6.0f);
			float b = DrawSliderInfo ("蓝色通道", curHueParams [i].z, 6.0f);
			float blendFactor = DrawSliderInfo ("混合值", curHueParams [i].w, 1.0f);


			curHueParams [i] = new Vector4 (r, g, b, blendFactor);

            string hueParams = GUILayout.TextField(VectorHelper.ToString(curHueParams[i]), GUILayout.Width(sliderWidth));
		    if (GUI.changed)
		    {
		        curHueParams[i] = VectorHelper.ParseToVector4(hueParams, new Vector4(0f, 1f, 1f, 0f));
		    }
            GUILayout.Space (10f);
			if (GUILayout.Button ("复制", GUILayout.Height (40f))) {
                FileHelper.ClipBoard = string.Format ("{0:0.00}-{1:0.00}-{2:0.00}-{3:0.00}", r, g, b, blendFactor);
			}
			if (GUILayout.Button ("重置", GUILayout.Height (40f))) {
				curHueParams [i] = new Vector4 (1f, 1f, 1f, 0f);
			}
            
			GUILayout.EndVertical ();
			GUILayout.Space (10f);
		}
		GUILayout.EndHorizontal ();

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();
		if (GUILayout.Button ("复制所有", GUILayout.Height (40f))) {
			string clipStr = "";
			for (int i = 0; i < 4; i++) {
				clipStr += string.Format ("{0:0.00}-{1:0.00}-{2:0.00}-{3:0.00}", curHueParams [i].x, curHueParams [i].y, curHueParams [i].z, curHueParams [i].w);
			}
			FileHelper.ClipBoard = clipStr;
		}
		GUI.color = Color.red;
		if (GUILayout.Button ("重置所有", GUILayout.Height (40f))) {
			for (int i = 0; i < 4; i++) {
				curHueParams [i] = new Vector4 (1f, 1f, 1f, 0f);
			}
		}

		GUI.color = Color.white;
		GUILayout.EndHorizontal ();

		#region Hair
		
		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		if (GUILayout.Button ("读入头发数据", GUILayout.Width (100f))) {

			hairColorInfo = ReadColorData();

			if (hairColorInfo != string.Empty)
			{
				isLoadHairData = true;
				hairColorDic = HandleColorData (hairColorInfo);
			}

		}

		if (GUILayout.Button ("默认数据", GUILayout.Width (100f))) {
			isLoadHairData = true;
			hairColorDic = HandleColorData (hairDefaultColor);
			hairColorInfo = hairDefaultColor;
		}

		if (isLoadHairData &&  (hairIndexLabel != string.Empty)) {

			if (GUI.changed)
			{
				hairColorDic [curHairKey] = curHueParams [0];
				hairColorInfo = ColorDicToStr (hairColorDic);
			}
		}

		hairColorInfo = GUILayout.TextArea (hairColorInfo, GUILayout.Width(600));

		GUILayout.EndHorizontal ();

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		GUILayout.Label ("颜色编号:", GUILayout.Width(70));
		GUI.color = Color.yellow;
		GUILayout.Label (hairIndexLabel, GUILayout.Width(40));
		GUI.color = Color.white;

		DrawHairButtonList (isLoadHairData, hairColorDic);

		GUI.color = Color.green;
		if (GUILayout.Button ("保存数据", GUILayout.Width (100f))) {
			if (hairIndexLabel != string.Empty)
			{
				SaveData (hairColorInfo, "hair");
			}else{
				EditorUtility.DisplayDialog(null, "颜色索引值不能为空", "ok");
			}

		}
		GUI.color = Color.white;	
		GUILayout.EndHorizontal ();

		#endregion

		#region Clothes

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		if (GUILayout.Button ("读入衣服数据", GUILayout.Width (100f))) {

			clothesColorInfo = ReadColorData();
			if (clothesColorInfo != string.Empty)
			{
				isLoadClothesData = true;
				clothesColorDic = HandleClothesColorData (clothesColorInfo);
			}

		}

		if (GUILayout.Button ("默认数据", GUILayout.Width (100f))) {
			isLoadClothesData = true;
			clothesColorDic = HandleClothesColorData (clothesDefaultColor);
			clothesColorInfo = clothesDefaultColor;
		}

		if (isLoadClothesData &&  (clothesIndexLabel != string.Empty)) {

			if (GUI.changed)
			{
				clothesColorDic [curClothesKey][0] = curHueParams [1];
				clothesColorDic [curClothesKey][1] = curHueParams [2];
				clothesColorInfo = ClothesColorDicToStr (clothesColorDic);
			}
		}

		clothesColorInfo = GUILayout.TextArea (clothesColorInfo, GUILayout.Width(600));

		GUILayout.EndHorizontal ();

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		GUILayout.Label ("颜色编号:", GUILayout.Width(70));
		GUI.color = Color.yellow;
		GUILayout.Label (clothesIndexLabel, GUILayout.Width(40));
		GUI.color = Color.white;

		DrawClothesButtonList (isLoadClothesData, clothesColorDic);

		GUI.color = Color.green;
		if (GUILayout.Button ("保存数据", GUILayout.Width (100f))) {
			if (clothesIndexLabel != string.Empty)
			{
				SaveData (clothesColorInfo, "clothes");
			}else{
				EditorUtility.DisplayDialog(null, "颜色索引值不能为空", "ok");
			}
		}
		GUI.color = Color.white;	
		GUILayout.EndHorizontal ();

		#endregion

		#region Pant

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		if (GUILayout.Button ("读入裤子数据", GUILayout.Width (100f))) {

			pantColorInfo = ReadColorData();
			if (pantColorInfo != string.Empty)
			{
				isLoadPantData = true;
				pantColorDic = HandleColorData (pantColorInfo);
			}

		}

		if (GUILayout.Button ("默认数据", GUILayout.Width (100f))) {
			isLoadPantData = true;
			pantColorDic = HandleColorData (pantDefaultColor);
			pantColorInfo = pantDefaultColor;
		}

		if (isLoadPantData &&  (pantIndexLabel != string.Empty)) {

			if (GUI.changed)
			{
				pantColorDic[curPantKey] = curHueParams [3];
				pantColorInfo = ColorDicToStr (pantColorDic);
			}
		}

		pantColorInfo = GUILayout.TextArea (pantColorInfo, GUILayout.Width(600));

		GUILayout.EndHorizontal ();

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		GUILayout.Label ("颜色编号:", GUILayout.Width(70));
		GUI.color = Color.yellow;
		GUILayout.Label (pantIndexLabel, GUILayout.Width(40));
		GUI.color = Color.white;

		DrawPantButtonList (isLoadPantData, pantColorDic);

		GUI.color = Color.green;
		if (GUILayout.Button ("保存数据", GUILayout.Width (100f))) {
			if (pantIndexLabel != string.Empty)
			{
				SaveData (pantColorInfo, "pant");
			}else{
				EditorUtility.DisplayDialog(null, "颜色索引值不能为空", "ok");
			}
		}
		GUI.color = Color.white;	
		GUILayout.EndHorizontal ();

		#endregion

		#region Summon

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		if (GUILayout.Button ("读入宠物数据", GUILayout.Width (100f))) {

			summonColorInfo = ReadColorData();
			if (summonColorInfo != string.Empty)
			{
				isLoadsummonData = true;
				summonColorDic = HandleSummonColorData (summonColorInfo);
			}

		}

		if (GUILayout.Button ("默认数据", GUILayout.Width (100f))) {
			isLoadsummonData = true;



			summonColorDic = HandleSummonColorData (summonDefaultColor);
			summonColorInfo = summonDefaultColor;
		}

		if (isLoadsummonData &&  (summonIndexLabel != string.Empty)) {

			if (GUI.changed)
			{
				summonColorDic [curSummonKey] = curHueParams;
				summonColorInfo = SummonColorDicToStr (summonColorDic);
			}
		}

		summonColorInfo = GUILayout.TextArea (summonColorInfo, GUILayout.Width(600));

		GUILayout.EndHorizontal ();

		GUILayout.Space (10f);
		GUILayout.BeginHorizontal ();

		GUILayout.Label ("颜色编号:", GUILayout.Width(70));
		GUI.color = Color.yellow;
		GUILayout.Label (summonIndexLabel, GUILayout.Width(40));
		GUI.color = Color.white;

		DrawSummonButtonList (isLoadsummonData, summonColorDic);

		GUI.color = Color.green;
		if (GUILayout.Button ("保存数据", GUILayout.Width (100f))) {
			if (summonIndexLabel != string.Empty)
			{
				SaveData (summonColorInfo, "summon");
			}else{
				EditorUtility.DisplayDialog(null, "颜色索引值不能为空", "ok");
			}
		}
		GUI.color = Color.white;	
		GUILayout.EndHorizontal ();

		#endregion


//		GUILayout.Space (10f);
//		GUILayout.BeginHorizontal ();
//
//		if (GUILayout.Button ("保存所有数据", GUILayout.Width (100f))) {
//			SaveAll ();
//		}
//
//		GUILayout.EndHorizontal ();


		GUILayout.BeginArea (new Rect (Screen.width - 100f, 0, Screen.width, Screen.height));
		if (GUILayout.Button (_debugMode ? "正常模式" : "调试模式", GUILayout.Width (100f), GUILayout.Height (50f))) {
			_debugMode = !_debugMode;
			_modelHSV.ChangeDebugMode (_debugMode);
		}

		if (GUILayout.Button (gameCam.activeSelf ? "调试镜头" : "游戏镜头", GUILayout.Width (100f), GUILayout.Height (50f))) {
			gameCam.SetActive (!gameCam.activeSelf);
			testCam.SetActive (!testCam.activeSelf);
		}
		if (GUILayout.Button ("切换角色材质", GUILayout.Width (100f), GUILayout.Height (50f))) {
			string newMatPath = _curMatPath == _maskMatPath ? _mutateMatPath : _maskMatPath;
			ChangeModelMaterial (newMatPath);
		}

		GUI.color = Color.yellow;
		if (GUILayout.Button ("切换到Main模型", GUILayout.Width (100f), GUILayout.Height (50f))) {
			string newMatPath = _maskMatPath;
			if (mainModel) {
				_modelRenderer = mainModel.GetComponent<SkinnedMeshRenderer> ();
				_modelHSV = mainModel.GetComponent<ModelHSV> ();
				ChangeModelMaterial (newMatPath);
			} else {
				EditorUtility.DisplayDialog(null, "请检查exModel是否命名正确", "ok");
			}

		}


		if (GUILayout.Button ("切换到Ex模型", GUILayout.Width (100f), GUILayout.Height (50f))) {
			string newMatPath = _exMaskMatPath;
			if (exModel) {
				_modelRenderer = exModel.GetComponent<SkinnedMeshRenderer> ();
				if (!exModel.GetComponent<ModelHSV> ()) {
					_modelHSV = exModel.AddComponent<ModelHSV> ();
				}
				_modelHSV = exModel.GetComponent<ModelHSV> ();
				ChangeModelMaterial (newMatPath);
			} else {
				EditorUtility.DisplayDialog(null, "请检查exModel是否命名正确", "ok");
			}

		}

		GUI.color = Color.white;

		GUILayout.EndArea ();

		if (GUI.changed) {
			if (showOrnamentParams) {
				_ornamentHSV.SetupHueShift (_ornamentHueParams [0], _ornamentHueParams [1], _ornamentHueParams [2], _ornamentHueParams [3]);
			} else {
				_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams [3]);
			}
		}
	}

	float DrawSliderInfo (string title, float param, float maxVal)
	{
		GUILayout.Label (string.Format ("{0}:{1:0.00}", title, param));
		float result = GUILayout.HorizontalSlider (param, 0.0f, maxVal, GUILayout.Width (sliderWidth), GUILayout.Height (sliderHeight));
		return result;
	}


	Dictionary<int, Vector4> HandleColorData(string info)
	{
		if (info == string.Empty) {
			return null;
		}

		Dictionary<int, Vector4> ColorDic = new Dictionary<int, Vector4> ();
		string[] sArray = info.Split (',');
		foreach (var item in sArray) {
			var itemAarray = item.Split ('|');
			if (!ColorDic.ContainsKey (int.Parse (itemAarray [0]))) {
				ColorDic.Add (int.Parse (itemAarray [0]), StrToV4 (itemAarray [1]));	
			}
		}

		return ColorDic;
			
	}

	Dictionary<int, List<Vector4>> HandleClothesColorData(string info)
	{
		if (info == string.Empty) {
			return null;
		}

		Dictionary<int, List<Vector4>> ColorDic = new Dictionary<int, List<Vector4>> ();
		string[] sArray = info.Split (',');
		foreach (var item in sArray) {
			var itemAarray = item.Split ('|');
			if (!ColorDic.ContainsKey (int.Parse (itemAarray [0]))) {
				List<Vector4> v4List = new List<Vector4> ();
				v4List.Add (StrToV4(itemAarray [1]));
				v4List.Add (StrToV4 (itemAarray [2]));
				ColorDic.Add (int.Parse (itemAarray [0]), v4List);	
			}
		}

		return ColorDic;

	}

	Dictionary<int, List<Vector4>> HandleSummonColorData(string info)
	{
		if (info == string.Empty) {
			return null;
		}

		Dictionary<int, List<Vector4>> ColorDic = new Dictionary<int, List<Vector4>> ();
		string[] sArray = info.Split (',');
		foreach (var item in sArray) {
			var itemAarray = item.Split ('|');
			if (!ColorDic.ContainsKey (int.Parse (itemAarray [0]))) {
				List<Vector4> v4List = new List<Vector4> ();
				v4List.Add (StrToV4(itemAarray [1]));
				v4List.Add (StrToV4 (itemAarray [2]));
				v4List.Add (StrToV4 (itemAarray [3]));
				v4List.Add (StrToV4 (itemAarray [4]));
				ColorDic.Add (int.Parse (itemAarray [0]), v4List);	
			}
		}

		return ColorDic;

	}

	string ColorDicToStr(Dictionary<int, Vector4> colorDic)
	{
		string[] strArray = new string[colorDic.Count];
		foreach (var item in colorDic) {
			strArray[item.Key-1] = string.Format("{0}|{1}", item.Key, V4ToStr (item.Value));
		}
			
		return  string.Join (",", strArray);
	}

	string ClothesColorDicToStr(Dictionary<int, List<Vector4>> colorDic)
	{
		string[] strArray = new string[colorDic.Count];
		foreach (var item in colorDic) {
			strArray[item.Key-1] = string.Format("{0}|{1}|{2}", item.Key, V4ToStr (item.Value[0]), V4ToStr (item.Value[1]));
		}

		return  string.Join (",", strArray);
	}

	string SummonColorDicToStr(Dictionary<int, List<Vector4>> colorDic)
	{
		string[] strArray = new string[colorDic.Count];
		foreach (var item in colorDic) {
			strArray[item.Key-1] = string.Format("{0}|{1}|{2}|{3}|{4}", item.Key, V4ToStr (item.Value[0]), V4ToStr (item.Value[1]), V4ToStr (item.Value[2]), V4ToStr (item.Value[3]));
		}

		return  string.Join (",", strArray);
	}



	string AllColorDicToStr(Dictionary<int, List<Vector4>> colorDic)
	{
		string[] strArray = new string[colorDic.Count];
		foreach (var item in colorDic) {
			strArray[item.Key-1] = string.Format("{0}|{1}|{2}|{3}|{4}", item.Key, V4ToStr (item.Value[0]), V4ToStr (item.Value[1]), V4ToStr (item.Value[2]), V4ToStr (item.Value[3]));
		}

		return  string.Join (",", strArray);
	}


	Vector4 StrToV4(string colorData)
	{
		var sArray = colorData.Split ('-');
		Vector4 colorList = new Vector4 (float.Parse(sArray[0]), float.Parse(sArray[1]), float.Parse(sArray[2]), float.Parse(sArray[3]));
		return colorList;
	}
	string V4ToStr(Vector4 colorData)
	{
		return string.Format ("{0}-{1}-{2}-{3}", colorData.x, colorData.y, colorData.z, colorData.w);
	}
		

	void DrawHairButtonList(bool isLoadData, Dictionary<int,Vector4> colorDic)
	{
		if (isLoadData) {
			foreach (var item in colorDic) {
				if (GUILayout.Toggle (hairIndexLabel == string.Empty?false: int.Parse(hairIndexLabel) == item.Key, item.Key.ToString(), GUILayout.Width (40f))) {
					curHairKey = item.Key;
					_modelHueParams[0] = colorDic [item.Key];
					_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams [3]);
					hairIndexLabel = item.Key.ToString ();

				}
			}
				
		}
	}

	void DrawPantButtonList(bool isLoadData,  Dictionary<int,Vector4> colorDic)
	{
		if (isLoadData) {

			foreach (var item in colorDic) {
				if (GUILayout.Toggle (pantIndexLabel == string.Empty?false: int.Parse(pantIndexLabel) == item.Key, item.Key.ToString(), GUILayout.Width (40f))) {
					curPantKey = item.Key;
					_modelHueParams[3] = colorDic [item.Key];
					_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams [3]);
					pantIndexLabel = item.Key.ToString ();
				}
			}

		}
	}

	void DrawClothesButtonList(bool isLoadData, Dictionary<int, List<Vector4>> colorDic)
	{
		if (isLoadData) {
			foreach (var item in colorDic) {
				if (GUILayout.Toggle (clothesIndexLabel == string.Empty?false: int.Parse(clothesIndexLabel) == item.Key, item.Key.ToString(), GUILayout.Width (40f))){
					curClothesKey = item.Key;
					_modelHueParams [1] = item.Value[0];
					_modelHueParams[2] = item.Value[1];
					_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams [3]);
					clothesIndexLabel = item.Key.ToString ();
				}
			}
		}
	}

	void DrawSummonButtonList(bool isLoadData, Dictionary<int, List<Vector4>> colorDic)
	{
		if (isLoadData) {
			foreach (var item in colorDic) {
				if (GUILayout.Toggle (summonIndexLabel == string.Empty?false: int.Parse(summonIndexLabel) == item.Key, item.Key.ToString(), GUILayout.Width (40f))){
					curSummonKey = item.Key;
					_modelHueParams = item.Value;
					_modelHSV.SetupHueShift (_modelHueParams [0], _modelHueParams [1], _modelHueParams [2], _modelHueParams [3]);
					summonIndexLabel = item.Key.ToString ();
				}
			}
		}
	}

	string ReadColorData()
	{
		string data = string.Empty;
		var path = EditorUtility.OpenFilePanel ("染色配置文件", null, "txt");
		if (path.Length != 0) {
			data = File.ReadAllText (path);
			Debug.Log ("------------------读取成功");
		}
		return data;
	}

	void SaveData(string data, string name)
	{
		var path = EditorUtility.SaveFilePanel ("保存数据", "", name, "txt");
		if (path.Length != 0) {
			File.WriteAllText (path, data);
			EditorUtility.DisplayDialog (null, "保存成功", "ok");

		}
	}

	void SaveAll()
	{
		if ((pantIndexLabel == string.Empty) || (clothesIndexLabel == string.Empty) || (hairIndexLabel == string.Empty)) {
			EditorUtility.DisplayDialog (null, "颜色索引不能为空", "ok");
			return;
		}

		if ((hairColorDic.Count == clothesColorDic.Count) && (clothesColorDic.Count == pantColorDic.Count)) {

			Dictionary<int, List<Vector4>> info = new Dictionary<int, List<Vector4>> ();

			foreach (var item in hairColorDic) {
				List<Vector4> v4List = new List<Vector4> ();
				if (!info.ContainsKey (item.Key)) {
					v4List.Add (item.Value);
					info.Add (item.Key, v4List);
				} else {
					var v4 = info [item.Key];
					v4.Add (item.Value);
				}
			}
			foreach (var item in clothesColorDic) {
				List<Vector4> v4List = new List<Vector4> ();
				if (!info.ContainsKey (item.Key)) {
					v4List.Add (item.Value[0]);
					v4List.Add (item.Value[1]);
					info.Add (item.Key, v4List);
				} else {
					var v4 = info [item.Key];
					v4.Add (item.Value[0]);
					v4.Add (item.Value[1]);
				}
			}

			foreach (var item in pantColorDic) {
				List<Vector4> v4List = new List<Vector4> ();
				if (!info.ContainsKey (item.Key)) {
					v4List.Add (item.Value);
					info.Add (item.Key, v4List);
				} else {
					var v4 = info [item.Key];
					v4.Add (item.Value);
				}
			}

			var colorStr = AllColorDicToStr (info);

			SaveData (colorStr, "allColor");


		} else {
			EditorUtility.DisplayDialog ("错误", "请检查数据长度是否正确!", "ok");
		}
	}
}

#endif
