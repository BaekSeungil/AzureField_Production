using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Sirenix.OdinInspector;
using UnityEngine.Localization;

//public enum QuestState
//{
//    Ready,
//    Active,
//    Closed,
//    Disabled
//}


[CreateAssetMenu(fileName = "NewStorylineData", menuName = "새 스토리라인 에셋 추가", order = 1)]
public class StorylineData : SerializedScriptableObject
{
    [SerializeField,LabelText("퀘스트 이름")] private LocalizedString questNameText;
    [SerializeField,LabelText("퀘스트 목표 텍스트들")] private LocalizedString[] objectives;
}
