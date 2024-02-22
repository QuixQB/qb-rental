local QBCore = exports["qb-core"]:GetCoreObject()

RegisterNetEvent('qb-rental:sv:rentVehicle', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    if data.paymentmethod == "cash" then
        if Player.Functions.GetMoney(data.paymentmethod) >= data.payment then
            Player.Functions.RemoveMoney('cash', data.payment, 'cash transfer')
            TriggerClientEvent('qb-rental:cl:spawnVehicle', src, data.carname, data.renttime)
            TriggerClientEvent('QBCore:Notify', src,'Purchase transaction successful', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src,'You dont have enough funds', 'error')

        end
    else        
        if Player.PlayerData.money.bank >= data.payment then
            Player.Functions.RemoveMoney(data.paymentmethod, data.payment)
            TriggerClientEvent('qb-rental:cl:spawnVehicle', src, data.carname, data.renttime)
            TriggerClientEvent('QBCore:Notify', src,'Purchase transaction successful', 'success')
        else
            TriggerClientEvent('QBCore:Notify', src,'You dont have enough funds', 'error')
        end
    end

end)

RegisterNetEvent('qb-rental:sv:updatesql', function(plate,vehicle,time)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cid = Player.PlayerData.citizenid
    local timeinday = time * 86400
    local endtime = tonumber(os.time() + timeinday)
    local timeTable = os.date('*t', endtime)
    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        cid,
        vehicle,
        GetHashKey(vehicle),
        '{}',
        plate,
        'apartments',
        0
    })
    MySQL.insert('INSERT INTO rentvehs (citizenid, vehicle, plate, time) VALUES (?, ?, ?, ?)', {cid, vehicle, plate, endtime})
    TriggerClientEvent('QBCore:Notify', src, "you successfly rent this car until "..timeTable['day'].." / "..timeTable['month'].." / "..timeTable['year'], "success",10000)   
end)

RegisterNetEvent('qb-rental:sv:checktime', function()
    local sqlresult = MySQL.Sync.fetchAll('SELECT citizenid, vehicle, plate, time FROM rentvehs', {})
    local currentTime = os.time()

    for _, row in pairs(sqlresult) do
        local citizenid = tonumber(row.citizenid)
        local timeInDB = tonumber(row.time)

        if currentTime > timeInDB then
            MySQL.Sync.execute('DELETE FROM rentvehs WHERE citizenid = ? AND vehicle = ? AND plate = ?', {row.citizenid, row.vehicle, row.plate})
            MySQL.Sync.execute('DELETE FROM player_vehicles WHERE citizenid = ? AND vehicle = ? AND plate = ?', {row.citizenid, row.vehicle, row.plate})
        end
    end
end)
