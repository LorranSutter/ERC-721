const Liken = artifacts.require("Liken");

module.exports = function (deployer) {
    deployer.deploy(Liken, "Liken", "LKN");
};