import Foundation

internal class ResolverKey<Service, Args>: Hashable {
		
		internal let key: AnyHashable?
		internal let serviceType = Service.self
		internal let argsType = Args.self
		
		internal init(_ key: AnyHashable? = nil) {
				self.key = key
		}
		
		var hashValue: Int {
				get {
						return ObjectIdentifier(serviceType).hashValue ^ ObjectIdentifier(argsType).hashValue ^ (key?.hashValue ?? 0)
				}
		}
		
		static func ==(lhs: ResolverKey<Service, Args>, rhs: ResolverKey<Service, Args>) -> Bool {
				return lhs.serviceType == rhs.serviceType && lhs.argsType == rhs.argsType && rhs.key == lhs.key
		}
}
