# ERC-721 Implementation
ERC-721 token implementation using Solidity and Truffle presented as final assingment for BCDV1010 - Smart Contracts Essentials from <a href='https://www.georgebrown.ca/programs/blockchain-development-program-t175/'>Blockchain Development</a> program from <a href='https://www.georgebrown.ca'>George Brown College</a>.

## :hospital: Description

ERC-721 based to tokenize patients allocated in a hospital.

Each patient is holded by a single hospital and only this hospital can retrieve personal information of the patient and transfer to another hospital if needed.

When a patient is added, a new token is minted to a target hospital with patient information and the address of an emergency hospital as well.

If the patient status is changed to Critical, the Patient token is transfered to the emergency hospital.

You can check the deployed contract in Etherscan [here](https://ropsten.etherscan.io/address/0xebb2bb4b323e65b4b4819b4d1cec4164f9a6eb64).

## :book: References

- [ERC-721](http://erc721.org/)
- [0xcert reference implementation](https://github.com/0xcert/ethereum-erc721)

## :computer: Technologies

- [Solidity](https://solidity.readthedocs.io/)
- [Truffle](https://www.trufflesuite.com/)