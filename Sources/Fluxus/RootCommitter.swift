public protocol RootCommitter {
  func commit(state: RootState, mutation: Mutation)
}
