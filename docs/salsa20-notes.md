# Salsa20 Original Research Paper (But I made notes for myself)

## Working 

- Modular Addition : Introduces non-linearity and helps in diffusion.
- XOR : A lightweight and reversible operation that mixes bits efficiently.
- Bitwise Rotation : Prevents linear dependencies and ensures proper mixing of bits.

Together, these operations create the Quarter-Round function, which is the core of Salsa20 and ChaCha20. This simplicity allows Salsa20 to be fast in software and hardware, making it ideal for cryptographic applications requiring high performance.

- These operations are fundamental – They are enough to build any computational circuit, meaning they can achieve the same level of security as more complex operations.
- Efficiency matters – More complex operations (like S-boxes in AES) might slow things down. The designer's goal is to maximize security while keeping the cipher fast on all types of hardware (CPUs, FPGAs, etc.).
- Bitwise diffusion – Addition, XOR, and rotation efficiently mix bits without introducing unnecessary complexity.

> [!NOTE]
> These operations are not "too simple"—they are chosen because they are the most efficient way to reach high security.

---

## Why avoid multiplication?
Multiplication is slower than addition, XOR, and rotation.

- On many processors, multiplication takes multiple clock cycles, while addition, XOR, and bitwise rotation are single-cycle operations.
This is even more critical on hardware like FPGAs and embedded devices, where multipliers take more logic area and power compared to adders and XOR gates.
Multiplication introduces carries, making diffusion unpredictable.

- In cryptographic algorithms, we want to mix bits efficiently in a predictable way.
Addition, XOR, and rotation spread bits efficiently while keeping the cipher simple and fast.
Better hardware portability.

- Operations like XOR, addition, and rotation are universally fast across CPUs, GPUs, FPGAs, and even software implementations.
Multiplication might not be optimized equally well on all hardware platforms.
- So, Salsa20 and ChaCha20 avoid multiplication to maintain speed, simplicity, and efficiency across different types of hardware.

- A timing attack happens when an attacker measures how long a cryptographic operation takes and uses that information to extract secret data (like encryption keys).
If different inputs cause different execution times, an attacker can infer bits of the key by carefully analyzing execution times.

- Many CPUs do not execute integer multiplication in constant time.
The time taken to multiply two numbers can depend on their values.
Example: Multiplying a large number by a small number might take fewer cycles than multiplying two large numbers.
This variation in execution time can leak information about secret keys.

- Cryptographic implementations must ensure that all operations take the same amount of time, regardless of input values.
This means that if multiplication is used, extra countermeasures (like masking techniques) may be needed to prevent timing leaks.
However, making multiplication constant-time usually makes it slower than operations like addition, XOR, and rotation.

- Addition, XOR, and rotation always take the same time on most hardware, making them resistant to timing attacks.
Multiplication is not guaranteed to be constant-time, so using it would require extra security measures, slowing down performance.
- Conclusion:
Avoiding integer multiplication in Salsa20 (and ChaCha20) reduces timing attack risks while also keeping the cipher fast and efficient.

---

An S-box (Substitution Box) lookup is a fundamental operation in cryptographic algorithms, particularly in block ciphers like AES and DES. It is used for non-linearity and confusion, making it harder for attackers to analyze the cipher.

How It Works:
- The input (usually a few bits) is used as an index to look up a predefined table (S-box).
- The table returns a substituted value, adding non-linearity to the cipher.
- Example in AES:
AES uses a 16x16 S-box table, where each 8-bit input is replaced by an 8-bit output.

- For example, in AES:

Input: `0x53`
Looked up in S-box → Output: `0xED`
This substitution helps break linear patterns and improve security.

- Salsa20 and ChaCha20 do not use S-box lookups.
Instead, they rely on XOR, addition, and rotation for security, which are fast and constant-time operations, avoiding table-based attacks like cache-timing attacks.

--- 

- The argument for S-boxes is that a single lookup in an S-box can efficiently transform its input, making it highly nonlinear in a single step. This is why AES relies heavily on S-boxes—each 8-bit input gets mapped to a 32-bit output in one operation, introducing strong confusion.

The counter-argument is that:

- Integer operations work on 32-bit words, not just 8-bit values – This means they can process more data per operation compared to an 8-bit S-box lookup, which may need multiple lookups to process a full 32-bit value.
- Cache efficiency concerns – Large S-box tables (like in AES) increase pressure on L1 cache, making memory accesses slower. Modern processors have deep cache hierarchies, and large S-boxes may not fit in L1, leading to more cache misses and slower performance.
- Scalability across different hardware – S-box-based implementations can behave differently on large vs. small CPUs. On high-performance processors, integer operations can be faster because they don't suffer from cache bottlenecks.
### Why Salsa20 and ChaCha20 Avoid S-boxes
Salsa20 and ChaCha20 avoid S-boxes entirely and rely only on addition, XOR, and bitwise rotation. This ensures:

- Faster execution on CPUs since these operations are directly supported by ALUs.
- Better hardware implementation (e.g., in FPGAs and ASICs) since these operations have a predictable and efficient hardware footprint.
- Side-channel resistance because these operations execute in constant time, unlike table lookups that depend on memory access patterns (which can be exploited in attacks like cache timing attacks).

--- 

Salsa20 uses rotation instead of shift because:

- Efficiency: A single XOR + rotation achieves the same effect as two XOR + shifts, reducing the number of operations.
- Speed: Rotation is faster than shift on many CPUs because it doesn’t involve carry propagation (unlike arithmetic shifts).
- Uniform Mixing: Rotation ensures that all bits contribute evenly to the output, improving diffusion across the cipher.
- Consistency: Rotations work efficiently across different hardware platforms, making the cipher more portable.
- This makes Salsa20’s design both performance-optimized and secure while avoiding unnecessary complexity.

--- 

## How Salsa20 Generates the Key Stream
### Inputs:

- 256-bit key (or 128-bit in some versions)
- 64-bit nonce (unique per message)
- Block counter (to ensure different blocks get different outputs)
- Constant values (used to structure the initial state)
### State Initialization:

- These values are arranged into a 4 × 4 matrix of 32-bit words (16 words in total).
- This is the Salsa20 state.
### Key Stream Generation:

- The state is processed through multiple rounds of quarter-round transformations (using addition, XOR, and bitwise rotation).
- After several rounds (typically 20 rounds in standard Salsa20), this state produces a 512-bit block of key stream.
- The key stream is then XORed with the plaintext to produce the ciphertext.

--- 

> [!NOTE]
> Salsa20 does not use chaining between blocks, unlike block ciphers in CBC mode.

## Key Points:

### 64-Byte Independent Blocks

Each 64-byte block of the key stream is generated independently using:
- The 256-bit key
- The 64-bit nonce
- The 64-bit block counter
- Salsa20's round function

### Random Access

- Since blocks are independent, you can generate any block at any position without computing the previous blocks.
- This is useful for parallelization and seeking within a stream (e.g., skipping to byte N directly).
### No Preprocessing

- Some ciphers preprocess the key (e.g., AES expands the key first).
- Salsa20 does not do this—the key is used directly for every block.
- Same for the nonce—no preprocessing, making Salsa20 fast with no hidden overhead.

This design makes Salsa20 highly efficient, especially for scenarios where you need fast random access to encrypted data. 

--- 

## Key distinction between Salsa20 and some other stream ciphers like Helix/Phelix—whether the plaintext influences the keystream.

### How Salsa20 Works (and Counter Mode in General)
- The keystream is purely determined by the key and nonce.
- The plaintext does not affect the keystream.
- Encryption is simply: Ciphertext = Plaintext⊕Keystream

- This allows random access and parallel computation of keystream blocks.
### Other Stream Ciphers (like Helix, Phelix)
- Modify the keystream based on plaintext.
- A claimed benefit: "free authentication", because the ciphertext inherently carries integrity protection.
- The downside:
Performance hit: Each block computation depends on previous blocks.
Security risk: Attackers may exploit the way plaintext affects the cipher state.
Not actually "free": Modern authentication (like Poly1305) is extremely fast and avoids these issues.

### Bernstein argues that:

Authentication should be done separately (Poly1305 + Salsa20 = ChaCha20-Poly1305).
Stream ciphers that mix plaintext into the keystream are harder to secure.
Handling forged packets efficiently is more important than slightly faster authenticated encryption.

--- 

## Why Salsa20 avoids chaining between blocks and instead treats each block as an independent hash of the key, nonce, and block counter.


### Chained stream ciphers

- Use state from previous blocks to generate the next block.
- Fewer rounds needed for security because mixing happens across blocks.
- Downside: Serialization! Blocks must be computed in order (can’t parallelize).

### Salsa20 (stateless per block)

- Each block is independent, using only key, nonce, and block counter.
- More rounds needed for security (because no chaining).
- Upside:
    - Random access: You can generate any block without computing the previous ones.
    - Parallelism: Multiple blocks can be computed at the same time.
    - Less state per channel (good for limited hardware).

### Why Salsa20 Prioritizes Parallelism
On modern CPUs (like Intel Core 2), multiple arithmetic operations can be executed in parallel.
Salsa20 can take advantage of multiple cores because blocks are independent.
If chaining was used, each block would depend on the previous one, forcing sequential computation.

--- 

## Tradeoff  between reducing the number of rounds vs. increasing the amount of data processed per block.

- Larger block size → fewer rounds needed (since more data is mixed in one go).
- But larger block size → slower memory access & inefficient for small messages (wasted space for partial blocks).


Salsa20 sticks to 64-byte blocks because it's a good balance—it avoids excessive CPU-memory bandwidth usage while still allowing efficient mixing through more rounds.

--- 

## The argument here is that 128-bit keys, while theoretically strong, may not be enough in practice because:

- Success probability: Brute force doesn't require trying all 2^128
keys—attackers can succeed with much fewer computations.
- Hardware efficiency: Specialized hardware (like FPGAs or ASICs) can check multiple keys in parallel, reducing cost per key search.
- Massive parallelism: If an attacker targets multiple keys at once (e.g., attacking many encrypted messages), the cost per attack drops significantly.

Because of these factors, the author believes that 256-bit keys provide a safer security margin for the future, while 128-bit keys might eventually be considered too weak.

--- 

## Salsa20 keeps all rounds identical (except for the final XOR step), making it simpler to implement and analyze. Some ciphers, like MARS, mix different types of rounds to supposedly make attacks harder, but this adds complexity to both software and hardware implementations.

### Why Salsa20 Uses Identical Rounds:
- Simplicity: The same logic repeats, leading to shorter, cleaner code.
- Efficiency: No need for extra instructions or lookups for different round types, reducing L1 cache pressure.
- Security: Adding more rounds is a proven way to strengthen encryption, while mixing round types has uncertain benefits.

So instead of switching round types like MARS, Salsa20 just increases the number of rounds for security.

---    

