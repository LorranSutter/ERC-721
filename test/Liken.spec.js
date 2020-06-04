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
    const token01 = 1;
    const token02 = 2;
    let likenInstance;

    // Deploy a new contract before each test to prevent one test from interfering with the other
    beforeEach(async () => {
        likenInstance = await Liken.new("Liken", "LKN");
    });

    it('ensures correct name and symbol', async () => {
        const name = await likenInstance.name.call();
        const symbol = await likenInstance.symbol.call();
        assert.equal(name, tokenNameExpected, "Token is not as expected");
        assert.equal(
            symbol,
            tokenSymbolExpected,
            "Token symbol is not as expected"
        );
    })

    it.only('returns correct balanceOf', async () => {
        let count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 0, "Initial balance should be 0");

        const tx = await likenInstance.mint(user01, token01, { from: creator });

        truffleAssert.eventEmitted(tx, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(token01).isEqualTo(obj._tokenId)
            );
        }, `Transfer event from mint token ${token01} failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 1, "Current balance should be 1");

        await likenInstance.mint(user01, token02, { from: creator });

        truffleAssert.eventEmitted(tx, "Transfer", (obj) => {
            return (
                obj._from === addressZero &&
                obj._to === user01 &&
                new BigNumber(token02).isEqualTo(obj._tokenId)
            );
        }, `Transfer event from mint token ${token02} failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current balance should be 2");

        count = await likenInstance.totalSupply();
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current total supply should be 2");
    });

    // it('returns correct balanceOf', async () => {
    //     let count = await likenInstance.balanceOf(user01);
    //     assert.equal(count, 0);

    //     await likenInstance.mint(user01, token01, { from: creator });
    //     count = await likenInstance.balanceOf(user01);
    //     assert.equal(count, 1);

    //     await likenInstance.mint(user01, token02, { from: creator });
    //     count = await likenInstance.balanceOf(user01);
    //     assert.equal(count, 2);

    //     count = await likenInstance.totalSupply();
    //     assert.equal(count, 2);
    // });

    it('returns correct ownerOf', async () => {
        await likenInstance.mint(user01, token01, { from: creator });
        count = await likenInstance.balanceOf(user01);
        assert.equal(count, 1, "Current balance should be 1");

        let ownerAddress = await likenInstance.ownerOf(token01);
        assert.equal(ownerAddress, user01, `Owner should be ${user01}`)
    });
});