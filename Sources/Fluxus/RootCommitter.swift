@available(OSX 10.15, iOS 13, *)
public protocol RootCommitter {
  func commit(state: RootState, mutation: Mutation)
}
