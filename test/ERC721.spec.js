const BigNumber = require("bignumber.js");
const truffleAssert = require("truffle-assertions");
const ERC721 = artifacts.require("ERC721");

contract("ERC721", (accounts) => {
    const creator = accounts[0];
    const user01 = accounts[1];
    const user02 = accounts[2];
    let likenInstance;

    // Deploy a new contract before each test to prevent one test from interfering with the other
    beforeEach(async () => {
        likenInstance = await ERC721.new("Liken", "LKN");
    });

    it('returns correct balanceOf', async () => {
        let count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 0, "Initial balance should be 0");

        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 1, "Current balance should be 1");

        const tx2 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(2).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 2 failed`);

        count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 2, "Current balance should be 2");
    });

    it('returns correct ownerOf', async () => {
        await likenInstance.mint(user01, { from: creator });
        count = await likenInstance.balanceOf(user01);
        assert.equal(count, 1, "Current balance should be 1");

        let ownerAddress = await likenInstance.ownerOf(1);
        assert.equal(ownerAddress, user01, `Owner should be ${user01}`);
    });

    it('approve spender', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        const tx2 = await likenInstance.approve(user02, 1, { from: user01 });

        truffleAssert.eventEmitted(tx2, "Approval", (obj) => {
            return (
                obj._owner === user01 &&
                obj._approved === user02 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Approval event to approve token 1 from ${user01} to ${user02} failed`);

        const approvedSpenderAddress = await likenInstance.getApproved(1);
        assert.equal(approvedSpenderAddress, user02, `Approved address should be ${user02}`);
    });

    it('approve operator', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        const tx2 = await likenInstance.setApprovalForAll(user02, true, { from: user01 });

        truffleAssert.eventEmitted(tx2, "ApprovalForAll", (obj) => {
            return (
                obj._owner === user01 &&
                obj._operator === user02 &&
                obj._approved === true
            );
        }, `Approval for all event of setApprovalForAll from ${user01} to ${user02} failed`);

        const isApproved = await likenInstance.isApprovedForAll(user01, user02);
        assert.equal(isApproved, true, `${user01} should have approved ${user02} as operator`);
    });

    it('safe transfer from one account to another', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        let ownerAddress = await likenInstance.ownerOf(1);
        assert.equal(ownerAddress, user01, `Owner should be ${user01}`);

        const tx2 = await likenInstance.safeTransferFrom(user01, user02, 1, { from: user01 });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === user01 &&
                obj._to === user02 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of transferFrom token 1 failed`);

        const tx3 = await likenInstance.safeTransferFrom(user02, user01, 1, '0x123456');

        truffleAssert.eventEmitted(tx3, "Transfer", (obj) => {
            return (
                obj._from === user02 &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of transferFrom token 1 failed`);
    });

    it('transfers from one account to another', async () => {
        const tx1 = await likenInstance.mint(user01, { from: creator });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === creator &&
                obj._to === user01 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of mint token 1 failed`);

        let ownerAddress = await likenInstance.ownerOf(1);
        assert.equal(ownerAddress, user01, `Owner should be ${user01}`);

        const tx2 = await likenInstance.transferFrom(user01, user02, 1, { from: user01 });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === user01 &&
                obj._to === user02 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Transfer event of transferFrom token 1 failed`);

        ownerAddress = await likenInstance.ownerOf(1);
        assert.equal(ownerAddress, user02, `Owner should be ${user02}`);

        let count = await likenInstance.balanceOf(user01);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 0, `Balance of ${user01} should be 0`);

        count = await likenInstance.balanceOf(user02);
        count = web3.utils.toBN(count);
        assert.equal(new BigNumber(count), 1, `Balance of ${user02} should be 1`);
    });

    it('supports interfaces ERC165, ERC721, ERC721-metadata, ERC721-enumerable', async () => {
        const supports165 = await likenInstance.supportsInterface('0x01ffc9a7', { from: creator });
        assert.equal(supports165, true, 'It does not supports ERC165 interface');

        const supports721 = await likenInstance.supportsInterface('0x80ac58cd', { from: creator });
        assert.equal(supports721, true, 'It does not supports ERC721 interface');

        const supports721_meta = await likenInstance.supportsInterface('0x5b5e139f', { from: creator });
        assert.equal(supports721_meta, true, 'It does not supports ERC721-metadata interface');

        const supports721_enum = await likenInstance.supportsInterface('0x780e9d63', { from: creator });
        assert.equal(supports721_enum, true, 'It does not supports ERC721-enumerable interface');
    });
});