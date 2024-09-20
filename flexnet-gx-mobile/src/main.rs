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
