public extension Container {
    
    @discardableResult
    func unregister<Service, Args>(_ type: Service.Type, _ argType: Args.Type, key: AnyHashable? = nil) -> Bool {
        return unregister(ResolverKey<Service, Args>(key))
    }
    
    private func unregister<Service, Args>(_ key: ResolverKey<Service, Args>) -> Bool {
        if !resolvers.keys.contains(key) {
            return false
        }
        return lock.locked({
            resolvers.removeValue(forKey: key)
            return true
        })
    }
    
    func resolve<Service, Args>(_ serviceType: Service.Type = Service.self, _ args: Args,
                                _ key: AnyHashable? = nil) -> Service? {
        return self.rootScope.internalResolve(serviceType, Args.self, args, key)
    }

}
