using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class KuwaharaRenderFeature : ScriptableRendererFeature
{
    [Serializable]
    public class KuwaharaProperty
    {
        [Range(1, 20)]
        public int kernelSize = 1;

        [Range(1, 4)]
        public int passes = 1;
    }


    [System.Serializable]
    public class KuwaharaSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingTransparents;
        public Material passMaterial = null;

        public KuwaharaProperty property;
    }

    public KuwaharaSettings settings = new KuwaharaSettings();

    class KuwaharaRenderPass : ScriptableRenderPass
    {
        //property
        public KuwaharaProperty property;


        public Material kuwaharaMat;
        string profilerTag;

        RenderTargetIdentifier cameraColorTexture;

        public KuwaharaRenderPass(string profilerTag)
        {
            this.profilerTag = profilerTag;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (kuwaharaMat == null)
                return;

            cameraColorTexture = renderingData.cameraData.renderer.cameraColorTargetHandle;
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            //
            Process();

            //
            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);


            void Process()
            {
                kuwaharaMat.SetInt("_KernelSize", property.kernelSize);

                var passes = new RenderTexture[property.passes];

                for (int i = 0; i < property.passes; ++i)
                {
                    passes[i] = RenderTexture.GetTemporary(opaqueDesc.width, opaqueDesc.height, 0, opaqueDesc.colorFormat);
                }

                cmd.Blit(cameraColorTexture, passes[0], kuwaharaMat);

                for (int i = 1; i < property.passes; ++i)
                {
                    cmd.Blit(passes[i - 1], passes[i], kuwaharaMat);
                }

                cmd.Blit(passes[property.passes - 1], cameraColorTexture);

                //release
                for (int i = 0; i < property.passes; ++i)
                {
                    RenderTexture.ReleaseTemporary(passes[i]);
                }
            }

        }


        public override void FrameCleanup(CommandBuffer cmd)
        {

        }
    } // end KuwaharaRenderPass

    private KuwaharaRenderPass scriptablePass;

    public override void Create()
    {
        scriptablePass = new KuwaharaRenderPass("kuwahara");
        scriptablePass.kuwaharaMat = settings.passMaterial;
        scriptablePass.renderPassEvent = settings.renderPassEvent;
        scriptablePass.property = settings.property;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(scriptablePass);
    }
}
