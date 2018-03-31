import Foundation

public final class Container {
		
    internal let lock = NSLock()
    internal var resolvers = [AnyHashable: ServiceResolverProtocol]()
    internal lazy var rootScope = Scope(0xB16B00B5, container: self)
    public static let DefaultIfRegistered = IfRegistered.skip
    public static var DefaultReuse = Reuse.inScope
    
    public init() {
    }
    
    internal func getResolver<Service, Args>(_ resolverKey: ResolverKey<Service, Args>) -> ServiceResolver<Service, Args>? {
        return resolvers[resolverKey] as? ServiceResolver<Service, Args>
    }
    
    internal func getResolver<Service>(_ resolverKey: ResolverKey<Service, Void>) -> ServiceResolver<Service, Void>? {
        return resolvers[resolverKey] as? ServiceResolver<Service, Void>
    }
  
    @discardableResult
    public func register<Service>(_ type: Service.Type, _ resolver: @escaping () -> Service, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil) -> ServiceResolver<Service, Void> {
        return try! _register(type, resolver, reuse, key: key, ifRegistered: Container.DefaultIfRegistered)
    }
  
    @discardableResult
    public func register<Service>(_ type: Service.Type, _ resolver: @escaping () -> Service, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil, ifRegistered: IfRegistered) throws
                    -> ServiceResolver<Service, Void> {
        return try! _register(type, resolver, reuse, key: key, ifRegistered: ifRegistered)
    }
  
    @discardableResult
    public func register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil, _ argType: Args.Type = Args.self)
										-> ServiceResolver<Service, Args> {
        return try! _register(type, resolver, reuse, key: key, ifRegistered: Container.DefaultIfRegistered)
    }
  
    @discardableResult
    public func register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service, reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil, ifRegistered: IfRegistered,
                                        _ argType: Args.Type = Args.self) throws -> ServiceResolver<Service, Args> {
        return try! _register(type, resolver, reuse, key: key, ifRegistered: ifRegistered)
    }
  
    private func _register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service, _ reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil, ifRegistered: IfRegistered) throws
										-> ServiceResolver<Service, Args> {
				
        let resolverKey = ResolverKey<Service, Args>(key)
        lock.lock()
        defer { lock.unlock() }
            
        if !resolvers.keys.contains(resolverKey) {
            let serviceResolver = ServiceResolver<Service, Args>(resolver, reuse)
            resolvers[resolverKey] = serviceResolver
            return serviceResolver
        }
        
        switch ifRegistered {
            case .skip:
                return resolvers[resolverKey] as! ServiceResolver<Service, Args>
            case .replace:
                let serviceResolver = ServiceResolver<Service, Args>(resolver, reuse)
                resolvers[resolverKey] = serviceResolver
                return serviceResolver
            case .throwErr:
                throw AlreadyRegisteredError(service: resolvers[resolverKey] as! ServiceResolver<Service, Args>)
        }
				
    }
	
	private func selfDispose() {
		resolvers.removeAll()
	}
		
}
