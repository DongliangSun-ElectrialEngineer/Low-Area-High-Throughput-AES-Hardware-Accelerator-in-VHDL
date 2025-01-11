# Low-Area-High-Throughput-AES-Hardware-Accelerator-in-VHDL
## Introduction

The AES-128 encryption algorithm is shown in Figure1. It mainly consists of 10 rounds. Each round includes SubBytes, ShiftRows, MixColumns and AddRoundKey, except the final round. The final round only has SubBytes, ShiftRows and AddRoundKey.

![Project Screenshot](assets/screenshot.png)

The AES-128 algorithm operates on 128-bit blocks, encompassing the plaintext, ciphertext, subkeys, and the outputs of each cryptographic operation. This structure allows for the data to be segmented into 16 bytes, denoted as  S_15~S_0, as shown in Table1. Here, S_0 corresponds to the eight least significant bits of the block, while S_15 corresponds to the eight most significant bits of the block. 

| S_15 | S_11 | S_7 | S_3 |
|:---:|:---:|:---:|:---:|
| S_14 | S_10 | S_6 |S_2 |
| S_13 | S_9 | S_5 |S_1 |
| S_12 | S_8 | S_4 |S_0 |

*Table1. 128-bit Block*

## Methodology
In this section, an iterative architecture of the AES-128 encryption algorithm is adopted for the resource-limited circumstances in this project, as shown in Figure2. In contrast to the fully pipelined architecture, this architecture utilizes fewer resources because it reuses the same SubBytes, ShiftRows, MixColumns and AddRoundKey components during each round. According to the architecture shown in Figure2, it takes 11 clock cycles to generate the ciphertext, which mean the next plaintext can be entered after 11 clock cycles.

![Project Screenshot](assets/screenshot.png)

### SubBytes component

S-box is an indispensable part of the SubBytes component. As a result, implementing S-box is the first step. S-box maps 8-bit inputs to the corresponding 8-bit outputs based on the predefined substitution values, providing non-linearity in the cipher. In this project, S-box is implemented using a precomputed lookup table. This table is implemented as a 256-element array where each element is an 8-bit value in VHDL. The index to the array represents the input byte, and the value at that index represents the substituted output byte. Given that the S-box is also required in the KeyExpansion component, the S-box has been implemented as a function within a package for this project.

In the SubBytes component, the 128-bit input block is divided into 16 bytes, denoted as  S_15~S_0, as shown in Table1. The S-box function is then invoked to substitute each input byte. The outcomes of the S-box function are subsequently concatenated to construct the 128-bit output block.

### ShiftRows component

In this component, the 128-bit input block is segmented into 16 bytes, denoted as  S_15~S_0, as shown in Table1. The 128-bit output block is formed through concatenating the 16 input bytes according the rules of ShiftRows.

### MixColumns component

Multiplication by 2 in the finite field GF (2^8) can be implemented as a left shift followed by a conditional bitwise XOR with 0x1B, which represents the irreducible polynomial x8 + x4 + x3 + x + 1 in AES, if the leftmost bit (before shifting) is 1, as illustrated in Figure3. This operation ensures that multiplication stays within the bounds of GF (2^8).

![Project Screenshot](assets/screenshot.png)

Multiplication by 3 can be achieved by first multiplying the input byte by 2 (as described above) and then adding (XORing in GF (2^8)) the original byte to the result, as shown in Figure4.

![Project Screenshot](assets/screenshot.png)

Both multiplication by 2 and by 3 are implemented as two functions in VHDL. For the 128-bit input block, the first step is to divide the block into 16 bytes, denoted as  S_15~S_0, as shown in Table1. Then each column in Table1 is multiplied by the constant matrix in the finite field GF (2^8). Since the constant matrix only contains 1, 2 and 3, calling the function of multiplication by 2 and by 3 in GF (2^8) can solve this matrix multiplication. After the matrix multiplication, the transformed columns can be obtained. Finally, the 128-bit output block will be available through concatenating the transformed columns.

### AddRoundKey component

This component is simply implemented as the 128-bit input XORing the 128-bit subkey.

### KeyExpansion component

KeyExpansion component takes the current 128-bit subkey and 8-bit Rconst as input, and outputs the next subkey. In this component, the 128-bit input block is split into 16 bytes, denoted as  S_15~S_0, as shown in Table1. The process of key expansion can be briefly described in Figure 5. For example, the first sub key is generated from the initial 128-bit key. The fourth word of the initial key, i.e. the thirty-two least significant bits, will be used as input to G function. In G function, this 32-bit vector will go through RotWord section, SubWord section, Rcon section. RotWord operation performs a cyclic permutation of the bytes within a word. Specifically, it rotates the bytes to the left, meaning that each byte is shifted one position to the left, and the leftmost byte is moved to the rightmost position. In this example, the word can be represented as [S_3, S_2, S_1, S_0], applying RotWord to this word would result in [S_2, S_1, S_0, S_3]. The SubWord operation utilizes the same S-box function as the one employed in the MixColumns component. Rcon operation expands an 8-bit Rconst (Round constant) into a 32-bit vector, and then XORs it with the output of SubWord operation. Finally, the output of G function is XORed with the first word of the initial key to generate the first word of the sub key.

![Project Screenshot](assets/screenshot.png)

### Controller

The controller is designed to generate the next round constant, Rconst, and produce control signals, such as "final_round" and "done" signals. The generation of round constants for AES-128 adheres to the following formulation: The round constants are derived from the powers of 2 in the finite field GF(2^8 ). The initial constant Rconst[1] is set to 0x01. Each subsequent round constant is calculated by multiplying the previous one by 2 in the Galois Field GF(2^8 ). The round constant Rconst[i] for round i of the key expansion in AES-128 is shown in Table2.

| i | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:--------:|:---------:|:---------:|
| R_const [i]  | 01  | 02  | 04  | 08  | 10  | 20  | 40  | 80  | 1B  | 36  |

*Table2. Values of Rconst[i] in hexadecimal*

The Rconst[i] variable is instrumental not only in the key expansion process but also in determining the "final_round" and "done" outputs of the controller block. For AES-128, the Rconst[i]  value for the 10th round is 0x36, which indicates the final round, and for the 11th round, it is 0x6c, which implies the encryption process is done. The final_round output signal is used as a select signal for the multiplexer to decide whether to skip the MixColumns operation or not. The done signal is also fed as one of the final outputs of the whole AES encryption module.

### Top entity
In the top entity, data registers are used to store the result obtained in the previous clock cycle while multiplexers play a role in selecting between two inputs based on which round it is in. Then, all we need to do is to instantiate the previous designed components and connect them according to Figure2.

## Simulation
This design has been coded using the VHDL language and the Vivado software has been utilized for the simulation. The timing waveforms for the encryption stages have been depicted in Figure6.

![Project Screenshot](assets/screenshot.png)

According to the Figure6, when the “done” signal is asserted high, which indicates the completion of the encryption process, the ciphertext is “83678f4a55edfe15ead65b2fc7c503d3” in hexadecimal, given the plaintext is “1002a1b1c3d34767afaf5f6f34367275” and the key is “11223344a1b2c3e4aabbccdd55667790” in hexadecimal.

In order to verify the correctness of the encryption result, CrypTool is used. CrypTool is a free e-learning software for illustrating cryptographic and cryptanalytic concepts. Take the AES-128 encryption algorithm as an example, CrypTool can display both the intermediate and final results for the given plaintext and key. The encryption result for the same plaintext and key is illustrated in Figure7 using CrypTool. Based on Figure7, it is evident that the encryption output, produced by the AES-128 encryption core designed for this project, aligns with the result in CrypTool. 

As expected, it takes 11 clock cycles to generate the ciphertext. As a result, the latency of this designed encryption core for each plaintext-key pair is 11 clock cycles. The throughput can be manually computed by the following equation:

	Throughput =  (128 * (clock frequency))/(Number of clock cycles per encrypted )	(3)

As a result, if the clock frequency is 100MHz, the throughput will be 1163Mbit/sec.

When implemented on an Artix-7 FPGA, this design utilizes merely 1055 lookup tables, 264 flip-flops, and 1 block RAM, showcasing a footprint that is significantly more compact compared to similar designs referenced in the literature.

![Project Screenshot](assets/screenshot.png)
