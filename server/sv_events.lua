RPC.register("np-beekeeping:getBeehives", function(pSource)
    local hives = getBeehives()
    TriggerClientEvent("np-beekeeping:trigger_zone", pSource, 1, hives)
end)

RPC.register("np-beekeeping:installHive", function(pSource, pCoords, pHeading)
    local coords = pCoords.param
    local heading = pHeading.param

    local result = Await(SQL.execute("INSERT INTO _beehive (x, y, z, heading, has_queen, timestamp) VALUES (@x, @y, @z, @heading, @has_queen, @timestamp)", {
        ["@x"] = coords.x,
        ["@y"] = coords.y,
        ["@z"] = coords.z,
        ["@heading"] = heading,
        ["@has_queen"] = false,
        ["@timestamp"] = os.time()
    }))
    
    if not result then return end

    local hive = getBeehive(result.insertId)

    TriggerClientEvent("np-beekeeping:trigger_zone", -1, 2, hive)
end)

RPC.register("np-beekeeping:addQueen", function(pSource, pId)
    local id = pId.param

    local result = Await(SQL.execute("UPDATE _beehive SET has_queen = @has_queen WHERE id = @id", {
        ["@has_queen"] = true,
        ["@id"] = id
    }))

    if not result then return end

    local hive = getBeehive(id)
    if not hive then return end

    TriggerClientEvent("np-beekeeping:trigger_zone", -1, 3, hive)
end)

RPC.register("np-beekeeping:removeHive", function(pSource, pData, pReadyPercent)
    local data = pData.param
    local readyPercent = pReadyPercent.param

    local result = Await(SQL.execute("DELETE FROM _beehive WHERE id = @id", {
        ["@id"] = data.id
    }))

    if not result then return end

    TriggerClientEvent("np-beekeeping:trigger_zone", -1, 4, data)
end)

RPC.register("np-beekeeping:harvestHive", function(pSource, pId) -- TODO; Implement
    local id = pId.param

    local result = Await(SQL.execute("UPDATE _beehive SET timestamp = @timestamp, last_harvest = @last_harvest WHERE id = @id", {
        ["@timestamp"] = os.time(),
        ["@last_harvest"] = os.time(),
        ["@id"] = id
    }))

    if not result then return end

    local hive = getBeehive(id)
    if not hive then return end

    if hive.has_queen then
        if HiveConfig.RemoveHiveWhenQueen then
            local result = Await(SQL.execute("DELETE FROM _beehive WHERE id = @id", {
                ["@id"] = id
            }))

            if not result then return end

            TriggerClientEvent("np-beekeeping:trigger_zone", -1, 4, hive)
        end
    else
        local chance = math.random(0, 100)
        if chance <= HiveConfig.QueenChance then
            TriggerClientEvent("player:receiveItem", pSource, "beequeen", 1)
        end

        TriggerClientEvent("np-beekeeping:trigger_zone", -1, 3, hive)
    end

    TriggerClientEvent("player:receiveItem", pSource, "beeswax", 1)
    TriggerClientEvent("player:receiveItem", pSource, "honey", 3)
end)