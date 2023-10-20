#allowAccountLinking

import "CoreWorld"

transaction {
    prepare(acct: AuthAccount) {
        // check if the platform is already created
        if acct.borrow<&AnyResource>(from: CoreWorld.WorldManagerStoragePath) == nil {
            // create a account capability
            let cap = acct.capabilities.account.issue<&AuthAccount>()
            CoreWorld.createManager(admin: cap)

            log("WorldManager created")
        }
    }
}
