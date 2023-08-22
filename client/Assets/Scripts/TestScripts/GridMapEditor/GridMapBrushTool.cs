using System;
using System.IO;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;

[ExecuteInEditMode]
public class GridMapBrushTool : MonoBehaviour
{
    public enum ColorChannel
    {
        R, G, B, A
    }

    //[SerializeField]
    public bool _inEditMode = false;

    public Texture2D gridRef;
    public float nodeSize = 0.32f;
    public float threshold = 0.2f; //只判断像素点大于该阈值的点
    //public Color unwalkableColor = Color.clear;
    //public Color walkableColor = new Color(1f, 0f, 0f, 0.25f);
    //public Color flyableColor = new Color(0, 1f, 0f, 0.25f);

    private Texture2D _gridRefTemp;

    public AstarPath astarPath
    {
        get { return AstarPath.active; }
    }

    public int Height { get; private set; }

    public int Width { get; private set; }

    public Texture2D GridRefTemp
    {
        get { return _gridRefTemp; }
    }

    private void Start()
    {
    }

    public void BeginEditMode()
    {
        if (this.gridRef == null)
        {
#if UNITY_EDITOR
            EditorUtility.DisplayDialog("提示", "未设置可行走区域贴图,不能编辑!", "OK");
#endif
            return;
        }

        if (!_inEditMode)
        {
            _inEditMode = true;
            astarPath.showNavGraphs = false;
            Width = gridRef.width;
            Height = gridRef.height;
            _gridRefTemp = Instantiate(gridRef) as Texture2D;
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
                resPath = AssetDatabase.GetAssetPath(gridRef);
#endif
                var bytes = _gridRefTemp.EncodeToPNG();
                File.WriteAllBytes(resPath, bytes);
            }
            catch (Exception e)
            {
                Debug.LogException(e);
            }
        }

        _gridRefTemp = null;
#if UNITY_EDITOR
        AssetDatabase.Refresh();
#endif
    }

    public Color GetPixelColor(int x, int y)
    {
        if (_gridRefTemp == null) return Color.black;
        return _gridRefTemp.GetPixel(x, y);
    }

    /// <summary>
    ///     绿色通道为飞行区域,红色通道为行走区域,否则为不可行走区域
    /// </summary>
    /// <param name="c"></param>
    /// <returns></returns>
    //public Color GetNodeColor(Color c)
    //{
    //    var result = unwalkableColor;
    //    if (c.g > threshold)
    //        result += flyableColor;
    //    if (c.r > threshold)
    //        result += walkableColor;
    //    return result;
    //}

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

    public void SetColor(int x, int y, Color c)
    {
        if (_gridRefTemp == null) return;

        _gridRefTemp.SetPixel(x, y, c);
    }

    public void SetColorChannel(int x, int y, float val, ColorChannel channel)
    {
        if (_gridRefTemp == null) return;

        var tmpColor = _gridRefTemp.GetPixel(x, y);
        if (channel == ColorChannel.R)
            tmpColor.r = val;
        else if (channel == ColorChannel.G)
            tmpColor.g = val;
        else if (channel == ColorChannel.B)
            tmpColor.b = val;
        else if (channel == ColorChannel.A)
            tmpColor.a = val;
        _gridRefTemp.SetPixel(x, y, tmpColor);
    }

    public void SetRectColor(int x0, int y0, int x1, int y1, Color c)
    {
        if (_gridRefTemp == null) return;

        for (int i = x0; i <= x1; i++)
        {
            for (int j = y0; j <= y1; j++)
            {
                _gridRefTemp.SetPixel(i, j, c);
            }
        }
    }

    public void SetRectColorChannel(int x0, int y0, int x1, int y1, float val, ColorChannel channel)
    {
        if (_gridRefTemp == null) return;

        for (int i = x0; i <= x1; i++)
        {
            for (int j = y0; j <= y1; j++)
            {
                SetColorChannel(i, j, val, channel);
            }
        }
    }
}