public protocol Committer {
  associatedtype StateType: State
  associatedtype MutationType: Mutation
  
  func commit(state: StateType, mutation: MutationType) -> Void
}
