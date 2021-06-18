const Money = artifacts.require("Money");
const Repository = artifacts.require("Repository");
const AuctionBase = artifacts.require("AuctionBase");
const FarmBase = artifacts.require("FarmBase");
const FarmMarket = artifacts.require("FarmMarket");
const MarketBase = artifacts.require("MarketBase");
const PixFarm = artifacts.require("PixFarm");
const ShopBase = artifacts.require("ShopBase");
const Auction = artifacts.require("Auction");

module.exports = function (deployer) {
  // deployer.deploy(Money);
  // deployer.deploy(Repository);
  // deployer.deploy(AuctionBase);

  // deployer.deploy(MarketBase);
  // deployer.deploy(PetBase);
  // deployer.deploy(PetFactory);
  // deployer.deploy(PetMarket);

  deployer.deploy(Auction);
  deployer.deploy(Repository).then(() => { return deployer.deploy(FarmBase, Repository.address) })
    .then(() => { return deployer.deploy(MarketBase, Repository.address) })
    .then(() => { return deployer.deploy(FarmMarket, Repository.address) })
    .then(() => { return deployer.deploy(PixFarm, Repository.address, Auction.address) });


  // deployer.deploy(PixPet);
};
