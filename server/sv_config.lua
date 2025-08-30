SV_Config = {}
--
SV_Config.Debug = false
--
SV_Config.AutoEnable = true                                    -- Auto enable when a player joins the server.
SV_Config.UseMPH = false                                       -- Use MPH, default false for kph, when true it uses kph
SV_Config.Mph = "KPH"                                          -- Default KPH, you can use KPH or MPH
SV_Config.SpeedMultiplier = SV_Config.UseMPH and 2.23694 or 3.6
SV_Config.InterActButton = 25                                  -- Right mouse butten
SV_Config.InterActDisplay = "RMB"                              -- Display text
SV_Config.WantedChange = 15                                    -- Default 10, the change that a vehicle is wanted
SV_Config.Speed = 70.0                                         -- Default 70, vehicle speed of flee driver
SV_Config.DriveStyle = 537133628                               -- Default 537133628, suspect drive style
SV_Config.UseCarThieve = true                                  -- default true, use car thieves this allows npc peds to steel vehicles.
SV_Config.ChangeToSteelVehicle = 25                            -- Defailt 25, Bigger value the more change the vehicle gets steelt by a npc.
SV_Config.MinSteelDistance = 50                                -- Default 50, The min distance before a npc steel a vehicle.
SV_Config.ChangeToCrash = 15                                   -- Defailt 15, The bigger value the more change the vehicle will flipover and crash.
SV_Config.MinDistance = 2000.0                                 -- Dfault 2000.0, The min Distance to lose suspect
SV_Config.MaxAngleForChangeToCrash = 15                        -- Defailt 15.
SV_Config.MinDriveSpeedChangeToCrash = 70.0                    -- Default 70, The min speed before a vehicle can flipover.
SV_Config.ReduseVehicleHealthWhenCrashed = 150.0               -- default 150, This will be -150.0 from the curent health.
SV_Config.Deliverpoint = vector3(437.3597, -978.7448, 30.6896) -- Suspect delivery point
SV_Config.Startpoint = vector3(442.2202, -1015.6671, 28.6577)  -- Duty Start point
SV_Config.HospitalPoint = vector3(303.5788, -597.8091, 43.2918)-- Hospital delivery Point

-- Rewards
SV_Config.Reward = 1000
SV_Config.Punishment = 1000

-- when a ped stands stil and you block it, this is the tameit will take before the ped get out the vehicle to get arrested.
SV_Config.MinSecsBeforeArrestTimer = 60 -- 60 = 1 min

--------------------------------------------------------
-- Points to earn ranks
-- do not go to the rank boss. 
SV_Config.Points = {
    [0] = {             -- current job rank
        earnrank = 1,   -- new job ranks
        minPoints = 50, -- min points to get new rank
    },
    [1] = {
        earnrank = 2,
        minPoints = 100,
    },
    [2] = {
        earnrank = 3,
        minPoints = 200,
    },
}
--------------------------------------------------------
-- Cooldown, make sure you add at least more than 300 secs
-- (5 * 1000) = 5 sec
-- (300 * 1000) = 5 min
-- (3600 * 1000) = 1 hour
SV_Config.CoolDownTime = 300
--------------------------------------------------------

-- Ignore classes to check
SV_Config.IgnoreClasses = {
    [0] = false, -- Compacts  
    [1] = false, -- Sedans  
    [2] = false, -- SUVs  
    [3] = false, -- Coupes  
    [4] = false, -- Muscle  
    [5] = false, -- Sports Classics  
    [6] = false, -- Sports  
    [7] = false, -- Super  
    [8] = true, -- Motorcycles  
    [9] = false, -- Off-road  
    [10] = true, -- Industrial  
    [11] = true, -- Utility  
    [12] = false, -- Vans  
    [13] = true, -- Cycles  
    [14] = true, -- Boats  
    [15] = true, -- Helicopters  
    [16] = true, -- Planes  
    [17] = true, -- Service  
    [18] = true, -- Emergency  
    [19] = true, -- Military  
    [20] = true, -- Commercial  
    [21] = true, -- Trains  
    [22] = false, -- Open Wheel
}

SV_Config.PedModels = PedModels
SV_Config.Vehicles = Vehicles