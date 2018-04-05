extension Container: ScopeProtocol {
		public var scopeKey: AnyHashable {
				get {
						return rootScope._scopeKey
				}
		}
		
		public func isSubScope() -> Bool {
				return false
		}
		
		public func resolve<Service>(_ serviceType: Service.Type) -> Service? {
				return self.rootScope.internalResolve(serviceType, Void.self, (), nil)
		}
		
		public func resolve<Service>(_ serviceType: Service.Type, _ key: AnyHashable) -> Service? {
				return self.rootScope.internalResolve(serviceType, Void.self, (), key)
		}
		
		public func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args) -> Service? {
				return self.rootScope.internalResolve(serviceType, Args.self, args, nil)
		}
		
		public func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args, _ key: AnyHashable) -> Service? {
				return self.rootScope.internalResolve(serviceType, Args.self, args, key)
		}
		
		public subscript(_ key: AnyHashable) -> ScopeProtocol? {
				return self.rootScope.subScopes[key]
		}
		
		public func dispose() {
				rootScope.dispose()
		}
		
		public func disposeScope(_ scope: ScopeProtocol) {
				rootScope.disposeScope(scope)
		}
		
		public func disposeScope(_ key: AnyHashable) {
				rootScope.disposeScope(key)
		}
		
		@discardableResult
		public func openScope(_ key: AnyHashable) -> ScopeProtocol {
				return rootScope.openScope(key)
		}
		
}
