import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import 'bootstrap/dist/css/bootstrap.css';
import currency_abi from "./abi/currency";
import factory_abi from "./abi/factory";
import capital_reserve_abi from "./abi/capital_reserve";
console.log(capital_reserve_abi)



export default function App() {
  const [account, setAccount] = useState(0);
  const [currencyState, setCurrencyState] = useState({
    mintAmou: 0,
    transferAmou: 0,
    address: '',
    c_spender_address:'',
    c_spender_amount:0,

    f_deployCapitalReserve:0,
    f_reserveGov:'',
    f_regulator:'',
    f_token:'',
    f_interestRate:0,
    f_intervalSeconds:0,
    f_interestMaxRate:0,
    f_whiteList:'',
    cr_spender_address:'',
    cr_spender_amount:0,
    cr_claim_pending_transection:'',
    cr_cancel_pending_transection:'',
    cr_accidental_goverance_amount:'',
    cr_accidental_goverance_amount:0,
    cr_withdraw_capital_reserve_pool:0,
    cr_withdraw_interest_pool:0,



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
      currency_abi
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
      currency_abi
    );
    contract
      .transfer(currencyState.address, String(currencyState.transferAmou))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };
  const c_ApproveToken = async () => {
    const contract = await FetchProvider(
      "0xb724BAE3A725329f5459b13954e99c560609070f",
      currency_abi
    );
    contract
      .approve(currencyState.c_spender_address, String(currencyState.c_spender_amount))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };
  // Factory Contract
  const factory_deploy_capital_reserve = async () => {
    // alert("good");
    const contract_factory = await FetchProvider(
      "0x480560EA4056e6d968821A719Fd4D310B6Fb825d",
      factory_abi
    );
    contract_factory
      .deployCapitalReserve(
        // String(currencyState.f_deployCapitalReserve),
        currencyState.f_reserveGov,
        currencyState.f_regulator,
        currencyState.f_token,
        String(currencyState.f_interestRate),
        String(currencyState.f_intervalSeconds))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };
  // Factory Contract
  const factory_setMaxInterestLimite = async () => {
    alert("good");
    const contract_factory = await FetchProvider(
      "0x480560EA4056e6d968821A719Fd4D310B6Fb825d",
      factory_abi
    );
    contract_factory
      .setMaxInterestLimit(String(currencyState.f_interestMaxRate))
      .then((res) => {
        console.log(res);
      })
      .catch((err) => {
        console.log(err);
      });
  };
    //
    const factory_whiteList = async () => {
      const contract_factory = await FetchProvider(
        "0x480560EA4056e6d968821A719Fd4D310B6Fb825d",
        factory_abi
      );
      contract_factory
        .whitelist(currencyState.f_whiteList)
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const captial_reserve_ApproveToken = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );
      capital_reserve
        .approve(currencyState.cr_spender_address, String(currencyState.cr_spender_amount))
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const btn_cr_claim_pending_transection = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );
      capital_reserve
        .claimPendingTransaction(currencyState.cr_claim_pending_transection)
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const btn_cr_cancel_pending_transection = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );
      capital_reserve
        .cancelPendingTransaction(currencyState.cr_cancel_pending_transection)
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const btn_cr_recoverAccidentalTransfer = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );
      capital_reserve
        .recoverAccidentalTransfer(currencyState.cr_accidental_goverance_amount)
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const btn_cr_withdraw_capital_reserve_pool = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );
      capital_reserve
        .withdrawFromCapitalReservePool(
          String(currencyState.cr_withdraw_capital_reserve_pool))
          
        .then((res) => {
          console.log(res);
        })
        .catch((err) => {
          console.log(err);
        });
    };

    const btn_cr_withdraw_interest_pool = async () => {
      const capital_reserve = await FetchProvider(
        "0x38771a3f27c8fbe2a3f87c9272caf64a1de57d5f",
        capital_reserve_abi
      );

      capital_reserve
        .withdrawFromInterestPool(
          currencyState.cr_withdraw_interest_pool)
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
                <button className="btn btn-primary" onClick={MintNft}>Mint Token</button>

              </fieldset>
              <fieldset>
                <legend className="w-auto"><small>Transfer Currency Token </small></legend>
                <br></br>
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
              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Approve token</small></legend>
                <br></br>
                <label className="col-form-label">Spender</label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.c_spender_address}
                  name="c_spender_address"
                  onChange={handleChange}
                />
                <label className="col-form-label">Amount</label>
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.c_spender_amount}
                  name="c_spender_amount"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={c_ApproveToken}>Transfer Token</button>

              </fieldset>
              <hr></hr>
              <fieldset>
              <legend className="w-auto"><small>Factory Contract Admin Side Working</small></legend>
              <br></br>
              <label>Deploy Capital Reserve<span className="required-star"></span></label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_deployCapitalReserve}
                  name="f_deployCapitalReserve"
                  onChange={handleChange}
                />
          <label>Reserve Goverance<span className="required-star"></span></label>

                 <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_reserveGov}
                  name="f_reserveGov"
                  onChange={handleChange}
                />
          <label>Regulator<span className="required-star"></span></label>

                 <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_regulator}
                  name="f_regulator"
                  onChange={handleChange}
                />
          <label>Token<span className="required-star"></span></label>

                 <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_token}
                  name="f_token"
                  onChange={handleChange}
                />
          <label>Interest Rate<span className="required-star"></span></label>

                <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_interestRate}
                  name="f_interestRate"
                  onChange={handleChange}
                />
          <label>Interval Seconds<span className="required-star"></span></label>

                    <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_intervalSeconds}
                  name="f_intervalSeconds"
                  onChange={handleChange}
                />
                 <br></br>
                <button className="btn btn-primary" onClick={factory_deploy_capital_reserve}>Transfer Token</button>
              </fieldset>
              <hr></hr>
              <fieldset>
              <legend className="w-auto"><small>Set Max Interest Limit</small></legend>
              <br></br>
              <label>Allowable Interest (uint256)*<span className="required-star"></span></label>
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.f_interestMaxRate}
                  name="f_interestMaxRate"
                  onChange={handleChange}
                />
                  <br></br>
                <button className="btn btn-primary" onClick={factory_setMaxInterestLimite} >Transfer Token</button>
                </fieldset>
                <fieldset>
              <legend className="w-auto"><small>White List User Address</small></legend>
              <br></br>
              <label>User (address)*<span className="required-star"></span></label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.f_whiteList}
                  name="f_whiteList"
                  onChange={handleChange}
                />
                  <br></br>
                <button className="btn btn-primary" onClick={factory_whiteList} >White List</button>
                </fieldset>
                <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Capital Reserve token Approve</small></legend>
                <br></br>
                <label className="col-form-label">Spender</label>
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.cr_spender_address}
                  name="cr_spender_address"
                  onChange={handleChange}
                />
                <label className="col-form-label">Amount</label>
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.cr_spender_amount}
                  name="cr_spender_amount"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={captial_reserve_ApproveToken}>Approve Token</button>

              </fieldset>
              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Claim Transection</small></legend>
                <br></br>
                <label className="col-form-label">Claim Pending Transection (btyes32)*</label>
            
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.cr_claim_pending_transection}
                  name="cr_claim_pending_transection"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={btn_cr_claim_pending_transection}>Approve Token</button>

              </fieldset>
              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Claim Transection</small></legend>
                <br></br>
                <label className="col-form-label">Cancel Pending Transection (btyes32)</label>
            
                <input
                  type="text"
                  className="form-control"
                  value={currencyState.cr_cancel_pending_transection}
                  name="cr_cancel_pending_transection"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={btn_cr_cancel_pending_transection}>Cancel Pending Transection</button>

              </fieldset>
              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Recover Accidental Only Goverance</small></legend>
                <br></br>
                <label className="col-form-label">Token (address)</label>
            
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.cr_accidental_goverance_token}
                  name="cr_accidental_goverance_token"
                  onChange={handleChange}
                />
                  <legend className="w-auto"><small>Recover Accidental Only Goverance</small></legend>
                <br></br>
                <label className="col-form-label">user (address)</label>
            
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.cr_accidental_goverance_amount}
                  name="cr_accidental_goverance_amount"
                  onChange={handleChange}
                />
                <br></br>
                <button className="btn btn-primary" onClick={btn_cr_recoverAccidentalTransfer}>Recover Accidental Transfer</button>

              </fieldset>

              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Withdraw</small></legend>
                <br></br>
                <label className="col-form-label">WithDraw From Capital Reserve Pool (uint256)</label>
            
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.cr_withdraw_capital_reserve_pool}
                  name="cr_withdraw_capital_reserve_pool"
                  onChange={handleChange}
                />
              
                <br></br>
                <button className="btn btn-primary" onClick={btn_cr_withdraw_capital_reserve_pool}>WithDraw From Capital Reserve Pool</button>

              </fieldset>
              <hr></hr>
              <fieldset>
                <legend className="w-auto"><small>Withdraw</small></legend>
                <br></br>
                <label className="col-form-label">WithDraw From Interest Pool (uint256)</label>
            
                <input
                  type="number"
                  className="form-control"
                  value={currencyState.cr_withdraw_interest_pool}
                  name="cr_withdraw_interest_pool"
                  onChange={handleChange}
                />
              
                <br></br>
                <button className="btn btn-primary" onClick={btn_cr_withdraw_interest_pool}>WithDraw From Interest Pool</button>

              </fieldset>


            </div>

          </div>
        </div>
        
        {/* ------------- */}


      </div>
    </>
  );
}
