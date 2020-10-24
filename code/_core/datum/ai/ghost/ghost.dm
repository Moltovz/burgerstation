/ai/ghost
	var/anger = 0
	var/hunt_duration = 0//Above 1 means hunt. Counts down by 1 every life tick.

	use_alerts = FALSE
	true_sight = TRUE
	use_cone_vision = FALSE
	should_investigate_alert = TRUE

	reaction_time = 0 //Instant

	var/mob/living/simple/npc/ghost/owner_as_ghost

	var/ghost_type = "ghost"
	//shade
	//revenant
	//faithless
	//forgotten


	var/shy_level = 0
	//1 = will become more visible the more people around it.
	//2 = will become less visible the more people around it.
	//3 = will only show itself if people aren't looking at it.
	//On hunts, it's fully visible.

	var/stealth_killer = 0
	//1 = fully visible on hunt
	//2 = invisbile on hunt

	roaming_distance = 0

	var/origin_area_identifier


/ai/ghost/New(var/mob/living/desired_owner)

	. = ..()

	var/turf/T = get_turf(desired_owner)
	var/area/A = T.loc
	origin_area_identifier = A.area_identifier

	owner_as_ghost = desired_owner
	shy_level = rand(1,3)
	//stealth_killer = rand(1,2)
	stealth_killer = 1
	ghost_type = pick("shade","revenant","faithless","forgotten")

	owner_as_ghost.icon = 'icons/mob/living/simple/ghosts.dmi'
	owner_as_ghost.icon_state = ghost_type
	desired_owner.name = ghost_type


	var/turf/T2 = find_new_location()
	if(T2)
		owner.force_move(T2)
		notify_ghosts("\The [owner.name] moved to [T2.loc.name].",T2)
		log_debug("\The [owner.name] moved to [T2.loc.name].")

	return .


/ai/ghost/proc/create_emf(var/turf/loc,var/desired_level=3,var/desired_range=VIEW_RANGE)

	if(!desired_level || !desired_range)
		return FALSE

	var/obj/emf/E = new(loc,desired_level,desired_range)
	INITIALIZE(E)
	GENERATE(E)
	FINALIZE(E)

	queue_delete(E,SECONDS_TO_DECISECONDS(20))

	return E

/ai/ghost/proc/find_new_location()

	var/list/possible_areas = SSarea.areas_by_identifier[origin_area_identifier]
	if(!length(possible_areas))
		return null

	var/chances_left = 5
	while(chances_left > 0)
		chances_left--
		var/area/A2 = pick(possible_areas)
		if(istype(A2,/area/transit))
			continue
		var/turf/T = locate(A2.average_x,A2.average_y,A2.z)
		return T

	return null

/ai/ghost/on_life(var/tick_rate=AI_TICK)

	anger = clamp(anger,0,200)

	var/turf/T = get_turf(owner)
	var/area/A = T.loc

	if(owner.move_delay <= 0)
		handle_movement_reset()
		handle_movement()

	if(owner.attack_next <= world.time)
		handle_attacking()

	owner.handle_movement(tick_rate)

	if(objective_attack || anger >= 100 || (anger >= 50 && prob(1)))
		var/no_objective = !objective_attack
		objective_ticks += tick_rate
		owner_as_ghost.desired_alpha = stealth_killer == 2 ? 0 : 255
		if(objective_ticks >= get_objective_delay())
			objective_ticks = 0
			handle_objectives()
			if(objective_attack)
				anger -= DECISECONDS_TO_SECONDS(1)
				A.smash_all_lights()
				if(no_objective) //First time attacking.
					var/can_hunt = TRUE
					for(var/obj/item/cross/C in range(objective_attack,6))
						if(C.icon_state == initial(C.icon_state))
							C.break_cross()
							can_hunt = FALSE
							break
					if(can_hunt)
						anger = 200
						notify_ghosts("\The [owner.name] is now hunting!",T)
						log_debug("\The [owner.name] is now hunting!")
						owner.icon_state = "[ghost_type]_angry"
					else
						set_objective(null)
						owner.icon_state = "[ghost_type]"
						anger = 50
			else
				owner.icon_state = "[ghost_type]"
				anger = 50
		return TRUE


	//Who is looking at us?
	var/list/viewers = list()
	var/mob/living/advanced/insane
	var/sanity_rating = 9999

	if(T.darkness >= 0 && owner.invisibility < 101)
		for(var/mob/living/advanced/ADV in view(owner,owner.view))
			if(ADV.dead)
				continue
			if(!ADV.client)
				continue
			if(!(ADV.dir & get_dir(ADV,owner)))
				continue
			viewers += ADV
			ADV.sanity -= DECISECONDS_TO_SECONDS(2)
			if(ADV.sanity < sanity_rating)
				insane = ADV
				sanity_rating = ADV.sanity

	var/viewer_count = length(viewers)

	var/desired_alpha = 200

	switch(shy_level)
		if(2) //Shy
			anger += viewer_count*0.05
			desired_alpha -= viewer_count ? 50 : 0
		if(3) //Super shy
			if(!viewer_count)
				anger -= 0.03
			else
				anger += viewer_count*0.15
			desired_alpha -= viewer_count ? 150 : 50

	if(T.darkness >= 0.5) //Light bad.
		desired_alpha = 0
	else if (T.darkness <= 0)
		desired_alpha = 0

	if(T.darkness >= 0.1 && prob(anger)) //Too bright
		desired_alpha -= 50
		if(anger >= 50)
			A.smash_all_lights()
			create_emf(T,4)
		else
			if(!A.toggle_all_lights())
				A.smash_all_lights()
				create_emf(T,4)
			else
				create_emf(T,3)
		var/annoying_player = FALSE
		for(var/light_source/LS in T.affecting_lights)
			if(LS.light_power < 0.5)
				continue
			if(is_advanced(LS.top_atom))
				var/mob/living/advanced/ADV = LS.top_atom
				if(anger >= 50)
					play(pick('sound/ghost/pain_1.ogg','sound/ghost/pain_2.ogg','sound/ghost/pain_3.ogg'),ADV)
					anger += 25
					anger = max(anger,90)
					ADV.sanity -= 50
				else
					anger += 25
					ADV.sanity -= 25
				annoying_player = TRUE
			if(istype(LS.source_atom,/obj/item/weapon/melee/torch))
				var/obj/item/weapon/melee/torch/L = LS.source_atom
				if(L.enabled) L.click_self(owner)
				create_emf(get_turf(L),3)
		if(annoying_player)
			if(viewer_count >= 3)
				var/turf/T2 = find_new_location()
				if(T2)
					create_emf(T,2)
					owner.force_move(T2)
					create_emf(T2,3,VIEW_RANGE*3)
					notify_ghosts("\The [owner.name] moved to [T2.loc.name].",T2)
					log_debug("\The [owner.name] moved to [T2.loc.name].")
			else
				anger += 10


	//Look at the man who will die.
	if(insane) owner.set_dir(get_dir(owner,insane))

	desired_alpha = clamp(desired_alpha,0,255)
	owner_as_ghost.desired_alpha = desired_alpha

	return TRUE


/ai/ghost/get_attack_score(var/mob/living/L)
	if(!is_advanced(L))
		return -1
	var/mob/living/advanced/A = L
	return 100 - A.sanity


/ai/ghost/set_alert_level(var/desired_alert_level,var/can_lower=FALSE,var/atom/alert_epicenter = null,var/atom/alert_source = null)
	//Trying to alert it just pisses it off.
	switch(desired_alert_level)
		if(ALERT_LEVEL_NOISE)
			anger += 3
		if(ALERT_LEVEL_CAUTION)
			anger += 5
		if(ALERT_LEVEL_COMBAT)
			anger += 20

	return TRUE