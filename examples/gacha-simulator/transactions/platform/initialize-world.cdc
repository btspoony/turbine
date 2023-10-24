#allowAccountLinking

import "FungibleToken"
import "FlowToken"

import "GachaPlatform"

transaction(
    name: String,
    pubKey: String,
    initialFundingAmt: UFix64,
) {
    prepare(acct: AuthAccount) {
        let platformPubRef = GachaPlatform.borrowPlatform()
        assert(platformPubRef.hasWorld(name) == false, message: "World name already exists")

        // Account creation and linking

        // Create the child account, funding via the signing app account
        let newAccount = AuthAccount(payer: acct)
        // Create a public key for the child account from string value in the provided arg
        // **NOTE:** You may want to specify a different signature algo for your use case
        let key = PublicKey(
            publicKey: pubKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm.ECDSA_P256
        )
        // Add the key to the new account
        // **NOTE:** You may want to specify a different hash algo & weight best for your use case
        newAccount.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm.SHA3_256,
            weight: 1000.0
        )

        /* ---  Additional Account Funding --- */
        //
        // Fund the new account if specified
        if initialFundingAmt > 0.0 {
            // Get a vault to fund the new account
            let fundingProvider = acct.borrow<&FlowToken.Vault{FungibleToken.Provider}>(
                    from: /storage/flowTokenVault
                )!
            // Fund the new account with the initialFundingAmount specified
            let receiverCap = newAccount.getCapability(/public/flowTokenReceiver)
                .borrow<&FlowToken.Vault{FungibleToken.Receiver}>()
                ?? panic("Could not borrow receiver reference to the new account")
            receiverCap.deposit(
                from: <- fundingProvider.withdraw(amount: initialFundingAmt)
            )
            let vaultRef = newAccount.getCapability(/public/flowTokenBalance)
                .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
                ?? panic("Could not borrow Balance reference to the Vault")
            log("Flow Balance: ".concat(vaultRef.balance.toString()))
        }

        // Link the new account to the platform
        let cap = newAccount.capabilities.account.issue<&AuthAccount>()
        GachaPlatform.createGachaWorld(cap, name: name)

        log("Initialized gacha world with new account")
    }
}
