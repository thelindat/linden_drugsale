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
		increaseSaleChance = 60,
		increaseEarnings = 1.40
	},

	Coke = {
		coords = vector3(277.556, -835.5033, 29.2124),
		radius = 20.0,
		increaseSaleOf = 'cocaine_packaged',
		increaseSaleChance = 60,
		increaseEarnings = 1.40
	},

	AltruistShrooms = {
		coords = vector3(277.556, -835.5033, 29.2124),
		radius = 20.0,
		increaseSaleOf = 'shrooms',
		increaseSaleChance = 70,
		increaseFightChange = 30,
		increaseChangeToRob = 40,
		increaseChanceToNotify = 0,
		increaseEarnings = 1.40
	},

}

-- [item name] Recommended Price + 20
-- Max Sell Price
Config.Drugs = {
	['meth_baggie'] = {name = 'meth_baggie', price = 60},
	['meth_baggief'] = {name = "meth_baggief", price = 60},
	['cocaine_packaged'] = {name = "cocaine_packaged", price = 50},
	['cocaine_packaged_f'] = {name = "cocaine_packaged_f", price = 50},
	['joint'] = {name = "joint", price = 35},
	['fentanyl'] = {name = "fentanyl", price = 65},
	['shrooms'] = {name = "shrooms", price = 40},
	['3d'] = {name = "3d", price = 95}
}