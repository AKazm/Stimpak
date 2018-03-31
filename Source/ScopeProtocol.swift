import Foundation

public protocol ScopeProtocol {
  
    var scopeKey: AnyHashable { get }
    func dispose()
    func disposeScope(_ scope: ScopeProtocol)
    func disposeScope(_ key: AnyHashable)
    func openScope(_ key: AnyHashable) -> ScopeProtocol
    func isSubScope() -> Bool
    func resolve<Service>(_ serviceType: Service.Type) -> Service?
    func resolve<Service>(_ serviceType: Service.Type, _ key: AnyHashable) -> Service?
    func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args) -> Service?
    func resolve<Service, Args>(_ serviceType: Service.Type, _ args: Args, _ key: AnyHashable) -> Service?
    subscript(_ key: AnyHashable) -> ScopeProtocol? { get }
  
}
