import Foundation

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
  
  private func _register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service,
                                        _ reuse: Reuse = Container.DefaultReuse,
                                        key: AnyHashable? = nil, ifRegistered: IfRegistered) throws
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
  public func register<Service>(_ type: Service.Type, _ resolver: @escaping () -> Service,
                                reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil)
                  -> ServiceResolver<Service, Void> {
    return try! _register(type, resolver, reuse, key: key, ifRegistered: Container.DefaultIfRegistered)
  }
  
  @discardableResult
  public func register<Service>(_ type: Service.Type, _ resolver: @escaping () -> Service,
                                reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                ifRegistered: IfRegistered) throws
                  -> ServiceResolver<Service, Void> {
    return try! _register(type, resolver, reuse, key: key, ifRegistered: ifRegistered)
  }
  
  @discardableResult
  public func register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service,
                                      reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                      _ argType: Args.Type = Args.self)
                  -> ServiceResolver<Service, Args> {
    return try! _register(type, resolver, reuse, key: key, ifRegistered: Container.DefaultIfRegistered)
  }
  
  @discardableResult
  public func register<Service, Args>(_ type: Service.Type, _ resolver: @escaping (_ args: Args) -> Service,
                                      reuse: Reuse = Container.DefaultReuse, key: AnyHashable? = nil,
                                      ifRegistered: IfRegistered, _ argType: Args.Type = Args.self) throws
                  -> ServiceResolver<Service, Args> {
    return try! _register(type, resolver, reuse, key: key, ifRegistered: ifRegistered)
  }
  
}