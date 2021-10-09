#define ACCESS_ADDITION 1
#define ACCESS_ADDITION_REVERTED 2
#define ACCESS_REVOCATION 3
#define ACCESS_REVOCATION_REVERTED 4



/datum/access_field_data
	var/access_permission
	var/current_enabled_status = 0
	var/original_id_enabled_status = 0

	New(var/access_permission)
		. = ..()
		src.access_permission = access_permission

	proc/toggle_access()
		current_enabled_status = !current_enabled_status

		if(current_enabled_status == FALSE) // toggled to no access
			if(current_enabled_status == original_id_enabled_status) // access was revoked and it's back to original value
				return ACCESS_ADDITION_REVERTED
			else // access was revoked
				return ACCESS_REVOCATION
		else // toggled to enabled access
			if(current_enabled_status == original_id_enabled_status) // access was added and it's back to original value
				return ACCESS_REVOCATION_REVERTED
			else // access was added
				return ACCESS_ADDITION

/datum/categorised_access_fields
	var/category_title
	var/category_color
	var/list/list_of_accesses // used to generate access_fields
	var/list/datum/access_field_data/access_fields

	New()
		. = ..()
		src.access_fields = generate_access_fields_from_list_of_accesses(list_of_accesses)

	proc/generate_access_fields_from_list_of_accesses(var/list/input_list)
		PRIVATE_PROC(TRUE)
		var/list/returned_list_of_access_fields = list()
		for(var/access_field in input_list)
			var/datum/access_field_data/new_field = new/datum/access_field_data(access_field)
			returned_list_of_access_fields.Add(new_field)
		return returned_list_of_access_fields

	civilian
		category_title = "Civilian"
		category_color = "#73eb3c"
		list_of_accesses = list(access_morgue, access_maint_tunnels, access_chapel_office, access_tech_storage, access_bar, access_janitor, access_crematorium, access_kitchen, access_hydro, access_ranch)

	engineering
		category_title = "Engineering"
		category_color = "#eeff04"
		list_of_accesses = list(access_external_airlocks, access_construction, access_engineering, access_engineering_storage, access_engineering_power, access_engineering_engine, access_engineering_mechanic, access_engineering_atmos, access_engineering_control)

	supply
		category_title = "Supply"
		category_color = "#ffc404"
		list_of_accesses = list(access_hangar, access_cargo, access_supply_console, access_mining, access_mining_shuttle, access_mining_outpost)

	research
		category_title = "Research"
		category_color = "#8600bb"
		list_of_accesses = list(access_medical, access_tox, access_tox_storage, access_medlab, access_medical_lockers, access_research, access_robotics, access_chemistry, access_pathology)

	security
		category_title = "Security"
		category_color = "#d10000"
		list_of_accesses = list(access_security, access_brig, access_forensics_lockers, access_maxsec, access_securitylockers, access_carrypermit, access_contrabandpermit)

	command
		category_title = "Command"
		category_color = "#009213"
		list_of_accesses = list(access_research_director, access_emergency_storage, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_engineering_chief, access_medical_director, access_head_of_personnel, access_ghostdrone)

/datum/identification_computer_process_data
	var/registered_name
	var/original_registered_name
	var/assignment
	var/original_assignment
	var/pin
	var/original_pin
	var/current_dropdown_selected_job
	var/list/types_of_categorised_access_fields_to_add // used to generate cat_access_fields
	var/list/cat_access_fields

	var/list/access_field_lookup = list()
	var/list/list_of_added_access_permissions = list()
	var/list/list_of_revoked_access_permissions = list()

	New()
		. = ..()
		generate_categorised_access_fields()
		setup_lookup_associative_list()

	proc/generate_categorised_access_fields()
		PRIVATE_PROC(TRUE)
		cat_access_fields = list()
		for(var/type in types_of_categorised_access_fields_to_add)
			cat_access_fields.Add(new type)

	proc/setup_lookup_associative_list()
		PRIVATE_PROC(TRUE)
		for(var/datum/categorised_access_fields/categorised_fields in cat_access_fields)
			for(var/datum/access_field_data/access_field in categorised_fields.access_fields)
				access_field_lookup["[access_field.access_permission]"] = access_field

	proc/setup_data_from_id(var/obj/item/card/id/input_id)
		src.registered_name = input_id.registered
		src.original_registered_name = input_id.registered
		src.assignment = input_id.assignment
		src.original_assignment = input_id.assignment
		src.pin = input_id.pin
		src.original_pin = input_id.pin
		setup_access_field_datas_from_a_list_of_accesses(input_id.access)

	proc/setup_access_field_datas_from_a_list_of_accesses(var/list/list_of_accesses)
		PRIVATE_PROC(TRUE)
		for(var/access in list_of_accesses) // set every access in list as originally and currently enabled
			if(access_field_lookup["[access]"])
				var/datum/access_field_data/found_access_field = access_field_lookup["[access]"]
				found_access_field.current_enabled_status = 1
				found_access_field.original_id_enabled_status = 1

	proc/toggle_access(var/access)
		if(access_field_lookup["[access]"])
			var/datum/access_field_data/matching_access = access_field_lookup["[access]"]
			switch(matching_access.toggle_access()) // toggles the state of the access and allows us to handle the result
				if(ACCESS_ADDITION)
					list_of_added_access_permissions.Add(matching_access)
				if(ACCESS_ADDITION_REVERTED)
					list_of_added_access_permissions.Remove(matching_access)
				if(ACCESS_REVOCATION)
					list_of_revoked_access_permissions.Add(matching_access)
				if(ACCESS_REVOCATION_REVERTED)
					list_of_revoked_access_permissions.Remove(matching_access)

	proc/set_access(var/access, var/enabled)
		if(access_field_lookup["[access]"])
			var/datum/access_field_data/access_data = access_field_lookup["[access]"]
			if(access_data.current_enabled_status == enabled)
				return // no change needed, already matches enabled's value
			else
				toggle_access(access) // calls proc which toggles the access to match enabled's value and handles keeping track of the change

	proc/set_all_accesses(var/enabled)
		for(var/access in access_field_lookup)
			set_access(access, enabled)

/datum/identification_computer_process_data/standard
	types_of_categorised_access_fields_to_add = list(/datum/categorised_access_fields/civilian,
		/datum/categorised_access_fields/engineering,
		/datum/categorised_access_fields/supply,
		/datum/categorised_access_fields/research,
		/datum/categorised_access_fields/security,
		/datum/categorised_access_fields/command)

/obj/machinery/computer/tguicard
	name = "Identification Computer"
	icon_state = "id"
	circuit_type = /obj/item/circuitboard/card
	flags = TGUI_INTERACTIVE
	var/obj/item/card/id/authentication_card = null
	var/obj/item/card/id/modified_card = null
	var/obj/item/eject = null //Overrides modified_card slot set_loc. sometimes we want to eject something that's not a card. like an implant!
	var/authenticated = 0.0
	var/mode = 0.0
	var/printing = null
	var/list/scan_access = null
	var/list/custom_names = list("Custom 1", "Custom 2", "Custom 3")
	var/custom_access_list = list(list(),list(),list())
	var/list/civilian_access_list = list(access_morgue, access_maint_tunnels, access_chapel_office, access_tech_storage, access_bar, access_janitor, access_crematorium, access_kitchen, access_hydro, access_ranch)
	var/list/engineering_access_list = list(access_external_airlocks, access_construction, access_engineering, access_engineering_storage, access_engineering_power, access_engineering_engine, access_engineering_mechanic, access_engineering_atmos, access_engineering_control)
	var/list/supply_access_list = list(access_hangar, access_cargo, access_supply_console, access_mining, access_mining_shuttle, access_mining_outpost)
	var/list/research_access_list = list(access_medical, access_tox, access_tox_storage, access_medlab, access_medical_lockers, access_research, access_robotics, access_chemistry, access_pathology)
	var/list/security_access_list = list(access_security, access_brig, access_forensics_lockers, access_maxsec, access_securitylockers, access_carrypermit, access_contrabandpermit)
	var/list/command_access_list = list(access_research_director, access_emergency_storage, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_heads, access_captain, access_engineering_chief, access_medical_director, access_head_of_personnel, access_ghostdrone)
	var/list/allowed_access_list
	req_access = list(access_change_ids)
	desc = "A computer that allows an authorized user to change the identification of other ID cards."

	deconstruct_flags = DECON_MULTITOOL
	light_r = 0.7
	light_g = 1
	light_b = 0.1

	// tgui data
	var/list/job_dropdown_selection_options // if this isn't defined, it'll be generated in New()

	var/id_computer_process_data_type_to_use = /datum/identification_computer_process_data/standard
	var/datum/identification_computer_process_data/id_computer_process_data

	var/tgui_main_tab_index = 1
	var/authentication_locked_tabs = list(2, 3)

/obj/machinery/computer/tguicard/New()
	..()
	src.allowed_access_list = civilian_access_list + engineering_access_list + supply_access_list + research_access_list + command_access_list + security_access_list - access_maxsec
	if (!job_dropdown_selection_options)
		job_dropdown_selection_options = list()
		var/list/civilianjobs = list("Staff Assistant", "Bartender", "Chef", "Botanist", "Rancher", "Chaplain", "Janitor", "Clown")
		var/list/engineeringjobs = list("Engineer", "Mechanic", "Miner", "Quartermaster")
		var/list/researchjobs = list("Scientist", "Medical Doctor", "Geneticist", "Roboticist")
		var/list/securityjobs = list("Security Officer", "Security Assistant", "Detective")
		var/list/commandjobs = list("Head of Personnel", "Chief Engineer", "Research Director", "Medical Director", "Captain")
		job_dropdown_selection_options.Add(civilianjobs, engineeringjobs, researchjobs, securityjobs, commandjobs)

/obj/machinery/computer/tguicard/ui_interact(mob/user, datum/tgui/ui)
	ui = tgui_process.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "IdentificationComputer", name)
		ui.open()

/obj/machinery/computer/tguicard/ui_data(mob/user)
	var/list/sent_id_computer_process_data_associative_list

	if(src.id_computer_process_data)
		var/list/list/list/associative_list_of_cat_access_fields = list()
		for(var/datum/categorised_access_fields/cat_field in src.id_computer_process_data.cat_access_fields)
			var/list/list/associated_access_fields = list()
			for(var/datum/access_field_data/access_field in cat_field.access_fields)
				var/list/associated_list_entry = list(
					"access_permission" = access_field.access_permission,
					"current_enabled_status" = access_field.current_enabled_status,
					"original_id_enabled_status" = access_field.original_id_enabled_status
				)
				associated_access_fields.Add(list(associated_list_entry))
			var/list/cat_field_associated_list = list(
				"category_title" = cat_field.category_title,
				"category_color" = cat_field.category_color,
				"access_fields" = associated_access_fields
			)
			associative_list_of_cat_access_fields.Add(list(cat_field_associated_list))

		sent_id_computer_process_data_associative_list = list(
		"registered_name" = src.id_computer_process_data.registered_name,
		"original_registered_name" = src.id_computer_process_data.original_registered_name,
		"assignment" = src.id_computer_process_data.assignment,
		"original_assignment" = src.id_computer_process_data.original_assignment,
		"pin" = src.id_computer_process_data.pin,
		"original_pin" = src.id_computer_process_data.original_pin,
		"current_dropdown_selected_job" = src.id_computer_process_data.current_dropdown_selected_job,
		"number_of_added_access" = length(src.id_computer_process_data.list_of_added_access_permissions),
		"number_of_removed_access" = length(src.id_computer_process_data.list_of_revoked_access_permissions),
		"cat_access_fields" = associative_list_of_cat_access_fields
		)
	var/list/sent_authenticaton_card_data
	if(src.authentication_card)
		sent_authenticaton_card_data = list(
		"name" = src.authentication_card.name,
		"registered" = src.authentication_card.registered,
		"assignment" = src.authentication_card.assignment
		)

	var/list/sent_modified_card_data
	if(src.modified_card)
		sent_modified_card_data = list(
		"name" = src.modified_card.name,
		"registered" = src.modified_card.registered,
		"assignment" = src.modified_card.assignment
		)

	. = list(
	"authentication_card_data" = sent_authenticaton_card_data,
	"modified_card_data" = sent_modified_card_data,
	"is_authenticated" = src.authenticated,
	"id_computer_process_data" = sent_id_computer_process_data_associative_list,
	"selected_main_tab_index" = src.tgui_main_tab_index
	)

/obj/machinery/computer/tguicard/ui_static_data(mob/user)
		. = list(
			"all_job_selections" = src.job_dropdown_selection_options
		)

/obj/machinery/computer/tguicard/proc/generate_id_computer_process_data_from_current_modified_card()
	src.id_computer_process_data = new id_computer_process_data_type_to_use
	src.id_computer_process_data.setup_data_from_id(src.modified_card)

/obj/machinery/computer/tguicard/ui_act(action, params)
	. = ..()
	if (.)
		return
	switch(action)
		if("insert_authentication_id")
			on_auth_card_pressed(usr)
			. = TRUE
		if("insert_target_id")
			on_target_card_pressed(usr)
			. = TRUE
		if("set_main_tab_index")
			var/new_index = params["index"]
			if(new_index in authentication_locked_tabs)
				if(!authentication_card || !authenticated)
					return TRUE
			tgui_main_tab_index = new_index
			. = TRUE
		if("set_identification_field")
			if(!authenticated)
				return FALSE

			switch(params["field"])
				if("registered")
					//src.id_computer_process_data.registered_name = params["value"]
					var/new_input_name = input(usr, "What name?", "ID computer", null)
					new_input_name = strip_html(new_input_name, 100, 1)
					if(new_input_name)
						src.id_computer_process_data.registered_name = new_input_name
						. = TRUE
				if("assignment")
					//src.id_computer_process_data.assignment = params["value"]
					var/new_input_assignment = input(usr, "Enter a custom job assignment.", "Assignment")
					new_input_assignment = strip_html(new_input_assignment, 100, 1)
					if(new_input_assignment)
						src.id_computer_process_data.assignment = new_input_assignment
						. = TRUE
				if("pin")
					//src.id_computer_process_data.pin = params["value"]
					var/new_input_pin = input(usr, "Enter a new PIN.", "ID computer", 0) as null|num
					if(new_input_pin < 1000)
						src.id_computer_process_data.pin = 1000
					else if(new_input_pin > 9999)
						src.id_computer_process_data.pin = 9999
					else
						src.id_computer_process_data.pin = round(new_input_pin)
					. = TRUE
		if("select_dropdown_job")
			if(!authenticated)
				return FALSE
			src.id_computer_process_data.current_dropdown_selected_job = params["selection"]
		if("set_access_from_current_selected_dropdown_job")
			if(!authenticated)
				return FALSE
			if(!src.id_computer_process_data.current_dropdown_selected_job)
				return FALSE

			var/list/job_accesses = get_access(src.id_computer_process_data.current_dropdown_selected_job)
			if(!length(job_accesses))
				return FALSE
			if(params["clear_access"]) // allows for setting a job by clearing old access
				src.id_computer_process_data.set_all_accesses(0)
			var/enabled = params["enabled_value_to_set"] // allows for adding or subtracting per-job access
			for(var/access in job_accesses)
				src.id_computer_process_data.set_access(access, enabled)
			. = TRUE
		if("toggle_access")
			if(!authenticated)
				return FALSE

			var/selected_access = params["selected_access"]
			src.id_computer_process_data.toggle_access(selected_access)
			. = TRUE

	/*
		if("copypasta")
			var/newvar = params["var"]
			// A demo of proper input sanitation.
			var = CLAMP(newvar, min_val, max_val)
			. = TRUE
			update_icon() // Not applicable to all objects.
	*/

/obj/machinery/computer/tguicard/proc/clear_id_computer_process_data()
	src.id_computer_process_data = null

/obj/machinery/computer/tguicard/console_upper
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "id1"
/obj/machinery/computer/tguicard/console_lower
	icon = 'icons/obj/computerpanel.dmi'
	icon_state = "id2"

/obj/machinery/computer/tguicard/proc/update_authentication_status()
	if(!src.authentication_card)
		src.authenticated = FALSE
		tgui_main_tab_index = 1
	src.authenticated = src.check_access(src.authentication_card)

/// Handles pressing the authentication card slot in the tgui interface.
/obj/machinery/computer/tguicard/proc/on_auth_card_pressed(var/mob/user)
	if(src.authentication_card) // card is already inside, eject
		src.authentication_card.set_loc(src.loc)
		user.put_in_hand_or_drop(src.authentication_card)
		src.authentication_card = null
		update_authentication_status()
		clear_id_computer_process_data()
	else // no card inside, trying to insert equipped card
		var/obj/item/I = usr.equipped()
		if (istype(I, /obj/item/card/id))
			usr.drop_item()
			I.set_loc(src)
			src.authentication_card = I
			update_authentication_status()
			if(src.modified_card)
				generate_id_computer_process_data_from_current_modified_card()

/// Handles pressing the modification target card slot in the tgui interface.
/obj/machinery/computer/tguicard/proc/on_target_card_pressed(var/mob/user)
	if (src.modified_card)
		src.modified_card.update_name()
		if (src.eject)
			src.eject.set_loc(src.loc)
			user.put_in_hand_or_drop(src.eject)
			src.eject = null
		else
			src.modified_card.set_loc(src.loc)
			user.put_in_hand_or_drop(src.modified_card)
		src.modified_card = null
		clear_id_computer_process_data()
	else
		var/obj/item/I = usr.equipped()
		if (!istype(I,/obj/item/card/id))
			I = get_card_from(I)
		if (istype(I, /obj/item/card/id))
			usr.drop_item()
			if (src.eject)
				src.eject.set_loc(src)
			else
				I.set_loc(src)
			src.modified_card = I
			if(src.authentication_card)
				generate_id_computer_process_data_from_current_modified_card()

/obj/machinery/computer/tguicard/Topic(href, href_list)
	if(..())
		return
	src.add_dialog(usr)
	if (href_list["modified_card"])
		if (src.modified_card)
			src.modified_card.update_name()
			if (src.eject)
				src.eject.set_loc(src.loc)
				src.eject = null
			else
				src.modified_card.set_loc(src.loc)
			src.modified_card = null
		else
			var/obj/item/I = usr.equipped()
			if (!istype(I,/obj/item/card/id))
				I = get_card_from(I)
			if (istype(I, /obj/item/card/id))
				usr.drop_item()
				if (src.eject)
					src.eject.set_loc(src)
				else
					I.set_loc(src)
				src.modified_card = I
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/card/id))
					I = mag.holding
					mag.dropItem(0)
					if (src.eject)
						src.eject.set_loc(src)
					else
						I.set_loc(src)
					src.modified_card = I
			if (I && !src.modified_card)
				boutput(usr, "<span class='notice'>[I] won't fit in the modified_card slot.</span>")
		src.authenticated = 0
		src.scan_access = null
	if (href_list["authentication_card"])
		if (src.authentication_card)
			src.authentication_card.set_loc(src.loc)
			src.authentication_card = null
		else
			var/obj/item/I = usr.equipped()
			if (istype(I, /obj/item/card/id))
				usr.drop_item()
				I.set_loc(src)
				src.authentication_card = I
			else if (istype(I, /obj/item/magtractor))
				var/obj/item/magtractor/mag = I
				if (istype(mag.holding, /obj/item/card/id))
					I = mag.holding
					mag.dropItem(0)
					I.set_loc(src)
					src.modified_card = I
			else
				boutput(usr, "<span class='notice'>[I] won't fit in the authentication slot.</span>")
		src.authenticated = 0
		src.scan_access = null
	if (href_list["auth"])
		if ((!( src.authenticated ) && (src.authentication_card || ((issilicon(usr) || isAI(usr)) && !isghostdrone(usr))) && (src.modified_card || src.mode)))
			if (src.check_access(src.authentication_card))
				src.authenticated = 1
				src.scan_access = src.authentication_card.access
		else if ((!( src.authenticated ) && (issilicon(usr) || isAI(usr))) && (!src.modified_card))
			boutput(usr, "You can't modified_card an ID without an ID inserted to modified_card. Once one is in the modified_card slot on the computer, you can log in.")
	if(href_list["access"] && href_list["allowed"])
		if(src.authenticated)
			var/access_type = text2num(href_list["access"])
			var/access_allowed = text2num(href_list["allowed"])
			if(access_type in get_all_accesses())
				src.modified_card.access -= access_type
				if(access_allowed == 1)
					src.modified_card.access += access_type

	if (href_list["assign"])
		if (src.authenticated && src.modified_card)
			var/t1 = href_list["assign"]

			if(t1 == "Head of Security")
				return

			if (t1 == "Custom Assignment")
				t1 = input(usr, "Enter a custom job assignment.", "Assignment")
				t1 = strip_html(t1, 100, 1)
				playsound(src.loc, "keyboard", 50, 1, -15)
			else
				src.modified_card.access = get_access(t1)

			//Wire: This possibly happens after the input() above, so we re-do the initial checks
			if (src.authenticated && src.modified_card)
				src.modified_card.assignment = t1


	if (href_list["reg"])
		if (src.authenticated)
			var/t2 = src.modified_card

			var/t1 = input(usr, "What name?", "ID computer", null)
			t1 = strip_html(t1, 100, 1)

			if ((src.authenticated && src.modified_card == t2 && (in_interact_range(src, usr) || (issilicon(usr) || isAI(usr))) && istype(src.loc, /turf)))
				logTheThing("station", usr, null, "changes the registered name on the ID card from [src.modified_card.registered] to [t1]")
				src.modified_card.registered = t1

			playsound(src.loc, "keyboard", 50, 1, -15)

	if (href_list["pin"])
		if (src.authenticated)
			var/currentcard = src.modified_card

			var/newpin = input(usr, "Enter a new PIN.", "ID computer", 0) as null|num

			if ((src.authenticated && src.modified_card == currentcard && (in_interact_range(src, usr) || (istype(usr, /mob/living/silicon))) && istype(src.loc, /turf)))
				if(newpin < 1000)
					src.modified_card.pin = 1000
				else if(newpin > 9999)
					src.modified_card.pin = 9999
				else
					src.modified_card.pin = round(newpin)
				playsound(src.loc, "keyboard", 50, 1, -15)

	if (href_list["mode"])
		src.mode = text2num(href_list["mode"])
	if (href_list["print"])
		if (!( src.printing ))
			src.printing = 1
			sleep(5 SECONDS)
			var/obj/item/paper/P = unpool(/obj/item/paper)
			P.set_loc(src.loc)

			var/t1 = "<B>Crew Manifest:</B><BR>"
			for(var/datum/data/record/t in data_core.general)
				t1 += "<B>[t.fields["name"]]</B> - [t.fields["rank"]]<BR>"
			P.info = t1
			P.name = "paper- 'Crew Manifest'"
			src.printing = null
	if (href_list["mode"])
		src.authenticated = 0
		src.scan_access = null
		src.mode = text2num(href_list["mode"])
	if (href_list["colour"])
		if(src.modified_card.keep_icon == FALSE) // ids that are FALSE will update their icon if the job changes
			var/newcolour = href_list["colour"]
			if (newcolour == "none")
				src.modified_card.icon_state = "id"
			if (newcolour == "blue")
				src.modified_card.icon_state = "id_civ"
			if (newcolour == "yellow")
				src.modified_card.icon_state = "id_eng"
			if (newcolour == "purple")
				src.modified_card.icon_state = "id_res"
			if (newcolour == "red")
				src.modified_card.icon_state = "id_sec"
			if (newcolour == "green")
				src.modified_card.icon_state = "id_com"
	if (href_list["save"])
		var/slot = text2num(href_list["save"])
		if (!src.modified_card.assignment)
			src.custom_names[slot] = "Custom [slot]"
		else
			src.custom_names[slot] = src.modified_card.assignment
		src.custom_access_list[slot] = src.modified_card.access.Copy()
		src.custom_access_list[slot] &= allowed_access_list //prevent saving non-allowed accesses
	if (href_list["apply"])
		var/slot = text2num(href_list["apply"])
		src.modified_card.assignment = src.custom_names[slot]
		var/list/selected_access_list = src.custom_access_list[slot]
		src.modified_card.access = selected_access_list.Copy()
	if (src.modified_card)
		src.modified_card.name = "[src.modified_card.registered]'s ID Card ([src.modified_card.assignment])"
	if (src.eject)
		if (istype(src.eject,/obj/item/implantcase/access))
			var/obj/item/implantcase/access/A = src.eject
			var/obj/item/implant/access/I = A.imp
			var/iassign = "None"
			if (istype(I) && I.access)
				iassign = I.access.assignment
			A.name = "glass case - 'Electronic Access' ([iassign])"
		else if (istype(src.eject, /obj/item/implant/access))
			var/obj/item/implant/access/A = src.eject
			A.name = "electronic access implant ([A.access ? A.access.assignment : "None"])"
	src.updateUsrDialog()
	return

/obj/machinery/computer/tguicard/attackby(obj/item/I as obj, mob/user as mob)
	//grab the ID card from an access implant if this is one
	var/modify_only = 0
	if (!istype(I,/obj/item/card/id))
		I = get_card_from(I)
		modify_only = 1

	if (modify_only && src.eject && !src.authentication_card && src.modified_card)
		boutput(user, "<span class='notice'>[src.eject] will not work in the authentication card slot.</span>")
		return
	else if (istype(I, /obj/item/card/id))
		if (!src.authentication_card && !modify_only)
			boutput(user, "<span class='notice'>You insert [I] into the authentication card slot.</span>")
			user.drop_item()
			I.set_loc(src)
			src.authentication_card = I
			ui_interact(user)
		else if (!src.modified_card)
			boutput(user, "<span class='notice'>You insert [src.eject ? src.eject : I] into the target card slot.</span>")
			user.drop_item()
			if (src.eject)
				src.eject.set_loc(src)
			else
				I.set_loc(src)
			src.modified_card = I
			ui_interact(user)
		return
	else
		..()
	return

/obj/machinery/computer/tguicard/proc/get_card_from(obj/item/I as obj)
	if (istype(I, /obj/item/implantcase/access))
		src.eject = I
		var/obj/item/implantcase/access/A = I
		if (A.imp)
			return A.imp:access
	else if (istype(I, /obj/item/implant/access)) //accept access implant - get their ID
		src.eject = I
		return I:access
	return I
