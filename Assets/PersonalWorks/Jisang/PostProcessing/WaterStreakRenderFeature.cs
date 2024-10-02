using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class WaterStreakRenderFeature : ScriptableRendererFeature
{
    [System.Serializable]
    public class WaterStreakSettings
    {
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
        public Material passMaterial = null;
    }

    public WaterStreakSettings settings = new WaterStreakSettings();

    class WaterStreakRenderPass : ScriptableRenderPass
    {
        public Material WaterStreakMat;
        string profilerTag;

        RenderTargetIdentifier cameraColorTexture;

        public WaterStreakRenderPass(string profilerTag)
        {
            this.profilerTag = profilerTag;
        }

        public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor)
        {
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (WaterStreakMat == null)
                return;

            cameraColorTexture = renderingData.cameraData.renderer.cameraColorTargetHandle;
            CommandBuffer cmd = CommandBufferPool.Get(profilerTag);

            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;

            //Process

            var passes = RenderTexture.GetTemporary(opaqueDesc.width, opaqueDesc.height, 0, opaqueDesc.colorFormat);
            cmd.Blit(cameraColorTexture, passes, WaterStreakMat);
            cmd.Blit(passes, cameraColorTexture);
            RenderTexture.ReleaseTemporary(passes);
            //

            context.ExecuteCommandBuffer(cmd);
            cmd.Clear();

            CommandBufferPool.Release(cmd);

        }


        public override void FrameCleanup(CommandBuffer cmd)
        {

        }
    } // end WaterStreakRenderPass

    private WaterStreakRenderPass scriptablePass;

    public override void Create()
    {
        scriptablePass = new WaterStreakRenderPass("WaterStreak");
        scriptablePass.WaterStreakMat = settings.passMaterial;
        scriptablePass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(scriptablePass);
    }
}
