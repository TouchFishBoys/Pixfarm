const PixFarm = artifacts.require("PixFarm");
const FarmMarket = artifacts.require("FarmMarket");

contract("buySeedTest", async accounts => {
  const [address1, address2] = accounts
  it("1)should register success", async() => {
    let instance = PixFarm.deployed();
    await instance.register("233").send({from:address1})
  })

  it("2)should buySeed success", async() => {
    let instance = FarmMarket.deployed()
    await instance.buySeed(0,0,1).send({from:address2})
  })
})
