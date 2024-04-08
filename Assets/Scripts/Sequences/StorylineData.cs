using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using UnityEngine.Localization;

public enum QuestState
{
    Ready,
    Active,
    Closed,
    Disabled
}

[CreateAssetMenu(fileName = "NewStorylineData", menuName = "새 스토리라인 에셋 추가", order = 1)]
public class StorylineData : SerializedScriptableObject
{
    [SerializeField] private string questNameText;
    [SerializeField] private SequenceBundleAsset[] sequenceAssets;
}
