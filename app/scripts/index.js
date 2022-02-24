/* global ethereum */
// Import the page's CSS. Webpack will know what to do with it.
import '../styles/app.css'

// Import libraries we need.
import Web3 from 'web3'
import contract from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import CoinArtifact from '../../build/contracts/Coin.json'
// import ? from '../../build/contracts/?.json'
import { networks } from './networks'

const Gsn = require('@opengsn/provider')

const RelayProvider = Gsn.RelayProvider

// Coin is our usable abstraction, which we'll use through the code below.
const Coin = contract(CoinArtifact)

// The following code is simple to show off interacting with your contracts.
// As your needs grow you will likely need to change its form and structure.
// For application bootstrapping, check out window.addEventListener below.
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
      } else { // We're on ganache
        // console.log('Using local ganache')
      
      }
    
      console.log('chainid=', networkId, network)

     
     
      var provider = RelayProvider.newProvider({ provider: web3.currentProvider, config: gsnConfig })
      await provider.init()
      web3.setProvider(provider)

      

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

        self.refreshBalance()
      })
    })
  },

  setStatus: function (message) {
    const status = document.getElementById('status')
    status.innerHTML = message
  },

  link: function (path, text) {
    return '<a href="' + network.baseurl + path + '">' + text + '</a>'
  },

  addressLink: function (addr) {
    return '<a href="' + network.addressUrl + addr + '" target="_info">' + addr + '</a>'
  },

  txLink: function (addr) {
    return '<a href="' + network.txUrl + addr + '" target="_info">' + addr + '</a>'
  },

  refreshBalance: function () {
    const self = this

    function putItem (name, val) {
      const item = document.getElementById(name)
      item.innerHTML = val
    }
    function putAddr (name, addr) {
      putItem(name, self.addressLink(addr))
    }

  },
}
