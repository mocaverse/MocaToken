# Contingency (Proposed)

Engage in off-chain monitoring of bridging. This can be done in 2 ways:

1. Tracking general health: Track total supply on every OFT contract to ensure it is not exceeded.
2. Transaction Monitoring: Track each bridging transaction to ensure it is not malicious.

With respect to option 1, we could potentially use Tenderly to set up alerts to ensure that total supply is not breached.
> Consider: https://forta.org/

## Mitigation options

1. Reject/Block a specific message if deemed malicious, by observing its LzSend event.
2. Disconnect bridge between two contracts if there is an extended malicious campaign.

# Off-chain transaction monitoring

## Rejecting/Blocking a malicious txn

Mints more than it burns/locks. We can assess this by observing 2 parts:

1. how many tokens did the address transfer to the OFT
2. how many tokens are going to be minted on dstChain as laid out by the lzReceive event emitted

The first reflects how much the address actually ponies up, while the latter reflects new issue of tokens.

If deemed incorrect, we can opt to simply reject this message by clearing it. This prevents the malicious packet from being executed on dstChain, while all other messages are well received.

> Please see: https://docs.layerzero.network/contracts/debugging-messages#clearing-message

Once a payload is cleared, it cannot be recovered. There are no retries. The tokens locked remain locked on srcChain.
Of course, the attacker can simply repeat with a new transaction, but he'd be paying gas again.

Alternatively, a suspicious message could be blocked from being executed on the dstChain.
However, it must be noted that blocked messages can be retried, by both ourselves and the attacker.
So we must be mindful in assessing intent quickly.

**Are there other metrics by which we can identify a malicious txn?**

## Alternative Measure: Breaking Bridges

We can disconnect the connection between contracts by calling `resetPeer`.
For example, when an incorrect lz event is emitted on the src chain, we look to disconnect the bridge by calling `resetPeer` on the dst chain. By breaking the connection between chains, on the dst chain we can essentially front-run the LZ relay and prevent a malicious mint.

![alt text](image.png)
**It is important to note that the end result of creating this blockage is that tokens will be lost on the src chain.**

Obviously, since the event is emitted on the src chain, nothing much can be done there.

When is this measure sensible?

- The attack consistently originates from a specific chain
- This could be on part due to faulty LZ messaging/validation in that specific part of the network
- Meaning, the attack cannot be reproduced elsewhere.

## Alternative Measure: Pausing all LZ contracts

We can pause all contracts, across all chains, with the exception of the MocaToken contract.
This includes x-chain messaging as well as token transfers.

When is this measure sensible?

- Possibly when a breach of totalSupply has occurred. It is necessary to freeze everything and investigate.
- Important that token transfers cannot occur, to avoid obfuscating evidence.

The exception to this is the MocaToken contract. We do not implement Pausable on it, as that would require implementing Ownable it.
It is thought that pausing the Adaptor contract adjacent to it should be sufficient in limiting attack vectors arising from LayerZero.

## Remediation

Unknown. Successful resolution may not be possible, particularly in extreme circumstances.
In minor one-off instances, where the value lost through attack or bugged execution, the treasury could step-in and buy up that supply or cover user losses.