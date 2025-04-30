local Translations = {
    ['press_to_start'] = "Press [~g~%{interact}~w~] to start the job",
    ['press_to_stop'] = "Press [~g~%{interact}~w~] to stop the job",
    ['press_to_deliver'] = "Press [~g~%{interact}~w~] to arrest the citizen",
    ['press_pullover'] = "Press [~g~%{interact}~w~] to pullover",
    ['press_handcuff'] = "Press [~g~%{interact}~w~] to handcuff",
    ['press_uncuff'] = "Press [~g~%{interact}~w~] to uncuff",
    ['press_set_in_vehicle'] = "Press [~g~%{interact}~w~] set thief in vehicle",
    ['press_get_out_vehicle'] = "Press [~g~%{interact}~w~] get thief out vehicle",
    ['press_to_chase_plate'] = "Press [~g~%{interact}~w~] to fallow",
    ['press_to_recover_suspect'] = "Press [~g~%{interact}~w~] to recover the suspect ",
    ['plate'] = "Plate ",
    ['speed'] = "Speed ",
    ['car_thief_plate'] = "Car-Thief",
    ['job_enable'] = "Job ~g~Enable~w~!",
    ['job_disable'] = "Job ~g~Disable~w~!",
    ['job_done'] = "~g~Well done, the suspect has been arrested~w~!",
    ['job_failed'] = "Why are you bringing an innocent person?",
    ['wanted'] = "~r~Wanted Vehicle~s~",
    ['suspect_vehicle'] = "Suspect Vehicle",
    ['suspect_has_damage'] = "The suspect suffered injuries from the car accident, take the suspect to the hospital...",
    ['suspect_has_recovered'] = "The suspect has recovered",
}

if GetConvar('qb_locale', 'en') == 'en' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end