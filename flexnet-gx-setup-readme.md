# Enhanced FlexNet GX Setup Script

## Overview

This bash script automates the setup process for the FlexNet GX application, a modern, serverless application with a Yew-based web frontend (WebAssembly), a mobile app structure, AWS serverless backend, and blockchain-based key management, all implemented in Rust.

The script performs the following main tasks:
1. Checks and installs necessary dependencies (Rust and wasm-pack)
2. Creates the required directory structure
3. Sets up the web frontend (Yew-based WebAssembly)
4. Prepares the mobile app structure
5. Configures the AWS Lambda backend
6. Initializes the Solana-based blockchain component

## Requirements

- Bash shell (Linux or macOS)
- Internet connection (for downloading dependencies)
- Sufficient permissions to create directories and install software

## Usage

1. Save the script to a file, e.g., `setup_flexnet_gx.sh`
2. Make the script executable:
   ```
   chmod +x setup_flexnet_gx.sh
   ```
3. Run the script:
   ```
   ./setup_flexnet_gx.sh
   ```

## Script Components

### Main Functions

1. `command_exists`: Checks if a command is available in the system.
2. `check_rust`: Ensures Rust is installed and up-to-date.
3. `check_wasm_pack`: Verifies wasm-pack is installed.
4. `check_and_create_dir`: Creates directories if they don't exist.
5. `setup_flexnet_gx`: The main function that orchestrates the entire setup process.

### Setup Steps

1. **Dependency Check**: Verifies and installs Rust and wasm-pack.
2. **Main Directory Creation**: Creates the `FlexNetGX` directory and adds a README.md file.
3. **Web Frontend Setup**: 
   - Creates the `flexnet-gx-web` directory
   - Initializes a Rust library project
   - Configures Cargo.toml with necessary dependencies
   - Creates source files (lib.rs) and HTML template
   - Adds a build script
4. **Mobile App Setup**:
   - Creates the `flexnet-gx-mobile` directory
   - Initializes a Rust binary project
   - Configures Cargo.toml for mobile development
   - Creates the main application file
   - Adds build scripts for Android and iOS
5. **AWS Lambda Setup**:
   - Creates the `flexnet-gx-lambda` directory
   - Initializes a Rust binary project
   - Configures Cargo.toml for AWS Lambda
   - Creates the Lambda function source file
   - Adds a build script for the Lambda function
6. **Blockchain Setup**:
   - Creates the `flexnet-gx-blockchain` directory
   - Initializes a Rust library project
   - Configures Cargo.toml for Solana development
   - Creates the initial Solana program file

## Error Handling

The script includes error checking and will exit immediately if any command fails (`set -e`). It also provides informative messages throughout the setup process.

## Post-Setup

After running the script, you'll have a directory structure ready for FlexNet GX development:

```
FlexNetGX/
├── README.md
├── flexnet-gx-web/
│   ├── Cargo.toml
│   ├── src/
│   │   └── lib.rs
│   ├── index.html
│   └── build.sh
├── flexnet-gx-mobile/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   ├── build-android.sh
│   └── build-ios.sh
├── flexnet-gx-lambda/
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   └── build-lambda.sh
└── flexnet-gx-blockchain/
    ├── Cargo.toml
    └── src/
        └── lib.rs
```

## Next Steps

After running the setup script:

1. Navigate into each directory to start developing the respective components.
2. Use the provided build scripts to compile and package each component.
3. Refer to the individual README files in each directory for more specific instructions on developing and deploying each component.

## Troubleshooting

If you encounter any issues during the setup:

1. Ensure you have a stable internet connection.
2. Check that you have the necessary permissions to create directories and install software.
3. If a specific step fails, try running that part of the script manually to see more detailed error messages.
4. For dependency-related issues, try installing Rust and wasm-pack manually following their official documentation.

## Contributing

Feel free to fork this script and submit pull requests for any improvements or bug fixes. Ensure you test any changes thoroughly before submitting.

## License

This script is provided as-is under the MIT License. See the LICENSE file for more details.
