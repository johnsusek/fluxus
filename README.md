# Fluxus

Fluxus is an implementation of the Flux pattern for SwiftUI that replaces MVC, MVVM, Viper, etc. 
* Organize all your model data into a store and easily access in your views. 
* Use mutations and actions from your views to modify your app's state. 
* Use getters to retrieve data in exactly the format you need.
* No more business or formatting logic in your views!

## Requirements

Xcode 11 beta on MacOS 10.14 or 10.15

## Installation

In Xcode, choose File -> Swift Packages -> Add Package Dependency and enter [this repo's URL](https://github.com/johnsusek/fluxus).

## Concepts

* **State** is the root source of truth for your app
* **Mutations** describe a synchronous change in state
* **Committers** apply mutations to the state
* **Actions** describe an asynchronous operation
* **Dispatchers** execute actions and commit mutations when complete
* **Getters** organize logic related to retrieving data from the store

See https://vuex.vuejs.org/ to learn more about this style of architecture.

## Example apps

👉 It is strongly suggested you download and explore the example apps to get an idea of how data flows in fluxus. 

* The [simple example app](https://github.com/johnsusek/fluxus-example-app) includes all the below code in a ready to run sample.
* The [landmarks example app](https://github.com/johnsusek/fluxus-landmark-example) is a fluxus version of the [official landmarks tutorial](https://developer.apple.com/tutorials/swiftui/working-with-ui-controls).

<br>

## Usage

### 1) Minimal example

<hr>

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

Run your app and you should see the counter incrementing.

<br>

### 2) Add getters

<hr>

#### Create getter
```swift
// Getters centralize logic related to retrieving data from the store
class AppRootGetters: RootGetters<AppRootState> {
  var countIsEven: Bool {
    get {
      return state.counterState.count % 2 == 0
    }
  }
}
```

#### Update SceneDelegate
```swift
let state = AppRootState()
let committer = AppRootCommitter()
let store = FluxStore(withState: state, withCommitter: committer, withDispatcher: nil)
let getters = AppRootGetters(withState: state) // + Added line

window.rootViewController = UIHostingController(rootView: ContentView()
  .environmentObject(store)
  .environmentObject(getters) // + Added line
  .environmentObject(state.counterState))
```

#### Update View
```swift
import Fluxus

struct ContentView: View {
  @EnvironmentObject var store: FluxStore
  @EnvironmentObject var counterState: CounterState
  @EnvironmentObject var getters: AppRootGetters // + Added line

  var body: some View {
    VStack {
      Text("Count: \(counterState.count)")
        .color(getters.countIsEven ? .orange : .green) // + Added line

      Button(action: { self.store.commit(CounterMutation.Increment) }) {
        Text("Increment")
      }
    }
  }
}
```

Now the color will change based on the getter value. 

<br>

### 3) Add actions/dispatchers

<hr>

#### Create actions/dispatchers

```swift
// Actions define an async operation
enum CounterAction: Action {
  case IncrementRandom
}

// Dispatchers execute actions
final class CounterDispatcher: Dispatcher {
  func dispatch(store: FluxStore, action: CounterAction) {
    switch action {
    case .IncrementRandom:
      CounterDispatcher.IncrementRandom(store: store)
    }
  }

  static func IncrementRandom(store: FluxStore) {
    // This could be any async operation, API call, etc
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
      let exampleResultFromAsyncOperation = Int.random(in: 1..<100)
      // Async operation done, commit mutation
      store.commit(CounterMutation.AddAmount(exampleResultFromAsyncOperation))
    })
  }
}

// All actions are first sent to the root dispatcher, which routes them to the
// correct dispatcher module
final class AppRootDispatcher: RootDispatcher {
  let counterDispatcher = CounterDispatcher()

  func dispatch(store: FluxStore, action: Action) {
    switch action {
    case is CounterAction:
      counterDispatcher.dispatch(store: store, action: action as! CounterAction)
    default:
      print("Unknown action type: \(action)")
    }
  }
}
```

#### Update mutations

Our IncrementRandom action commits a CounterMutation.AddAmount(Int) mutation when it's done, so let's add that to our mutations:

```swift
enum CounterMutation: Mutation {
  case Increment
  case AddAmount(Int) // + Added line
}
```

And then implement it in our CounterCommitter:

```swift
final class CounterCommitter: Committer {
  func commit(state: CounterState, mutation: CounterMutation) {
    switch mutation {
    case .Increment:
      state.count += 1
    case .AddAmount(let amount): // + Added line
      state.count += amount // + Added line
    }
  }
}
```

#### Update SceneDelegate

```swift
let dispatcher = AppRootDispatcher() // + Added line
let store = FluxStore(withState: state, withCommitter: committer, withDispatcher: dispatcher) // ~ Updated line
```

#### Update ContentView

```swift
// +++ Added lines
Button(action: { self.store.dispatch(CounterAction.IncrementRandom) }) {
  Text("Increment Random (Async)")
}
```

The count will now update asynchronously as you dispatch the IncrementRandom action.

<br>

### Additional functionality

To be documented:

* Getter modules
* Getter functions
* Actions with params

<br>

## Feedback

Please take a look through the source and file an issue if you spot a bug or see a better way to do something.
