@available(OSX 10.15, iOS 13, *)
public protocol RootDispatcher {
  func dispatch(store: FluxStore, action: Action)
}
