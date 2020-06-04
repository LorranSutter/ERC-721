const BigNumber = require("bignumber.js");
const truffleAssert = require("truffle-assertions");
const Liken = artifacts.require("Liken");

contract("Liken", (accounts) => {
    const tokenNameExpected = "Liken";
    const tokenSymbolExpected = "LKN";
    const tokenSupplyExpected = web3.utils.toBN(10000000000000000000);
    const addressZero = "0x0000000000000000000000000000000000000000";
    const creator = accounts[0];
    const user01 = accounts[1];
    const user01Amount = web3.utils.toBN(500000000000000000);
    const spender = accounts[2];
    const spenderAmount = web3.utils.toBN(300000000000000000);
    const user02 = accounts[3];
    let likenInstance;

    // Deploy a new contract before each test to prevent one test from interfering with the other
    beforeEach(async () => {
        likenInstance = await Liken.new("Liken", "LKN");
    });

    it('returns correct name and symbol', async () => {
        const name = await likenInstance.name.call();
        const symbol = await likenInstance.symbol.call();
        assert.equal(name, tokenNameExpected, "Token is not as expected");
        assert.equal(
            symbol,
            tokenSymbolExpected,
            "Token symbol is not as expected"
        );
    })

    it('returns correct balanceOf', async () => {
        let count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 0, "Initial balance should be 0");

        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event to mint token 1 failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 1, "Current balance should be 1");

        const tx2 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(2).isEqualTo(obj._tokenId)
            );
        }, `Transfer event to mint token 2 failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current balance should be 2");

        count = await likenInstance.totalSupply();
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current total supply should be 2");
    });

    it('returns correct ownerOf', async () => {
        await likenInstance.mint(user01, { from: creator });
        count = await likenInstance.balanceOf(user01);
        assert.equal(count, 1, "Current balance should be 1");

        let ownerAddress = await likenInstance.ownerOf(1);
        assert.equal(ownerAddress, user01, `Owner should be ${user01}`)
    });
});