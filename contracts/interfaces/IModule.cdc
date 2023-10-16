
/// The contract interface for the module, which is the basic unit of the
/// application. A module is a collection of systems that provide a specific
/// functionality. A module can be installed in the application and can be used
/// by other modules.
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
