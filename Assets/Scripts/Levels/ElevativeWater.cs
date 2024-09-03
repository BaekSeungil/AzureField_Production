using FMODUnity;
using Sirenix.OdinInspector;
using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Entities.UniversalDelegates;
using UnityEditor;
using UnityEngine;

[RequireComponent(typeof(StudioEventEmitter))]
public class ElevativeWater : MonoBehaviour
{
    [Title("")]
    [SerializeField,LabelText("수위 조절 옵션(M)")] private float[] waterLevelOptions;
    [SerializeField,LabelText("수위 조절 시간")] private float changeTime = 1.0f;
    [SerializeField,LabelText("수위 조절 커브")] private AnimationCurve changeCurve;

    [Title("")]
    [SerializeField] private EventReference sound_levelChangeLoop;
    [SerializeField] private EventReference sound_leveChangeEnd;

    [SerializeField] private Transform waterTF;

    private StudioEventEmitter sound;
    private Coroutine transition;
    private int currentindex = 0;


    private void Awake()
    {
        sound = GetComponent<StudioEventEmitter>();
    }

    public void SetWaterlevel(float waterLevel)
    {
        if (transition != null) return;

        transition = StartCoroutine(Cor_SetWaterlevel(waterLevel));
        return;
    }

    public void SetWaterlevel(int index)
    {
        if (transition != null) return;

        transition = StartCoroutine(Cor_SetWaterlevel(waterLevelOptions[index]));
        currentindex = index;
        return;
    }

    public void SetWaterlevelAuto()
    {
        if (transition != null) return;

        transition = StartCoroutine(Cor_SetWaterlevel(waterLevelOptions[currentindex]));
        currentindex++;
        if (currentindex >= waterLevelOptions.Length) currentindex = 0;
        return;
    }

    IEnumerator Cor_SetWaterlevel(float waterLevel)
    {
        float from = waterTF.localScale.y;

        sound.ChangeEvent(sound_levelChangeLoop);
        sound.Play();

        for(float t = 0; t < changeTime; t+= Time.fixedDeltaTime)
        {
            float segment = changeCurve.Evaluate(t/changeTime);
            waterTF.localScale = new Vector3(waterTF.localScale.x,Mathf.Lerp(from,waterLevel,segment) ,waterTF.localScale.z);
            yield return new WaitForFixedUpdate();
        }

        sound.Stop();
        sound.ChangeEvent(sound_leveChangeEnd);
        sound.Play();

        waterTF.localScale = new Vector3(waterTF.localScale.x, waterLevel, waterTF.localScale.z);

        transition = null;
    }

    private void OnDrawGizmosSelected()  
    {
        Gizmos.color = Color.blue;
        GUIStyle labelStyle = new GUIStyle();
        labelStyle.fontSize = 18;
        labelStyle.fontStyle = FontStyle.Bold;

        if (waterLevelOptions != null && waterLevelOptions.Length > 0)
        {
            for (int i = 0; i < waterLevelOptions.Length; i++)
            {
                if (i != 0) DrawArrow.ForGizmo(transform.position + Vector3.up*waterLevelOptions[i - 1] + Vector3.right*(i-2)*0.2f, Vector3.up * (waterLevelOptions[i] - waterLevelOptions[i - 1]));

                Gizmos.DrawWireCube(transform.position + Vector3.up * waterLevelOptions[i], new Vector3(2f, 0f, 2f));
                Handles.Label(transform.position + Vector3.up * waterLevelOptions[i] + Vector3.right * -1f, i.ToString() + "번 수위 : " + waterLevelOptions[i] + "M",labelStyle);
            }
            int last = waterLevelOptions.Length-1;
            Gizmos.color = Color.magenta;
            DrawArrow.ForGizmo(transform.position + Vector3.up * waterLevelOptions[last] + Vector3.right * (last - 2) * 0.2f, Vector3.up * (waterLevelOptions[0] - waterLevelOptions[last]));

        }
    }

}
