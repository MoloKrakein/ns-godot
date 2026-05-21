using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class DamagePopUps : MonoBehaviour
{
    public Slider HealthBar;
    public TextMeshProUGUI dmgValue1;
    public TextMeshProUGUI dmgValue2;
    public float LifeTime;

    public Transform EnemyPopUpLocation;
    public Transform PlayerPopUpLocation;

    public GameObject DownImage;
    public GameObject CritImage;

    public void SetupDmgPopup(int maxHealth){
        HealthBar.maxValue = maxHealth;

    }

    public void UpdateHealthBar(int health)
    {
        HealthBar.value = health;

    }

    void dmgValue1Text(int damage)
    {
        dmgValue1.text = damage.ToString();
    }

    void dmgValue2Text(int damage)
    {
        dmgValue2.text = damage.ToString();
    }

    public void spawnPopups(int damage, bool isPlayer, bool isDown, bool isCrit, int Health, int maxHealth){
        // Check if crit or not, if crit first then show crit Image then ignore down image
        if(isCrit){
            CritImage.SetActive(true);
            DownImage.SetActive(false);
        }
        else if(isDown){
            DownImage.SetActive(true);
            CritImage.SetActive(false);
        }
        else{
            DownImage.SetActive(false);
            CritImage.SetActive(false);
        }
        if(isPlayer){
            transform.position = PlayerPopUpLocation.position;
        }
        else{
            transform.position = EnemyPopUpLocation.position;
        }
        // Health = Health - damage;
        SetupDmgPopup(maxHealth);
        dmgValue1Text(damage*2);
        dmgValue2Text(damage*2);
        UpdateHealthBar(Health);
        StartCoroutine(DestroyPopups());
    }

    IEnumerator DestroyPopups(){
        yield return new WaitForSeconds(LifeTime);
        Destroy(gameObject);
    }


}
