#define RESTRICT_CKEYS 1
#define RESTRICT_IPS 2
#define RESTRICT_CIDS 4

var/tempbans_loaded = FALSE

var/list/banned_ckeys = list()
var/list/banned_ips = list()
var/list/banned_cids = list()

var/tempban_restriction = RESTRICT_CKEYS ^ RESTRICT_IPS ^ RESTRICT_CIDS

/client/New()
	if(tempban_restriction & RESTRICT_CKEYS)
		if(length(banned_ckeys) && (src.ckey in banned_ckeys))
			message_admins("TEMP BANS: Kicked banned ckey [src.ckey].")
			logTheThing("debug", null, null, "TEMP BANS: Kicked banned ckey [src.ckey].")
			del(src)
			return

	if(tempban_restriction & RESTRICT_IPS)
		if(length(banned_ips) && (src.address in banned_ips))
			message_admins("TEMP BANS: Kicked banned ip [src.address].")
			logTheThing("debug", null, null, "TEMP BANS: Kicked banned ip [src.address].")
			del(src)
			return

	if(tempban_restriction & RESTRICT_CIDS)
		if(length(banned_cids) && (src.computer_id in banned_cids))
			message_admins("TEMP BANS: Kicked banned cid [src.computer_id].")
			logTheThing("debug", null, null, "TEMP BANS: Kicked banned cid [src.computer_id].")
			del(src)
			return

	. = ..()

/proc/add_ban_to_tempbans(var/ckey, var/ip, var/cid, var/admin)
	// for this round
	banned_ckeys.Add(ckey)
	banned_ips.Add(ip)
	banned_cids.Add(cid)

	// to the tempbans file for future rounds
	var/comment = "\n#Ban issued by [admin] at [time2text(world.realtime, "YYYY-MM-DD-hh-mm")]:\n"
	var/entry = "[ckey];[ip];[cid]"
	text2file(comment + entry, config.tempbans_path)
	message_admins("Tempban added by [admin]. To mirror the ban to the other server issue a ban with the special string type and use the string below:<br>[entry]")

/proc/load_temp_bans()
	var/fileName = config.tempbans_path
	var/text = file2text(fileName)
	if(!text)
		message_admins("TEMP BANS: Couldn't load temp bans or they were empty.")
		logTheThing("debug", null, null, "TEMP BANS: tempbans failed to load or empty")
		return
	else
		message_admins("TEMP BANS: Successfully loaded.")
		logTheThing("debug", null, null, "TEMP BANS: tempbans loaded")
	// format:  ckey;ip;cid
	var/list/lines = splittext(text, "\n")
	var/list/bad_ckeys = list()
	var/list/bad_ips = list()
	var/list/bad_cids = list()
	for(var/line in lines)
		if (!line)
			continue

		if (copytext(line, 1, 2) == "#")
			continue

		var/list/split_line = splittext(line, ";")
		bad_ckeys.Add(split_line[1])
		bad_ips.Add(split_line[2])
		bad_cids.Add(split_line[3])

	banned_ckeys = bad_ckeys
	banned_ips = bad_ips
	banned_cids = bad_cids

/proc/overwrite_temp_bans(var/string, var/user)
	if(fexists(config.tempbans_path))
		if(!fdel(config.tempbans_path))
			message_admins("TEMP BANS: [user] tried to overwrite temp bans but for some reason they couldn't be deleted.")
			logTheThing("debug", null, null, "TEMP BANS: [user] tried to overwrite temp bans but for some reason they couldn't be deleted.")
			return
	message_admins("TEMP BANS: [user] is editing and overwriting temp bans.")
	logTheThing("debug", null, null, "TEMP BANS: [user] is editing and overwriting temp bans.")
	if(text2file(string, config.tempbans_path))
		message_admins("TEMP BANS: [user] has successfully edited and overwritten temp bans.")
		logTheThing("debug", null, null, "TEMP BANS: [user] has successfully edited and overwritten temp bans.")
	else
		message_admins("TEMP BANS: failed to edit temp bans. Something went wrong. Emergency dump has been logged, use it for potential recovery.")
		logTheThing("debug", null, null, "TEMP BANS: Emergency dump: <br>[replacetext(string, "\n", "<br>")]")

	message_admins("TEMP BANS: Reloading tempbans from file.")
	logTheThing("debug", null, null, "TEMP BANS: Reloading tempbans from file.")
	load_temp_bans()
