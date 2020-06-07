const Liken = artifacts.require("Liken");

contract("Liken Metadata", () => {
    const tokenNameExpected = "Liken";
    const tokenSymbolExpected = "LKN";
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
    });
});