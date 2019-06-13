import SwiftUI
import Combine

@available(OSX 10.15, iOS 13, *)
public class FluxStore: BindableObject {
  public var didChange = PassthroughSubject<Void, Never>()

  public let state: RootState
  public let rootCommitter: RootCommitter
  public let rootDispatcher: RootDispatcher

  public init(withState: RootState, withCommitter: RootCommitter, withDispatcher: RootDispatcher) {
    state = withState
    rootCommitter = withCommitter
    rootDispatcher = withDispatcher
  }

  public func commit(_ mutation: Mutation) {
    rootCommitter.commit(state: state, mutation: mutation)
  }

  public func dispatch(_ action: Action) {
    rootDispatcher.dispatch(store: self, action: action)
  }
}
