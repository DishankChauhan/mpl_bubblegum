use mpl_bubblegum::{
    instructions::{
        CreateTreeConfigBuilder,
        MintV1Builder,
        MintToCollectionV1Builder,
        TransferBuilder,
        BurnBuilder,
        VerifyBuilder,
    },
    state::{
        metaplex_adapter::*,
        TreeConfig,
        LeafSchema,
        Collection,
        metadata::TokenProgramVersion,
    },
    utils::*,
};
use rustler::{Atom, Error, NifResult, Encoder, Env, Term};
use solana_program::{
    pubkey::Pubkey,
    system_program,
    sysvar::rent,
    instruction::Instruction,
    program_error::ProgramError,
};
use solana_sdk::{
    signature::{Keypair, Signer},
    transaction::Transaction,
    commitment_config::CommitmentConfig,
    hash::Hash,
};
use std::{str::FromStr, convert::TryFrom};
use anchor_lang::prelude::*;

mod atoms {
    rustler::atoms! {
        ok,
        error,
        invalid_public_key,
        invalid_metadata,
        invalid_tree_config,
        invalid_collection,
        transaction_error,
        internal_error,
        verification_failed
    }
}

#[derive(Debug)]
struct TransactionResult {
    signature: String,
    instructions: Vec<Instruction>,
}

/// Creates a new tree configuration for compressed NFTs
#[rustler::nif]
fn create_tree_config(
    max_depth: u32,
    max_buffer_size: u32,
    public_key: String,
    is_public: bool,
) -> NifResult<(Atom, String)> {
    // Validate and convert public key
    let payer = match Pubkey::from_str(&public_key) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::invalid_public_key(), "Invalid public key format".to_string())),
    };

    // Generate new keypairs for tree and merkle tree
    let tree_keypair = Keypair::new();
    let merkle_tree = Keypair::new();

    // Create tree configuration
    let tree_config = TreeConfig {
        tree_creator: payer,
        tree_delegate: payer,
        total_mint_capacity: 1 << max_depth,
        num_minted: 0,
        is_public,
    };

    // Build create tree config instruction
    let create_tree_ix = match CreateTreeConfigBuilder::new()
        .max_depth(max_depth)
        .max_buffer_size(max_buffer_size)
        .public(is_public)
        .merkle_tree(merkle_tree.pubkey())
        .tree_creator(payer)
        .payer(payer)
        .tree_delegate(payer)
        .system_program(system_program::id())
        .instruction() {
            Ok(ix) => ix,
            Err(e) => return Ok((atoms::error(), format!("Failed to create tree instruction: {}", e))),
    };

    // Create and sign transaction
    let recent_blockhash = Hash::default(); // Note: In production, get this from the network
    let transaction = Transaction::new_signed_with_payer(
        &[create_tree_ix],
        Some(&payer),
        &[&tree_keypair, &merkle_tree],
        recent_blockhash
    );

    Ok((atoms::ok(), transaction.signatures[0].to_string()))
}

/// Mints a new compressed NFT, optionally to a collection
#[rustler::nif]
fn mint_compressed_nft(
    tree_address: String,
    metadata_uri: String,
    name: String,
    symbol: String,
    collection_address: Option<String>,
    creator_address: String,
    seller_fee_basis_points: u16,
) -> NifResult<(Atom, String)> {
    // Validate tree address
    let tree = match Pubkey::from_str(&tree_address) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::invalid_tree_config(), "Invalid tree address".to_string())),
    };

    // Validate creator address
    let creator = match Pubkey::from_str(&creator_address) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::invalid_public_key(), "Invalid creator address".to_string())),
    };

    // Create metadata
    let metadata = MetadataArgs {
        name,
        symbol,
        uri: metadata_uri,
        collection: collection_address.map(|addr| {
            Collection {
                key: Pubkey::from_str(&addr).unwrap_or_default(),
                verified: false
            }
        }),
        creators: vec![Creator {
            address: creator,
            verified: false,
            share: 100,
        }],
        seller_fee_basis_points,
        primary_sale_happened: false,
        is_mutable: true,
        edition_nonce: None,
        token_standard: None,
        uses: None,
        token_program_version: TokenProgramVersion::Original,
        properties: None,
    };

    // Build mint instruction based on collection presence
    let instruction = if let Some(collection) = collection_address {
        let collection_key = match Pubkey::from_str(&collection) {
            Ok(key) => key,
            Err(_) => return Ok((atoms::invalid_collection(), "Invalid collection address".to_string())),
        };

        MintToCollectionV1Builder::new()
            .tree_config(tree)
            .metadata(metadata)
            .collection_authority(collection_key)
            .instruction()
    } else {
        MintV1Builder::new()
            .tree_config(tree)
            .metadata(metadata)
            .instruction()
    };

    // Handle instruction creation result
    let mint_ix = match instruction {
        Ok(ix) => ix,
        Err(e) => return Ok((atoms::error(), format!("Failed to create mint instruction: {}", e))),
    };

    // Generate leaf owner keypair
    let leaf_owner = Keypair::new();
    
    // Create and sign transaction
    let recent_blockhash = Hash::default(); // Note: In production, get this from the network
    let transaction = Transaction::new_signed_with_payer(
        &[mint_ix],
        Some(&leaf_owner.pubkey()),
        &[&leaf_owner],
        recent_blockhash
    );

    Ok((atoms::ok(), transaction.signatures[0].to_string()))
}

/// Transfers a compressed NFT to a new owner
#[rustler::nif]
fn transfer_compressed_nft(
    nft_address: String,
    from: String,
    to: String,
    tree_address: String,
    delegate_address: Option<String>,
) -> NifResult<(Atom, String)> {
    // Validate addresses
    let nft = match Pubkey::from_str(&nft_address) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::error(), "Invalid NFT address".to_string())),
    };

    let from_pubkey = match Pubkey::from_str(&from) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::error(), "Invalid sender address".to_string())),
    };

    let to_pubkey = match Pubkey::from_str(&to) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::error(), "Invalid recipient address".to_string())),
    };

    let tree = match Pubkey::from_str(&tree_address) {
        Ok(key) => key,
        Err(_) => return Ok((atoms::error(), "Invalid tree address".to_string())),
    };

    let delegate = delegate_address
        .map(|addr| Pubkey::from_str(&addr))
        .transpose()
        .map_err(|_| Error::Term(Box::new("Invalid delegate address")))?;

    // Build transfer instruction
    let transfer_ix = match TransferBuilder::new()
        .leaf_owner(from_pubkey)
        .leaf_delegate(delegate.unwrap_or(from_pubkey))
        .new_leaf_owner(to_pubkey)
        .merkle_tree(tree)
        .tree_config(nft)
        .instruction() {
            Ok(ix) => ix,
            Err(e) => return Ok((atoms::error(), format!("Failed to create transfer instruction: {}", e))),
    };

    // Create and sign transaction
    let recent_blockhash = Hash::default(); // Note: In production, get this from the network
    let transaction = Transaction::new_signed_with_payer(
        &[transfer_ix],
        Some(&from_pubkey),
        &[],  // Add required signers in production
        recent_blockhash
    );

    Ok((atoms::ok(), transaction.signatures[0].to_string()))
}

/// Verifies a compressed NFT's collection membership
#[rustler::nif]
fn verify_collection_item(
    tree_address: String,
    nft_address: String,
    collection_address: String,
    authority_address: String,
) -> NifResult<(Atom, String)> {
    // Validate addresses
    let tree = Pubkey::from_str(&tree_address)
        .map_err(|_| Error::Term(Box::new("Invalid tree address")))?;

    let nft = Pubkey::from_str(&nft_address)
        .map_err(|_| Error::Term(Box::new("Invalid NFT address")))?;

    let collection = Pubkey::from_str(&collection_address)
        .map_err(|_| Error::Term(Box::new("Invalid collection address")))?;

    let authority = Pubkey::from_str(&authority_address)
        .map_err(|_| Error::Term(Box::new("Invalid authority address")))?;

    // Build verify instruction
    let verify_ix = match VerifyBuilder::new()
        .leaf_owner(authority)
        .merkle_tree(tree)
        .tree_config(nft)
        .collection(collection)
        .instruction() {
            Ok(ix) => ix,
            Err(e) => return Ok((atoms::error(), format!("Failed to create verify instruction: {}", e))),
    };

    // Create and sign transaction
    let recent_blockhash = Hash::default();
    let transaction = Transaction::new_signed_with_payer(
        &[verify_ix],
        Some(&authority),
        &[],
        recent_blockhash
    );

    Ok((atoms::ok(), transaction.signatures[0].to_string()))
}

/// Burns a compressed NFT
#[rustler::nif]
fn burn_compressed_nft(
    tree_address: String,
    nft_address: String,
    owner_address: String,
) -> NifResult<(Atom, String)> {
    // Validate addresses
    let tree = Pubkey::from_str(&tree_address)
        .map_err(|_| Error::Term(Box::new("Invalid tree address")))?;

    let nft = Pubkey::from_str(&nft_address)
        .map_err(|_| Error::Term(Box::new("Invalid NFT address")))?;

    let owner = Pubkey::from_str(&owner_address)
        .map_err(|_| Error::Term(Box::new("Invalid owner address")))?;

    // Build burn instruction
    let burn_ix = match BurnBuilder::new()
        .leaf_owner(owner)
        .merkle_tree(tree)
        .tree_config(nft)
        .instruction() {
            Ok(ix) => ix,
            Err(e) => return Ok((atoms::error(), format!("Failed to create burn instruction: {}", e))),
    };

    // Create and sign transaction
    let recent_blockhash = Hash::default();
    let transaction = Transaction::new_signed_with_payer(
        &[burn_ix],
        Some(&owner),
        &[],
        recent_blockhash
    );

    Ok((atoms::ok(), transaction.signatures[0].to_string()))
}

rustler::init!("Elixir.MplBubblegum.Native", [
    create_tree_config,
    mint_compressed_nft,
    transfer_compressed_nft,
    verify_collection_item,
    burn_compressed_nft
]);