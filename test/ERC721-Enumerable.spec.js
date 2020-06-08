const BigNumber = require("bignumber.js");
const truffleAssert = require("truffle-assertions");
const ERC721 = artifacts.require("ERC721");

contract("ERC721 Enumerable", (accounts) => {
    const addressZero = "0x0000000000000000000000000000000000000000";
    const creator = accounts[0];
    const user01 = accounts[1];
    let likenInstance;

    // Deploy a new contract before each test to prevent one test from interfering with the other
    beforeEach(async () => {
        likenInstance = await ERC721.new("Liken", "LKN");
    });

    it('returns correct totalSupply', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        const tx2 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(2).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 2 failed`);

        count = await likenInstance.totalSupply();
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current total supply should be 2");
    });

    it('returns correct token by index', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        let tokenId = await likenInstance.tokenByIndex(0);
        tokenId = web3.utils.toBN(tokenId);
        assert.equal(new BigNumber(tokenId), 1, "Token should be 1 for index 0");

        const tx2 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(2).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 2 failed`);

        tokenId = await likenInstance.tokenByIndex(1);
        tokenId = web3.utils.toBN(tokenId);
        assert.equal(new BigNumber(tokenId), 2, "Token should be 2 for index 1");
    });
});