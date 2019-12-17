public final class Scope: ScopeProtocol {
    
    internal let lock = RecursiveMutex()
    internal weak var parentScope: Scope?
    internal var instances = [AnyHashable: ServiceResolverProtocol]()
    internal var subScopes = [AnyHashable: Scope]()
    internal let _scopeKey: AnyHashable
    
    private weak var _container: Container?
    
    internal init(_ scopeKey: AnyHashable, container: Container) {
        self._container = container
        self._scopeKey = scopeKey
    }
    
    internal init(_ scopeKey: AnyHashable, parent: Scope) {
        self._container = nil
        self._scopeKey = scopeKey
        self.parentScope = parent
    }
    
    public var scopeKey: AnyHashable {
        return _scopeKey
    }
    
    public subscript(_ key: AnyHashable) -> ScopeProtocol? {
        return self.subScopes[key]
    }
    
    public func dispose() {
        if parentScope == nil {
            lock.locked({ selfDispose() })
            return
        }
        parentScope!.disposeScope(_scopeKey)
    }
    
    public func disposeScope(_ scope: ScopeProtocol) {
        disposeScope(scope.scopeKey)
    }
    
    public func disposeScope(_ key: AnyHashable) {
        guard let scope = subScopes[key] else { return }
        lock.locked({
            scope.selfDispose()
            subScopes.removeValue(forKey: key)
        })
    }
    
    @discardableResult
    public func openScope(_ key: AnyHashable) -> ScopeProtocol {
        return lock.locked({
            if subScopes.keys.contains(key) {
                return subScopes[key]!
            }
            let scope = Scope(key, parent: self)
            subScopes[key] = scope
            return scope
        })
    }
    
    public func isSubScope() -> Bool {
        return parentScope != nil
    }
    
    public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return self.internalResolve(serviceType, Void.self, (), nil)
    }
    
    public func resolve<Service>(_ serviceType: Service.Type, _ key: AnyHashable) -> Service? {
        return self.internalResolve(serviceType, Void.self, (), key)
    }
    
    public func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args) -> Service? {
        return self.internalResolve(serviceType, Args.self, args, nil)
    }
    
    public func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args, _ key: AnyHashable) -> Service? {
        return self.internalResolve(serviceType, Args.self, args, key)
    }
    
    internal var isRootScope: Bool {
        return _container != nil && parentScope == nil
    }
    
    internal var container: Container? {
        if _container != nil {
            return _container
        }
        return parentScope?.container
    }
    
    internal func internalResolve<Service, Args>(_ resolverKey: ResolverKey<Service, Args>, _ args: Args) -> Service? {
        
        guard let resolver = container?.getResolver(resolverKey) else {
            return nil
        }
        return internalResolve(resolverKey, resolver, args)
        
    }
    
    internal func internalResolve<Service, Args>(_ objType: Service.Type = Service.self, _ argType: Args.Type,
                                                 _ args: Args, _ key: AnyHashable? = nil) -> Service? {
        return internalResolve(ResolverKey<Service, Args>(key), args)
    }
    
    private func internalResolve<Service, Args>(_ resolverKey: ResolverKey<Service, Args>,
                                                _ resolver: ServiceResolver<Service, Args>, _ args: Args) -> Service? {
        let instanceKey = InstanceKey<Service, Args>(resolver, resolverKey.key, args, resolver.reuse)
        if let instance = instances[instanceKey] as? ServiceInstance<Service, Args> {
            return instance.value
        }
        return lock.locked({
            switch resolver.reuse {
                case .singleton:
                    if (isRootScope) {
                        return storeNew(resolver, instanceKey, args)
                    }
                    return container?.rootScope.internalResolve(resolverKey, resolver, args)
                case .inScope:
                    return storeNew(resolver, instanceKey, args)
                case .transient:
                    let instance = resolver.resolve(args)
                    resolver.postInit?(self, instance)
                    return instance
                }
        })
    }
    
    private func storeNew<Service, Args>(_ resolver: ServiceResolver<Service, Args>,
                                         _ instanceKey: InstanceKey<Service, Args>, _ args: Args) -> Service {
        let instance = resolver.resolve(args)
        resolver.postInit?(self, instance)
        let serviceInstance = ServiceInstance(instance, resolver.reuse, args)
        instances[instanceKey] = serviceInstance
        return instance
    }
    
    private func selfDispose() {
        instances.removeAll()
        subScopes.removeAll()
    }
    
}
