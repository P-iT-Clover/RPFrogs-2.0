--[[

    Functions

]]

function IsNearPlayer(player)
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    local ply2 = GetPlayerPed(GetPlayerFromServerId(player))
    local ply2Coords = GetEntityCoords(ply2, 0)
    local distance = Vdist2(plyCoords, ply2Coords)
    if(distance <= 5) then
        return true
    end
end

--[[

    Events

]]

AddEventHandler("np-financials:giveCash", function(pParams, pEntity, pContext)
    local input = exports["np-input"]:showInput({
		{
            icon = "hand-holding-usd",
            label = "Give Cash",
            name = "amount",
        },
	})

	if input["amount"] then
		local amount = tonumber(input["amount"])
		if not amount or amount < 1 then
			TriggerEvent("DoLongHudText", "invalid number", 2)
			return
		end

        if not IsNearPlayer(pEntity) then
            TriggerEvent("DoLongHudText", "You are not close to the player!", 2)
            return
        end

        local _cash = RPC.execute("np-financials:getCash")
        if not _cash or _cash < amount then
            TriggerEvent("DoLongHudText", "You don't have that amount with you", 2)
            return
        end

        TriggerEvent("animation:PlayAnimation","id")
		TriggerServerEvent("np-financials:giveCash", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), amount)
	end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local group = { 1 }

    local data = {
        {
            id = "give_cash",
            label = "Give Cash",
            icon = "hand-holding-usd",
            event = "np-financials:giveCash",
            parameters = {},
        }
    }

    local options = {
        distance = { radius = 1.5 },
        isEnabled = function(pEntity, pContext)
            return pContext.flags["isPlayer"] and pContext.distance <= 1.2
        end
    }

    exports["np-eye"]:AddPeekEntryByEntityType(group, data, options)
end)