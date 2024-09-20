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
