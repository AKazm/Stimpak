import Foundation

public extension Container {
  
  @discardableResult
  public func unregister<Service>(_ type: Service.Type, key: AnyHashable? = nil) -> Bool {
    return unregister(ResolverKey<Service, Void>(key))
  }
  
  private func unregister<Service>(_ key: ResolverKey<Service, Void>) -> Bool {
    
    if resolvers.keys.contains(key) {
      return lock.locked({
        resolvers.removeValue(forKey: key)
        return true
      })
    }
    return false
    
  }
  
  @discardableResult
  public func register<Service: Instantiable>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse,
                                              key: AnyHashable? = nil) -> ServiceResolver<Service, Void> {
    
    return try! self.register(type, { () -> Service in Service.init() }, reuse: reuse, key: key,
            ifRegistered: Container.DefaultIfRegistered)
    
  }
  
  @discardableResult
  public func register<Service: Instantiable>(_ type: Service.Type, reuse: Reuse = Container.DefaultReuse,
                                              key: AnyHashable? = nil,
                                              ifRegistered: IfRegistered) throws -> ServiceResolver<Service, Void> {
    
    return try self.register(type, { () -> Service in Service.init() }, reuse: reuse, key: key,
            ifRegistered: ifRegistered)
    
  }
  
  public func resolve<Service>(_ serviceType: Service.Type = Service.self, _ key: AnyHashable? = nil)
                  -> Service? {
    return self.rootScope.internalResolve(serviceType, Void.self, (), key)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: Service.Type) {
    lhs.register(rhs)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, IfRegistered)) throws {
    try lhs.register(rhs.0, ifRegistered: rhs.1)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, AnyHashable)) {
    lhs.register(rhs.0, key: rhs.1)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, Reuse)) {
    lhs.register(rhs.0, reuse: rhs.1)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, Reuse, AnyHashable)) {
    lhs.register(rhs.0, reuse: rhs.1, key: rhs.2)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, Reuse, IfRegistered)) throws {
    try lhs.register(rhs.0, reuse: rhs.1, ifRegistered: rhs.2)
  }
  
  public static func +=<Service: Instantiable>(lhs: Container, rhs: (Service.Type, Reuse, AnyHashable,
                                                                     IfRegistered)) throws {
    try lhs.register(rhs.0, reuse: rhs.1, key: rhs.2, ifRegistered: rhs.3)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service)) {
    lhs.register(rhs.0, rhs.1)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, IfRegistered)) throws {
    try lhs.register(rhs.0, rhs.1, reuse: Container.DefaultReuse, ifRegistered: rhs.2)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, AnyHashable)) {
    lhs.register(rhs.0, rhs.1, key: rhs.2)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, Reuse)) {
    lhs.register(rhs.0, rhs.1, reuse: rhs.2)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, Reuse,
                                                       AnyHashable)) {
    lhs.register(rhs.0, rhs.1, reuse: rhs.2, key: rhs.3)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, Reuse,
                                                       IfRegistered)) throws {
    try lhs.register(rhs.0, rhs.1, reuse: rhs.2, ifRegistered: rhs.3)
  }
  
  public static func +=<Service>(lhs: Container, rhs: (Service.Type, () -> Service, Reuse,
                                                       AnyHashable, IfRegistered)) throws {
    try lhs.register(rhs.0, rhs.1, reuse: rhs.2, key: rhs.3, ifRegistered: rhs.4)
  }
  
}