const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

describe('Token Testing', () => {
    let token;

    beforeEach(async () => {
        const Token = await ethers.getContractFactory('Token');
        token = await Token.deploy('Chaintask', 'CTK', 18, '1000000');
    });

    describe("Deployment", () => {
        const name = 'Chaintask';
        const symbol = 'CTK';
        const decimals = 18;
        const totalSupply = tokens('1000000');

        it('has correct name', async () => {
            // Runs test for the token name
            expect(await token.name()).to.equal(name);
        });
    
        it('has correct symbol', async () => {
            // Runs test for the token symbol
            expect(await token.symbol()).to.equal(symbol);
        });
    
        it('has correct decimals', async() => {
            // Runs test for the token decimals
            expect(await token.decimals()).to.equal(decimals);
        });
    
        it('has correct total supply', async() => {
            expect(await token.totalSupply()).to.equal(totalSupply);
        });
    });
});