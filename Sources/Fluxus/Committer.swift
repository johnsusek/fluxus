public protocol Committer {
  associatedtype StateType: FluxState
  associatedtype MutationType: Mutation
  
  func commit(state: StateType, mutation: MutationType) -> Void
}
