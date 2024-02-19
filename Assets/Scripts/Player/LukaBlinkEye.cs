using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LukaBlinkEye : MonoBehaviour
{
    //================================================
    //
    // ĳ������ �ڿ������� �� �����̱⸦ ���� ������� Ŭ���� �Դϴ�.
    // �𵨸��� Blendshape�� ����մϴ�.
    // 
    //================================================

    [SerializeField] private float blinkInterval = 4.0f;        // ���� �����̴µ� ������ �ϴ� ������� �ð��Դϴ�. (����)
    [SerializeField] private float blinkTime = 0.2f;            // ���� �����̴� �ð��Դϴ�.
    [SerializeField] private float intervalNoise = 2.5f;        // ���� �����̰� �ϴ� �ð��� �������� ���� �������Դϴ�.
    [SerializeField] private int blinkBlendshapeIndex = 0;      // �𵨸����� ���� �����̴� ���� �ش��ϴ� blendshape�� �̰��� �Է��ؾ��մϴ�.
    [SerializeField] private AnimationCurve blinkCurve;         // ���� ��� �������� ���ϴ� �ִϸ��̼� Ŀ���Դϴ�.

    [SerializeField] private SkinnedMeshRenderer playerMesh;

    float nextblink = 0.0f;

    private void OnEnable()
    {
        nextblink = 0.0f;
        StartCoroutine(Cor_BlinkSequence());
    }

    IEnumerator Cor_BlinkSequence()
    {
        while (true)
        {
            nextblink = blinkInterval + Random.Range(-intervalNoise, intervalNoise);

            yield return new WaitForSeconds(nextblink);

            for (float t = 0; t < blinkTime; t += Time.deltaTime)
            {
                playerMesh.SetBlendShapeWeight(blinkBlendshapeIndex, blinkCurve.Evaluate(t / blinkTime)*100f);
                yield return null;
            }

            if (Random.Range(0, 2) == 0)
            {
                for (float t = 0; t < blinkTime; t += Time.deltaTime)
                {
                    playerMesh.SetBlendShapeWeight(blinkBlendshapeIndex, blinkCurve.Evaluate(t / blinkTime) * 100f);
                    yield return null;
                }
            }
            playerMesh.SetBlendShapeWeight(blinkBlendshapeIndex,0f);
        }
    }
}
