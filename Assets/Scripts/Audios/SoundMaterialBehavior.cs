using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum SoundMaterial
{
    Default,
    Sand,
    Water,
    Grass,
    Wood
}

public class SoundMaterialBehavior : MonoBehaviour
{
    [SerializeField] private SoundMaterial soundmat;

    public virtual SoundMaterial GetSoundMaterial(Vector3 position)
    {
        return soundmat;
    }
}
