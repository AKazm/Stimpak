//Credit goes to Tommy van der Vorst, https://gist.github.com/pixelspark
//https://gist.github.com/pixelspark/e5836624303083ea2f04d59c25a468dd
import Foundation

final class RecursiveMutex {
  
  private var mutex: pthread_mutex_t = pthread_mutex_t()
  
  public init() {
    var attr: pthread_mutexattr_t = pthread_mutexattr_t()
    pthread_mutexattr_init(&attr)
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
    
    let err = pthread_mutex_init(&self.mutex, &attr)
    pthread_mutexattr_destroy(&attr)
    
    switch err {
      case 0:
        // Success
        break
      
      case EAGAIN:
        fatalError("Could not create mutex: EAGAIN (The system temporarily lacks the resources to create another mutex.)")
      
      case EINVAL:
        fatalError("Could not create mutex: invalid attributes")
      
      case ENOMEM:
        fatalError("Could not create mutex: no memory")
      
      default:
        fatalError("Could not create mutex, unspecified error \(err)")
    }
  }
  
  private final func lock() {
    let ret = pthread_mutex_lock(&self.mutex)
    switch ret {
      case 0:
        // Success
        break
      
      case EDEADLK:
        fatalError("Could not lock mutex: a deadlock would have occurred")
      
      case EINVAL:
        fatalError("Could not lock mutex: the mutex is invalid")
      
      default:
        fatalError("Could not lock mutex: unspecified error \(ret)")
    }
  }
  
  private final func unlock() {
    let ret = pthread_mutex_unlock(&self.mutex)
    switch ret {
      case 0:
        // Success
        break
      
      case EPERM:
        fatalError("Could not unlock mutex: thread does not hold this mutex")
      
      case EINVAL:
        fatalError("Could not unlock mutex: the mutex is invalid")
      
      default:
        fatalError("Could not unlock mutex: unspecified error \(ret)")
    }
  }
  
  deinit {
    assert(pthread_mutex_trylock(&self.mutex) == 0 && pthread_mutex_unlock(&self.mutex) == 0, "deinitialization of a locked mutex results in undefined behavior!")
    pthread_mutex_destroy(&self.mutex)
  }
  
  @discardableResult public final func locked<T>(_ block: () throws -> (T)) throws -> T {
    return try self.tryLocked(block)
  }
  
  @discardableResult public final func locked<T>(_ block: () -> (T)) -> T {
    return try! self.tryLocked(block)
  }
  
  /** Execute the given block while holding a lock to this mutex. */
  @discardableResult public final func tryLocked<T>(_ block: () throws -> (T)) throws -> T {
    self.lock()
    
    defer {
      self.unlock()
    }
    let ret: T = try block()
    return ret
  }
}

