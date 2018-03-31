import Foundation

public extension Container {
		
		@discardableResult
		public func unregister<Service, Args>(_ type: Service.Type, _ argType: Args.Type, key: AnyHashable? = nil) -> Bool {
			return unregister(ResolverKey<Service, Args>(key))
		}
		
		private func unregister<Service, Args>(_ key: ResolverKey<Service, Args>) -> Bool {
		
				if resolvers.keys.contains(key) {
						lock.lock()
						defer { lock.unlock() }
						resolvers.removeValue(forKey: key)
						return true
				}
				return false
				
		}
		
		public func resolve<Service, Args>(_ serviceType: Service.Type = Service.self, _ args: Args,
																			 _ key: AnyHashable? = nil) -> Service? {
				return self.rootScope.internalResolve(serviceType, Args.self, args, key)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, IfRegistered))
												throws {
				try lhs.register(rhs.0, rhs.1, reuse: Container.DefaultReuse, ifRegistered: rhs.2)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, AnyHashable)) {
				lhs.register(rhs.0, rhs.1, key: rhs.2)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, Reuse)) {
				lhs.register(rhs.0, rhs.1, reuse: rhs.2)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, Reuse,
																															 AnyHashable)) {
				lhs.register(rhs.0, rhs.1, reuse: rhs.2, key: rhs.3)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, Reuse,
																															 IfRegistered)) throws {
				try lhs.register(rhs.0, rhs.1, reuse: rhs.2, ifRegistered: rhs.3)
		}
		
		public static func +=<Service, Args>(lhs: Container, rhs: (Service.Type, (_ args: Args) -> Service, Reuse,
																															 AnyHashable, IfRegistered)) throws {
				try lhs.register(rhs.0, rhs.1, reuse: rhs.2, key: rhs.3, ifRegistered: rhs.4)
		}
}