# Fluxus

True one-way data flow for SwiftUI, inspired by Vuex

## Requirements

Xcode 11 beta on MacOS 10.14 or 10.15

## Installation

Choose File -> Swift Packages -> Add Package Dependency and enter [this repo's .git URL](https://github.com/johnsusek/fluxus.git):

![](https://user-images.githubusercontent.com/611996/59441703-a00cb200-8dbe-11e9-8483-c740b8274595.gif)

For now just choose the master branch under rules; as this package matures semantic versioning will be adopted.

## Usage

### Minimal example

#### Create state
```swift
// Organize your state into modules, for this example we just use a single module
class AppRootState: RootState {
  let counterState = CounterState()
}

// Here is the state module we are using, just a simple BindableObject
class CounterState: FluxState, BindableObject {
  var didChange = PassthroughSubject<CounterState, Never>()

  var count: Int = 0 {
    didSet {
      didChange.send(self)
    }
  }
}
```

#### Create mutations/committers
```swift
// Mutations define a change in state
enum CounterMutation: Mutation {
  case Increment
}

// Committers apply mutations to state
final class CounterCommitter: Committer {
  func commit(state: CounterState, mutation: CounterMutation) {
    switch mutation {
    case .Increment:
      state.count += 1
    }
  }
}

// All mutations are first sent to the root committer, which routes them to the
// correct committer module
class AppRootCommitter: RootCommitter {
  let counterCommitter = CounterCommitter()

  // All mutations start here
  func commit(state rootState: RootState, mutation: Mutation) {
    guard let state = rootState as? AppRootState else { return }

    // Route to correct committer
    switch mutation {
    case is CounterMutation:
      // It's a counter mutation, commit it to the counter state
      counterCommitter.commit(state: state.counterState, mutation: mutation as! CounterMutation)
    default:
      print("Unknown mutation type: \(mutation)")
    }
  }
}
```

#### Connect to view

Inside SceneDelegate.swift's scene():

```swift
let state = AppRootState()
let committer = AppRootCommitter()
let store = FluxStore(withState: state, withCommitter: committer, withDispatcher: nil)

window.rootViewController = UIHostingController(rootView: ContentView()
  .environmentObject(store)
  .environmentObject(state.counterState))
```

#### Use in views

Inside ContentView.swift:
```swift
import Fluxus

struct ContentView: View {
  @EnvironmentObject var store: FluxStore
  @EnvironmentObject var counterState: CounterState

  var body: some View {
    VStack {
      Text("Count: \(counterState.count)")

      Button(action: { self.store.commit(CounterMutation.Increment) }) {
        Text("Increment")
      }
    }
  }
}
```

## Concepts

Coming soon, see https://vuex.vuejs.org/ for now...

## Feedback

Please take a look through the source and file an issue if you spot a bug or see a better way to do something.
