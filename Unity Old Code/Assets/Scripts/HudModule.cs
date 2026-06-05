using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using TMPro;
using System.Collections.Generic;

public class HudModule : MonoBehaviour {
    public HUD playerHUD;
    public HUD enemyHUD;
    public BattleFlow battleFlow;
    public MagicSkillList magicSkill;
    public ItemList itemList;
    public GameObject ActionButtons;
    public Canvas canvas;
    public GameObject extraTurnPopup;
    public GameObject ChangeTurnPopup;
    public GameObject BattleLog;
    // public GameObject EncounterPopup;
    public GameObject DamagePopup;
    private Unit PlayerUnit;
    private Unit EnemyUnit;
    private BattleState state;



    
    private void Start() {
        PlayerUnit = battleFlow.PlayerUnit;
        EnemyUnit = battleFlow.EnemyUnit;
        state = battleFlow.state;
        setupHUD();
        setupButtons();

    }

    public void setupButtons()
    {

        for(int i = 0; i < 5; i++){
            magicSkill.SetButton(i, PlayerUnit.ReadySkills[i].Name, PlayerUnit.ReadySkills[i].ManaCost, PlayerUnit.ReadySkills[i].UsesHP, PlayerUnit.ReadySkills[i].SkillSprite);
        }
        for(int i = 0; i < 5; i++){
                  itemList.SetButton(i, PlayerUnit.PassiveSkill[i].ItemName, PlayerUnit.PassiveSkill[i].Cost, PlayerUnit.PassiveSkill[i].isUsingHP, PlayerUnit.PassiveSkill[i].ItemSprite);
        }
        
    }
    public void updateButtons()
    {
for(int i = 0; i < 5; i++){
            magicSkill.SetButton(i, PlayerUnit.ReadySkills[i].Name, PlayerUnit.ReadySkills[i].ManaCost, PlayerUnit.ReadySkills[i].UsesHP, PlayerUnit.ReadySkills[i].SkillSprite);
        }

    }

    public void setupHUD()
    {
        if(PlayerUnit != null && EnemyUnit != null){
            playerHUD.setupHUD(PlayerUnit);
            enemyHUD.setupHUD(EnemyUnit);
        }else{
            Debug.Log("Player or Enemy is null");
        }
    }

    public void hideSkillbtn(){
        magicSkill.HideButton();
    }
    public void hideActionButtons()
    {
        ActionButtons.SetActive(false);
    }
    public void showActionButtons()
    {
        ActionButtons.SetActive(true);
    }

    public void hideItemPanel()
    {
        itemList.HidePanel();
    }

    public IEnumerator ExtraTurnPopup()
    {
        GameObject extraTurnPopUp = Instantiate(extraTurnPopup, canvas.transform);
        yield return new WaitForSeconds(2f);
        Destroy(extraTurnPopUp);
    }

    public void ChangeTurn()
    {
        GameObject changeTurnPopUp = Instantiate(ChangeTurnPopup, canvas.transform);
        changeTurnPopUp.GetComponent<ChangeTurnPopUps>().spawnPopups(true);


    }

public void UpdateHUD()
{
    if (PlayerUnit != null && EnemyUnit != null)
    {
        playerHUD.updateHP(PlayerUnit.currentHP);
        playerHUD.updateMP(PlayerUnit.currentMP);
        enemyHUD.updateHP(EnemyUnit.currentHP);
        enemyHUD.updateMP(EnemyUnit.currentMP);
        playerHUD.updateWeakness(PlayerUnit);
        enemyHUD.updateWeakness(EnemyUnit);
    }
    if(PlayerUnit == null){
        Debug.Log("Player is null");
    }

}

public void SpawnDamagePopup(int damage, bool isPlayer, bool isDown, bool isCrit, int Health, int maxHealth)
{
    GameObject damagePopUp = Instantiate(DamagePopup, canvas.transform);
    damagePopUp.GetComponent<DamagePopUps>().spawnPopups(damage, isPlayer, isDown, isCrit, Health, maxHealth);
}


public void UpdateBattleLog(string name, DmgType action)
{
    string log = "";
    log = name + " " + "used" + " " + action + "\n";

    BattleLog.GetComponent<BattleLog>().UpdateLog(log);
}

public void UpdateBattleLogChangeWeakness(string name, DmgType weakness)
{
    string text = "";
    text = name + " " + "changed weakness !";

    BattleLog.GetComponent<BattleLog>().UpdateLog(text);
}



}