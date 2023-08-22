using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(GridMapAreaTool))]
public class GridMapAreaToolEditor : Editor
{
    public enum BrushMode
    {
        Brush0,
        Brush1,
        Brush2,
        Brush3,
        Brush4,
        Brush5,
    }

    public static int gridMapBrushHashCode = "GridMapAreaTool".GetHashCode();
    private static bool bShowCube = true;
    public static BrushMode brushMode = BrushMode.Brush0;
    private readonly Color tileSelectionFillColor = new Color32(0, 128, 255, 32);
    private readonly Color tileSelectionOutlineColor = new Color32(0, 200, 255, 255);
    int cursorX0 = 0, cursorY0 = 0;
    int cursorX = 0, cursorY = 0;
    bool pencilDragActive = false;
    private GridMapAreaTool tileMap;

    BrushMode pushedToolbarMainMode = BrushMode.Brush0;
    bool hotkeyModeSwitchActive = false;
    System.Action<int> pendingModeChange = null;


    private void OnEnable()
    {
        tileMap = target as GridMapAreaTool;
	}
	
	private void OnDisable()
	{
		if (GridMapGenerator.Instance && GridMapGenerator.Instance.gridEditorType != GridMapGenerator.GridEditorType.Nothing) {
			Selection.activeGameObject = GridMapGenerator.Instance.AreaTool.gameObject;
		}
	}

    public override void OnInspectorGUI()
    {
        tileMap.textAssetData = EditorGUILayout.ObjectField("TextAsset:", tileMap.textAssetData, typeof(TextAsset), false) as TextAsset;


        tileMap.threshold = EditorGUILayout.FloatField("Threshold:", 0.2f);
        //tileMap.unwalkableColor = EditorGUILayout.ColorField("Unwalkable Color:", tileMap.unwalkableColor);
        //tileMap.walkableColor = EditorGUILayout.ColorField("Walkable Color:", tileMap.walkableColor);
        //tileMap.flyableColor = EditorGUILayout.ColorField("Flyable Color:", tileMap.flyableColor);
        tileMap.nodeSize = EditorGUILayout.FloatField("NodeSize:", 0.32f);
        bShowCube = GUILayout.Toggle(bShowCube, new GUIContent("显示cube"));
        tileMap.ShowCube(bShowCube);

        if (!tileMap._inEditMode)
        {
            if (GUILayout.Button("编辑", GUILayout.Height(40f)))
            {
				if (tileMap.textAssetData == null) {
					return;
				}
                tileMap.BeginEditMode();
                Repaint();
            }
            return;
        }

        if (GUILayout.Button("保存", GUILayout.Height(40f)))
        {
			if (tileMap.textAssetData == null) {
				EditorUtility.DisplayDialog("提示", "未找到数据文件!", "OK");
				return;
			}
            bool save = EditorUtility.DisplayDialog("提示", "是否保存编辑数据?", "Yes", "No");
            tileMap.EndEditMode(save);
            Repaint();
        }
    }


    private static int clickColorValue = 1;

    private void OnSceneGUI()
    {
        if (!tileMap._inEditMode) return;
        DrawOutline();
        DrawTileMap();
        DrawTileCursor();

        //Draw Toolbar
        DrawToolbar();

        //EventHandler
        int controlID = gridMapBrushHashCode;
        EventType controlEventType = Event.current.GetTypeForControl(controlID);
        switch (controlEventType)
        {
            case EventType.MouseDown:
            case EventType.MouseDrag:
                if ((controlEventType == EventType.MouseDrag && GUIUtility.hotControl != controlID) ||
                    (Event.current.button != 0 && Event.current.button != 1))
                {
                    return;
                }

                // make sure we don't use up reserved combinations
                bool inhibitMouseDown = false;
                if (Application.platform == RuntimePlatform.OSXEditor)
                {
                    if (Event.current.command && Event.current.alt)
                    { // pan combination on mac
                        inhibitMouseDown = true;
                    }
                }

                if (Event.current.type == EventType.MouseDown && !inhibitMouseDown)
                {
                    if (UpdateCursorPosition() && !Event.current.shift)
                    {
                        GUIUtility.hotControl = controlID;
                        PencilDrag();
                    }
                }

                if (Event.current.type == EventType.MouseDrag && GUIUtility.hotControl == controlID)
                {
                    UpdateCursorPosition();
                    PencilDrag();
                }
                break;

            case EventType.MouseUp:
                if ((Event.current.button == 0 || Event.current.button == 1) && GUIUtility.hotControl == controlID)
                {
                    GUIUtility.hotControl = 0;
                    RectangleDragEnd();

                    cursorX0 = cursorX;
                    cursorY0 = cursorY;

                    HandleUtility.Repaint();
                }
                break;

            case EventType.Layout:
                //HandleUtility.AddDefaultControl(controlID);
                break;

            case EventType.MouseMove:
                UpdateCursorPosition();
                cursorX0 = cursorX;
                cursorY0 = cursorY;
                break;
        }

        // Hotkeys switch the static toolbar mode
        {
            bool ctrlKeyDown = (Application.platform == RuntimePlatform.OSXEditor) ? Event.current.command : Event.current.control;
            bool atlKeyDown = Event.current.alt;
            bool hotkeysPressed = ctrlKeyDown || atlKeyDown;

            if (!pencilDragActive)
            {

                if (ctrlKeyDown)
                {
                    clickColorValue = 0;
                }
                else
                {
                    clickColorValue = 1;
                }
            }

        }

        if (pendingModeChange != null && Event.current.type == EventType.Repaint)
        {
            pendingModeChange(0);
            pendingModeChange = null;
            HandleUtility.Repaint();
        }
    }

    void PencilDrag()
    {
        pencilDragActive = true;
    }

    void RectangleDragEnd()
    {
        if (!pencilDragActive)
            return;

        //if (RectangleDragSize() > 50)
        //{
        //    tk2dUndo.RegisterCompleteObjectUndo(tileMap.GridRefTemp, "Edit tile map");
        //}
        //else
        //{
        //    tk2dUndo.RecordObject(tileMap.GridRefTemp, "Edit tile map");
        //}

        if ((cursorX == cursorX0) && (cursorY == cursorY0))
        {
            tileMap.SetValue(cursorX, cursorY, (int)brushMode);
        }
        else
        {
            int x0 = Mathf.Min(cursorX, cursorX0);
            int x1 = Mathf.Max(cursorX, cursorX0);
            int y0 = Mathf.Min(cursorY, cursorY0);
            int y1 = Mathf.Max(cursorY, cursorY0);
            tileMap.SetRectValue(x0, y0, x1, y1, (int)brushMode);
        }

        pencilDragActive = false;
    }

    int RectangleDragSize()
    {
        if (!pencilDragActive)
            return 0;

        int x0 = Mathf.Min(cursorX, cursorX0);
        int x1 = Mathf.Max(cursorX, cursorX0);
        int y0 = Mathf.Min(cursorY, cursorY0);
        int y1 = Mathf.Max(cursorY, cursorY0);

        return (x1 - x0) * (y1 - y0);
    }

    private static bool HiliteBtn(Texture2D texture, bool hilite, Color hiliteColor, string tooltip)
    {
        hiliteColor.a = 1.0f;
        if (hilite)
        {
            GUI.contentColor = hiliteColor + new Color(0.3f, 0.3f, 0.3f, 0);
            GUI.backgroundColor = hiliteColor + new Color(0.3f, 0.3f, 0.3f, 0);
        }
        else
        {
            GUI.contentColor = Color.white;
            GUI.backgroundColor = Color.gray;
        }
        bool pressed = GUILayout.Button(new GUIContent(texture, tooltip), GUILayout.Width(30));

        GUI.backgroundColor = Color.white;
        GUI.contentColor = Color.white;

        return pressed;
    }

    private void DrawToolbar()
    {
        Handles.BeginGUI();
        GUILayout.BeginArea(new Rect(0, 0, Screen.width, Screen.height));
        var ev = Event.current;

        GUILayout.BeginVertical("Box", GUILayout.Width(20), GUILayout.Height(34));
        string eraseTooltipStr = Application.platform == RuntimePlatform.OSXEditor ? "Command" : "Ctrl";

        var lastColor = GUI.contentColor;

        GUILayout.BeginHorizontal();

        // Brush modes
        if (HiliteBtn(null, brushMode == BrushMode.Brush0, GridMapAreaTool.ColorChannnel[(int)BrushMode.Brush0], "Brush0"))
            brushMode = BrushMode.Brush0;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.Brush1, GridMapAreaTool.ColorChannnel[(int)BrushMode.Brush1], "Brush1"))
            brushMode = BrushMode.Brush1;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.Brush2, GridMapAreaTool.ColorChannnel[(int)BrushMode.Brush2], "Brush2"))
            brushMode = BrushMode.Brush2;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.Brush3, GridMapAreaTool.ColorChannnel[(int)BrushMode.Brush3], "Brush3"))
            brushMode = BrushMode.Brush3;

        GUILayout.Space(10);
        if (HiliteBtn(null, brushMode == BrushMode.Brush4, GridMapAreaTool.ColorChannnel[(int)BrushMode.Brush4], "Brush4"))
            brushMode = BrushMode.Brush4;
        GUILayout.Space(10);

        GUILayout.EndHorizontal();

        GUILayout.Space(10);
        EditorGUILayout.LabelField("origin:    " + cursorX0 + "," + cursorY0, GUILayout.Width(100f));
        EditorGUILayout.LabelField("end:    " + cursorX + "," + cursorY, GUILayout.Width(100f));

        GUI.contentColor = lastColor;
        GUILayout.EndVertical();
        GUILayout.EndArea();
        Handles.EndGUI();
    }

    void DrawOutline()
    {
        Vector3 p0 = Vector3.zero;
        Vector3 p1 = new Vector3(p0.x + tileMap.nodeSize * tileMap.Width, p0.y + tileMap.nodeSize * tileMap.Height, 0);

        Vector3[] v = new Vector3[5];
        v[0] = new Vector3(p0.x, p0.y, 0);
        v[1] = new Vector3(p1.x, p0.y, 0);
        v[2] = new Vector3(p1.x, p1.y, 0);
        v[3] = new Vector3(p0.x, p1.y, 0);
        v[4] = new Vector3(p0.x, p0.y, 0);

        //for (int i = 0; i < 5; ++i)
        //{
        //    v[i] = tileMap.transform.TransformPoint(v[i]);
        //}

        Handles.DrawPolyLine(v);
    }


    private void DrawTileMap()
    {
        if (tileMap == null || tileMap.gridRef == null) return;
        int width = tileMap.Width;
        int height = tileMap.Height;

        for (int i = 0; i < width; i++)
        {
            for (int j = 0; j < height; j++)
            {
                var pixelColor = tileMap.GetPixelColor(i, j);
                if (pixelColor == Color.black) continue;
                DrawTileRect(i, j, pixelColor, Color.black);
            }
        }
    }

    private void DrawTileCursor()
    {
        int x0 = Mathf.Min(cursorX, cursorX0);
        int x1 = Mathf.Max(cursorX, cursorX0) + 1;
        int y0 = Mathf.Min(cursorY, cursorY0);
        int y1 = Mathf.Max(cursorY, cursorY0) + 1;

        var p0 = new Vector3(x0 * tileMap.nodeSize, y0 * tileMap.nodeSize, 0f);
        var p1 = new Vector3(x1 * tileMap.nodeSize, y1 * tileMap.nodeSize, 0f);

        var v = tileRectPoints;
        v[0] = new Vector3(p0.x, p0.y, 0);
        v[1] = new Vector3(p1.x, p0.y, 0);
        v[2] = new Vector3(p1.x, p1.y, 0);
        v[3] = new Vector3(p0.x, p1.y, 0);

        //for (int i = 0; i < v.Length; ++i)
        //    v[i] = tileMap.transform.TransformPoint(v[i]);

        Handles.DrawSolidRectangleWithOutline(v, tileSelectionFillColor, tileSelectionOutlineColor);
    }

    private static readonly Vector3[] tileRectPoints = new Vector3[4];
    private void DrawTileRect(int x, int y, Color faceColor, Color outlineColor)
    {
        var p0 = new Vector3(x * tileMap.nodeSize, y * tileMap.nodeSize, 0f);
        var p1 = new Vector3((x + 1) * tileMap.nodeSize, (y + 1) * tileMap.nodeSize, 0f);

        var v = tileRectPoints;
        v[0] = new Vector3(p0.x, p0.y, 0);
        v[1] = new Vector3(p1.x, p0.y, 0);
        v[2] = new Vector3(p1.x, p1.y, 0);
        v[3] = new Vector3(p0.x, p1.y, 0);

        //for (int i = 0; i < v.Length; ++i)
        //    v[i] = tileMap.transform.TransformPoint(v[i]);

        Handles.DrawSolidRectangleWithOutline(v, faceColor, outlineColor);
    }

    private bool UpdateCursorPosition()
    {
        bool isInside = false;

        var p = new Plane(tileMap.transform.forward, tileMap.transform.position);
        var r = HandleUtility.GUIPointToWorldRay(Event.current.mousePosition);
        float hitD = 0.0f;

        if (p.Raycast(r, out hitD))
        {
            if (tileMap.GetTileIndexByWorldPos(r.GetPoint(hitD), out cursorX, out cursorY))
            {
                isInside = true;
            }

            HandleUtility.Repaint();
        }

        return isInside;
    }
}