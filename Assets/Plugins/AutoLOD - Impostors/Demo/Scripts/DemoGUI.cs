// Copyright (c) 2021-2022 Léo Chaumartin

using UnityEngine;
using System.Collections;

public class DemoGUI : MonoBehaviour
{
    float deltaTime = 0.0f;
    bool autolod = true;
    Color textColor = Color.black;
    GUIStyle style;

    private void Start()
    {

        style = new GUIStyle();
        style.alignment = TextAnchor.MiddleCenter;
        style.fontSize = 32;
        style.normal.textColor = textColor;
    }

    void Update()
    {
        deltaTime += (Time.unscaledDeltaTime - deltaTime) * 0.1f;
        if (Input.GetKeyDown(KeyCode.E))
        {
            autolod = !autolod;
            LODGroup[] lodgroups = FindObjectsOfType(typeof(LODGroup)) as LODGroup[];
            if (autolod)
            {
                foreach (LODGroup lg in lodgroups)
                {
                    lg.enabled = true;
                    lg.GetLODs()[1].renderers[0].gameObject.SetActive(true);
                }
            }
            else
            {
                foreach (LODGroup lg in lodgroups)
                {
                    lg.GetLODs()[1].renderers[0].gameObject.SetActive(false);
                    lg.enabled = false;
                }
            }
        }
    }

    void OnGUI()
    {
        int w = Screen.width, h = Screen.height;

        Rect containerRect = new Rect(8, h - 72, w - 16, 64);
        GUI.DrawTexture(containerRect, Texture2D.linearGrayTexture);
        Rect labelRect = new Rect(0, h - 72, w, 32);
        string text;
        float msec = deltaTime * 1000.0f;
        float fps = 1.0f / deltaTime;
        text = string.Format( (autolod ? "Impostors enabled : " : "Impostors disabled : ") + "{0:0.0} ms ({1:0.} fps)", msec, fps);
        GUI.Label(labelRect, text, style);
        labelRect.y += 32;
        GUI.Label(labelRect, "Press E to switch " + (autolod ? "Off" : "On") + " LODGroups and impostors", style);

        
        
    }
}