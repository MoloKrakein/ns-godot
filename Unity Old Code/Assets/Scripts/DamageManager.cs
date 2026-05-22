using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DamageManager : MonoBehaviour{


public BattleFlow battleFlow;

public Canvas canvas;

public AudioSource SFXSource;
public AudioClip PhysicalAttack;
public AudioClip FireAttack;
public AudioClip EarthAttack;
public AudioClip DarknessAttack;
public AudioClip LightAttack;
public AudioClip GenericHitSound;

// Buff sfx
public AudioClip ChangeSkillSFX;
public AudioClip HealSFX;
public AudioClip RefillManaSFX;
public AudioClip PowerBuffSFX;
public AudioClip ChangeWeaknessSFX;



public GameObject GenericHit;
public GameObject PhysicalHit;
public GameObject FireHit;
public GameObject EarthHit;
public GameObject DarknessHit;
public GameObject LightHit;


// buff effect
public GameObject ChangeSkill;

public GameObject HealEffect;

public GameObject RefillMana;
public GameObject PowerBuff;

public GameObject ChangeWeakness;


public GameObject SummoningEffect;

public void PlayAttackSound(DmgType dmgType)
{
    PlayHitSoundEffect();
    switch (dmgType)
    {
        case DmgType.Physical:
            SFXSource.PlayOneShot(PhysicalAttack);
            break;
        case DmgType.Fire:
            SFXSource.PlayOneShot(FireAttack);
            break;
        case DmgType.Earth:
            SFXSource.PlayOneShot(EarthAttack);
            break;
        case DmgType.Darkness:
            SFXSource.PlayOneShot(DarknessAttack);
            break;
        case DmgType.Light:
            SFXSource.PlayOneShot(LightAttack);
            break;
        default:
            break;
    }

}

public void PlayBuffSound(ItemType buffType)
{
    switch (buffType)
    {
        case ItemType.ChangeSkill:
            SFXSource.PlayOneShot(ChangeSkillSFX);
            break;
        case ItemType.Heal:
            SFXSource.PlayOneShot(HealSFX);
            break;
        case ItemType.RechargeMana:
            SFXSource.PlayOneShot(RefillManaSFX);
            break;
        case ItemType.DmgBoost:
            SFXSource.PlayOneShot(PowerBuffSFX);
            break;
        case ItemType.ChangeWeakness:
            SFXSource.PlayOneShot(ChangeWeaknessSFX);
            break;
        default:
            break;
    }

}


public IEnumerator PlayFX(DmgType dmgType, Transform Target, float delay)
{
    yield return new WaitForSeconds(delay);
    GameObject HitFX;
    switch (dmgType)
    {
        case DmgType.Physical:
            HitFX = Instantiate(PhysicalHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;
        case DmgType.Fire:
            HitFX = Instantiate(FireHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;

        case DmgType.Earth:
            HitFX = Instantiate(EarthHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;

        case DmgType.Darkness:
            HitFX = Instantiate(DarknessHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;

        case DmgType.Light:
            HitFX = Instantiate(LightHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;

        default:
            HitFX = Instantiate(GenericHit, Target.position, Quaternion.identity);
            HitFX.gameObject.layer = 5;
            HitFX.GetComponent<ParticleSystem>().Play();
            yield return new WaitForSeconds(1f);
            Destroy(HitFX);
            break;
            


    }
}

IEnumerator PlaySummoningEffect(Transform Attacker)
{
    GameObject SummoningFX = Instantiate(SummoningEffect, Attacker.position, Quaternion.identity);
    SummoningFX.gameObject.layer = 5;
    SummoningFX.GetComponent<ParticleSystem>().Play();
    yield return new WaitForSeconds(1f);
    Destroy(SummoningFX);
}

IEnumerator PlayBuffFX(ItemType buffType, Transform Target, float delay)
{
    yield return new WaitForSeconds(delay);
    GameObject BuffFX;
switch (buffType)
{
    case ItemType.Heal:
        BuffFX = Instantiate(HealEffect, Target.position, Quaternion.identity);
        // move BuffFX to Bottom of the Character
        BuffFX.transform.position = new Vector3(BuffFX.transform.position.x -0.2f, BuffFX.transform.position.y - 2f, BuffFX.transform.position.z);

        break;

    case ItemType.RechargeMana:
        BuffFX = Instantiate(RefillMana, Target.position, Quaternion.identity);
        BuffFX.transform.position = new Vector3(BuffFX.transform.position.x -0.2f, BuffFX.transform.position.y - 2f, BuffFX.transform.position.z);
        break;

    case ItemType.DmgBoost:
        BuffFX = Instantiate(PowerBuff, Target.position, Quaternion.identity);
        BuffFX.transform.position = new Vector3(BuffFX.transform.position.x - 0.2f, BuffFX.transform.position.y - 1f, BuffFX.transform.position.z);
        break;

    case ItemType.ChangeWeakness:
        BuffFX = Instantiate(ChangeWeakness, Target.position, Quaternion.identity);
        break;

    case ItemType.ChangeSkill:
        BuffFX = Instantiate(ChangeSkill, Target.position, Quaternion.identity);
        break;

    default:
        BuffFX = Instantiate(GenericHit, Target.position, Quaternion.identity);
        break;
}

if (BuffFX != null)
{
    BuffFX.gameObject.layer = 5;
    BuffFX.GetComponent<ParticleSystem>().Play();
    yield return new WaitForSeconds(2f);
    Destroy(BuffFX);
}

}

public void DmgEffect(DmgType dmgType, Transform Attacker, Transform Target, float delay)
{
    StartCoroutine(PlayFX(dmgType, Target, delay));
    // StartCoroutine(PlaySummoningEffect(Attacker));
}

public void BuffEffect(ItemType buffType, Transform Target, float delay)
{
    StartCoroutine(PlayBuffFX(buffType, Target, delay));
}
public void PlayHitSoundEffect()
{
    SFXSource.PlayOneShot(GenericHitSound);
    // SFXSource.PlayOneShot(Summoning);  
}

public void PlayUseItemSoundEffect()
{
    SFXSource.PlayOneShot(GenericHitSound);

}


}


