# Stimpak
## Swift Dependency Injection Container

Stimpak is a Dependency Injection Container written in Swift. It is inspired by [DryIoc](https://bitbucket.org/dadhi/dryioc) and by
Java's [CDI](http://www.cdi-spec.org/).

Please note that this documentation is WIP. If you have any questions, please [create an issue](https://github.com/AKazm/Stimpak/issues).

## Examples

## Basics



```swift
public class Foo {

	public init() {

	}

}

//Create a new container
var container = Container()

//Register Foo as a service using register ...
container.register(Foo.self, { () -> Foo in return Foo.init() })
//... or using the += operator:
container += (Foo.self, { () -> Foo in return Foo.init() })

//Resolve a new instance of Foo
let foo = container.resolve(Foo.self)!
```

### Scoping & Reuse

Stimpak supports scoping in a very flexible way. You can open a scope by calling `openScope(_:AnyHashable)`:

```swift
//Create a new container
let container = Container()

let myScope = container.openScope(UUID().uuidString)
```

You can then dispose the scope using either `myScope.dispose()` or `container.disposeScope(myScope)`. Any scope can open and dispose new scopes, so you can open and dispose entire scope hierarchies.

The lifecycle of your dependencies depends on their registered `Reuse`, which is either `.transient` (default), `.singleton` or `.inScope`.

`.transient` dependencies are never stored in any scope whatsoever,

`.singleton` dependencies are only stored in the root scope of the container across a scope hierarchy. They are only disposed when the container scope itself is disposed.

`.inScope` dependencies are bound to the resolving scope. Consider the following example:

```swift
var container = Container()
container += (Foo.self, { () -> Foo in return Foo.init() }, Reuse.inScope)

let aScope = container.openScope(UUID().uuidString)
let bScope = aScope.openScope(UUID().uuidString)

let aFoo = aScope.resolve(Foo.self)
let bFoo = bScope.resolve(Foo.self)
```

`aFoo` and `bFoo` are different instances because they have been resolved from within different scopes.

### Register & Resolve with arguments

Stimpak supports registering and resolving dependencies using tuples.

```swift
container += (Foo.self, { (_ a: String, _ b: String) -> Foo in return Foo(a, b) }, Reuse.inScope )
container.register(Foo.self, { (_ a: String, _ b: String) -> Foo in return Foo(a, b) }, reuse: Reuse.inScope )

container.resolve(Foo.self, ("Bill", "Gates"))
```

`register` returns a `ServiceResolver<Foo, (String, String)>` in this case. You can specify an `ArgEqualityComparator` as well as an instantiation callback for ServiceResolvers. `ArgEqualityComparator` is important if you do want to prevent that ...

```swift
let gates = container.resolve(Foo.self, ("Bill", "Gates"))
let supposedSteve = container.resolve(Foo.self, ("Steve", "Jobs"))
```

... both return a Foo with first name Bill and last name Gates:

```swift
container.register(Foo.self, { (_ a: String, _ b: String) -> Foo in return Foo(a, b) }, reuse: Reuse.inScope )
				.compareArgsBy( { ( a: (String, String), b: (String, String) ) -> Bool in return a.0 == b.0 && a.1 == a.1 })
```

You can also specify keys of type `AnyHashable` as a registration argument:

```swift
container.register(Foo.self, { (_ a: String, _ b: String) -> Foo in return Foo(a, b) }, reuse: Reuse.inScope, key: "A" )
container.register(Foo.self, { (_ a: String, _ b: String) -> Foo in return Foo(a, b) }, reuse: Reuse.inScope, key: "B" )

container.resolve(Foo.self, ("Bill", "Gates"), "A")
```

### Instantiable-Protocol

Stimpak comes with a simple Protocol called `Instantiable`. Each struct or class conforming to `Instantiable` is required to implement a default initializer.

```swift
public class Foo : Instantiable {

	public required init() {

	}

}
```

`Foo` can now be registered as a dependency like this:

```swift
container += (Foo.self, Reuse.singleton)
```
