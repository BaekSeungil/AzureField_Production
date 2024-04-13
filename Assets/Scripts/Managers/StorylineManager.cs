using NUnit.Framework.Internal;
using Sirenix.OdinInspector;
using Sirenix.Utilities;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;

public class StorylineManager : StaticSerializedMonoBehaviour<StorylineManager>
{
    [SerializeField,Required] private StorylineStash storylineStashAsset;
    private StorylineStash storylineStashInstance;
    private string activeStorylineKey;
    private StorylineData activeStoryline;
    public StorylineData ActiveStoryline { get { return activeStoryline; } }

    [SerializeField, FoldoutGroup("Debug")] private bool InvokeDefaultOnStart = false;
    [SerializeField, FoldoutGroup("Debug")] private string defaultStorylineID = "EXAMPLE";
    [SerializeField, ReadOnly, FoldoutGroup("Debug")] private string debug_active_storyline;
    [SerializeField, ReadOnly ,FoldoutGroup("Debug")] private int debug_objective_index = 0;

    int currentIndex = 0;

    protected override void Awake()
    {
        base.Awake();
        storylineStashInstance = Instantiate(storylineStashAsset);
    }

    private void Start()
    {
        if (InvokeDefaultOnStart) StartCoroutine(StartNewStroyline(defaultStorylineID));
    }

    private void Update()
    {
#if UNITY_EDITOR
        debug_active_storyline = (activeStoryline != null) ? activeStorylineKey : "null" ;
        debug_objective_index = currentIndex;
#endif
    }

    bool progress = false;

    public void MakeProgressStroyline(string KeyIndexPair)
    {
        string[] parsed = KeyIndexPair.Split(",");
        Debug.Log(parsed[0] + " / " + parsed[1]);
        int index = 0;

        if(parsed.Length == 2) 
        {
            if (!int.TryParse(parsed[1], out index))
                Debug.LogError("MakeProgressStoryline : 값을 잘못 입력하였습니다. [키],[번호] 형식으로 입력하세요");
        }
        else
        {
            Debug.LogError("MakeProgressStoryline : 값을 잘못 입력하였습니다. [키],[번호] 형식으로 입력하세요");
        }

        Debug.Log("Index : " + currentIndex);

        if (storylineStashInstance.packedStoryline.ContainsKey(parsed[0]))
        {
            if (currentIndex == index)
                progress = true;
            else
                Debug.Log("현재 Storyline의 키,번호 값과 입력한 키,번호 값이 다릅니다. " + KeyIndexPair +" | " +activeStorylineKey+"," + currentIndex);
        }
        else
        {
            Debug.LogError("MakeProgressStoryline : StorylineStash 에서 Key " + parsed[0] + " 를 찾을 수 없었습니다.");
        }
    }

    public void MakeProgressStoryline()
    {
        progress = true;
    }



    private IEnumerator StartNewStroyline(string storylineKey)
    {
        activeStorylineKey = storylineKey;
        if (!storylineStashInstance.packedStoryline.ContainsKey(storylineKey))
        {
            Debug.LogError("StorylineStash 에서 StroylineKey " + storylineKey + " 를 찾을 수 없었습니다.");
            yield break;
        }

        activeStoryline = storylineStashInstance.packedStoryline[storylineKey];

        currentIndex = 0;


        var sequence = SequenceInvoker.Instance;
        for (int i = 0; i < activeStoryline.Objectives.Length; i++)
        {
            currentIndex = i;

            if (activeStoryline.Objectives[i].sequenceOnStart != null)
            {
                if (sequence.IsSequenceRunning) SequenceInvoker.Instance.ForceAbortAllSequences();

                PlayerCore.Instance.DisableForSequence(); UI_PlaymenuBehavior.Instance.DisableInput();
                yield return SequenceInvoker.Instance.Cor_RecurciveSequenceChain(activeStoryline.Objectives[i].sequenceOnStart.SequenceBundles);
                PlayerCore.Instance.EnableForSequence(); UI_PlaymenuBehavior.Instance.EnableInput();
            }

            UI_Objective.Instance.OpenObjective(activeStoryline.QuestNameText.GetLocalizedString(), activeStoryline.Objectives[i].objectiveText.GetLocalizedString());

            Transform dest;
            if (!activeStoryline.Objectives[i].destinationTransformName.IsNullOrWhitespace())
            {
                GameObject destObject = GameObject.Find(activeStoryline.Objectives[i].destinationTransformName);
                if (destObject != null) dest = destObject.transform;
                else { dest = null; }

                if (dest != null)
                    UI_Marker.Instance.SetMarker(dest);
            }
            else
            {
                UI_Marker.Instance.DisableMarker();
            }
            

            yield return new WaitUntil(() => progress == true);
            progress = false;

            if (activeStoryline.Objectives[i].sequenceOnFinished != null)
            {
                if (sequence.IsSequenceRunning) SequenceInvoker.Instance.ForceAbortAllSequences();

                PlayerCore.Instance.DisableForSequence(); UI_PlaymenuBehavior.Instance.DisableInput();
                yield return sequence.Cor_RecurciveSequenceChain(activeStoryline.Objectives[i].sequenceOnFinished.SequenceBundles);
                PlayerCore.Instance.EnableForSequence(); UI_PlaymenuBehavior.Instance.EnableInput();
            }

        }

        Debug.Log("Close");
        UI_Objective.Instance.CloseObjective();
        UI_Marker.Instance.DisableMarker();
    }
}
