import { useEffect } from 'react';
import config from '../config.json';
import '../App.css';
import { useDispatch } from 'react-redux';

import {
  loadProvider,
  loadNetwork,
  loadAccount,
  loadTokens,
  loadExchange,
  loadAllOrders,
  subscribeToEvents
} from '../store/interactions';

import Navbar from './Navbar';
import Markets from './Markets';
import Balance from './Balance';
import Order from './Order';
import OrderBook from './OrderBook';
import PriceChart from './PriceChart';
import Trades from './Trades';
import Transactions from './Transactions';
import Alert from './Alert';


function App() {

  const dispatch = useDispatch();

  const loadBlockchainData = async () => {
    // Connect Ethers to blockchain
    const provider = loadProvider(dispatch);

    // Fetch current netwoprk's chainId (e.g. hardhat: 31337, kovan: 42)
    const chainId = await loadNetwork(provider, dispatch);

    window.ethereum.on('chainChanged', () => {
      window.location.reload()
    })

    window.ethereum.on('accountsChanged', () => {
      loadAccount(provider, dispatch);
    })

    // Fetch current account & balance from metamask
    //await loadAccount(provider, dispatch);


    // Load token smart contracts
    const CTK = config[chainId].CTK;
    const mETH = config[chainId].mETH;
    await loadTokens(provider, [CTK.address, mETH.address], dispatch);

    // Load exchange contract
    const exchangeConfig = config[chainId].Exchange;
    const exchange = await loadExchange(provider, exchangeConfig.address, dispatch);

    // Fetch all orders: open, filled, cancelled
    loadAllOrders(provider, exchange, dispatch);

    // Listen to events
    subscribeToEvents(exchange, dispatch);
    }
  

  useEffect(() => {
    loadBlockchainData();
  });

  return (
    <div>

      <Navbar />

      <main className='exchange grid'>
        <section className='exchange__section--left grid'>

          <Markets />
          
          <Balance />

          <Order />

        </section>
        <section className='exchange__section--right grid'>

          <PriceChart />

          <Transactions />

          <Trades />

          <OrderBook />

        </section>
      </main>

      <Alert />

    </div>
  );
}

export default App;