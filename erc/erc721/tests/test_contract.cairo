use core::array::ArrayTrait;
use core::traits::Into;
use core::result::ResultTrait;
use starknet::{ContractAddress, contract_address_const};
use core::byte_array::ByteArray;
// use openzeppelin_token::erc721::interface::{ERC721ABIDispatcher, ERC721ABIDispatcherTrait};
use erc::erc721::{IERC721Dispatcher as NFTDispatcher, IERC721DispatcherTrait as
NFTDispatcherTrait};
use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address,
    stop_cheat_caller_address,
};

// Account functions
fn owner() -> ContractAddress {
    contract_address_const::<'OWNER'>()
}

fn caller() -> ContractAddress {
    contract_address_const::<'CALLER'>()
}

fn recipient() -> ContractAddress {
    contract_address_const::<'RECIPIENT'>()
}


fn setup_dispatcher() -> (ContractAddress, NFTDispatcher) {

    let owner_address: ContractAddress = contract_address_const::<'OWNER'>();
    // Declare the contract
    let contract = declare("ERC721").unwrap().contract_class();

    // Prepare constructor calldata
    let mut calldata: Array<felt252> = ArrayTrait::new();

    // Add constructor arguments
    owner_address.serialize(ref calldata);

    let name: ByteArray = "TestNFT";
    let symbol: ByteArray = "TNFT";
    let base_uri: ByteArray = "hhtp://baseuri";

    name.serialize(ref calldata);
    symbol.serialize(ref calldata);
    base_uri.serialize(ref calldata);

    // Deploy contract
    let (address, _) = contract.deploy(@calldata).unwrap();

    // Create dispatcher
    (address, NFTDispatcher { contract_address: address })
}

// #[test]
// fn test_successful_mint() {
//     // Deploy the contract and get the dispatcher
//     let (contract_address, dispatcher) = setup_dispatcher();
//     let recipient = contract_address_const::<'RECIPIENT'>();
//     let token_id: u256 = 1;

//     // Cheat the caller address to be the owner
//     start_cheat_caller_address(contract_address, owner());

//     // Mint the token
//     dispatcher.mint(recipient, token_id);

//     // Stop cheating the caller address
//     stop_cheat_caller_address(contract_address);

//     // Create a dispatcher for assertions
//     let erc721 = NFTDispatcher { contract_address };

//     // Assert that the token is owned by the recipient
//     assert(erc721.owner_of(token_id) == recipient, 'Wrong owner');

//     // Assert that the recipient's balance is 1
//     assert(erc721.balance_of(recipient) == 1, 'Wrong balance');
// }

// #[test]
// #[should_panic(expected: ('Caller is not the owner',))]
// fn test_mint_not_owner() {
//     // Deploy the contract and get the dispatcher
//     let (contract_address, dispatcher) = setup_dispatcher();
//     let recipient = contract_address_const::<'RECIPIENT'>();
//     let token_id: u256 = 1;

//     // Cheat the caller address to be a non-owner
//     start_cheat_caller_address(contract_address, caller());

//     // Attempt to mint the token, expecting a panic
//     dispatcher.mint(recipient, token_id);

//     // Stop cheating the caller address
//     stop_cheat_caller_address(contract_address);
// }


#[test]
fn test_successful_mint() {
    let (contract_address, dispatcher) = setup_dispatcher();
    // let recipient = contract_address_const::<'RECIPIENT'>();
    let token_id: u256 = 1;
    let data: Span<felt252> = array![].span();
    let recipient = recipient();

    // deploy a mock (ERC721Received) contract at the recipient address
    deploy_contract(recipient);

    // Mint the token
    start_cheat_caller_address(contract_address, owner());
    dispatcher.safe_mint(recipient, token_id, data);
    stop_cheat_caller_address(contract_address);

    let erc721 = NFTDispatcher { contract_address };
    assert(erc721.owner_of(token_id) == recipient, 'Wrong owner');
    assert(erc721.balance_of(recipient) == 1, 'Wrong balance');
}

#[test]
#[should_panic(expected: ('Caller is not the owner',))]
fn test_mint_not_owner() {
    let (contract_address, dispatcher) = setup_dispatcher();
    let recipient = contract_address_const::<'RECIPIENT'>();
    let token_id: u256 = 1;
    let data: Span<felt252> = array![].span();

    start_cheat_caller_address(contract_address, caller());
    dispatcher.safe_mint(recipient, token_id, data);
    stop_cheat_caller_address(contract_address);
}
