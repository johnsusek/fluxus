import SwiftUI
import Combine

@available(OSX 10.15, iOS 13, *)
open class RootGetters<T>: BindableObject {
  public var didChange = PassthroughSubject<Void, Never>()

  public var rootState: T

  public init(withState: T) {
    self.rootState = withState
  }
}
