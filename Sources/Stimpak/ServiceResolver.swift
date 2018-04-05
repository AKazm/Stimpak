public final class ServiceResolver<Service, Args>: ServiceResolverProtocol {
		public typealias ArgEqualityComparator = (Args, Args) -> Bool
		public typealias ResolverCallback = (_ scope: Scope, _ obj: Service) -> Void
		
		internal let reuse: Reuse
		internal let _argType = Args.self
		internal var _serviceType = Service.self
		
		internal let resolve: ((_ args: Args) -> Service)
		private(set) internal var argumentsEqual: ArgEqualityComparator? = nil
		private(set) internal var postInit: ResolverCallback? = nil
		
		public init(_ resolve: @escaping (Args) -> Service, _ reuse: Reuse) {
				self.resolve = resolve
				self.reuse = reuse
		}
		
		var argsType: Any.Type {
				get {
						return _argType
				}
		}
		
		var serviceType: Any.Type {
				get {
						return _serviceType
				}
		}
		
		@discardableResult
		public func compareArgsBy(_ eq: (ArgEqualityComparator)?) -> ServiceResolver<Service, Args> {
				self.argumentsEqual = eq
				return self
		}
		
		@discardableResult
		public func resolved(_ eq: (ResolverCallback)?) -> ServiceResolver<Service, Args> {
				self.postInit = eq
				return self
		}
		
}