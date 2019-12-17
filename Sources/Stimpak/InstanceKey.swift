internal final class InstanceKey<Service, Args>: Hashable {
    
    internal let serviceType = Service.self
    internal let argsType = Args.self
    
    internal let reuse: Reuse
    internal let key: AnyHashable?
    internal let args: Args?
    internal weak var srcResolver: ServiceResolver<Service, Args>?
    
    internal init(_ src: ServiceResolver<Service, Args>, _ key: AnyHashable? = nil, _ reuse: Reuse) {
        self.reuse = reuse
        self.key = key
        self.args = nil
        self.srcResolver = nil
    }
    
    internal init(_ src: ServiceResolver<Service, Args>, _ key: AnyHashable? = nil, _ args: Args, _ reuse: Reuse) {
        self.reuse = reuse
        self.key = key
        self.args = args
        self.srcResolver = nil
    }
    
    internal init(_ key: AnyHashable? = nil, _ reuse: Reuse) {
        self.srcResolver = nil
        self.reuse = reuse
        self.key = key
        self.args = nil
    }
    
    func hash(into: inout Hasher) {
        into.combine(ObjectIdentifier(serviceType))
        into.combine(ObjectIdentifier(argsType))
        into.combine(key?.hashValue ?? 0)
    }
    
    static func ==(lhs: InstanceKey<Service, Args>, rhs: InstanceKey<Service, Args>) -> Bool {
        
        let fieldsEqual = lhs.reuse == rhs.reuse
            && lhs.serviceType == rhs.serviceType
            && lhs.argsType == rhs.argsType
            && rhs.key == lhs.key
        if lhs.args == nil && rhs.args != nil {
            return false
        }
        if rhs.args == nil && lhs.args != nil {
            return false
        }
        if rhs.args == nil && lhs.args == nil {
            return fieldsEqual
        }
        if lhs.srcResolver?.argumentsEqual != nil {
            return fieldsEqual && lhs.srcResolver!.argumentsEqual!(lhs.args!, rhs.args!)
        }
        if rhs.srcResolver?.argumentsEqual != nil {
            return fieldsEqual && rhs.srcResolver!.argumentsEqual!(lhs.args!, rhs.args!)
        }
        return fieldsEqual
        
    }
}
