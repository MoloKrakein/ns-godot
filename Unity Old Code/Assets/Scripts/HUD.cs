using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
// using textmeshpro;
using TMPro;

public class HUD : MonoBehaviour
{
    // public TextMeshProUGUI nameText;
    // public TextMeshProUGUI lvlText;
    // public TextMeshProUGUI dmgText;

    // public GameObject hpBar;
    // public GameObject mpBar;

    public Slider hpSlider;
    public Slider mpSlider;

    public Sprite Fire;
    public Sprite Earth;
    public Sprite Light;
    public Sprite Dark;
    public Sprite Physical;

    public Image weaknessImage;

    public GameObject HUDObject;

    public void setupHUD(Unit unit)
    {

        hpSlider.maxValue = unit.maxHP;
        hpSlider.value = unit.currentHP;
        mpSlider.maxValue = unit.maxMP;
        mpSlider.value = unit.currentMP;
        // Switch unit.weakness to determine which sprite to use
        switch (unit.weakness)
        {
            case DmgType.Fire:
                weaknessImage.sprite = Fire;
                break;
            case DmgType.Earth:
                weaknessImage.sprite = Earth;
                break;
            case DmgType.Light:
                weaknessImage.sprite = Light;
                break;
            case DmgType.Darkness:
                weaknessImage.sprite = Dark;
                break;
            case DmgType.Physical:
                weaknessImage.sprite = Physical;
                break;
            default:
                weaknessImage.sprite = Physical;
                break;
        }
    }
    // update damage text
    public void setupEnemyHPHUD(Unit unit)
    {

        hpSlider.maxValue = unit.maxHP;
        hpSlider.value = unit.currentHP;
        mpSlider.maxValue = unit.maxMP;
        mpSlider.value = unit.currentMP;
    switch (unit.weakness)
        {
            case DmgType.Fire:
                weaknessImage.sprite = Fire;
                break;
            case DmgType.Earth:
                weaknessImage.sprite = Earth;
                break;
            case DmgType.Light:
                weaknessImage.sprite = Light;
                break;
            case DmgType.Darkness:
                weaknessImage.sprite = Dark;
                break;
            case DmgType.Physical:
                weaknessImage.sprite = Physical;
                break;
            default:
                weaknessImage.sprite = Physical;
                break;
        }
    }
    public void updateHP(int hp)
    {
        hpSlider.value = hp;

    }
    // update mana text
    public void updateMP(int mp)
    {
        mpSlider.value = mp;
    }

    public void updateWeakness(Unit unit)
    {
        switch (unit.weakness)
        {
            case DmgType.Fire:
                weaknessImage.sprite = Fire;
                break;
            case DmgType.Earth:
                weaknessImage.sprite = Earth;
                break;
            case DmgType.Light:
                weaknessImage.sprite = Light;
                break;
            case DmgType.Darkness:
                weaknessImage.sprite = Dark;
                break;
            case DmgType.Physical:
                weaknessImage.sprite = Physical;
                break;
            default:
                weaknessImage.sprite = Physical;
                break;
        }
    }

    public void hideUI()
    {
        // originalTransform = HUDObject.transform;
        HUDObject.transform.position = new Vector3(HUDObject.transform.position.x + 1000, HUDObject.transform.position.y, HUDObject.transform.position.z);

    }

    public void showUI()
    {
        HUDObject.transform.position = new Vector3(HUDObject.transform.position.x - 1000, HUDObject.transform.position.y, HUDObject.transform.position.z);

    }
}