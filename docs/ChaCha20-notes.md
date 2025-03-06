# ChaCha20 Original Research Paper (But I made notes for myself)

ChaCha improves upon Salsa20 primarily by increasing diffusion per round. The key differences are:

- Each word is updated twice per quarter-round instead of once, allowing input bits to mix faster across the state.
- Faster diffusion—on average, a single-bit difference affects 12.5 output bits in ChaCha, compared to 8 in Salsa20.
- Different rotation constants (16, 12, 8, 7) compared to Salsa20’s (7, 9, 13, 18), improving performance on some platforms while maintaining similar security.

Because ChaCha spreads changes more efficiently, it requires fewer rounds than Salsa20 for the same level of security.

---

## ChaCha differs from Salsa20 in three key ways:

- Output word permutation: ChaCha reorders the output words to match its internal permutation, optimizing performance on SIMD platforms.
- Modified input matrix: Attacker-controlled input words (block counter + nonce) are placed at the bottom, while keys are in the middle. This design improves diffusion and prevents unnecessary attacker flexibility.
- Consistent quarter-round order: ChaCha applies its rounds in a fixed order—first processing columns, then diagonals. This likely improves diffusion efficiency compared to Salsa20’s approach.

These changes make ChaCha more resistant to cryptanalysis while maintaining performance advantages over Salsa20.

