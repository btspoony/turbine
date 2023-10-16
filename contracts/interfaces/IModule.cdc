
/// The contract interface for the entity resource
///
pub contract interface IModule {

    /// Returns the name of the module
    pub resource interface ModulePublic {
        /// Returns the name of the module
        pub view fun getName()
    }

    pub resource interface Installer {
        access(account)
        fun installRoot(opts: {String: AnyStruct}) {
            panic("Root install is not supported")
        }

        access(account)
        fun install(opts: {String: AnyStruct}) {
            panic("NonRoot install is not supported")
        }
    }

    pub resource Module: ModulePublic, Installer  {
        pub view fun getName()
        access(account) fun installRoot(opts: {String: AnyStruct})
        access(account) fun install(opts: {String: AnyStruct})
    }

    pub fun createModule(name: String): @Module
}
