using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum UnitSide { Player, Enemy };
public class Unit : MonoBehaviour
{
    public string unitName;
    public int unitLevel;
    public int damage;
    public int maxHP;
    public int currentHP;
    public int maxMP;
    public int currentMP;
    private ItemList itemList;

    // public int speed;
    // public bool isDown = false;
    // public bool hasExtraTurn;

    // Use a list of skills instead of a skill set
    public List<Skill> skills = new List<Skill>();
    public List<Skill> ReadySkills = new List<Skill>();
    // public List<Skill> InitialSkills = new List<Skill>();
    public List<Skill> AlreadyUsedSkills = new List<Skill>();

    public List<Item> PassiveSkill = new List<Item>();


    public Skill NormalAttack;

    // unit side player or enemy
    public UnitSide unitSide;

    public DmgType weakness; // changed type to enum DmgType

    public UnitStatus.Status status;

    private DmgType originalWeakness;
    private bool isBoosted = false;
    


    public void attack(){
        // get animator controller
        Animator animator = GetComponent<Animator>();
        animator.SetTrigger("attack");
    }

    public void TakeDamage(int damage)
    {
        // get animator controller
        Animator animator = GetComponent<Animator>();
        if(UnitStatus.Status.Defend == status)
        {
            damage /= 10;
            revertStatus();
        }
        if(isBoosted)
        {
            damage *= 2;
            revertStatus();
        }

        currentHP -= damage;
        animator.SetTrigger("hit");
        // Debug.Log(unitName + " took " + damage + " ");

    }

    public bool isDead()
    {
        if(currentHP <= 0)
        {
            status = UnitStatus.Status.Dead;
            return true;
        }
        else
        {
            return false;
        }
    }

    public bool isDown(){
        if(UnitStatus.Status.Down == status){
            return true;
        }else{
            return false;
        }
    }
    
    public bool isWeakness(DmgType attackType)
    {
        if(weakness == attackType)
        {
            status = UnitStatus.Status.Down;
            return true;
        }
        else
        {
            return false;
        }
    }

    public void OnDefend(){
        status = UnitStatus.Status.Defend;
        originalWeakness = weakness;
        weakness = DmgType.None;
    }

    public void revertStatus(){
        status = UnitStatus.Status.Idle;
        weakness = originalWeakness;
        isBoosted = false;
    }

public void UsePassive(Item item, bool isBuffed)
{
    isBoosted = isBuffed;
    switch (item.itemType)
    {
        case ItemType.Heal:
        if(isBuffed){
            currentHP += item.ItemPower * 5;
            revertStatus();
        }
        else{
            currentHP += item.ItemPower;
        }
            // currentHP += item.ItemPower;
            if (currentHP > maxHP)
            {
                currentHP = maxHP;
            }
            
            break;
        case ItemType.RechargeMana:
        if(isBuffed){
            currentMP += item.ItemPower * 5;
            revertStatus();
        }
        else{
            currentMP += item.ItemPower;
        }

            if (currentMP > maxMP)
            {
                currentMP = maxMP;
            }
            break;
        case ItemType.DmgBoost:
            status = UnitStatus.Status.Buff;
            isBoosted = true;
            break;
        case ItemType.Defend:
            OnDefend();
            break;
        case ItemType.ChangeWeakness:
            // Randomize seed

            // Randomize weakness
            int randIndex = Random.Range(0, 5);

            weakness = (DmgType)randIndex;
            break;
        case ItemType.ChangeSkill:
            RandomizeReadySkills();
            break;
    }
}


public void SetupSkills()
    {
        Random.InitState((int)System.DateTime.Now.Ticks);
        HashSet<Skill> uniqueSkills = new HashSet<Skill>(skills);

        // Jika ada kurang dari 5 skill unik, masukkan semuanya ke ReadySkills
        if (uniqueSkills.Count <= 6)
        {
            ReadySkills.Clear();
            ReadySkills.AddRange(uniqueSkills);
        }
        else
        {
            // Jika ada lebih dari 5 skill unik, pilih 5 secara acak
            ReadySkills.Clear();
            while (ReadySkills.Count < 6)
            {
                int randIndex = Random.Range(0, skills.Count);
                Skill skill = skills[randIndex];

                if (!ReadySkills.Contains(skill)) // Memastikan skill unik
                {
                    ReadySkills.Add(skill);
                }
            }
        }


    }
    // setup passive skill
public void RandomizeReadySkills()
{
    // Delete index 0-4
    ReadySkills.RemoveRange(0, 5);

    // Buat salinan dari daftar keterampilan
    List<Skill> uniqueSkills = new List<Skill>(skills);

    // Randomize ReadySkills
    Random.InitState((int)System.DateTime.Now.Ticks);

    // Jika ada kurang dari 6 skill unik, masukkan semuanya ke ReadySkills
    if (uniqueSkills.Count <= 6)
    {
        ReadySkills.AddRange(uniqueSkills);
    }
    else
    {
        // Jika ada lebih dari 6 skill unik, pilih 6 secara acak
        while (ReadySkills.Count < 6)
        {
            int randIndex = Random.Range(0, uniqueSkills.Count);
            Skill skill = uniqueSkills[randIndex];

            if (!ReadySkills.Contains(skill)) // Memastikan skill unik
            {
                ReadySkills.Add(skill);
            }
        }
    }
}




    // setup passive skill
    public void SetupPassiveSkill()
    {
        HashSet<Item> uniqueSkills = new HashSet<Item>(PassiveSkill);

        // Jika ada kurang dari 5 skill unik, masukkan semuanya ke ReadySkills
        if (uniqueSkills.Count <= 6)
        {
            PassiveSkill.Clear();
            PassiveSkill.AddRange(uniqueSkills);
        }
        else
        {
            // Jika ada lebih dari 5 skill unik, pilih 5 secara acak
            PassiveSkill.Clear();
            while (PassiveSkill.Count < 6)
            {
                int randIndex = Random.Range(0, PassiveSkill.Count);
                Item skill = PassiveSkill[randIndex];

                if (!PassiveSkill.Contains(skill)) // Memastikan skill unik
                {
                    PassiveSkill.Add(skill);
                }
            }
        }
}
public void HandleUsedSkill(Skill usedSkill)
    {
        AlreadyUsedSkills.Add(usedSkill);
        Skill newSkill;
        Random.InitState((int)System.DateTime.Now.Ticks);
        int randIndex = Random.Range(0, skills.Count);
        newSkill = skills[randIndex];

        // Tambahkan skill baru ke ReadySkills
        ReadySkills.Add(newSkill);


        // Tambahkan skill yang digunakan ke AlreadyUsedSkills

        // Jika sudah ada 5 skill di AlreadyUsedSkills, hapus skill yang paling awal digunakan
        if (AlreadyUsedSkills.Count >= 5)
        {
            AlreadyUsedSkills.RemoveAt(0);
        }

        // Jika sudah ada 5 skill di ReadySkills, hapus skill yang paling awal digunakan
        if (ReadySkills.Count >= 5)
        {
            ReadySkills.RemoveAt(0);
        }
    }


// clear already used skill
public void ClearAlreadyUsedSkills()
{
    AlreadyUsedSkills.Clear();
}

private void SwapSkill(Skill skill1, Skill skill2)
{
    int index1 = ReadySkills.IndexOf(skill1);
    int index2 = ReadySkills.IndexOf(skill2);

    ReadySkills[index1] = skill2;
    ReadySkills[index2] = skill1;

}

    internal void RandomizeUnit()
    {
        // Randomize seed
        Random.InitState((int)System.DateTime.Now.Ticks);

        // Randomize weakness
        int randIndex = Random.Range(0, 5);
        weakness = (DmgType)randIndex;



        //randomize unit level 1 - 29
        unitLevel = Random.Range(1,29);
        
    }

public void RandomWeakness(DmgType weakness)
{
    // Randomize seed
    Random.InitState((int)System.DateTime.Now.Ticks);

    // Randomize weakness
    while (this.weakness == weakness)
    {
        int randIndex = Random.Range(0, 5);
        this.weakness = (DmgType)randIndex;
    }

}
}

