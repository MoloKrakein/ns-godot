using UnityEngine.UI;
using TMPro;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

public class CameraModule : MonoBehaviour {
    public BattleFlow battleFlow;
    public Camera cam;
    public float shakeDuration = 1f;
    public float shakeMagnitude = 1f;
    public float zoomSize = 5f;
    public GameObject DarkScreen;
    private Unit PlayerUnit;
    private Unit EnemyUnit;

    private HUD playerHUD;
    private HUD enemyHUD;

    private Transform playerLocation;
    private Transform enemyLocation;

    public BattleState state;

    private void Start() {
        PlayerUnit = battleFlow.PlayerUnit;
        EnemyUnit = battleFlow.EnemyUnit;
        playerHUD = battleFlow.playerHUD;
        enemyHUD = battleFlow.enemyHUD;
        playerLocation = battleFlow.playerLocation;
        enemyLocation = battleFlow.enemyLocation;
        state = battleFlow.state;

    }

   public IEnumerator ShakeCamera(){
        enemyHUD.hideUI();
        playerHUD.hideUI();
        Vector3 originalPos = cam.transform.localPosition;
        float elapsed = 0.0f;

        Vector3 originalScalePlayer = PlayerUnit.transform.localScale;
        Vector3 originalScaleEnemy = EnemyUnit.transform.localScale;
        Vector3 OriginalPosPlayer = playerLocation.transform.localPosition;
        Vector3 OriginalPosEnemy = enemyLocation.transform.localPosition;
        Vector3 midPos = new Vector3(originalPos.x, originalPos.y-1.5f, 0);
       
       
        if(state == BattleState.PLAYERTURN){
            PlayerUnit.transform.localScale = originalScalePlayer * 1.5f;
            // EnemyUnit.transform.localScale = originalScaleEnemy * 0.5f;
            playerLocation.transform.localPosition = midPos;
            // PlayerCopy.transform.localScale = originalScalePlayer * 0.5f;
            // PlayerCopy.transform.localPosition = PlayerLocationCopy;

        }else{
            EnemyUnit.transform.localScale = originalScaleEnemy * 1.5f;
            // PlayerUnit.transform.localScale = originalScalePlayer * 0.5f;
            enemyLocation.transform.localPosition = midPos;
            // EnemyCopy.transform.localScale = originalScaleEnemy * 0.5f;
            // EnemyCopy.transform.localPosition = EnemyLocationCopy;
        }

        DarkScreen.SetActive(true);

        while (elapsed < shakeDuration)
        {
            float x = Random.Range(-1f, 1f) * shakeMagnitude;
            float y = Random.Range(-1f, 1f) * shakeMagnitude;

            cam.transform.localPosition = new Vector3(x, y, originalPos.z);
            elapsed += Time.deltaTime;
            yield return null;
        }
        cam.transform.localPosition = originalPos;


        yield return new WaitForSeconds(1f);
        DarkScreen.SetActive(false);
        // Scale down playerunit
        PlayerUnit.transform.localScale = originalScalePlayer;
        EnemyUnit.transform.localScale = originalScaleEnemy;
        playerLocation.transform.localPosition = OriginalPosPlayer;
        enemyLocation.transform.localPosition = OriginalPosEnemy;

        playerHUD.showUI();
        enemyHUD.showUI();

        playerHUD.updateHP(PlayerUnit.currentHP);
        enemyHUD.updateHP(EnemyUnit.currentHP);


       }
}