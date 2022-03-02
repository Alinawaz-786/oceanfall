import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import 'bootstrap/dist/css/bootstrap.css';
import data from "../src/abi";



export default function App() {
  const [account, setAccount] = useState(0);
  const [currencyState, setCurrencyState] = useState({
    mintAmou: 0,
    transferAmou: 0,

    address: 0,
  });
  useEffect(() => {
    async function fetch() {
      const { ethereum } = window;
      if (ethereum) {
        var provider = new ethers.providers.Web3Provider(ethereum);
        const isMetaMaskConnected = async () => {
          const accounts = await provider.listAccounts();
          return accounts.length > 0;
        };
        await isMetaMaskConnected().then((connected) => {
          if (connected) {
            console.log("MetamasK connected ");
          } else {
          }
        });
        const accounts = await ethereum.request({
          method: "eth_requestAccounts"
        });
        if (accounts != null) {
          setAccount(accounts);
        }
      }
    }
    fetch();
  }, []);
  const handleChange = (e) => {
    const { name, value } = e.target;
    console.log("my value is ", name, value);
    setCurrencyState({ ...currencyState, [name]: value });
  };
  const FetchProvider = async (tokenAdd, Abi) => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    var address = tokenAdd;
    var contract = await new ethers.Contract(address, Abi, signer);
    return contract;
  };
  const MintNft = async () => {
    const contract = await FetchProvider(
      "0xb724BAE3A725329f5459b13954e99c560609070f",
      data
    );
    contract
      .mint(String(currencyState.mintAmou))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };

  const transferToken = async () => {
    const contract = await FetchProvider(
      "0xb724BAE3A725329f5459b13954e99c560609070f",
      data
    );
    contract
      .transfer(currencyState.address, parseInt(currencyState.transferAmou))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };



  return (
    <>
      <div className="App">
        <div className="container">
          <div className="row" >
            <div className="col-lg-6">
              <fieldset>
                <legend className="w-auto"><small>Currency Token Admin Side </small></legend>
                <br></br>
                <label className="col-form-label">Mint Amount</label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.mintAmou}
                  name="mintAmou"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={MintNft}>Mint nft</button>

              </fieldset>
              <fieldset>
                <legend className="w-auto"><small>Transfer Currency Token </small></legend>
                <label className="col-form-label">Address</label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.address}
                  name="address"
                  onChange={handleChange}
                />
                <label className="col-form-label">Amount</label>
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.transferAmou}
                  name="transferAmou"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={transferToken}>Transfer Token</button>

              </fieldset>
            </div>


          </div>
        </div>

        {/* ------------- */}
      </div>
    </>
  );
}
