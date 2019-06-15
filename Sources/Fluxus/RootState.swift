import SwiftUI
import Combine

@available(OSX 10.15, iOS 13, *)
open class RootState: BindableObject {
  public var didChange = PassthroughSubject<Void, Never>()

  public init() {}
}
