using System;
using UnityEditor;
using UnityEditor.AnimatedValues;
using UnityEditor.Rendering;
using UnityEngine;

namespace NKStudio
{
    public class WaterUI
    {
        public static Texture AssetIcon;
        public static Texture WarningIcon;
        public static Texture ErrorIcon;
        public static Texture InfoIcon;

        private static readonly Color RedColor = new Color(1f, 0.31f, 0.34f);
        private static readonly Color OrangeColor = new Color(1f, 0.68f, 0f);

        private const float ANIM_SPEED = 12f;

        // const float XPadding = 30f;
        // const float YPadding = 5f;
        // const float DefaultHeight = 20f;
        // const float DocsButtonHeight = 20f;
        static float _height;

        public static bool ExpandTooltips
        {
            get => SessionState.GetBool("UI_TOOLTIPS", false);
            set => SessionState.SetBool("UI_TOOLTIPS", value);
        }

        static WaterUI()
        {
            WarningIcon = EditorGUIUtility.IconContent(iconPrefix + "console.warnicon").image;
            ErrorIcon = EditorGUIUtility.IconContent(iconPrefix + "console.erroricon").image;
            InfoIcon = EditorGUIUtility.IconContent(iconPrefix + "console.infoicon").image;
            AssetIcon = EditorGUIUtility.IconContent("Material Icon").image;
        }


        public static string iconPrefix => EditorGUIUtility.isProSkin ? "d_" : "";

        public static void DrawHeader(string name, Shader targetShader)
        {
            // Init
            GUIStyle rolloutHeaderStyle = new GUIStyle();
            rolloutHeaderStyle.fontStyle = FontStyle.Bold;
            rolloutHeaderStyle.normal.textColor = EditorGUIUtility.isProSkin ? Color.white : Color.black;
            rolloutHeaderStyle.alignment = TextAnchor.MiddleCenter;
            rolloutHeaderStyle.fontSize = 24;

            if (GUILayout.Button(name, rolloutHeaderStyle, GUILayout.Height(24), GUILayout.ExpandWidth(true)))
            {
                string path = AssetDatabase.GetAssetPath(targetShader);
                Shader textAsset = AssetDatabase.LoadAssetAtPath<Shader>(path);
                AssetDatabase.OpenAsset(textAsset);
            }
            Rect buttonRect = GUILayoutUtility.GetLastRect();
            EditorGUIUtility.AddCursorRect(buttonRect, MouseCursor.Link);
        }

        private static float Sin(float offset = 0f)
        {
            return Mathf.Sin(offset + (float)EditorApplication.timeSinceStartup*Mathf.PI*2f)*0.5f + 0.5f;
        }

        public static bool Foldout(GUIContent titleContent, bool display)
        {
            var style = new GUIStyle("ShurikenModuleTitle");
            style.font = new GUIStyle(EditorStyles.label).font;
            style.border = new RectOffset(15, 7, 4, 4);
            style.fixedHeight = 22;
            style.contentOffset = new Vector2(20f, -2f);

            var rect = GUILayoutUtility.GetRect(16f, 22f, style);
            GUI.Box(rect, titleContent, style); // titleContent is used here

            var e = Event.current;

            var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);
            if (e.type == EventType.Repaint)
            {
                EditorStyles.foldout.Draw(toggleRect, false, false, display, false);
            }

            if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))
            {
                display = !display;
                e.Use();
            }

            return display;
        }

        public static void DrawNotification(string text, MessageType messageType = MessageType.None)
        {
            DrawHelpBox(text, messageType);
        }

        public static void DrawNotification(bool condition, string text, string label, Action action,
            MessageType messageType = MessageType.None)
        {
            DrawHelpBox(text, messageType, condition, label, action);
        }

        public static void DrawNotification(bool condition, string text, MessageType messageType = MessageType.None)
        {
            DrawHelpBox(text, messageType, condition, null, null);
        }

        private static void DrawHelpBox(string text, MessageType messageType = MessageType.None, bool condition = true,
            string buttonLabel = "", Action action = null)
        {
            if (!condition) return;

            Rect r = EditorGUILayout.GetControlRect();
            r.width -= 10f;

            Color sideColor = Color.gray;
            Texture icon = null;
            switch (messageType)
            {
                case (MessageType.None):
                {
                    sideColor = Color.gray;
                }
                    break;
                case (MessageType.Warning): //Warning
                {
                    sideColor = Color.Lerp(OrangeColor, OrangeColor*1.20f, Sin(r.y));
                    icon = WarningIcon;
                }
                    break;
                case (MessageType.Error): //Error
                {
                    sideColor = Color.Lerp(RedColor, RedColor*1.33f, Sin(r.y));
                    icon = ErrorIcon;
                }
                    break;
                case (MessageType.Info): //Info
                {
                    sideColor = Color.Lerp(new Color(1f, 1f, 1f), new Color(0.9f, 0.9f, 0.9f), Sin(r.y));
                    icon = InfoIcon;
                }
                    break;
            }

            float width = r.width;
            float height = EditorStyles.helpBox.CalcHeight(new GUIContent(text), EditorGUIUtility.currentViewWidth) +
                (EditorStyles.label.lineHeight*1.5f);
            r.height = height;

            Rect btnRect = r;
            GUIContent btnContent = null;
            //Showing a button instead
            if (action != null)
            {
                icon = null;

                btnContent = new GUIContent(" " + buttonLabel, EditorGUIUtility.IconContent("SceneLoadIn").image,
                    "Execute suggested action");
                float size = EditorStyles.toolbarButton.CalcSize(btnContent).x + 5f;
                btnRect.width = size;
                btnRect.x = width - size;
                btnRect.height = EditorStyles.miniButtonMid.fixedHeight + 5f;
                //Vertical center
                btnRect.y += (height*0.5f) - (btnRect.height*0.5f);
            }

            Rect iconRect = r;
            if (icon != null)
            {
                float size = Mathf.Min(height*0.75f, 50f);
                iconRect = r;
                iconRect.x = r.width;

                if (messageType == MessageType.Error)
                    iconRect.x -= 10f;

                iconRect.width = size;
                iconRect.height = iconRect.width;
                //Vertical center
                iconRect.y += (height*0.5f) - (iconRect.height*0.5f);

                //Recalculate text height
                height = EditorStyles.helpBox.CalcHeight(new GUIContent(text),
                    EditorGUIUtility.currentViewWidth - size) + (EditorStyles.label.lineHeight*2f);
                r.height = height;
            }

            float backgroundTint = EditorGUIUtility.isProSkin ? 0.4f : 1f;
            EditorGUI.DrawRect(r, new Color(backgroundTint, backgroundTint, backgroundTint, 0.2f));

            Rect colorRect = r;
            colorRect.width = 7f;

            EditorGUI.DrawRect(colorRect, sideColor);

            Rect textRect = r;
            textRect.x += colorRect.width + 10f;

            //Shrink text area on right side to make room
            if (icon != null) textRect.width -= iconRect.width*2f;
            if (action != null) textRect.width -= btnRect.width*1.75f;

            GUI.Label(textRect, new GUIContent(text), Styles.NotificationArea);

            if (icon != null)
            {
                GUI.DrawTexture(iconRect, icon, ScaleMode.ScaleToFit);
            }

            if (action != null)
            {
                if (GUI.Button(btnRect, btnContent))
                {
                    action?.Invoke();
                }
            }

            GUILayout.Space(height - EditorStyles.label.lineHeight); //17=default line height
        }


        /// <summary>
        /// 셰이더 UI Vector2를 그려냅니다.
        /// </summary>
        /// <param name="prop">그려낼 프로퍼티</param>
        /// <param name="label">프로퍼티 이름</param>
        /// <param name="tooltip">툴팁</param>
        public static void DrawVector2(MaterialProperty prop, string label, string tooltip = null)
        {
            MaterialEditor.BeginProperty(prop);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Vector2 value;
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel(new GUIContent(label, tooltip));
                value = EditorGUILayout.Vector2Field(new GUIContent("", null, tooltip), prop.vectorValue);
            }

            if (EditorGUI.EndChangeCheck())
                prop.vectorValue = value;

            EditorGUI.showMixedValue = false;

            MaterialEditor.EndProperty();
        }

        /// <summary>
        /// 셰이더 UI Float를 그려냅니다.
        /// </summary>
        /// <param name="prop">그려낼 프로퍼티</param>
        /// <param name="label">프로퍼티 이름</param>
        /// <param name="tooltip">툴팁</param>
        public static void DrawFloatField(MaterialProperty prop, string label = null, string tooltip = null)
        {
            MaterialEditor.BeginProperty(prop);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            float value = EditorGUILayout.FloatField(new GUIContent(label ?? prop.displayName, null, tooltip),
                prop.floatValue);

            if (EditorGUI.EndChangeCheck())
                prop.floatValue = value;
            EditorGUI.showMixedValue = false;

            MaterialEditor.EndProperty();
        }

        /// <summary>
        /// 기본적인 셰이더 프로퍼티를 그려냅니다.
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="prop">그려낼 프로퍼티</param>
        /// <param name="content">콘텐츠</param>
        /// <param name="indent">들여쓰기</param>
        public static void DrawShaderProperty(MaterialEditor materialEditor, MaterialProperty prop, string content,
            int indent = 0)
        {
            materialEditor.ShaderProperty(prop, content, indent);
        }

        /// <summary>
        /// 기본적인 셰이더 프로퍼티를 그려냅니다.
        /// </summary>
        /// <param name="materialEditor"></param>
        /// <param name="prop">그려낼 프로퍼티</param>
        /// <param name="content">콘텐츠</param>
        /// <param name="indent">들여쓰기</param>
        public static void DrawShaderProperty(MaterialEditor materialEditor, MaterialProperty prop, GUIContent content,
            int indent = 0)
        {
            materialEditor.ShaderProperty(prop, content, indent);
        }

        /// <summary>
        /// 컬러 필드를 그려냅니다.
        /// </summary>
        /// <param name="prop"></param>
        /// <param name="hdr"></param>
        /// <param name="name"></param>
        /// <param name="tooltip"></param>
        public static void DrawColorField(MaterialProperty prop, bool hdr, string name = null,
            string tooltip = null)
        {
            MaterialEditor.BeginProperty(prop);

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            Color color;
            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.PrefixLabel(new GUIContent(name ?? prop.displayName, tooltip));
                color = EditorGUILayout.ColorField(new GUIContent("", null, tooltip), prop.colorValue, true, true,
                    hdr);
            }

            if (ExpandTooltips && tooltip != null) EditorGUILayout.HelpBox(tooltip, MessageType.None);

            if (EditorGUI.EndChangeCheck())
                prop.colorValue = color;
            EditorGUI.showMixedValue = false;

            MaterialEditor.EndProperty();
        }

        /// <summary>
        /// Min-Max 슬라이더 필드를 그려냅니다.
        /// </summary>
        /// <param name="prop"></param>
        /// <param name="min"></param>
        /// <param name="max"></param>
        /// <param name="label"></param>
        /// <param name="tooltip"></param>
        public static void DrawMinMaxSlider(MaterialProperty prop, float min, float max, string label = null,
            string tooltip = null)
        {

            MaterialEditor.BeginProperty(prop);


            float minVal = prop.vectorValue.x;
            float maxVal = prop.vectorValue.y;

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            using (new EditorGUILayout.HorizontalScope())
            {
                EditorGUILayout.LabelField(new GUIContent(label, null, tooltip),
                    GUILayout.MaxWidth(EditorGUIUtility.labelWidth));
                minVal = EditorGUILayout.FloatField(minVal, GUILayout.Width(EditorGUIUtility.fieldWidth));
                EditorGUILayout.MinMaxSlider(ref minVal, ref maxVal, min, max);
                maxVal = EditorGUILayout.FloatField(maxVal, GUILayout.Width(EditorGUIUtility.fieldWidth));
            }

            if (ExpandTooltips && tooltip != null) EditorGUILayout.HelpBox(tooltip, MessageType.None);

            if (EditorGUI.EndChangeCheck())
            {
                prop.vectorValue = new Vector4(minVal, maxVal);
            }

            EditorGUI.showMixedValue = false;

            MaterialEditor.EndProperty();

        }
        public static void DrawIntSlider(MaterialProperty prop, string label = null, string tooltip = null)
        {

            MaterialEditor.BeginProperty(prop);
            
            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = prop.hasMixedValue;

            float value = (float)EditorGUILayout.IntSlider(new GUIContent(label ?? prop.displayName, null, tooltip),
                (int)prop.floatValue, (int)prop.rangeLimits.x, (int)prop.rangeLimits.y);

            if (ExpandTooltips && tooltip != string.Empty) EditorGUILayout.HelpBox(tooltip, MessageType.None);

            if (EditorGUI.EndChangeCheck())
                prop.floatValue = value;
            EditorGUI.showMixedValue = false;
            
            MaterialEditor.EndProperty();
        }

        public class Styles
        {
            public static GUIStyle _NotificationArea;

            public static GUIStyle NotificationArea
            {
                get
                {
                    if (_NotificationArea == null)
                    {
                        _NotificationArea = new GUIStyle(EditorStyles.label) {
                            //margin = new RectOffset(15, 0, 15, 0),
                            //padding = new RectOffset(5, 5, 5, 5),
                            richText = true,
                            wordWrap = true,
                            clipping = TextClipping.Overflow,
                        };
                    }

                    return _NotificationArea;
                }
            }

            private static Texture2D _smallGreenDot;

            public static Texture2D SmallGreenDot
            {
                get
                {
                    if (_smallGreenDot == null)
                    {
                        _smallGreenDot = EditorGUIUtility.FindTexture("d_winbtn_mac_max");
                    }

                    return _smallGreenDot;
                }
            }

            private static Texture2D _smallOrangeDot;

            public static Texture2D SmallOrangeDot
            {
                get
                {
                    if (_smallOrangeDot == null)
                    {
                        _smallOrangeDot = EditorGUIUtility.FindTexture("d_winbtn_mac_min");
                    }

                    return _smallOrangeDot;
                }
            }

            private static Texture2D _smallRedDot;

            public static Texture2D SmallRedDot
            {
                get
                {
                    if (_smallRedDot == null)
                    {
                        _smallRedDot = EditorGUIUtility.FindTexture("d_winbtn_mac_close_h");
                    }

                    return _smallRedDot;
                }
            }

            private static GUIStyle _UpdateText;

            public static GUIStyle UpdateText
            {
                get
                {
                    if (_UpdateText == null)
                    {
                        _UpdateText = new GUIStyle("Button") {
                            //fontSize = 10,
                            alignment = TextAnchor.MiddleLeft,
                            stretchWidth = false,
                        };
                    }

                    return _UpdateText;
                }
            }

            private static GUIStyle _Footer;

            public static GUIStyle Footer
            {
                get
                {
                    if (_Footer == null)
                    {
                        _Footer = new GUIStyle(EditorStyles.centeredGreyMiniLabel) {
                            richText = true,
                            alignment = TextAnchor.MiddleCenter,
                            wordWrap = true,
                            fontSize = 12
                        };
                    }

                    return _Footer;
                }
            }

            private static GUIStyle _Button;

            public static GUIStyle Button
            {
                get
                {
                    if (_Button == null)
                    {
                        _Button = new GUIStyle(GUI.skin.button) {
                            alignment = TextAnchor.MiddleLeft,
                            stretchWidth = true,
                            richText = true,
                            wordWrap = true,
                            padding = new RectOffset() {
                                left = 14,
                                right = 14,
                                top = 8,
                                bottom = 8
                            }
                        };
                    }

                    return _Button;
                }
            }

            private static GUIContent _AssetStoreBtnContent;

            public static GUIContent AssetStoreBtnContent
            {
                get
                {
                    if (_AssetStoreBtnContent == null)
                    {
                        _AssetStoreBtnContent = new GUIContent("  View on Asset Store ",
                            EditorGUIUtility.IconContent("Asset Store").image,
                            "Open web page.\n\nURL may contain an affiliate ID to fund the purchase of new assets and investigate/develop integrations for them.");
                    }

                    return _AssetStoreBtnContent;
                }
            }

            private static GUIStyle _H1;

            public static GUIStyle H1
            {
                get
                {
                    if (_H1 == null)
                    {
                        _H1 = new GUIStyle(GUI.skin.label) {
                            richText = true,
                            alignment = TextAnchor.MiddleCenter,
                            wordWrap = true,
                            fontSize = 18,
                            fontStyle = FontStyle.Normal
                        };
                    }

                    return _H1;
                }
            }

            private static GUIStyle _H2;

            public static GUIStyle H2
            {
                get
                {
                    if (_H2 == null)
                    {
                        _H2 = new GUIStyle(GUI.skin.label) {
                            richText = true,
                            alignment = TextAnchor.MiddleLeft,
                            wordWrap = true,
                            fontSize = 14,
                            fontStyle = FontStyle.Bold
                        };
                    }

                    return _H2;
                }
            }

            private static GUIStyle _Section;
            
            private static GUIStyle _WordWrapLabel;

            public static GUIStyle WordWrapLabel
            {
                get
                {
                    if (_WordWrapLabel == null)
                    {
                        _WordWrapLabel = new GUIStyle(EditorStyles.label);
                        _WordWrapLabel.wordWrap = true;
                        _WordWrapLabel.richText = true;
                    }

                    return _WordWrapLabel;
                }
            }

            private static GUIStyle _BoldLabel;

            public static GUIStyle BoldLabel
            {
                get
                {
                    if (_BoldLabel == null)
                    {
                        _BoldLabel = new GUIStyle(EditorStyles.largeLabel);
                        _BoldLabel.fontStyle = FontStyle.Bold;
                    }

                    return _BoldLabel;
                }
            }

            private static GUIStyle _Tab;

            public static GUIStyle Tab
            {
                get
                {
                    if (_Tab == null)
                    {
                        _Tab = new GUIStyle(EditorStyles.miniButtonMid) {
                            alignment = TextAnchor.MiddleCenter,
                            stretchWidth = true,
                            richText = true,
                            wordWrap = true,
                            fontSize = 16,
                            fixedHeight = 27.5f,
                            fontStyle = FontStyle.Bold,
                            padding = new RectOffset() {
                                left = 14,
                                right = 14,
                                top = 3,
                                bottom = 3
                            }
                        };
                    }

                    return _Tab;
                }
            }

            private static GUIStyle s_CenterBoldLabel;

            public static GUIStyle CenterBoldLabel
            {
                get
                {
                    if (s_CenterBoldLabel == null)
                    {
                        s_CenterBoldLabel = new GUIStyle(EditorStyles.largeLabel);
                        s_CenterBoldLabel.alignment = TextAnchor.UpperCenter;
                        s_CenterBoldLabel.padding = new RectOffset();
                        s_CenterBoldLabel.fontStyle = FontStyle.Bold;
                    }

                    return s_CenterBoldLabel;
                }
            }

            private static GUIStyle s_AddOnTitle;

            private static GUIStyle AddOnTitle
            {
                get
                {
                    if (s_AddOnTitle == null)
                    {
                        s_AddOnTitle = new GUIStyle(CenterBoldLabel);
                        s_AddOnTitle.fontSize = 14;
                        s_AddOnTitle.alignment = TextAnchor.MiddleLeft;
                    }

                    return s_AddOnTitle;
                }
            }
        }
    }
}
