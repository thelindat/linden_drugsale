Config = {}

Config.ChanceToRob = 5 			-- Chance for NPC to steal from player
Config.ChanceToFight = 10 		-- Chance for NPC to fight player
Config.ChanceToNotify = 15		-- Chance for NPC to notify police
Config.ChanceToSell = 50		-- Chance for NPC to buy drugs
Config.AttemptSaleTime = 1500	-- Time taken to attempt sale
Config.SaleConfirmTime = 400	-- Time allowed for player to confirm sale
Config.SaleTime = 3000			-- Time taken to complete the sale
Config.MaxSellAmount = 5		-- Maximum amount to be sold in single transaction
Config.MinimumPayment = 20		-- Minimum amount a drug can sell for (Used to generate random number)
Config.PaymentType = 'money' -- 'black_money'
Config.Debug = false

-- Chance to sell specific item is increased in this location / radius
Config.SaleLocations = {
	 ['StabCity'] = {
	 	coords = vector3(66.00, 3697.29, 46.26),
	 	radius = 75.0,
	 	increaseSaleOf = 'meth_baggie',
	 	increaseSaleChance = 15,
		increaseEarnings = 1.10,

	 	increaseFightChance = 15,
	 	increaseRobChance = 10,
	 	increaseNotifyChance = 0,
	 },

	 ['VinewoodStrip'] = {
	 	coords = vector3(295.24, 181.20, 104.23),
	 	radius = 180.0,
	 	increaseSaleOf = 'cocaine_packaged',
	 	increaseSaleChance = 5,
	 	increaseEarnings = 1.35,

	 	increaseFightChance = 0,
	 	increaseRobChance = 5,
	 	increaseNotifyChance = 10,
	},

	['AltruistShrooms'] = {
	  	coords = vector3(-1105.2329, 4919.7758, 217.48),
	  	radius = 70.0,
	  	increaseSaleOf = 'shrooms',
	  	increaseSaleChance = 35,
	  	increaseEarnings = 1.40,

		increaseFightChance = 20,
		increaseRobChance = 10,
		increaseNotifyChance = -20,
	},

	['Grove'] = {
		coords = vector3(279.416, -1853.3872, 26.86),
		radius = 260.0,
	 	increaseSaleOf = 'joint',
	 	increaseSaleChance = 15,
	 	increaseEarnings = 1.20,

		increaseFightChance = 10,
		increaseRobChance = 5,
		increaseNotifyChance = 10,
	},

	['MirrorPark'] = {
		coords = vector3(1132.242, -550.936, 60.2357),
		radius = 285.0,
	 	increaseSaleOf = 'xtc_baggie',
	 	increaseSaleChance = 15,
	 	increaseEarnings = 1.25,

		increaseFightChance = 0,
		increaseRobChance = 0,
		increaseNotifyChance = 20,
	}

}

<<<<<<< Updated upstream
-- Max Sell Price
=======
-- Recommended Sell Price
>>>>>>> Stashed changes
Config.Drugs = {
	['meth_baggie'] = 40,
	['meth_baggief'] = 40,
	['cocaine_packaged'] = 35,
	['cocaine_packaged_f'] = 35,
<<<<<<< Updated upstream
	['joint'] = 15,
	['fentanyl'] = 45,
	['shrooms'] = 20,
	['3d'] = 75
=======
	['joint'] = 20,
	['fentanyl'] = 45,
	['shrooms'] = 25,
	['3d'] = 75,
	['xtc_baggie'] = 50
>>>>>>> Stashed changes
}