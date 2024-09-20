#!/bin/bash
cargo ndk -t armeabi-v7a -t arm64-v8a -t x86 -t x86_64 -o ./jniLibs build --release
