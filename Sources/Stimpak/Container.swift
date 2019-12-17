public final class Container {
    
    internal let lock = RecursiveMutex()
    internal var resolvers = [AnyHashable: ServiceResolverProtocol]()
    internal lazy var rootScope = Scope(0xB16B00B5, container: self)
    
    public static let DefaultIfRegistered = IfRegistered.skip
    public static let DefaultReuse = Reuse.transient
    
    public init() { }
    
    internal func getResolver<Service, Args>(_ resolverKey: ResolverKey<Service, Args>) -> ServiceResolver<Service, Args>? {
        return resolvers[resolverKey] as? ServiceResolver<Service, Args>
    }
    
    internal func getResolver<Service>(_ resolverKey: ResolverKey<Service, Void>) -> ServiceResolver<Service, Void>? {
        return resolvers[resolverKey] as? ServiceResolver<Service, Void>
    }
    
    private func _register<Service, Args>(_ type: Service.Type, _ reuse: Reuse = Container.DefaultReuse,
                                          key: AnyHashable? = nil, ifRegistered: IfRegistered,
                                          _ resolver: @escaping (_ args: Args) -> Service) throws
        -> ServiceResolver<Service, Args> {
            
            let resolverKey = ResolverKey<Service, Args>(key)
            
            if !resolvers.keys.contains(resolverKey) {
                return lock.locked({
                    let serviceResolver = ServiceResolver<Service, Args>(resolver, reuse)
                    resolvers[resolverKey] = serviceResolver
                    return serviceResolver
                })
            }
            
            switch ifRegistered {
                case .skip:
                    return resolvers[resolverKey] as! ServiceResolver<Service, Args>
                case .replace:
                    return lock.locked({
                        let serviceResolver = ServiceResolver<Service, Args>(resolver, reuse)
                        resolvers[resolverKey] = serviceResolver
                        return serviceResolver
                    })
                case .throwErr:
                    throw AlreadyRegisteredError(service: resolvers[resolverKey] as! ServiceResolver<Service, Args>)
            }
            
    }
    
    private func selfDispose() {
        resolvers.removeAll()
    }
    
}

extension Container {
    
    @discardableResult
    public func register<Service>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                  _ resolver: @escaping () -> Service)
        -> ServiceResolver<Service, Void> {
            return try! _register(type, reuse, key: key, ifRegistered: Container.DefaultIfRegistered, resolver)
    }
    
    @discardableResult
    public func register<Service>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                  ifRegistered: IfRegistered, _ resolver: @escaping () -> Service) throws
        -> ServiceResolver<Service, Void> {
            return try! _register(type, reuse, key: key, ifRegistered: ifRegistered, resolver)
    }
    
    @discardableResult
    public func register<Service, Args>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                        _ argType: Args.Type = Args.self, _ resolver: @escaping (_ args: Args) -> Service)
        -> ServiceResolver<Service, Args> {
            return try! _register(type, reuse, key: key, ifRegistered: Container.DefaultIfRegistered, resolver)
    }
    
    @discardableResult
    public func register<Service, Args>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                        ifRegistered: IfRegistered, _ argType: Args.Type = Args.self,
                                        _ resolver: @escaping (_ args: Args) -> Service) throws
        -> ServiceResolver<Service, Args> {
            return try! _register(type, reuse, key: key, ifRegistered: ifRegistered, resolver)
    }
    
}
