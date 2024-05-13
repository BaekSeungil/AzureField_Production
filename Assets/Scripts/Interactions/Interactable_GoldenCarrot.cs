using DG.Tweening;
using FMODUnity;
using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactable_GoldenCarrot : Interactable_Base
{
    [InfoBox("같은 오브젝트 이름을 가진 황금당근이 생기지 않도록 해주세요! 애니메이션이 제데로 작동하지 않을 수 있습니다")]

    [SerializeField] private string _ID;
    public string ID { get { return _ID; } }
    [SerializeField, LabelText("공중에 떠있음")] private bool floating = false;
    [SerializeField, LabelText("황금 당근 데이터")] private ItemData carrotItem;
    [SerializeField, LabelText("황금 당근 개수")] private int carrotQuantity = 1;

    [LabelText("")]
    [SerializeField] private EventReference sound_CarrotPicked;
    [SerializeField] private EventReference sound_CarrotGone;

    Sequence_Base[] carrotAquiredSequences;

    private void Start()
    {
        if(floating)
        {
            GetComponent<DOTweenAnimation>().DOPlayById("CarrotFloating");
        }
    }


    public override void Interact()
    {
        GetComponent<DOTweenAnimation>().DOPause();


        if (!floating)
        {
            carrotAquiredSequences = new Sequence_Base[5];

            Sequence_Animation animation1 = new Sequence_Animation();
            animation1.objectName = gameObject.name;
            animation1.stateName = "Picked";

            Sequence_PlaySound sound1 = new Sequence_PlaySound();
            sound1.sound = sound_CarrotPicked;

            Sequence_ObtainItem obtain = new Sequence_ObtainItem();
            obtain.item = carrotItem;
            obtain.quantity = 1;

            Sequence_PlaySound sound2 = new Sequence_PlaySound();
            sound2.sound = sound_CarrotGone;

            Sequence_Animation animation2 = new Sequence_Animation();
            animation2.objectName = gameObject.name;
            animation2.stateName = "Gone";

            carrotAquiredSequences[0] = sound1;
            carrotAquiredSequences[1] = animation1;
            carrotAquiredSequences[2] = obtain;
            carrotAquiredSequences[3] = sound2;
            carrotAquiredSequences[4] = animation2;
        }
        else
        {
            carrotAquiredSequences = new Sequence_Base[3];

            Sequence_PlaySound sound2 = new Sequence_PlaySound();
            sound2.sound = sound_CarrotGone;

            Sequence_Animation animation2 = new Sequence_Animation();
            animation2.objectName = gameObject.name;
            animation2.stateName = "Gone";

            Sequence_ObtainItem obtain = new Sequence_ObtainItem();
            obtain.item = carrotItem;
            obtain.quantity = 1;

            carrotAquiredSequences[0] = sound2;
            carrotAquiredSequences[1] = animation2;
            carrotAquiredSequences[2] = obtain;
        }


        GetComponent<Collider>().enabled = false;
        SequenceInvoker.Instance.StartSequence(carrotAquiredSequences);
        base.OnDisable();

    }
}
