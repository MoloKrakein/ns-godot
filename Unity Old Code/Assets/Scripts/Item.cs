using UnityEngine;

[CreateAssetMenu(fileName = "Item", menuName = "Scriptable/Item", order = 0)]
public class Item : ScriptableObject {
   public string ItemName;
    public int ItemPower;
    public ItemType itemType;
    public int Cost;
    // public int ItemQuantity;
    public string ItemDescription;
    public Sprite ItemSprite;
    public bool isUsingHP;
    public Item(string name, int power, ItemType type, int SkillCost, string description, Sprite sprite, bool useHP)
    {
        ItemName = name;
        ItemPower = power;
        itemType = type;
        Cost = SkillCost;
        ItemDescription = description;
        ItemSprite = sprite;
        isUsingHP = useHP;
    }
    
}