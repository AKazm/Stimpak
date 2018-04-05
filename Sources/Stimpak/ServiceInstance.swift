internal class ServiceInstance<Service, Args>: ServiceResolverProtocol {
		
		internal let reuse: Reuse
		internal let value: Service
		internal let args: Args
		
		internal let _serviceType = Service.self
		internal let _argType = Args.self
		
		internal init(_ instance: Service, _ reuse: Reuse, _ args: Args) {
				self.value = instance
				self.args = args
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
		
}
