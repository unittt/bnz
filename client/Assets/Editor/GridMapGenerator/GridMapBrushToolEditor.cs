using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(GridMapBrushTool))]
public class GridMapBrushToolEditor : Editor
{
    public enum BrushMode
    {
        WalkableBrush,
        FlyableBrush,
        Transparent,
        Erase
    }

    public static int gridMapBrushHashCode = "GridMapBrushTool".GetHashCode();

    public static BrushMode brushMode = BrushMode.WalkableBrush;
    private readonly Color tileSelectionFillColor = new Color32(0, 128, 255, 32);
    private readonly Color tileSelectionOutlineColor = new Color32(0, 200, 255, 255);
    int cursorX0 = 0, cursorY0 = 0;
    int cursorX = 0, cursorY = 0;
    bool pencilDragActive = false;
    private GridMapBrushTool tileMap;

    BrushMode pushedToolbarMainMode = BrushMode.WalkableBrush;
    bool hotkeyModeSwitchActive = false;
    System.Action<int> pendingModeChange = null;


    private void OnEnable()
    {
        tileMap = target as GridMapBrushTool;
    }

    public override void OnInspectorGUI()
    {
        tileMap.gridRef =
            EditorGUILayout.ObjectField("GridRef:", tileMap.gridRef, typeof(Texture2D), false) as Texture2D;
        tileMap.threshold = EditorGUILayout.FloatField("Threshold:", tileMap.threshold);
        //tileMap.unwalkableColor = EditorGUILayout.ColorField("Unwalkable Color:", tileMap.unwalkableColor);
        //tileMap.walkableColor = EditorGUILayout.ColorField("Walkable Color:", tileMap.walkableColor);
        //tileMap.flyableColor = EditorGUILayout.ColorField("Flyable Color:", tileMap.flyableColor);
        tileMap.nodeSize = EditorGUILayout.FloatField("NodeSize:", tileMap.nodeSize);
        
        if (!tileMap._inEditMode)
        {
            if (GUILayout.Button("编辑", GUILayout.Height(40f)))
            {
                tileMap.BeginEditMode();
                Repaint();
            }
            return;
        }

        if (GUILayout.Button("保存", GUILayout.Height(40f)))
        {
            bool save = EditorUtility.DisplayDialog("提示", "是否保存寻路数据贴图?", "Yes", "No");
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

                //    if (hotkeysPressed)
                //    {
                //        if (!hotkeyModeSwitchActive)
                //        {
                //            // Push mode
                //            pushedToolbarMainMode = brushMode;
                //        }
                //        if (ctrlKeyDown)
                //        {
                //            clickColorValue = 0;
                //            //pendingModeChange = delegate (int i)
                //            //{
                //            //    brushMode = BrushMode.Erase;
                //            //    hotkeyModeSwitchActive = true;
                //            //};
                //        }
                //        else
                //        {
                //            clickColorValue = 1;
                //            //pendingModeChange = delegate (int i)
                //            //{
                //            //    brushMode = BrushMode.FlyableBrush;
                //            //    hotkeyModeSwitchActive = true;
                //            //};
                //        }
                //    }
                //    else
                //    {
                //        if (hotkeyModeSwitchActive)
                //        {
                //            // Pop mode
                //            clickColorValue = 1;
                //            pendingModeChange = delegate(int i)
                //            {
                //                brushMode = pushedToolbarMainMode;
                //                hotkeyModeSwitchActive = false;
                //            };
                //        }
                //    }

                //}

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

        if (RectangleDragSize() > 50)
        {
            Undo.RegisterCompleteObjectUndo(tileMap.GridRefTemp, "Edit tile map");
        }
        else
        {
            Undo.RecordObject(tileMap.GridRefTemp, "Edit tile map");
        }

        if ((cursorX == cursorX0) && (cursorY == cursorY0))
        {
            if (brushMode == BrushMode.WalkableBrush)
            {
                tileMap.SetColorChannel(cursorX, cursorY, clickColorValue, GridMapBrushTool.ColorChannel.R);
            }
            else if (brushMode == BrushMode.FlyableBrush)
            {
                //行走区域是飞行区域的子集,所以飞行区域填充黄色
                tileMap.SetColorChannel(cursorX, cursorY, clickColorValue, GridMapBrushTool.ColorChannel.G);
            }
            else if (brushMode == BrushMode.Transparent)
            {
                tileMap.SetColorChannel(cursorX, cursorY, clickColorValue, GridMapBrushTool.ColorChannel.B);
            }
            else if (brushMode == BrushMode.Erase)
            {
                tileMap.SetColor(cursorX, cursorY, Color.black);
            }
        }
        else
        {
            int x0 = Mathf.Min(cursorX, cursorX0);
            int x1 = Mathf.Max(cursorX, cursorX0);
            int y0 = Mathf.Min(cursorY, cursorY0);
            int y1 = Mathf.Max(cursorY, cursorY0);

            if (brushMode == BrushMode.WalkableBrush)
            {
                tileMap.SetRectColorChannel(x0, y0, x1, y1, clickColorValue, GridMapBrushTool.ColorChannel.R);
            }
            else if (brushMode == BrushMode.FlyableBrush)
            {
                tileMap.SetRectColorChannel(x0, y0, x1, y1, clickColorValue, GridMapBrushTool.ColorChannel.G);
            }
            else if (brushMode == BrushMode.Transparent)
            {
                tileMap.SetRectColorChannel(x0, y0, x1, y1, clickColorValue, GridMapBrushTool.ColorChannel.B);
            }
            else if (brushMode == BrushMode.Erase)
            {
                tileMap.SetRectColor(x0, y0, x1, y1, Color.black);
            }
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
        GUILayout.TextArea(tooltip);
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
        if (HiliteBtn(null, brushMode == BrushMode.WalkableBrush,
            Color.red, "行走"))
            brushMode = BrushMode.WalkableBrush;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.FlyableBrush,
            Color.green, "飞行"))
            brushMode = BrushMode.FlyableBrush;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.Transparent,
            Color.blue, "透明"))
            brushMode = BrushMode.Transparent;
        GUILayout.Space(10);

        if (HiliteBtn(null, brushMode == BrushMode.Erase,
            Color.white, "清除"))
            brushMode = BrushMode.Erase;

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
                pixelColor.a = 0.25f;
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