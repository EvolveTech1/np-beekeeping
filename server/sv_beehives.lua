function getBeehives()
    local beehives = Await(SQL.execute("SELECT * FROM _beehive"))
    local hives = {}

    for i = 1, #beehives do
        table.insert(hives, {
            id = beehives[tonumber(i)].id,
            coords = vector3(beehives[tonumber(i)].x, beehives[tonumber(i)].y, beehives[tonumber(i)].z),
            heading = beehives[tonumber(i)].heading,
            has_queen = beehives[tonumber(i)].has_queen,
            timestamp = beehives[tonumber(i)].timestamp,
            last_harvest = beehives[tonumber(i)].last_harvest or 0
        })
    end

    print("Beehives loaded: " .. #hives)

    return hives
end

function getBeehive(pId)
    local beehive = Await(SQL.execute("SELECT * FROM _beehive WHERE id = @id", {
        ["@id"] = pId
    }))

    if not beehive[1] then return false end

    return {
        id = beehive[1].id,
        coords = vector3(beehive[1].x, beehive[1].y, beehive[1].z),
        heading = beehive[1].heading,
        has_queen = beehive[1].has_queen,
        timestamp = beehive[1].timestamp,
        last_harvest = beehive[1].last_harvest or 0
    }
end

Citizen.CreateThread(function()
    -- Trigger thread
    while true do
        Citizen.Wait(HiveConfig.UpdateTimer)
        local hives = getBeehives()
        TriggerClientEvent("np-beekeeping:trigger_zone", -1, 1, hives)
    end
end)