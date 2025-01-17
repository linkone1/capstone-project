async function main() {
    console.log(`Preparing deployment...\n`);

    // Fetch contract's to deploy
    const Token = await ethers.getContractFactory('Token');
    const Exchange = await ethers.getContractFactory('Exchange');


    // Fetch accounts
    const accounts = await ethers.getSigners();

    console.log(`Accounts fetched:\n${accounts[0].address}\n${accounts[1].address}\n`);

    // Deploy contracts

    // Chaintask Deployment (My Own Coin)
    const ctk = await Token.deploy('Chaintask', 'CTK', '1000000');
    await ctk.deployed();
    console.log(`CTK deployed to: ${ctk.address}`);

    // Mock Ether Deployment
    const mETH = await Token.deploy('mETH', 'mETH', '1000000');
    await mETH.deployed();
    console.log(`mETH deployed to: ${mETH.address}`);

    // Mock Dai Deployment
    const mDAI = await Token.deploy('mDAI', 'mDAI', '1000000');
    await mDAI.deployed();
    console.log(`mDAI deployed to: ${mDAI.address}`);

    // Exchange deployment
    const exchange = await Exchange.deploy(accounts[1].address, 10);
    await exchange.deployed();
    console.log(`Exchange deployed to: ${exchange.address}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });