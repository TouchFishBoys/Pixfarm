const Money = artifacts.require("Money");
const Repository = artifacts.require("Repository");
const AuctionBase = artifacts.require("AuctionBase");
const FarmBase = artifacts.require("FarmBase");
const FarmFactory = artifacts.require("FarmFactory");
const FarmMarket = artifacts.require("FarmMarket");
const MarketBase = artifacts.require("MarketBase");
const PetBase = artifacts.require("PetBase");
const PetFactory = artifacts.require("PetFactory");
const PetMarket = artifacts.require("PetMarket");
const PixFarm = artifacts.require("PixFarm");
const PixPet = artifacts.require("PixPet");
const ShopBase = artifacts.require("ShopBase");
const Pixfarmon = artifacts.require("Pixfarmon");
const Auction = artifacts.require("Auction");

module.exports = function(deployer) {
  // deployer.deploy(Money);
  // deployer.deploy(Repository);
  // deployer.deploy(AuctionBase);

  // deployer.deploy(MarketBase);
  // deployer.deploy(PetBase);
  // deployer.deploy(PetFactory);
  // deployer.deploy(PetMarket);

  deployer.deploy(Auction);
  deployer
    .deploy(Repository)
    .then(() => {
      return deployer.deploy(FarmFactory, Repository.address);
    })
    .then(() => {
      return deployer.deploy(
        FarmMarket,
        FarmFactory.address,
        Repository.address
      );
    })
    .then(() => {
      return deployer.deploy(
        PixFarm,
        FarmMarket.address,
        FarmFactory.address,
        Repository.address
      );
    });

  // deployer.deploy(PixPet);
};
