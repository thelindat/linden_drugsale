Config = {}

Config.ChanceToRob = 5 			-- Chance for NPC to steal from player
Config.ChanceToFight = 10 		-- Chance for NPC to fight player
Config.ChanceToNotify = 20		-- Chance for NPC to notify police
Config.ChanceToSell = 50		-- Chance for NPC to buy drugs
Config.AttemptSaleTime = 1500	-- Time taken to attempt sale
Config.SaleConfirmTime = 400	-- Time allowed for player to confirm sale
Config.SaleTime = 3000			-- Time taken to complete the sale
Config.MaxSellAmount = 5		-- Maximum amount to be sold in single transaction
Config.MinimumPayment = 20		-- Minimum amount a drug can sell for (Used to generate random number)
Config.PaymentType = 'money' -- 'black_money'

-- Chance to sell specific item is increased in this location / radius
Config.SaleLocations = {
	Meth = {
		coords = vector3(277.556, -835.5033, 29.2124),
		radius = 20.0,
		increaseSaleOf = 'meth_baggie',
		increaseSaleChance = 60
	},
	-- Water = {
	-- 	coords = vector3(235.8593, -867.9692, 30.29089),
	-- 	radius = 20.0,
	-- 	increaseSaleOf = 'water',
	-- 	increaseSaleChance = 60
	-- }
}

-- [item name] price
Config.Drugs = {
	['meth_baggie'] = 25,
	['meth_baggief'] = 25,
	['cocaine_packaged'] = 30,
	['cocaine_packaged_f'] = 30,
	['joint'] = 15,
	['fentanyl'] = 45,
	['shrooms'] = 20,
	['3d'] = 75
}