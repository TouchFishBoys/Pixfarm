const EtherplantFactory = artifacts.require("EtherplantFactory")

contract("Plant factory test", async accounts => {
    it("should dna generated correctly", async () => {
        let testedDna = 197346
        let instance = await EtherplantFactory.deployed()
        let properties = await instance.getPlantProperties(testedDna)

        let def = properties.def;
        let spd = properties.spd;
        let hp = properties.hp;
        let atk = properties.atk;
        let specie = properties.specie;

        let dna = await instance.getDNA(specie, hp, atk, def, spd);

        assert.equal(dna.toNumber(), testedDna);
    })
})
