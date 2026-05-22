using UnityEngine;

[CreateAssetMenu(fileName = "Skill", menuName = "Scriptable/Skill", order = 0)]
public class Skill : ScriptableObject
{
    public string Name;
    public int AttackPower;
    public DmgType AttackType;
    public bool targetsAllEnemies;
    public int ManaCost;
    public bool UsesHP;
    public string info;
    public Sprite SkillSprite;
    public Skill(string name, int power, DmgType type, bool targetsAll, int manaCost, bool usesHP, string description, Sprite sprite)
    {
        Name = name;
        AttackPower = power;
        AttackType = type;
        targetsAllEnemies = targetsAll;
        ManaCost = manaCost;
        UsesHP = usesHP;
        info = description;
        SkillSprite = sprite;
    }
}