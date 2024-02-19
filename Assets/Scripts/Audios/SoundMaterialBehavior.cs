using System.Collections;
using System.Collections.Generic;
using UnityEngine;

//============================================
//
// SoundMaterialBehavior : ���� ���� ������ ��Ÿ���� ���� Ŭ���� �Դϴ�.
// ���带 ���� ��ũ��Ʈ�� SoundMaterial ������ �ʿ�� �� ��, GetSoundMaterial�� ���� � ���� ���� ������ ���� �ϴ��� �����մϴ�.
// �̴� Terrain ���� ���� SoundMaterial�� �ʿ�� �ϴ� ������Ʈ ���� ������ �ʿ��մϴ�. (TerrainSoundMaterialBehavior.cs ����)
//
//============================================

public enum SoundMaterial
{
    // ���� ������ ����
    Default,
    Sand,
    Water,
    Grass,
    Wood
}

public class SoundMaterialBehavior : MonoBehaviour
{
    [SerializeField] private SoundMaterial soundmat;

    public virtual SoundMaterial GetSoundMaterial() 
    // ���� soundMat��ȯ
    {
        return soundmat;
    }

    public virtual SoundMaterial GetSoundMaterial(Vector3 position) 
    // position : �Ҹ����°��� ��ġ, �������̵� ���� ���� �� ���� soundMat �״�� ��ȯ
    {
        return soundmat;
    }
}
