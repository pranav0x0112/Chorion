#!/bin/bash

echo "Welcome to Shell Interface!"

read -p "Enter plaintext: " plaintext
read -p "Enter key: " key
read -p "Enter nonce: " nonce
read -p "Enter counter: " counter

ciphertext = $(python3 ../py/cipher.py encrypt "$plaintext" "$key" "$nonce" "$counter")
echo "Ciphertext: $ciphertext"

decrypted = $(python3 ../py/cipher.py decrypt "$ciphertext" "$key" "$nonce" "$counter")
echo "Decrypted: $decrypted"

