/savedata/client/
	var/client/owner
	var/ckey
	var/bot_controlled = FALSE

/savedata/client/Destroy()
	owner = null
	return ..()

/savedata/client/New(var/client/new_owner)

	if(!new_owner)
		CRASH("FATAL ERROR: Savedata did not have a valid owner!")
		qdel(src)

	if(new_owner)
		owner = new_owner
		ckey = owner.ckey
	else
		bot_controlled = TRUE
		ckey = "BOT"

	return ..()

/savedata/client/get_folder(var/folder_id)
	return replacetext(CKEY_PATH_FORMAT,"%CKEY",folder_id)

/savedata/client/get_files()
	return flist(get_folder(ckey))