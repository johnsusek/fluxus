@available(OSX 10.15, iOS 13, *)
open class Getter<T, Y> {
  public var state: T
  public var getters: Y

  public init(withState: T, usingGetters: Y) {
    self.state = withState
    self.getters = usingGetters
  }
}

