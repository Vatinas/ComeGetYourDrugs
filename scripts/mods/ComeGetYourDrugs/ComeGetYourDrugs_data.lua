local mod = get_mod("ComeGetYourDrugs")

local widgets = {
	{
		setting_id      = "place_marker_keybind",
  		type            = "keybind",
		default_value = {},
		--keybind_global = false,
  		keybind_trigger = "pressed",
  		keybind_type    = "function_call",
  		function_name   = "place_marker_on_player",
	}
}

return {
	name = "ComeGetYourDrugs",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
        widgets = widgets
    }
}
