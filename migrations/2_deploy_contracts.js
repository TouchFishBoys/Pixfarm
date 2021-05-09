const Money = artifacts.require("Money")
const RepositoryBase = artifacts.require("RepositoryBase")
const AuctionBase = artifacts.require("AuctionBase")
const FarmBase = artifacts.require("FarmBase")
const FarmFactory = artifacts.require("FarmFactory")
const FarmMarket = artifacts.require("FarmMarket")
const MarketBase = artifacts.require("MarketBase")
const PetBase = artifacts.require("PetBase")
const PetFactory = artifacts.require("PetFactory")
const PetMarket = artifacts.require("PetMarket")
const PixFarm = artifacts.require("PixFarm")
const PixPet = artifacts.require("PixPet")
const ShopBase = artifacts.require("ShopBase")
const Pixfarmon = artifacts.require("Pixfarmon")
const Auction = artifacts.require("Auction")
module.exports = function (deployer) {
    // deployer.deploy(Money);
    // deployer.deploy(RepositoryBase);
    // deployer.deploy(AuctionBase);
    deployer.deploy(FarmBase);
    deployer.deploy(FarmFactory).then(function () {
        return deployer.deploy(FarmMarket, FarmFactory.address).then(function () {
            return deployer.deploy(PixFarm, FarmMarket.address, FarmFactory.address);
        });
    });

    // deployer.deploy(MarketBase);
    // deployer.deploy(PetBase);
    // deployer.deploy(PetFactory);
    //deployer.deploy(PetMarket);

    deployer.deploy(Auction);
    deployer.deploy(Money);
    deployer.deploy(RepositoryBase).then(function () {
        return deployer.deploy(Pixfarmon, Auction.address, Money.address, RepositoryBase.address, FarmMarket.address, FarmBase.address);
    });
    //deployer.deploy(PixPet);

}
