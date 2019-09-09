/obj/item/magazine/smg_9mm
	name = "\improper 9mm smg magazine"
	bullet_type = "9mm"
	icon = 'icons/obj/items/magazine/9mmsmg.dmi'
	icon_state = "9mmt"
	bullet_capacity = 20

	weapon_whitelist = list(
		/obj/item/weapon/ranged/bullet/magazine/smg/pdw
	)

/obj/item/magazine/smg_9mm/update_icon()
	icon_state = "[initial(icon_state)]-[round(length(stored_bullets),4)]"
	..()

/obj/item/magazine/smg_9mm/on_spawn()
	for(var/i=1, i <= bullet_capacity, i++)
		stored_bullets += new /obj/item/bullet/pistol_9mm(src)
	update_icon()