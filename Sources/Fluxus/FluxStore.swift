import SwiftUI
import Combine

@available(OSX 10.15, iOS 13, *)
public class FluxStore<T>: BindableObject {
  public var didChange = PassthroughSubject<Void, Never>()

  public let state: RootState
  public let rootCommitter: RootCommitter
  public let getters: T
  //  let rootDispatcher: Dispatcher

  public init(withState: RootState, withCommitter: RootCommitter, withGetter: T) {
    state = withState
    rootCommitter = withCommitter
    getters = withGetter
    //    rootDispatcher = withDispatcher
  }

  public func commit(_ mutation: Mutation) {
    rootCommitter.commit(state: state, mutation: mutation)
  }

  //
  //  func dispatch(_ action: Action) {
  //    rootDispatcher.dispatch(store: self, action: action)
  //  }
}
