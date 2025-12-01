return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`ComeGetYourDrugs` encountered an error loading the Darktide Mod Framework.")

		new_mod("ComeGetYourDrugs", {
			mod_script       = "ComeGetYourDrugs/scripts/mods/ComeGetYourDrugs/ComeGetYourDrugs",
			mod_data         = "ComeGetYourDrugs/scripts/mods/ComeGetYourDrugs/ComeGetYourDrugs_data",
			mod_localization = "ComeGetYourDrugs/scripts/mods/ComeGetYourDrugs/ComeGetYourDrugs_localization",
		})
	end,
	packages = {},
}
