const { expect } = require('chai');
const { ethers } = require('hardhat');

const tokens = (n) => {
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

describe('Token Testing', () => {
    let token;
    let accounts;
    let deployer;

    beforeEach(async () => {
        const Token = await ethers.getContractFactory('Token');
        token = await Token.deploy('Chaintask', 'CTK', '1000000');

        accounts = await ethers.getSigners();
        deployer = accounts[0];
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
            // Runs test for the token total supply
            expect(await token.totalSupply()).to.equal(totalSupply);
        });

        it('assigns total supply to deployer', async () => {
            expect(await token.balanceOf(deployer.address)).to.equal(totalSupply);

        });
    });
});