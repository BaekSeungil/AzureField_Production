using Sirenix.OdinInspector;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerAttributeTest : MonoBehaviour
{
    [DisableInEditorMode(),Button()]
    public void SetPermentAttribute(PlayerCore.AbilityAttribute attribute, float value)
    {
        PlayerCore.Instance.AddPermernentAttribute(attribute, value);
    }

    [DisableInEditorMode(), Button()]
    public void SetTimeAttribute(PlayerCore.AbilityAttribute attribute, float value, float time)
    {
        PlayerCore.Instance.SetTempoaryAttribute(attribute, value, time);
    }

    [DisableInEditorMode(), Button()]
    public void SetIDAttribute(PlayerCore.AbilityAttribute attribute, float value, string ID)
    {
        PlayerCore.Instance.SetAttributeWithID(attribute, value, ID);
    }

    [DisableInEditorMode(), Button()]
    public void RemoveIDAttribute(string ID) 
    {   
        PlayerCore.Instance.CancelAttributeWithID(ID);
    }
}
