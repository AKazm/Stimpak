public extension Container {
    
    @discardableResult
    func unregister<Service>(_ type: Service.Type, key: AnyHashable? = nil) -> Bool {
        return unregister(ResolverKey<Service, Void>(key))
    }
    
    private func unregister<Service>(_ key: ResolverKey<Service, Void>) -> Bool {
        if !resolvers.keys.contains(key) {
            return false
        }
        return lock.locked({
            resolvers.removeValue(forKey: key)
            return true
        })
    }
    
    @discardableResult
    func register<Service: Instantiable>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse,
                                         key: AnyHashable? = nil) -> ServiceResolver<Service, Void> {
        return try! self.register(type, reuse: reuse, key: key, ifRegistered: Container.DefaultIfRegistered) { () -> Service in Service.init() }
    }
    
    @discardableResult
    func register<Service: Instantiable>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse,
                                         key: AnyHashable? = nil,
                                         ifRegistered: IfRegistered) throws -> ServiceResolver<Service, Void> {
        return try self.register(type, reuse: reuse, key: key, ifRegistered: ifRegistered) { () -> Service in Service.init() }
    }
    
    func resolve<Service>(_ serviceType: Service.Type = Service.self, _ key: AnyHashable? = nil)
        -> Service? {
            return self.rootScope.internalResolve(serviceType, Void.self, (), key)
    }
    
}
