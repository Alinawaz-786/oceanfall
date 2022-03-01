/* global ethereum */
// Import the page's CSS. Webpack will know what to do with it.
import '../styles/app.css'

// Import libraries we need.
import Web3 from 'web3'
import contract from 'truffle-contract'

import CurrencyCoinArtifact from '../../build/gsn/Currency.json'
import FactoryCoinArtifact from '../../build/gsn/Factory.json'
import CapitalReserveArtifact from '../../build/gsn/CapitalReserve.json'
import OFERC20Artifact from '../../build/gsn/OFERC20.json'

import { networks } from './networks'


const CurrencyCoin = contract(CurrencyCoinArtifact)
const FactorySmartContract = contract(FactoryCoinArtifact)
const CapitalReserveContract = contract(CapitalReserveArtifact)
const OFERC20Contract = contract(OFERC20Artifact)



let accounts
let account

var network

const App = {
  start: async function () {
    const self = this
    // This should actually be web3.eth.getChainId but MM compares networkId to chainId apparently
    web3.eth.net.getId(async function (err, networkId) {
      if (parseInt(networkId) < 1000) { // We're on testnet/
        network = networks[networkId]
        CurrencyCoin.deployed = () => CurrencyCoin.at(network.CurrencyCoin)
      } else { // We're on ganache
        console.log('Using local ganache')
        network = {
          capitalreserve: require('../../build/gsn/CapitalReserve.json').address,
          factory: require('../../build/gsn/Factory.json').address,
          oferc20: require('../../build/gsn/OFERC20.json').address
        }
      }
      if (!network) {
        const fatalmessage = document.getElementById('fatalmessage')
        fatalmessage.innerHTML = "Wrong network. please switch to 'rinkeby'"
        return
      }
      console.log('chainid=', networkId, network)

      if (err) {
        console.log('Error getting chainId', err)
        process.exit(-1)
      }
      const gsnConfig = {
        relayLookupWindowBlocks: 600000,
        loggerConfigration: {
          logLevel: window.location.href.includes('verbose') ? 'debug' : 'error'
        },
        paymasterAddress: network.paymaster
      }
      // var provider = RelayProvider.newProvider({ provider: web3.currentProvider, config: gsnConfig })
      // await provider.init()
      // web3.setProvider(provider)

      // Bootstrap the CurrencyCoin abstraction for Use.
      CurrencyCoin.setProvider(web3.currentProvider)

      // Get the initial account balance so it can be displayed.
      web3.eth.getAccounts(function (err, accs) {
        if (err != null) {
          alert('There was an error fetching your accounts.')
          return
        }

        if (accs.length === 0) {
          alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.")
          return
        }

        accounts = accs
        account = accounts[0]

      })
    })
  },

  setStatus: function (message) {
    const status = document.getElementById('status')
    status.innerHTML = message
  },

  //Currency Token
  currency_mint: function () {
    const self = this
    const currency_mint = parseInt(document.getElementById('currency_mint').value)
    this.setStatus('Initiating transaction... (please wait)')
    let meta
    CurrencyCoin.deployed().then(function (instance) {
      meta = instance
      return meta.mint(currency_mint,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  currency_transfer: function () {
    const self = this
    const amount = parseInt(document.getElementById('currency_amount').value)
    const receiver = document.getElementById('currency_receiver').value
    this.setStatus('Initiating transaction... (please wait)')
    let meta
    CurrencyCoin.deployed().then(function (instance) {
      meta = instance
      return meta.transfer(receiver, amount,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  currency_approve: function(){
    alert("approve")
    const self = this
    const currency_spender_amount = parseInt(document.getElementById('currency_spender_amount').value)
    const currency_spender = document.getElementById('currency_spender').value
    this.setStatus('Initiating transaction... (please wait)')
    let meta
    CurrencyCoin.deployed().then(function (instance) {
      meta = instance
      return meta.approve(currency_spender, currency_spender_amount,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  //Currency End

  //Factory

  factory_deploy_capital_reserve: function(){
    alert('test')
    const self = this
    const f_deployCapitalReserve = document.getElementById('f_deployCapitalReserve').value
    const f_reserveGov = document.getElementById('f_reserveGov').value
    const f_regulator = document.getElementById('f_regulator').value
    const f_token = document.getElementById('f_token').value
    const f_interestRate = parseInt(document.getElementById('f_interestRate').value)
    const f_intervalSeconds = parseInt(document.getElementById('f_intervalSeconds').value)

    let meta
    FactorySmartContract.deployed().then(function (instance) {
      meta = instance
      return meta.deployCapitalReserve(f_deployCapitalReserve, 
        f_reserveGov,
        f_regulator,
        f_token,
        f_interestRate,
        f_intervalSeconds,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  factory_setMaxInterestLimite: function(){
    const f_interestRate = parseInt(document.getElementById('f_interestRate').value)
    let meta
    FactorySmartContract.deployed().then(function (instance) {
      meta = instance
      return meta.setMaxInterestLimit(f_interestRate,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  factory_whiteList: function(){
    const f_whiteList = document.getElementById('f_whiteList').value
    let meta
    FactorySmartContract.deployed().then(function (instance) {
      meta = instance
      return meta.whitelist(f_whiteList,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  }, 
  //Factory End

  //Capital Reserve 
  cr_approve: function(){
    const cr_spender = document.getElementById('cr_spender').value
    const cr_amount = parseInt(document.getElementById('cr_amount').value)
    let meta
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.approve(cr_spender,cr_amount,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  cr_claim_pending_transection: function(){
    const cr_claim_pending_transection = document.getElementById('cr_claim_pending_transection').value
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.claimPendingTransaction(cr_claim_pending_transection,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    })
  },
  cr_cancel_pending_transection: function(){
    const cr_cancel_pending_transection = document.getElementById('cr_cancel_pending_transection').value
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.cancelPendingTransaction(cr_cancel_pending_transection,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  btn_cr_deposit_capital_reserve_pool: function(){
    const cr_deposit_capital_reserve_pool = document.getElementById('cr_deposit_capital_reserve_pool').value
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.depositToCapitalReservePool(cr_deposit_capital_reserve_pool,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  btn_cr_deposit_interest_pool: function(){
    const cr_deposit_interest_pool = document.getElementById('cr_deposit_interest_pool').value
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.depositToCapitalReservePool(cr_deposit_interest_pool,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  btn_cr_recoverAccidentalTransfer: function(){
    const cr_accidental_goverance_token = document.getElementById('cr_accidental_goverance_token').value
    const cr_accidental_goverance_amount = parseInt(document.getElementById('cr_accidental_goverance_amount').value)
    
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.recoverAccidentalTransfer(
        cr_accidental_goverance_token,
        cr_accidental_goverance_amount,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  btn_cr_withdraw_capital_reserve_pool: function(){
    const cr_withdraw_capital_reserve_pool = parseInt(document.getElementById('cr_withdraw_capital_reserve_pool').value)
    
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.withdrawFromCapitalReservePool(
        cr_withdraw_capital_reserve_pool,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  btn_cr_withdraw_interest_pool: function(){
    const cr_withdraw_interest_pool = parseInt(document.getElementById('cr_withdraw_interest_pool').value)
    CapitalReserveContract.deployed().then(function (instance) {
      meta = instance
      return meta.withdrawFromCapitalReservePool(
        cr_withdraw_interest_pool,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },
  //Capital Reserve End
  btn_oferc20_token: function(){
    const oferd20_token_address = parseInt(document.getElementById('oferd20_token_address').value)
    const oferd20_amount = parseInt(document.getElementById('oferd20_amount').value)
    OFERC20Contract.deployed().then(function (instance) {
      meta = instance
      return meta.withdrawFromCapitalReservePool(
        oferd20_token_address,
        oferd20_amount,
        { from: account })
    }).then(function (res) {
      self.setStatus('Transaction complete!<br>\n' + self.txLink(res.tx))
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error sending coin; see log.')
    }) 
  },

}

window.App = App
window.addEventListener('load', async () => {
  // Modern dapp browsers...
  if (window.ethereum) {
    console.warn(
      'Using web3 detected from external source.' +
      ' If you find that your accounts don\'t appear or you have 0 CurrencyCoin,' +
      ' ensure you\'ve configured that source properly.' +
      ' (and allowed the app to access MetaMask.)' +
      ' If using MetaMask, see the following link.' +
      ' Feel free to delete this warning. :)' +
      ' http://truffleframework.com/tutorials/truffle-and-metamask'
    )
    window.web3 = new Web3(ethereum)
    try {
      // Request account access if needed
      await ethereum.enable()

      ethereum.on('chainChanged', (chainId)=>{
        console.log( 'chainChanged', chainId)
        window.location.reload()
      })
      ethereum.on('accountsChanged', (accs)=>{
        console.log( 'accountChanged', accs)
        window.location.reload()
      })

    } catch (error) {
      // User denied account access...
      alert('NO NO NO')
    }
  } else if (window.web3) {
    // Legacy dapp browsers...
    window.web3 = new Web3(web3.currentProvider)
  } else {
    console.warn(
      'No web3 detected. Falling back to http://127.0.0.1:9545.' +
      ' You should remove this fallback when you deploy live, as it\'s inherently insecure.' +
      ' Consider switching to Metamask for development.' +
      ' More info here: http://truffleframework.com/tutorials/truffle-and-metamask'
    )
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:9545'))
  }
  await App.start()
})
