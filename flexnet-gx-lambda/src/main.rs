use lambda_runtime::{service_fn, LambdaEvent, Error};
use serde_json::{json, Value};
use aes_gcm::{Aes256Gcm, Key, Nonce};
use aes_gcm::aead::{Aead, NewAead};
use sha2::{Sha256, Digest};

#[tokio::main]
async fn main() -> Result<(), Error> {
    lambda_runtime::run(service_fn(func)).await?;
    Ok(())
}

async fn func(event: LambdaEvent<Value>) -> Result<Value, Error> {
    let (event, _context) = event.into_parts();
    let input_data = event["data"].as_str().unwrap_or("No data provided");

    let encrypted_data = encrypt_data(input_data);
    let blockchain_hash = simulate_blockchain_storage(&encrypted_data);

    Ok(json!({
        "message": "Data processed by FlexNet GX Lambda",
        "encrypted_data": encrypted_data,
        "blockchain_hash": blockchain_hash
    }))
}

fn encrypt_data(data: &str) -> String {
    let key = Key::from_slice(b"an example very very secret key.");
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(b"unique nonce");

    let encrypted = cipher.encrypt(nonce, data.as_bytes())
        .expect("encryption failure!");
    
    hex::encode(encrypted)
}

fn simulate_blockchain_storage(data: &str) -> String {
    let mut hasher = Sha256::new();
    hasher.update(data);
    let result = hasher.finalize();
    hex::encode(result)
}
