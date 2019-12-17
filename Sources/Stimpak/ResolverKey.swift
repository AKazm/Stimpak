internal final class ResolverKey<Service, Args>: Hashable {
    
    internal let key: AnyHashable?
    internal let serviceType = Service.self
    internal let argsType = Args.self
    
    internal init(_ key: AnyHashable? = nil) {
        self.key = key
    }
    
    func hash(into: inout Hasher) {
        into.combine(ObjectIdentifier(serviceType))
        into.combine(ObjectIdentifier(argsType))
        into.combine(key?.hashValue ?? 0)
    }
    
    static func ==(lhs: ResolverKey<Service, Args>, rhs: ResolverKey<Service, Args>) -> Bool {
        return lhs.serviceType == rhs.serviceType && lhs.argsType == rhs.argsType && rhs.key == lhs.key
    }
}
