using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class ItemList : MonoBehaviour
{
    public Button[] ItemListBtn;
    public GameObject btnPrefab;
    public GameObject ItemPanel;

    public void HidePanel()
    {
        ItemPanel.SetActive(false);
    }

    public void ShowPanel()
    {
        ItemPanel.SetActive(true);
    }

      public int  ButtonAction(int index)
    {
        return index;
    }

    public void SetButton(int index, string name, int mana, bool useHP, Sprite icon)
    {
        ItemListBtn[index].transform.Find("Image").GetComponent<Image>().sprite = icon;
        ItemListBtn[index].transform.Find("skillName").GetComponent<TextMeshProUGUI>().text = name;
        ItemListBtn[index].transform.Find("mp_bar").GetComponent<TextMeshProUGUI>().text = mana.ToString();
        if(useHP){
            ItemListBtn[index].transform.Find("SkillAttribute").GetComponent<TextMeshProUGUI>().text = "HP";
            ItemListBtn[index].transform.Find("SkillBg").GetComponent<Image>().color = new Color32(255, 0, 0, 255);
        }
        else{
            ItemListBtn[index].transform.Find("SkillAttribute").GetComponent<TextMeshProUGUI>().text = "MP";
        }
    }


}
    

