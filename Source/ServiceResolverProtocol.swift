import Foundation

internal protocol ServiceResolverProtocol {

  var reuse: Reuse { get }
  var argsType: Any.Type { get }
  var serviceType: Any.Type { get }

}