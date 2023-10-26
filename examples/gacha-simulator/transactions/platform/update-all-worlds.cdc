import "GachaPlatform"

/// Update all registered worlds
/// This is called by the platform owner
transaction {
    prepare(acct: AuthAccount) {
        let platform = acct.borrow<&GachaPlatform.Platform>(from: GachaPlatform.GachaPlatformStoragePath)
            ?? panic("Cannot borrow platform from storage")
        let now = getCurrentBlock().timestamp
        platform.updateAll(now)
    }
}
