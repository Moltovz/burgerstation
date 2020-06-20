/obj/structure/interactive/blob/node
	name = "blob node"
	icon_state = "node"
	has_damaged_state = TRUE
	health_base = 500

	health_states = 1

	var/mob/living/simple/npc/blobbernaught/linked_blobbernaught

/obj/structure/interactive/blob/node/proc/check_jugs()

	if(!linked_blobbernaught)
		linked_blobbernaught = new(get_turf(src),null,1,src)
		INITIALIZE(linked_blobbernaught)

	return FALSE

/obj/structure/interactive/blob/node/New(var/desired_loc,var/obj/structure/interactive/blob/core/desired_owner)

	. = ..()

	if(desired_owner)
		desired_owner.linked_nodes += src

	return .

/obj/structure/interactive/blob/node/update_overlays()
	. = ..()
	var/image/I = new/image(icon,"node_overlay")
	I.appearance_flags = KEEP_TOGETHER | RESET_COLOR
	add_overlay(I)
	return .