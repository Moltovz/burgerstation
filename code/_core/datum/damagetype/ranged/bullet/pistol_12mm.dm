/damagetype/ranged/bullet/pistol_12mm
	name = "pistol bullet"

	//The base attack damage of the weapon. It's a flat value, unaffected by any skills or attributes.
	attack_damage_base = list(
		BLUNT = 30,
		PIERCE = 30
	)

	//How much armor to penetrate. It basically removes the percentage of the armor using these values.
	attack_damage_penetration = list(
		BLUNT = 25,
		PIERCE = 25
	)

	falloff = VIEW_RANGE*0.75


/damagetype/ranged/bullet/pistol_12mm/ap
	name = "ap pistol bullet"

	//The base attack damage of the weapon. It's a flat value, unaffected by any skills or attributes.
	attack_damage_base = list(
		PIERCE = 50
	)

	//How much armor to penetrate. It basically removes the percentage of the armor using these values.
	attack_damage_penetration = list(
		PIERCE = 100
	)

/damagetype/ranged/bullet/pistol_12mm/surplus
	damage_mod = SURPLUS_MUL
	penetration_mod = SURPLUS_MUL