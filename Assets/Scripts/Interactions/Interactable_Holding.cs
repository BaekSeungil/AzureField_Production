using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Interactable_Holding : Interactable_Base
{
    //================================================
    //
    // Interactable_Base�� �ڽ� Ŭ����,  Interact�� �������̵�
    // Interact�� �÷��̾ �� ������Ʈ�� ��ϴ�.
    // �� �� PlayerCore�� HoldItem�� ȣ��˴ϴ�.
    //
    //================================================

    public Transform leftHandPoint;         // �÷��̾ �������� ���� �� �޼��� ��ġ�� ������ ��Ÿ���ϴ�.
    public Transform rightHandPoint;        // �÷��̾ �������� ���� �� �������� ��ġ�� ������ ��Ÿ���ϴ�.

    private bool isHolding = false;
    [SerializeField] private new Rigidbody rigidbody;
    [SerializeField] private Collider collision;

    public override void Interact()
    {
        PlayerCore player = PlayerCore.Instance;

        if (isHolding) return;        
        if (player == null) return;

        Hold(player);
    }
    
    public void Hold(PlayerCore player)
    {
        if (player.HoldItem(leftHandPoint, rightHandPoint, this))
        {
            isHolding = true;
            rigidbody.isKinematic = true;
            collision.enabled = false;
            base.isEnabled = false;
        }
    }

    public void Release()
    {
        isHolding = false;
        rigidbody.isKinematic = false;
        collision.enabled = true;
        base.isEnabled = true;
    }
}
