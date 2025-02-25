////////////////////////////////
// Exercise 8
// Recursions - basics
////////////////////////////////
// - Use this contract's claim_points() function
// - Your points are credited by the contract
////////////////////////////////

#[contract]
mod Ex08 {
    ////////////////////////////////
    // Core Library imports
    // These are syscalls and functionalities that allow you to write Starknet contracts
    /////////////////////////////////
    use starknet::get_caller_address;
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use option::OptionTrait;

    ////////////////////////////////
    // Internal imports
    // These function become part of the set of function of the current contract
    ////////////////////////////////
    use starknet_cairo_101::utils::ex00_base::Ex00Base::distribute_points;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::validate_exercise;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::ex_initializer;
    use starknet_cairo_101::utils::ex00_base::Ex00Base::update_class_hash_by_admin;
    use starknet_cairo_101::utils::helper;

    ////////////////////////////////
    // Storage
    // In Cairo 1, storage is declared in a struct
    // Storage is not visible by default through the ABI
    ////////////////////////////////
    struct Storage {
        user_values: LegacyMap::<(ContractAddress, u128), u128>
    }

    ////////////////////////////////
    // Constructor
    // This function (indicated with #[constructor]) is called when the contract is deployed and is used to initialize the contract's state
    ////////////////////////////////
    #[constructor]
    fn constructor(
        _tderc20_address: ContractAddress,
        _players_registry: ContractAddress,
        _workshop_id: u128,
        _exercise_id: u128
    ) {
        ex_initializer(_tderc20_address, _players_registry, _workshop_id, _exercise_id);
    }

    ////////////////////////////////
    // View Functions
    // Public variables should be declared explicitly with a getter function (indicated with #[view]) to be visible through the ABI and callable from other contracts
    ////////////////////////////////
    #[view]
    fn get_user_values(account: ContractAddress, slot: u128) -> u128 {
        return user_values::read((account, slot));
    }

    ////////////////////////////////
    // External functions
    // These functions are callable by other contracts or external calls such as DAPP, which are indicated with #[external] (similar to "public" in Solidity)
    ////////////////////////////////
    #[external]
    fn claim_points() {
        // Reading caller address
        let sender_address: ContractAddress = get_caller_address();
        let user_value_at_slot_ten = user_values::read((sender_address, 10_u128));
        assert(user_value_at_slot_ten == 10_u128, 'USER_VALUE_NOT_10');

        // Checking if the user has validated the exercise before
        validate_exercise(sender_address);
        // Sending points to the address specified as parameter
        distribute_points(sender_address, 2_u128);
    }

    // This function takes an array as a parameter
    #[external]
    fn set_user_values(account: ContractAddress, values: Array::<u128>) {
        let mut idx = 0_u128;
        set_user_values_internal(account, idx, values);
    }

    ////////////////////////////////
    // Internal functions
    // These functions are not accessible to external calls only callable inside the contracts or be used in other contracts using "use statement" (similar to "private" in Solidity)
    ////////////////////////////////
    fn set_user_values_internal(
        account: ContractAddress, mut idx: u128, mut values: Array::<u128>
    ) {
        helper::check_gas();
        if !values.is_empty() {
            user_values::write((account, idx), values.pop_front().unwrap());
            idx = idx + 1_u128;
            set_user_values_internal(account, idx, values);
        }
    }

    ////////////////////////////////
    // External functions - Administration
    // Only admins can call these. You don't need to understand them to finish the exercise.
    ////////////////////////////////
    #[external]
    fn update_class_hash(class_hash: felt252) {
        update_class_hash_by_admin(class_hash);
    }
}
