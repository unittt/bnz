using System;
using System.IO;
using System.Collections.Generic;
using System.Text;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

[ExecuteInEditMode]
public class GridMapAreaTool : MonoBehaviour
{
    public float _minX, _maxX, _minY, _maxY = 0.0f;
    public static Color[] ColorChannnel = new Color[]
    {
        new Color(1, 1, 1, 0.2f),
        new Color(1, 0, 0, 0.2f),
        new Color(0, 1, 0, 0.2f),
        new Color(0, 0, 1, 0.2f),
        new Color(1, 1, 0, 0.2f),
        new Color(0, 1, 1, 0.2f),
    };

    //[SerializeField]
    public bool _inEditMode = false;
    public Texture2D gridRef;
    public float nodeSize = 0.32f;
    public float threshold = 0.2f; //只判断像素点大于该阈值的点
    public GameObject _cubes;
    public Dictionary<string, GameObject> redColor = new Dictionary<string, GameObject>();
    public AstarPath astarPath
    {
        get { return AstarPath.active; }
    }

    public int Height { get; private set; }

    public int Width { get; private set; }

    public TextAsset textAssetData;

    public int[,] lineData;

    private void Start()
    {
        _cubes = GameObject.Find("_Cubes");
        if (_cubes == null)
        {
            _cubes = new GameObject("_Cubes");
            _cubes.transform.position = Vector3.zero;
        }
    }

    public void BeginEditMode()
    {
        if (this.textAssetData == null)
        {
#if UNITY_EDITOR
            EditorUtility.DisplayDialog("提示", "未找到数据文件，是否新建!", "OK");
#endif
            return;
        }

        if (_inEditMode)
            return;

        _inEditMode = true;
        astarPath.showNavGraphs = false;
        Width = gridRef.width;
        Height = gridRef.height;

        string[] lines = this.textAssetData.text.ToString().Split('\n');
        if (lines.Length != Height || lines[0].Length != Width)
        {
#if UNITY_EDITOR
            string msg = string.Format("加载数据有误, 地图大小{0}x{1} 文件数据大小{2}x{3}", Width, Height, lines[0].Length, lines.Length);
            EditorUtility.DisplayDialog("提示", msg, "OK");
#endif
        }
        
        lineData = new int[Width, Height];
        for (int y = 0; y < lines.Length; y++)
        {
            for (int x = 0; x < lines[y].Length; x++)
            {
                int ry = lines.Length - 1 - y;
                lineData[x, ry] = (int)(lines[y][x] - '0');
            }
        }
    }

    public void EndEditMode(bool save)
    {
        _inEditMode = false;
        astarPath.showNavGraphs = true;
        Width = 0;
        Height = 0;

        if (save)
        {
            try
            {
                string resPath = null;
#if UNITY_EDITOR
				resPath = AssetDatabase.GetAssetPath(textAssetData);
#endif
                StringBuilder sb = new StringBuilder();
                for (int y = 0; y < lineData.GetLength(1); y++)
                {
                    int ry = lineData.GetLength(1) - 1 - y;
                    for(int x = 0; x < lineData.GetLength(0); x++)
                    {
                        sb.Append((char)('0' + lineData[x, ry]));
                    }
                    //Debug.Log(i + " " + lineData.GetLength(0));
                    //if(i < lineData.Length - 2)
					sb.Append('\n');
                }
                sb.Remove(sb.Length -1 , 1);
                Debug.Log(sb.ToString());
                File.WriteAllText(resPath, sb.ToString());

            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }
        
        //_gridRefTemp = null;
#if UNITY_EDITOR
        AssetDatabase.Refresh();
#endif
    }

    public void Clear()
    {
        textAssetData = null;
    }

    public Color GetPixelColor(int x, int y)
    {
        if(lineData == null)
            return Color.black;

        int value = lineData[x, y];
        AddCube(x, y);
        return ColorChannnel[value];
    }

    /// <summary>
    /// 添加一个世界坐标的cube检测实际坐标
    /// </summary>
    /// <param name="x"></param>
    /// <param name="y"></param>
    private void AddCube(int x, int y)
    {
        int value = lineData[x, y];
        string key = "x=" + x + "," + "y=" + y;
        if (value == 1)
        {
            if (!redColor.ContainsKey(key))
            {
                GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
                redColor[key] = cube;
                float xValue = 0.16f + (float)x * 0.32f;
                float yValue = 0.16f + (float)y * 0.32f;
                cube.gameObject.name = string.Format("编辑点({0},{1})__实际点({2},{3})",x, y, xValue, yValue);
                cube.transform.position = new Vector3(xValue, yValue, 0);
                cube.transform.SetParent(_cubes.transform);
                /*
                if (_minX == 0)
                {
                    _minX = xValue;
                }
                if (_minY == 0)
                {
                    _minY = yValue;
                }
                if (xValue < _minX)
                {
                    _minX = xValue;
                }
                if (xValue > _maxX)
                {
                    _maxX = xValue;
                }
                if (yValue < _minY)
                {
                    _minY = yValue;
                }
                if (yValue > _maxY)
                {
                    _maxY = yValue;
                }
                */
            }

        }
        else
        {
            if (redColor.ContainsKey(key))
            {
                DestroyImmediate(redColor[key].gameObject, true);
                redColor.Remove(key);
            }
        }
    }

    public void ShowCube(bool bShow)
    {
        foreach (var item in redColor)
        {
            item.Value.gameObject.SetActive(bShow);
        }
        //PK擂台区域。
        //Debug.Log(_minX.ToString() + "," + _maxX.ToString() + "," + _minY.ToString() + "," + _maxY.ToString());
    }

    /// <summary>
    ///     根据世界坐标获取对应贴图的像素点索引值
    /// </summary>
    /// <param name="position"></param>
    /// <param name="x"></param>
    /// <param name="y"></param>
    /// <returns></returns>
    public bool GetTileIndexByWorldPos(Vector3 position, out int x, out int y)
    {
        var localPosition = transform.worldToLocalMatrix.MultiplyPoint(position);
        x = (int)(localPosition.x / nodeSize);
        y = (int)(localPosition.y / nodeSize);

        bool isInside = x >= 0 && x < Width && y >= 0 && y < Height;
        x = Mathf.Clamp(x, 0, Width - 1);
        y = Mathf.Clamp(y, 0, Height - 1);
        return isInside;
    }


    public void SetValue(int x, int y, int value)
    {

        lineData[x, y] = value;
    }

    public void SetRectValue(int x0, int y0, int x1, int y1, int val)
    {
        for (int i = x0; i <= x1; i++)
        {
            for (int j = y0; j <= y1; j++)
            {
                SetValue(i, j, val);
            }
        }
    }

}