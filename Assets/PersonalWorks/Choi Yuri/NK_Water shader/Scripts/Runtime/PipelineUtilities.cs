using System;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using ForwardRendererData = UnityEngine.Rendering.Universal.UniversalRendererData;

#if UNITY_EDITOR
#endif

namespace NKStudio
{
    public static class PipelineUtilities
    {
        private const string renderDataListFieldName = "m_RendererDataList";
        
        /// <summary>
        /// Render Data List를 가져옵니다.
        /// </summary>
        /// <param name="asset"></param>
        /// <returns></returns>
        /// <exception cref="Exception"></exception>
        private static ScriptableRendererData[] GetRenderDataList(UniversalRenderPipelineAsset asset)
        {
            FieldInfo renderDataListField = typeof(UniversalRenderPipelineAsset).GetField(renderDataListFieldName,
                BindingFlags.NonPublic | BindingFlags.Instance);

            if (renderDataListField != null)
            {
                return (ScriptableRendererData[])renderDataListField.GetValue(asset);
            }

            throw new Exception(
                "Reflection failed on field \"m_RendererDataList\" from class \"UniversalRenderPipelineAsset\". URP API likely changed");
        }

        public static void RefreshRendererList()
        {
            if (UniversalRenderPipeline.asset == null)
            {
                Debug.LogError("활성화된 파이프라인이 없습니다. 그렇지 않은 경우 이 기능을 사용하는 UI를 표시하지 마세요!");
            }

            ScriptableRendererData[] m_rendererDataList = GetRenderDataList(UniversalRenderPipeline.asset);

            //Display names
            _rendererDisplayList = new GUIContent[m_rendererDataList.Length + 1];

            int defaultIndex = GetDefaultRendererIndex(UniversalRenderPipeline.asset);
            _rendererDisplayList[0] = new GUIContent($"Default ({(m_rendererDataList[defaultIndex].name)})");

            for (int i = 1; i < _rendererDisplayList.Length; i++)
            {
                _rendererDisplayList[i] = new GUIContent($"{(i - 1).ToString()}: {(m_rendererDataList[i - 1]).name}");
            }

            //Indices
            _rendererIndexList = new int[m_rendererDataList.Length + 1];
            for (int i = 0; i < _rendererIndexList.Length; i++)
            {
                _rendererIndexList[i] = i - 1;
            }
        }

        private static GUIContent[] _rendererDisplayList;
        
        private static int[] _rendererIndexList;
        
        /// <summary>
        /// 렌더러 인덱스가 주어지면 인덱스에 실제로 렌더러가 있는지 확인합니다. 그렇지 않으면 기본 렌더러의 인덱스를 반환합니다.
        /// </summary>
        /// <param name="index"></param>
        /// <returns></returns>
        public static int ValidateRenderer(int index)
        {
            if (UniversalRenderPipeline.asset)
            {
                int defaultRendererIndex = GetDefaultRendererIndex(UniversalRenderPipeline.asset);
                ScriptableRendererData[] m_rendererDataList = GetRenderDataList(UniversalRenderPipeline.asset);

                // -1은 기본 렌더러를 나타내는 데 사용됩니다.
                if (index == -1) index = defaultRendererIndex;

                // 현재 인덱스에 렌더러가 있는지 확인
                if (!(index < m_rendererDataList.Length && m_rendererDataList[index] != null))
                {
                    Debug.LogWarning(
                        $"<b>색인 {index.ToString()}</b>의 렌더러가 누락되어 기본 렌더러로 돌아갑니다. <b>{m_rendererDataList[defaultRendererIndex].name}</b>",
                        UniversalRenderPipeline.asset);
                    return defaultRendererIndex;
                }
                else
                {
                    //Valid
                    return index;
                }
            }
            else
            {
                Debug.LogError("현재 활성화된 유니버설 렌더 파이프라인이 없습니다.");
                return 0;
            }
        }
        
        /// <summary>
        /// 투명한 객체에 그림자를 그리는지를 반환합니다.
        /// </summary>
        /// <returns>투명한 객체에 그림자를 그리면 true를 반환</returns>
        public static bool TransparentShadowsEnabled()
        {
            if (!UniversalRenderPipeline.asset) return false;

            ForwardRendererData main = (ForwardRendererData)GetDefaultRenderer();

            return main ? main.shadowTransparentReceive : false;
        }
        
        /// <summary>
        /// CopyDepthMode가 AfterTransparents인지 확인합니다.
        /// </summary>
        /// <returns></returns>
        public static bool IsDepthAfterTransparents()
        {
            if (!UniversalRenderPipeline.asset) return false;
            
            ForwardRendererData main = (ForwardRendererData)GetDefaultRenderer();

            return main.copyDepthMode == CopyDepthMode.AfterTransparents;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="asset"></param>
        /// <returns></returns>
        private static int GetDefaultRendererIndex(UniversalRenderPipelineAsset asset)
        {
            return (int)typeof(UniversalRenderPipelineAsset)
                .GetField("m_DefaultRendererIndex", BindingFlags.NonPublic | BindingFlags.Instance).GetValue(asset);
        }
        
        /// <summary>
        /// 프로젝트에 supportsCameraOpaqueTexture 옵션이 비활성화되어 있는지 확인합니다.
        /// </summary>
        /// <returns>비활성화 되어있으면 true</returns>
        public static bool IsOpaqueTextureOptionDisabledAnywhere()
        {
            bool state = false;

            for (int i = 0; i < GraphicsSettings.allConfiguredRenderPipelines.Length; i++)
            {
                if(GraphicsSettings.allConfiguredRenderPipelines[i].GetType() != typeof(UniversalRenderPipelineAsset)) continue;
                
                UniversalRenderPipelineAsset pipeline = (UniversalRenderPipelineAsset)GraphicsSettings.allConfiguredRenderPipelines[i];

                if (pipeline.supportsCameraOpaqueTexture == false) return true;
            }

            return state;
        }
        
        /// <summary>
        /// 프로젝트에 Depth Texture 옵션이 비활성화되어 있는지 확인합니다.
        /// </summary>
        /// <returns>비활성화 되어있으면 true</returns>
        public static bool IsDepthTextureOptionDisabledAnywhere()
        {
            bool state = false;

            for (int i = 0; i < GraphicsSettings.allConfiguredRenderPipelines.Length; i++)
            {
                if (GraphicsSettings.allConfiguredRenderPipelines[i].GetType() !=
                    typeof(UniversalRenderPipelineAsset)) continue;

                UniversalRenderPipelineAsset pipeline =
                    (UniversalRenderPipelineAsset)GraphicsSettings.allConfiguredRenderPipelines[i];

                state |= (pipeline.supportsCameraDepthTexture == false);
            }

            return state;
        }
        
        /// <summary>
        /// 기본값으로 표시된 현재 파이프라인 자산에서 렌더러를 가져옵니다.
        /// </summary>
        /// <returns></returns>
        public static ScriptableRendererData GetDefaultRenderer()
        {
            if (UniversalRenderPipeline.asset)
            {
                ScriptableRendererData[] rendererDataList = GetRenderDataList(UniversalRenderPipeline.asset);
                int defaultRendererIndex = GetDefaultRendererIndex(UniversalRenderPipeline.asset);

                return rendererDataList[defaultRendererIndex];
            }
            else
            {
                Debug.LogError("현재 활성화된 유니버설 렌더 파이프라인이 없습니다.");
                return null;
            }
        }
        
        /// <summary>
        /// 불투명 텍스쳐를 별도로 생성하는 기능을 렌더 파이프라인 에셋에서 모두 켤지 말지 결정합니다.
        /// </summary>
        /// <param name="state">true시 켜집니다.</param>
        public static void SetOpaqueTextureOnAllAssets(bool state)
        {
            for (int i = 0; i < GraphicsSettings.allConfiguredRenderPipelines.Length; i++)
            {
                if(GraphicsSettings.allConfiguredRenderPipelines[i].GetType() != typeof(UniversalRenderPipelineAsset)) continue;
                
                UniversalRenderPipelineAsset pipeline = (UniversalRenderPipelineAsset)GraphicsSettings.allConfiguredRenderPipelines[i];

#if UNITY_EDITOR
                if(pipeline.supportsCameraOpaqueTexture != state) EditorUtility.SetDirty(pipeline);
#endif
                
                pipeline.supportsCameraOpaqueTexture = state;
            }
        }

        /// <summary>
        /// 카메라의 깊이 텍스처를 생성하는 기능을 렌더 파이프라인 에셋에서 모두 켤지 말지 결정합니다.
        /// </summary>
        /// <param name="state"></param>
        public static void SetDepthTextureOnAllAssets(bool state)
        {
            for (int i = 0; i < GraphicsSettings.allConfiguredRenderPipelines.Length; i++)
            {
                if(GraphicsSettings.allConfiguredRenderPipelines[i].GetType() != typeof(UniversalRenderPipelineAsset)) continue;
                
                UniversalRenderPipelineAsset pipeline = (UniversalRenderPipelineAsset)GraphicsSettings.allConfiguredRenderPipelines[i];

#if UNITY_EDITOR
                if(pipeline.supportsCameraDepthTexture != state) EditorUtility.SetDirty(pipeline);
#endif
                
                pipeline.supportsCameraDepthTexture = state;
            }
        }
        
        
    }
}