import Foundation

public enum IfRegistered {
		case skip
		case replace
		case throwErr
}

public struct AlreadyRegisteredError<Service, Args>: Error {
		
		let service: ServiceResolver<Service, Args>
		
}