import { useSelector, useDispatch } from 'react-redux';
import Blockies from 'react-blockies';

import logo from '../assets/logo.png';
import eth from '../assets/eth.svg';
import { loadAccount } from '../store/interactions';


const Navbar = () => {
    const provider = useSelector(state => state.provider.connection);
    const account = useSelector(state => state.provider.account);
    const balance = useSelector(state => state.provider.balance);

    const dispatch = useDispatch();

    const connectHandler = async () => {
        await loadAccount(provider, dispatch);
    }

    const networkHandler = async (event) => {
        console.log(event.target.value);
    }

    return(
      <div className='exchange__header grid'>
        <div className='exchange__header--brand flex'>
            <img src={logo} className="logo"></img>
            <h1>ChainTask Token Exchange</h1>
        </div>
  
        <div className='exchange__header--networks flex'>
            <img src={eth} alt="ETH Logo" className='Eth Logo' />

            <select name="networks" id="networks" value="0" onChange={networkHandler}>
                <option value="0" disabled>Select Networks</option>
                <option value="0x7A69">Localhost</option>
                <option value="0x2A">Kovan</option>
            </select>
        </div>
  
        <div className='exchange__header--account flex'>
            { balance ? (
                <p><small>My Balance</small>{Number(balance).toFixed(4)}</p>
            ) : (
                <p><small>My Balance</small>0 ETH</p>
            )}
            { account ? (
                <a href="">{account.slice(0, 5) + '...' + account.slice(38,42)}
                  <Blockies
                    account={account}
                    size={10}
                    scale={3}
                    color="#2187D0"
                    bgColor="#F1F2F9"
                    spotColor="#767F92"
                    className="identicon"
                />
                </a>
            ) : (
                <button className="button" onClick={connectHandler}>Connect</button>
            )}
        </div>
      </div>
    )
  }
  
  export default Navbar;