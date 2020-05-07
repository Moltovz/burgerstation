/mob/living/simple/npc/bear
	name = "brown bear"
	icon = 'icons/mob/living/simple/bears.dmi'
	icon_state = "brown"
	damage_type = /damagetype/unarmed/claw/
	class = "bear"

	ai = /ai/

	stun_angle = 90

/mob/living/simple/npc/bear/post_death()
	..()
	icon_state = "[initial(icon_state)]_dead"
	update_sprite()

/mob/living/simple/npc/bear/snow
	name = "snow bear"
	icon_state = "white"

	level_multiplier = 1.25