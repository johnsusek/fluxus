public protocol FluxState {}

public protocol Mutation {}

public protocol Committer {
  associatedtype StateType: FluxState
  associatedtype MutationType: Mutation
  func commit(state: StateType, mutation: MutationType) -> StateType
}

public protocol Action {}

public protocol Dispatcher {
  associatedtype ActionType: Action
  var commit: (Mutation) -> Void { get set }
  func dispatch(action: ActionType)
}
