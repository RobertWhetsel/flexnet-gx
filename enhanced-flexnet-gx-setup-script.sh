#!/bin/bash

# Enhanced FlexNet GX Setup Script with Error Checking and Dependency Management

set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check and install Rust
check_rust() {
    if ! command_exists rustc; then
        echo "Rust is not installed. Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source $HOME/.cargo/env
    else
        echo "Rust is already installed."
    fi

    # Check Rust version
    local rust_version=$(rustc --version | cut -d ' ' -f 2)
    if [[ "$rust_version" < "1.60.0" ]]; then
        echo "Updating Rust to the latest version..."
        rustup update stable
    fi
}

# Function to check and install wasm-pack
check_wasm_pack() {
    if ! command_exists wasm-pack; then
        echo "wasm-pack is not installed. Installing wasm-pack..."
        curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
    else
        echo "wasm-pack is already installed."
    fi
}

# Function to check and create directory
check_and_create_dir() {
    if [ ! -d "$1" ]; then
        echo "Creating directory: $1"
        mkdir -p "$1"
    else
        echo "Directory already exists: $1"
    fi
}

# Main setup function
setup_flexnet_gx() {
    # Check and install dependencies
    check_rust
    check_wasm_pack

    # Create the main FlexNet GX directory
    check_and_create_dir "FlexNetGX"
    cd FlexNetGX

    # Create README.md
    cat << EOF > README.md
# FlexNet GX Application

This is a modern, serverless application with a Yew-based web frontend (WebAssembly), 
a mobile app structure, AWS serverless backend, and blockchain-based key management,
all implemented in Rust.

## Structure

- \`flexnet-gx-web/\`: Yew-based web frontend (WebAssembly)
- \`flexnet-gx-mobile/\`: Mobile application structure
- \`flexnet-gx-lambda/\`: Rust-based AWS Lambda functions for serverless backend
- \`flexnet-gx-blockchain/\`: Solana-based blockchain for key management and secure data storage

See individual directories for build and run instructions.
EOF

    # Web Frontend Setup
    check_and_create_dir "flexnet-gx-web"
    cd flexnet-gx-web

    if [ ! -f "Cargo.toml" ]; then
        cargo init --lib
    fi

    # Add necessary dependencies to Cargo.toml
    cat << EOF > Cargo.toml
[package]
name = "flexnet-gx-web"
version = "0.1.0"
edition = "2021"

[dependencies]
yew = "0.19"
wasm-bindgen = "0.2"
wasm-bindgen-futures = "0.4"
web-sys = "0.3"
js-sys = "0.3"
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
reqwest = { version = "0.11", features = ["json"] }
aes-gcm = "0.9"
sha2 = "0.9"
hex = "0.4"

[lib]
crate-type = ["cdylib", "rlib"]
EOF

    # Create src/lib.rs with the correct content
    cat << EOF > src/lib.rs
use yew::prelude::*;
use wasm_bindgen::prelude::*;
use wasm_bindgen_futures::spawn_local;
use web_sys::console;
use aes_gcm::{Aes256Gcm, Key, Nonce};
use aes_gcm::aead::{Aead, NewAead};
use sha2::{Sha256, Digest};

struct App {
    blockchain_data: String,
    encrypted_data: String,
}

enum Msg {
    FetchData,
    ReceiveData(String),
    EncryptData(String),
}

impl Component for App {
    type Message = Msg;
    type Properties = ();

    fn create(_ctx: &Context<Self>) -> Self {
        Self {
            blockchain_data: "Click to fetch data from blockchain".to_string(),
            encrypted_data: String::new(),
        }
    }

    fn update(&mut self, ctx: &Context<Self>, msg: Self::Message) -> bool {
        match msg {
            Msg::FetchData => {
                let link = ctx.link().clone();
                spawn_local(async move {
                    match fetch_blockchain_data().await {
                        Ok(data) => link.send_message(Msg::ReceiveData(data)),
                        Err(e) => console::log_1(&format!("Error: {:?}", e).into()),
                    }
                });
                false
            }
            Msg::ReceiveData(data) => {
                self.blockchain_data = data;
                true
            }
            Msg::EncryptData(data) => {
                self.encrypted_data = encrypt_data(&data);
                true
            }
        }
    }

    fn view(&self, ctx: &Context<Self>) -> Html {
        html! {
            <div>
                <h1>{ "FlexNet GX Web Frontend" }</h1>
                <button onclick={ctx.link().callback(|_| Msg::FetchData)}>
                    { "Fetch Blockchain Data" }
                </button>
                <p>{ &self.blockchain_data }</p>
                <input
                    type="text"
                    placeholder="Enter data to encrypt"
                    onchange={ctx.link().callback(|e: Event| {
                        let input: web_sys::HtmlInputElement = e.target_unchecked_into();
                        Msg::EncryptData(input.value())
                    })}
                />
                <p>{ "Encrypted data: " }{ &self.encrypted_data }</p>
            </div>
        }
    }
}

async fn fetch_blockchain_data() -> Result<String, anyhow::Error> {
    // Replace with actual blockchain data fetching logic
    Ok("Simulated blockchain data".to_string())
}

fn encrypt_data(data: &str) -> String {
    let key = Key::from_slice(b"an example very very secret key.");
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(b"unique nonce");

    let encrypted = cipher.encrypt(nonce, data.as_bytes())
        .expect("encryption failure!");
    
    hex::encode(encrypted)
}

#[wasm_bindgen(start)]
pub fn run_app() {
    yew::start_app::<App>();
}
EOF

    # Create index.html
    cat << EOF > index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>FlexNet GX Web</title>
  </head>
  <body>
    <div id="app">Loading...</div>
    <script type="module">
      import init from './pkg/flexnet_gx_web.js';
      init()
        .then(() => console.log("WASM loaded successfully"))
        .catch(err => console.error("Error loading WASM:", err));
    </script>
  </body>
</html>
EOF

    # Add a build script
    cat << EOF > build.sh
#!/bin/bash
wasm-pack build --target web --out-name flexnet_gx_web
EOF

    chmod +x build.sh

    cd ..

    # Mobile App Setup
    check_and_create_dir "flexnet-gx-mobile"
    cd flexnet-gx-mobile

    if [ ! -f "Cargo.toml" ]; then
        cargo init --bin
    fi

    # Update Cargo.toml
    cat << EOF > Cargo.toml
[package]
name = "flexnet-gx-mobile"
version = "0.1.0"
edition = "2021"

[dependencies]
dioxus = "0.3"
dioxus-mobile = "0.3"
tokio = { version = "1", features = ["full"] }
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
aes-gcm = "0.9"
sha2 = "0.9"
hex = "0.4"

[target.'cfg(target_os = "android")'.dependencies]
ndk-glue = "0.7"

[target.'cfg(target_os = "ios")'.dependencies]
objc = "0.2"
cocoa = "0.24"
core-graphics = "0.22"

[lib]
crate-type = ["cdylib", "rlib"]

[[bin]]
name = "flexnet-gx-mobile"
path = "src/main.rs"
EOF

    # Create src/main.rs
    cat << EOF > src/main.rs
use dioxus::prelude::*;
use dioxus_mobile::Config;
use aes_gcm::{Aes256Gcm, Key, Nonce};
use aes_gcm::aead::{Aead, NewAead};
use sha2::{Sha256, Digest};

fn main() {
    dioxus_mobile::launch_with_props(
        App,
        (),
        Config::new().with_window(
            dioxus_mobile::WindowBuilder::new().with_title("FlexNet GX Mobile"),
        ),
    );
}

#[derive(PartialEq)]
struct AppState {
    blockchain_data: String,
    encrypted_data: String,
}

fn App(cx: Scope) -> Element {
    let state = use_state(cx, || AppState {
        blockchain_data: "Click to fetch data from blockchain".to_string(),
        encrypted_data: String::new(),
    });

    let on_fetch_click = move |_| {
        let state = state.clone();
        cx.spawn(async move {
            match fetch_blockchain_data().await {
                Ok(data) => state.set(AppState {
                    blockchain_data: data,
                    encrypted_data: state.encrypted_data.clone(),
                }),
                Err(e) => println!("Error: {:?}", e),
            }
        });
    };

    let on_encrypt_click = move |input: String| {
        let encrypted = encrypt_data(&input);
        state.set(AppState {
            blockchain_data: state.blockchain_data.clone(),
            encrypted_data: encrypted,
        });
    };

    cx.render(rsx! {
        div {
            h1 { "FlexNet GX Mobile" }
            button { 
                onclick: on_fetch_click,
                "Fetch Blockchain Data"
            }
            p { "Blockchain Data: {state.blockchain_data}" }
            input {
                placeholder: "Enter data to encrypt",
                onchange: move |evt| on_encrypt_click(evt.value.clone())
            }
            p { "Encrypted Data: {state.encrypted_data}" }
        }
    })
}

async fn fetch_blockchain_data() -> Result<String, anyhow::Error> {
    // Replace with actual blockchain data fetching logic
    Ok("Simulated blockchain data".to_string())
}

fn encrypt_data(data: &str) -> String {
    let key = Key::from_slice(b"an example very very secret key.");
    let cipher = Aes256Gcm::new(key);
    let nonce = Nonce::from_slice(b"unique nonce");

    let encrypted = cipher.encrypt(nonce, data.as_bytes())
        .expect("encryption failure!");
    
    hex::encode(encrypted)
}
EOF

    # Create build scripts for Android and iOS
    cat << EOF > build-android.sh
#!/bin/bash
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ./jniLibs build --release
EOF

    cat << EOF > build-ios.sh
#!/bin/bash
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release
EOF

    chmod +x build-android.sh build-ios.sh

    cd ..

    # AWS Lambda Setup
    check_and_create_dir "flexnet-gx-lambda"
    cd flexnet-gx-lambda

    if [ ! -f "Cargo.toml" ]; then
        cargo init --bin
    fi

    # Update Cargo.toml
    cat << EOF > Cargo.toml
[package]
name = "flexnet-gx-lambda"
version = "0.1.0"
edition = "2021"

[dependencies]
lambda_runtime = "0.7"
tokio = { version = "1", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
aes-gcm = "0.9"
sha2 = "0.9"
hex = "0.4"

[[bin]]
name = "bootstrap"
path = "src/main.rs"
EOF

    # Create src/main.rs
    cat << EOF > src/main.rs
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
EOF
# Create build script for the Lambda function
    cat << EOF > build-lambda.sh
#!/bin/bash
cargo build --release --target x86_64-unknown-linux-musl
zip -j rust.zip ./target/x86_64-unknown-linux-musl/release/bootstrap
EOF

    chmod +x build-lambda.sh

    cd ..

    # Blockchain Setup (Solana-based)
    check_and_create_dir "flexnet-gx-blockchain"
    cd flexnet-gx-blockchain

    if [ ! -f "Cargo.toml" ]; then
        cargo init --lib
    fi

    # Update Cargo.toml with necessary dependencies for Solana
    cat << EOF > Cargo.toml
[package]
name = "flexnet-gx-blockchain"
version = "0.1.0"
edition = "2021"

[dependencies]
solana-program = "1.9"
thiserror = "1.0"
serde = { version = "1.0", features = ["derive"] }
borsh = "0.9"
borsh-derive = "0.9"
spl-token = { version = "3.3", features = ["no-entrypoint"] }

[lib]
crate-type = ["cdylib", "lib"]
EOF

    # Create the Solana program for key management
    cat << EOF > src/lib.rs
use solana_program::{
    account_info::AccountInfo,
    entrypoint,
    entrypoint::ProgramResult,
    pubkey::Pubkey,
    msg,
};
use borsh::{BorshDeserialize, BorshSerialize};

#[derive(BorshSerialize, BorshDeserialize, Debug)]
pub struct KeyData {
    pub owner: Pubkey,
    pub key: [u8; 32],
}

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    instruction_data: &[u8],
) -> ProgramResult {
    msg!("FlexNet GX Blockchain program entrypoint");
    
    // Add your Solana program logic here
    
    Ok(())
}
EOF

    cd ..

    echo "FlexNet GX setup completed successfully!"
}

# Run the setup
setup_flexnet_gx