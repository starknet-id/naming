use array::ArrayTrait;
use array::SpanTrait;
use debug::PrintTrait;
use option::OptionTrait;
use zeroable::Zeroable;
use traits::Into;
use starknet::testing;
use starknet::ContractAddress;
use starknet::contract_address::ContractAddressZeroable;
use starknet::contract_address_const;
use starknet::testing::set_contract_address;
use super::super::utils;
use openzeppelin::token::erc20::interface::{IERC20, IERC20Dispatcher, IERC20DispatcherTrait};
use identity::interface::identity::{IIdentityDispatcher, IIdentityDispatcherTrait};
use naming::interface::naming::{INamingDispatcher, INamingDispatcherTrait};
use naming::interface::pricing::{IPricingDispatcher, IPricingDispatcherTrait};
use naming::naming::main::Naming;
use naming::pricing::Pricing;
use super::super::identity::Identity;
use super::super::erc20::ERC20;
use super::common::deploy;


#[cfg(test)]
#[test]
#[available_gas(2000000000)]
fn test_subdomains() {
    // setup
    let (eth, pricing, identity, naming) = deploy();
    let caller = contract_address_const::<0x123>();
    set_contract_address(caller);
    let id1: u128 = 1;
    let id2: u128 = 2;
    let th0rgal: felt252 = 33133781693;
    let hello: felt252 = 29811539;
    let altdomain: felt252 = 57437602667574;

    //we mint an id
    identity.mint(id1);

    // we check how much a domain costs
    let (_, price) = pricing.compute_buy_price(th0rgal, 365);

    // we allow the naming to take our money
    eth.approve(naming.contract_address, price);

    // we buy with no resolver, no sponsor and empty metadata
    naming
        .buy(
            id1, th0rgal, 365, ContractAddressZeroable::zero(), ContractAddressZeroable::zero(), 0
        );

    let subdomain = array![hello, th0rgal].span();

    // we transfer hello.th0rgal.stark to id2
    naming.transfer_domain(subdomain, id2);

    // and make sure the owner has been updated
    assert(naming.domain_to_id(subdomain) == id2, 'owner not updated correctly');
}