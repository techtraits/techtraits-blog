--- 
layout: post
title: Understanding block chain
date: 2017-10-30 05:26:32
authors: 
- usman
categories: 
- cat
tags:
- blockchain
permalink: /blockchain
---

Crypto currencies and the block chain technology underlying them is racing towards the Peak of inflated expectations on the [Gartner Hype-Cycle](https://en.wikipedia.org/wiki/Hype_cycle#/media/File:Hype-Cycle-General.png). We have crossed the mass-media hype stage and our getting into the supplier proliferation stage. There is a lot written about block chain technologies and its various potential applications. Reactions to such articles generally fall in one of three categories, breathless enthusiasm, casual dismissal or confusion. As with all technologies in this stage there are some real benefits or use cases for block chains as well as a lot of opportunism. Hence, we wanted to take a step back see if there can be a framework for filtering the noise and identifying what are valid interesting directions to explore in this technology space. 

## Categorizing block chain applications

In order to understand what applications are suitable to be tackled using block chain based solutions we use three fairly simple rules:

1. Is this a problem that needs solving? 
2. Is this a problem that lends it self to being solved using a block-chain? 
3. Is the block chain based solution better than a centralized solution? 

There are few worse ways to spend time than looking for a problem to apply your solution on. However, the way venture funds operate and fund companies finding problems for the popular solution at the time is highly incentivised. Hence we need to first filter out applications that tackle a problem that is not all that problematic to begin with. We can be fairly lenient with this test as a problem that is solved for one person (specially one living in North America or Europe) may not be all that solved in another part of that world. The next test verifies if the underlying problem is a suitable fit for block-chain or not. Unfortunately, 'do it on a block chain' is the new 'Do it on a computer' and many classes of problems are not really suitable for block-chains at all. Block chains solve the problem of distributed consensus (described shortly), if the application does not require distributed consensus then they are probably not a fit for block chain. Thirdly, while some problems are worthy of solving and solvable using a block-chain, they may be more easily solved by other means. For example, Etherium in their [whitepaper](https://github.com/ethereum/wiki/wiki/White-Paper#further-applications) lists Cloud computing as one of the applications of their smart-contract framework. While this is undoubtedly possible the mechanics and cost of using the etherium block chain for general purpose large-scale computing in comparison on commercial offerings makes it impractical.  


Earlier we mentioned that the primary problem that block chains solve is how to achieve distributed consensus, i.e. How to reach agreement about the state of a system between many parties without a central arbitrator. This agreement must be reached even when that state is changing over time and some of the parties are malicious in their attempts to change the state. The *state* that a block chain maintains is a series of changes (or transactions) that happened since initial state. Examples of such states are the bitcoins in all wallets (as expressed by credit and debit transactions into each wallet) or who has which library books checked out (by keeping track of checkouts and returns). In order to reach agreement without an arbitrator block chains use two components: Public Key Cryptography to make you can make changes only to state you own (i.e. bitcoins in your wallet or books you have checked out) and voting to decide whose version of the change is accepted as the truth. 

## Limitations of block chains

The above examples help illustrate the three major limitations of block-chain based distributed consensus. The first issue its inability to verify external facts. In the library book only the Librarian knows if you returned a book, the block chain only knows that you have claimed to do so. Hence, even if the network agrees that ownership has passed from you to the library we don't know if you actually gave the book back. This not a problem in the bitcoin case, because the virtual good (bitcoin) is the item of value as opposed to a stand-in for a real item. Note that Etherium's smart contracts may allow for solutions to the specific library book example but the general problem of externally verifiable facts remains. There are tokens that track gold and USD and other assets but the central promise of the asset to token mapping is based on trusting the issuing authority.

The second limitation of block chain technology is the incentives of being honest and verifying transactions. Going back to the library book use-case if you claim to have returned a book and the library claims you did not, then the vote of all participants in the block chain network will decide the matter. However, other users have very little stake in whether you correctly report a returned book. Hence they are not incentivised to ensure you or the library is being honest. In the bitcoin case there is an incentive to maintain the integrity of the block-chain as it underpins the value of their bitcoin holdings. Furthermore, the receiver of the bitcoins can withhold delivering the paid for service until the block-chain stabilizes to agreed upon state. However, if the receiver is malicious at this point there is no recourse for the sender of the funds as is no reversibility mechanism. Note that given enough voting power even after the chain as agreed on a given state malicious actors can change history. This is discussed in the next paragraph.

Third limitation of block chain based systems is the voting mechanism. Simple plurality is not feasible without controls on who can vote. It is trivial to create new identities in the block chain and hence case an infinite number of votes. Therefore block chains use a proof of work to allow a vote. Without going to details block chains require you to run a very expensive probabilistic computation and your voting power is decided by how much computation you are able to do. The idea is that to have a voting majority you would need more computation than everyone else combined. Furthermore, there is an intrinsic reward in running this computation hence it should be more profitable to honestly run the computation rather than game the system. However, even with bitcoin the [top four mining pools](https://blockchain.info/pools) control more than 54% of the voting rights. Any collusion on their part will break the integrity of the block chain. In fact as there is no independent verification mechanism other than voting an even smaller percentage maybe needed for malicious updates as many non-malicious may accept and propagate seemingly valid transactions from a malicious node. 


Some Use case TODO Expand into paragraphs:

    * Currencies / ledger
        * There is no central global authority hence fulfills 1
    	* Needs distributed trust because you exchange with strangers hence fulfills 2
        * Normal Bank you can’t prove if bank fucks you over public ledger is better hence fulfills 3
        * Real reason why criminals like bit-coin not anonymity but easy to establish trust with strangers
    * Digital Voting
        * Vote fraud is common the world over hence fulfills 1
        * Design fulfills 2
        	* Each person generates a random wallet only they know id
        	* Each wallet can vote once
        	* Wallet to who they voted for is publicly known 
        	* Wallet to person is only known to person
        	* Person can validate their vote was successfully tracked
        * Problem is how to make sure # of wallets = # of voters?
        * fulfilling 3 is questionable based on the problem but still probably better than other systems 
    * Digital notary
    	* Probably fulfills 1 based on Notarization requires physical presence which makes it difficult for virtual documents
        * Design Fulfills 2
        	* Upload document to intermediary 
        	* Intermediary takes a hash and adds hash + timestamp to chain
        	* User can now prove that the given document existed at a given time in public record
        * Problems Still needs trusted intermediary to take hash otherwise you could just add any hash to chain
        * Trusted 
    * Identify verification 
    	* Sho Card
    * StayAWhile
        * 
    * Walmart supply chain 
        * http://fortune.com/2017/08/22/walmart-blockchain-ibm-food-nestle-unilever-tyson-dole/
    * Smart Contracts
        * https://github.com/ethereum/wiki/wiki/White-Paper
    * 
* Collusion issue
* Incentive issue
    * Benefit from legal mining must out-weigh reward from cheating
* Externalization of Input Issue