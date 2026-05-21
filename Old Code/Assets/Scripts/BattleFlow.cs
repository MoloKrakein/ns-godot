using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;



public enum BattleState { START, PLAYERTURN, ENEMYTURN, WON, LOST }

public class BattleFlow : MonoBehaviour
{
    public GameObject playerPrefab;
    public GameObject enemyPrefab;

    public Transform playerLocation;

    public Transform enemyLocation;

    public HUD playerHUD;
    public HUD enemyHUD;

    public Canvas EndGameCanvas;

    public DamageManager DamageManager;
    [HideInInspector]public Unit PlayerUnit;
    [HideInInspector]public Unit EnemyUnit;
    public BattleState state;
    private CameraModule cameraModule;
    public HudModule hudModule;

    private bool isPlayerExtraMove;
    private bool isEnemyExtraMove;
    [HideInInspector]public bool isPlayerBuffed;
    void Start()
    {
        StartCoroutine(SetupBattle());
        state = BattleState.START;
        cameraModule = GetComponent<CameraModule>();
    
    }
    private void Awake() {
        GameObject PlayerGO = Instantiate(playerPrefab, playerLocation);
        PlayerUnit = PlayerGO.GetComponent<Unit>();
        PlayerUnit.gameObject.layer = 5;

        GameObject EnemyGO = Instantiate(enemyPrefab, enemyLocation);
        EnemyUnit = EnemyGO.GetComponent<Unit>();
        EnemyUnit.gameObject.layer = 5;
        EnemyUnit.RandomizeUnit();

        PlayerUnit.SetupSkills();
        EnemyUnit.SetupSkills();
    
    }

    IEnumerator SetupBattle()
    {
        CheckCombatStatus();
        yield return new WaitForSeconds(2f);

        state = BattleState.PLAYERTURN;
        PlayerTurn();
    }

    IEnumerator PlayerAttack(Skill selectedSkill, bool isNormalAttack)
    {
        CheckCombatStatus();
        isEnemyExtraMove = false;
        hudModule.hideActionButtons();
        PlayerUnit.status = UnitStatus.Status.Idle;
        giveDamage(selectedSkill.AttackPower, EnemyUnit, selectedSkill.AttackType);
        PlayerUnit.attack();
        bool isDead = EnemyUnit.isDead();
        bool isWeakness = EnemyUnit.isWeakness(selectedSkill.AttackType);
        if(!isNormalAttack){
            PlayerUnit.HandleUsedSkill(selectedSkill);
        }


        bool extra = ExtraTurn(isWeakness);
        yield return new WaitForSeconds(2f);
        if (isDead)
        {
            state = BattleState.WON;
            EndBattle();
        }
        else if (extra)
        {
            yield return new WaitForSeconds(1f);
            StartCoroutine(hudModule.ExtraTurnPopup());
            PlayerUnit.status = UnitStatus.Status.Buff;
            state = BattleState.PLAYERTURN;
            hudModule.UpdateHUD();
            PlayerTurn();
            EnemyUnit.status = UnitStatus.Status.Idle;
        }
        else
        {
            state = BattleState.ENEMYTURN;
            StartCoroutine(EnemyTurn());
        }
        enemyHUD.updateHP(EnemyUnit.currentHP);
    }

    IEnumerator EnemyTurn()
    {
        CheckCombatStatus();

        isPlayerExtraMove = false;
        EnemyUnit.status = UnitStatus.Status.Idle;

        int randIndex = Random.Range(0, EnemyUnit.skills.Count);
        Skill selectedSkill = EnemyUnit.skills[randIndex];
        // chance enemy to attacking or swap weakness
        if(Random.Range(0,2)==0){
            giveDamage(selectedSkill.AttackPower, PlayerUnit, selectedSkill.AttackType);
            EnemyUnit.attack();
        hudModule.UpdateBattleLog(EnemyUnit.unitName, selectedSkill.AttackType);
        }else{
            EnemyUnit.RandomWeakness(EnemyUnit.weakness);
            DmgType weakness = EnemyUnit.weakness;
            hudModule.UpdateBattleLogChangeWeakness(EnemyUnit.unitName,weakness);
        }
    
        // giveDamage(selectedSkill.AttackPower, PlayerUnit, selectedSkill.AttackType);
        // EnemyUnit.attack();
        bool isDead = PlayerUnit.isDead();
        bool isWeakness = PlayerUnit.isWeakness(selectedSkill.AttackType);
        bool extra = ExtraTurn(isWeakness);
        yield return new WaitForSeconds(2f);

        if (isDead)
        {
            state = BattleState.LOST;
            EndBattle();
        }
        else if (extra)
        {
            yield return new WaitForSeconds(1f);
            StartCoroutine(hudModule.ExtraTurnPopup());
            EnemyUnit.status = UnitStatus.Status.Buff;
            state = BattleState.ENEMYTURN;
            StartCoroutine(EnemyTurn());
            PlayerUnit.status = UnitStatus.Status.Idle;
        }
        else
        {
            state = BattleState.PLAYERTURN;
            PlayerTurn();
        }
        playerHUD.updateHP(PlayerUnit.currentHP);

    }
void PlayerTurn()
    {
        CheckCombatStatus();
        if(!isPlayerExtraMove){
            hudModule.ChangeTurn();
        }
        hudModule.updateButtons();
        hudModule.showActionButtons();
        
        PlayerUnit.status = UnitStatus.Status.Idle;

    }
    public bool ExtraTurn(bool IsWeakness)
    {
        if (state == BattleState.PLAYERTURN)
        {
            if (EnemyUnit.isDown() && IsWeakness)
            {
                if (isPlayerExtraMove)
                {
                    return false;
                }
                else
                {
                    isPlayerExtraMove = true;
                    return true;
                }
            }
            else
            {
                isPlayerExtraMove = false;
                return false;
            }
        }else if(state == BattleState.ENEMYTURN)
        {
            if (PlayerUnit.isDown() && IsWeakness)
            {
                if (isEnemyExtraMove)
                {
                    return false;
                }
                else
                {
                    isEnemyExtraMove = true;
                    return true;
                }
            }
            else
            {
                isEnemyExtraMove = false;
                return false;
            }
        } else
        {
            return false;
        }
    }
    private void giveDamage(int damage, Unit unitType, DmgType dmgType)
    {
        hudModule.hideActionButtons();
        hudModule.hideItemPanel();
        hudModule.hideSkillbtn();
        int minimumDamage = unitType.damage / 2;
        Random.InitState((int)System.DateTime.Now.Ticks);
        int actualDamage = Random.Range(minimumDamage, damage + 1);
        float criticalChance = 0.1f;
        float randomValue = Random.value;
        bool isDown = false;
        bool isCrit = false;


        DamageManager.PlayAttackSound(dmgType);
        
        if (unitType.status == UnitStatus.Status.Down)
        {
            criticalChance = 0.3f;
        }
        if (randomValue < criticalChance)
        {
            actualDamage *= 2;
            isCrit = true;
            unitType.status = UnitStatus.Status.Down;
            if (BattleState.PLAYERTURN == state)
            {
                isPlayerExtraMove = true;
            }
            else
            {
                isEnemyExtraMove = true;
            }
        }
        if (unitType.isWeakness(dmgType))
        {
            isDown = true;
        }
        DamageManager.PlayHitSoundEffect();
        unitType.TakeDamage(actualDamage);

        if(unitType == PlayerUnit){
            hudModule.SpawnDamagePopup(actualDamage, true, isDown, isCrit, PlayerUnit.currentHP, PlayerUnit.maxHP);
        }else{
            hudModule.SpawnDamagePopup(actualDamage, false, isDown, isCrit, EnemyUnit.currentHP, EnemyUnit.maxHP);
        }
       
        if(state == BattleState.PLAYERTURN){
            cameraModule.state = BattleState.PLAYERTURN;
            StartCoroutine(cameraModule.ShakeCamera());
            DamageManager.DmgEffect(dmgType, PlayerUnit.transform, EnemyUnit.transform, 0.1f);

        }
        else{
            cameraModule.state = BattleState.ENEMYTURN;
            StartCoroutine(cameraModule.ShakeCamera());
            DamageManager.DmgEffect(dmgType, EnemyUnit.transform, PlayerUnit.transform, 0.1f);
        }


    }

    public void CheckCombatStatus()
    {
        hudModule.UpdateHUD();
        PlayerUnit.damage = PlayerUnit.damage + 1;
        EnemyUnit.damage = EnemyUnit.damage + 1;
        if (PlayerUnit.status == UnitStatus.Status.Dead)
        {
            state = BattleState.LOST;
            EndBattle();
        }
        else if (EnemyUnit.status == UnitStatus.Status.Dead)
        {
            SpawnNewEnemy();
        }
    }

    void EndBattle()
    {
        if (state == BattleState.WON)
        {
            // EndGameCanvas.gameObject.SetActive(true);
            // EndGameCanvas.GetComponentInChildren<TextMeshProUGUI>().text = "You Won!";
            // Change Scene to EndScreen and pass the data if player win or lose
            StaticValue.isWin = true;
            StartCoroutine(EndScreen());

        }
        else if (state == BattleState.LOST)
        {
            // EndGameCanvas.gameObject.SetActive(true);
            // EndGameCanvas.GetComponentInChildren<TextMeshProUGUI>().text = "You Lost!";
            // Change Scene to EndScreen and pass the data if player win or lose
            StaticValue.isWin = false;
            StartCoroutine(EndScreen());
          
        }
        
      

    }

    IEnumerator EndScreen()
    {
        yield return new WaitForSeconds(2f);
        SceneManager.LoadScene("EndScreen");
    }

    void SpawnNewEnemy()
    {

        GameObject EnemyGO = Instantiate(enemyPrefab, enemyLocation);
        EnemyUnit = EnemyGO.GetComponent<Unit>();
        EnemyUnit.SetupSkills();
        enemyHUD.setupHUD(EnemyUnit);
        EnemyUnit.RandomizeUnit();

        state = BattleState.ENEMYTURN;
        StartCoroutine(EnemyTurn());
    }


    public void NormalAttack(){
        hudModule.hideActionButtons();
        StartCoroutine(PlayerAttack(PlayerUnit.NormalAttack, true));
        
    }
    public bool Skillusage(int skillCost, bool usesHP)
    {
        if (isPlayerExtraMove)
        {
            skillCost = 0;
        }

        if (usesHP)
        {
            if (PlayerUnit.currentHP < skillCost)
            {
                return false;
            }
            PlayerUnit.currentHP -= skillCost;
            playerHUD.updateHP(PlayerUnit.currentHP);
            return true;
        }
        else
        {
            if (PlayerUnit.currentMP < skillCost)
            {
                return false;
            }
            PlayerUnit.currentMP -= skillCost;
            playerHUD.updateMP(PlayerUnit.currentMP);
            return true;
        }
    }
    public void onDefendButton()
    {
        PlayerUnit.OnDefend();
        hudModule.hideActionButtons();
        state = BattleState.ENEMYTURN;
        StartCoroutine(EnemyTurn());
    }
    public void UseSkill(int skillIndex)
    {
        Skill selectedSkill = PlayerUnit.ReadySkills[skillIndex];

        bool usesHP = selectedSkill.UsesHP;
        int skillCost = selectedSkill.ManaCost;
        if (!Skillusage(skillCost, usesHP))
            return;

        StartCoroutine(PlayerAttack(selectedSkill, false));
        isPlayerBuffed = false;
    }
    public void UseItem(int itemIndex)
    {
        Item selectedItem = PlayerUnit.PassiveSkill[itemIndex];
        StartCoroutine(UseItem(selectedItem));
        hudModule.hideItemPanel();
    }
    IEnumerator UseItem(Item selectedItem)
    {
        PlayerUnit.status = UnitStatus.Status.Idle;
        bool useHP = selectedItem.isUsingHP;
        int skillCost = selectedItem.Cost;
        if (!Skillusage(skillCost, useHP))
            yield break;
        if(selectedItem.itemType == ItemType.DmgBoost){
            isPlayerBuffed = true;
            Debug.Log("Buffed Enabled");
        }
        PlayerUnit.UsePassive(selectedItem, isPlayerBuffed);
        playerHUD.updateHP(PlayerUnit.currentHP);
        playerHUD.updateMP(PlayerUnit.currentMP);
        

        DamageManager.BuffEffect(selectedItem.itemType,playerLocation, 0.1f);
        DamageManager.PlayBuffSound(selectedItem.itemType);
        yield return new WaitForSeconds(2f);

        yield return new WaitForSeconds(1f);
        state = BattleState.ENEMYTURN;
        StartCoroutine(EnemyTurn());
    }



}