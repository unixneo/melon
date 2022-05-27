# The Melon Coin

This repository coins a blockchain and cryptocurrency implemented from scratch in Ruby.

The goal of this repository is to understand better how blockchains work and how to implement one. Read the [associated article to learn more](https://antoinefink.com/building-a-blockchain-and-cryptocurrency-in-ruby).

## Env Vars:

```command
export MELON_ROOT=/path/to/app/root/melon          # example only
export MELON_PORT=4567
export MELON_PEERS=localhost:4567,localhost,4568   # example only
```

## Known Issues, Unknowns or Bugs:

- Mining rewards appear to be broken.  Need to confirm this, but it appears that mining reward transactions are provided on the same reward transactions, which provides an infinite loop of miners getting rewarded on their mining rewards and so block are infinitely added to the Melon blockchain for each active minor.
- Prototype keeps mining new blocks when there are no transactions
- Not sure why the blockchain was stored in a DB in the original code (each block is a row in a db), need to check how security is done
- Not clear how the pending transaction DB table works

## Otherwise, this is a fun tool to learn on !! :)


