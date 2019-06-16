@available(OSX 10.15, iOS 13, *)
open class Getters<T, Y, U> {
  public var state: T
  public var rootGetters: Y
  public var rootState: U

  public init(withState: T, rootGetters: Y, rootState: U) {
    self.state = withState
    self.rootGetters = rootGetters
    self.rootState = rootState
  }
}

