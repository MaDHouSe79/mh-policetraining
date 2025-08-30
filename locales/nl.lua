local Translations = {
    ['press_to_start'] = "Druk op [~g~%{interact}~w~] om de job te starten",
    ['press_to_stop'] = "Druk op [~g~%{interact}~w~] om de job te stoppen",
    ['press_to_deliver'] = "Druk op [~g~%{interact}~w~] om de buger in te arresteren",
    ['press_pullover'] = "Druk op [~g~%{interact}~w~] om te stoppen",
    ['press_handcuff'] = "Druk op [~g~%{interact}~w~] om de handboeien om te doen",
    ['press_uncuff'] = "Druk op [~g~%{interact}~w~] om de handboeien af te doen",
    ['press_set_in_vehicle'] = "Druk op [~g~%{interact}~w~] om de dief in het voertuig te zetten",
    ['press_get_out_vehicle'] = "Druk op [~g~%{interact}~w~] om de dief uit het voertuig te halen",
    ['press_to_chase_plate'] = "Druk op [~g~%{interact}~w~] om te volgen ",
    ['press_to_recover_suspect'] = "Druk op [~g~%{interact}~w~] om de verdachten te helpen ",
    ['plate'] = "Kenteken ",
    ['speed'] = "Snelheid ",
    ['car_thief_plate'] = "Auto-Dief",
    ['job_enable'] = "Job ~g~Inschakelen~w~!",
    ['job_disable'] = "Job ~g~Uitschakelen~w~!",
    ['job_done'] = "~g~Goed gedaan, de verdachte is aangehouden~w~!",
    ['job_failed'] = "Waarom breng je een onschuldig persoon mee?",
    ['wanted'] = "~r~Gezocht Voertuig~s~",
    ['suspect_vehicle'] = "Verdacht Voertuig",
    ['suspect_has_damage'] = "De verdachte heeft letsel opgelopen bij het auto-ongeluk, brenng de verdachte naar het ziekenhuis...",
    ['suspect_has_recovered'] = "De verdachte is genezen",
}

if GetConvar('qb_locale', 'en') == 'nl' then
    Lang = Locale:new({phrases = Translations, warnOnMissing = true, fallbackLang = Lang})
end