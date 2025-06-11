Enhanced Organ Donation Matching using Blockchain and LLM
---------------------------------------------------------------------------------------------------------
This repository contains the implementation of a decentralized and AI-enhanced organ donation system. The solution leverages Ethereum smart contracts, a fine-tuned GPT-4o model, IPFS for off-chain storage, and a Gradio-based interface to automate, secure, and streamline the organ transplantation process.
---------------------------------------------------------------------------------------------------------
Key Features

- Fine-tuned LLM (GPT-4o-mini) to suggest optimal donor-recipient matches based on medical attributes (e.g., HLA, blood type, urgency).

- Ethereum smart contracts to manage donor/recipient registration, ethical approval, and matching authorization.

- IPFS for cost-efficient decentralized storage of medical records.

- Gradio DApp for real-time interaction with stakeholders.

- Security and scalability evaluations using tools like Slither and Mythril, and stress testing on the Sepolia testnet.
---------------------------------------------------------------------------------------------------------
How It Works

1) Entity Registration: Regulatory authority registers hospitals, ethical committees, and LLMs via the smart contract.

2) Donor/Recipient Upload: Hospitals register patients and upload encrypted data to IPFS.

3) Ethical Approval: Ethics Committee validates cases through smart contract calls.

4) LLM Matching: The LLM analyzes the case and proposes two top recipients based on clinical rules.

5) Blockchain Logging: Final decisions are logged on-chain, ensuring traceability and tamper-proof records.
---------------------------------------------------------------------------------------------------------
Technologies Used

Ethereum (Solidity on Sepolia Testnet)

GPT-4o-mini (fine-tuned)

IPFS (via Pinata)

Gradio (Frontend Interface)

Python (Web3.py, threading, JSON handling)

Slither & Mythril (Security Analysis)

---------------------------------------------------------------------------------------------------------
