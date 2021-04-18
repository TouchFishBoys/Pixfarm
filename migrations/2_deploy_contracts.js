const EtherplantFactory = artifacts.require("EtherplantFactory")

module.exports = function (deployer) {
    deployer.deploy(EtherplantFactory);
}
