# ![Fluxus](https://user-images.githubusercontent.com/611996/59575192-ec3a4980-907f-11e9-9073-4d32108a39f7.png)

⚠️ Fluxus is no longer maintained, and may not be using latest SwiftUI best practices.

👉 I encourage you to look at the [source of Fluxus](https://github.com/johnsusek/fluxus/blob/master/Sources/Fluxus/Fluxus.swift). If you do, you'll realize this is simply a pattern more than a framework, so please study and you can roll your own Vuex-style SwiftUI store. 



-----


Fluxus is an implementation of the Flux pattern for SwiftUI that replaces MVC, MVVM, Viper, etc. 
* Organize all your model data into a store and easily access in your views. 
* Use mutations to modify your app's state.
* Use actions to perform asynchronous operations.  
* Keep your models and views as simple as possible.

## Requirements

Xcode 11 beta on MacOS 10.14 or 10.15

## Installation

In Xcode, choose File -> Swift Packages -> Add Package Dependency and enter [this repo's URL](https://github.com/johnsusek/fluxus).

## Concepts

* **State** is the root source of truth for your app
* **Mutations** describe a synchronous change in state
* **Committers** apply mutations to the state
* **Actions** describe an asynchronous operation
* **Dispatchers** execute asynchronous actions and commit mutations when complete

![Obligatory Flux Diagram](https://user-images.githubusercontent.com/611996/59575032-4b4b8e80-907f-11e9-8fc3-9efe5aaa0682.png)

## When should I use it?

Fluxus helps us deal with shared state management at the cost of more concepts and boilerplate. If you're not building a complex app, and jump right into Fluxus, it may feel verbose and unnecessary. If your app is simple, you probably don't need it. But once your app grows to a certain complexity, you'll start looking for ways to organize shared state, and Fluxus is here to help with that. To quote Dan Abramov, author of Redux:

> Flux libraries are like glasses: you’ll know when you need them.

*Using Fluxus doesn't mean you should put **all** your state in Fluxus.* If a piece of state strictly belongs to a single View, it might be fine to just use local @State. Check out the landmarks example to see how local @State and Fluxus state can work together.

## Example apps

* The [minimal example app](https://github.com/johnsusek/fluxus-example-app) includes all the below code in a ready to run sample.
* The [landmarks example app](https://github.com/johnsusek/fluxus-landmark-example) is a reimplementation of the official landmarks tutorial app using fluxus.
* The [todo example app](https://github.com/johnsusek/fluxus-todo-example) is a very simple implementation of a todo list.

## Articles
* [Let's Write a To-Do App with Fluxus](https://www.notion.so/7e6f682ca7e24d0f8504eedfd0cec132)

## Usage

### Create state

State is the root source of truth for the model data in your app. We create one state module, for a counter, and add it to the root state struct.

```swift
import Fluxus

struct CounterState: FluxState {
  var count = 0

  var myBoolValue = false

  var countIsEven: Bool {
    get {
      return count % 2 == 0
    }
  }

  func countIsDivisibleBy(_ by: Int) -> Bool {
    return count % by == 0
  }
}

struct RootState {
  var counter = CounterState()
}
```

### Create mutations/committers

Mutations describe a change in state. Committers receive mutations and modify the state.

```swift
import Fluxus

enum CounterMutation: Mutation {
  case Increment
  case AddAmount(Int)
  case SetMyBool(Bool)
}

struct CounterCommitter: Committer {
  func commit(state: CounterState, mutation: CounterMutation) -> CounterState {
    var state = state

    switch mutation {
    case .Increment:
      state.count += 1
    case .AddAmount(let amount):
      state.count += amount
    case .SetMyBool(let value):
      state.myBoolValue = value
    }

    return state
  }
}
```

### Create actions/dispatchers

Actions describe an asynchronous operation. Dispatchers receive actions, then commit mutations when the operation is complete.

```swift 
import Foundation
import Fluxus

enum CounterAction: Action {
  case IncrementRandom
  case IncrementRandomWithRange(Int)
}

struct CounterDispatcher: Dispatcher {
  var commit: (Mutation) -> Void

  func dispatch(action: CounterAction) {
    switch action {
    case .IncrementRandom:
      IncrementRandom()
    case .IncrementRandomWithRange(let range):
      IncrementRandom(range: range)
    }
  }

  func IncrementRandom(range: Int = 100) {
    // Simulate API call that takes 150ms to complete
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(150), execute: {
      let exampleResultFromAsyncOperation = Int.random(in: 1..<range)
      self.commit(CounterMutation.AddAmount(exampleResultFromAsyncOperation))
    })
  }
}
```

### Create store

The store holds the current state. It also provides commit and dispatch methods, which route mutations and actions to the correct modules.

```swift
import SwiftUI
import Combine
import Fluxus

let rootStore = RootStore()

final class RootStore: BindableObject {
  var didChange = PassthroughSubject<RootStore, Never>()

  var state = RootState() {
    didSet {
      didChange.send(self)
    }
  }

  func commit(_ mutation: Mutation) {
    switch mutation {
    case is CounterMutation:
      state.counter = CounterCommitter().commit(state: self.state.counter, mutation: mutation as! CounterMutation)
    default:
      print("Unknown mutation type!")
    }
  }

  func dispatch(_ action: Action) {
    switch action {
    case is CounterAction:
      CounterDispatcher(commit: self.commit).dispatch(action: action as! CounterAction)
    default:
      print("Unknown action type!")
    }
  }
}
```

### Add store to environment

We now provide the store to our views inside SceneDelegate.swift.

```swift
window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(rootStore))
```

### Use in views

ContentView.swift:
```swift
import SwiftUI

struct ContentView : View {
  @EnvironmentObject var store: RootStore

  var body: some View {
    NavigationView {
      Form {
        // Read the count from the store, and use a getter function to decide color
        Text("Count: \(store.state.counter.count)")
          .color(store.state.counter.countIsDivisibleBy(3) ? .orange : .green)

        Section {
          // Commit a mutation without a param
          Button(action: { self.store.commit(CounterMutation.Increment) }) {
            Text("Increment")
          }

          // Commit a mutation with a param
          Button(action: { self.store.commit(CounterMutation.AddAmount(5)) }) {
            Text("Increment by amount (5)")
          }

          // Dispatch an action without a param
          Button(action: { self.store.dispatch(CounterAction.IncrementRandom) }) {
            Text("Increment random")
          }

          // Dispatch an action with a param
          Button(action: { self.store.dispatch(CounterAction.IncrementRandomWithRange(20)) }) {
            Text("Increment random with range (20)")
          }
        }

        // Use with bindings
        Toggle(isOn: myToggleBinding) {
          Text("My boolean is: \(myToggleBinding.value ? "true" : "false")")
        }
      }.navigationBarTitle(Text("Fluxus Example"))
    }
  }

  // Use computed properties to get/set state via a binding
  var myToggleBinding = Binding<Bool> (
    getValue: {
      rootStore.state.counter.myBoolValue
  },
    setValue: { value in
      rootStore.commit(CounterMutation.SetMyBool(value))
  })
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    return ContentView().environmentObject(rootStore)
  }
}
#endif
```

![Simulator Screen Shot - iPhone Xs - 2019-06-17 at 15 32 11](https://user-images.githubusercontent.com/611996/59634784-2dc90400-9115-11e9-9180-e4d4639d34d5.png)

💡 You should now have an app that demonstrates the basics of the flux pattern with Fluxus & SwiftUI. If you're having trouble getting this running, download the example app, or file a Github issue and we'll try to help.

## Where to go from here

Check out the [landmarks example app](https://github.com/johnsusek/fluxus-landmark-example) to see fluxus used in a more complex app environment. 

## Troubleshooting

**Swift/SourceKit are using 100% CPU!**

*This is a bug in Xcode 11 beta, it usually means something is wrong with your @EnvironmentObject, make sure you are passing .environmentObject() to your view correctly.*

*If you are presenting a new view (e.g. a modal) you will have to pass .environmentObject(store) to it, just like your root view controller.*

## Feedback

Please file an issue if you spot a bug or think of a better way to do something. 

Follow me on twitter [@jsusek](https://twitter.com/jsusek) for random thoughts on SwiftUI.

## Other SwiftUI Flux implementations 
* https://github.com/Dimillian/SwiftUIDemo
* https://github.com/pocket7878/swift-ui-redux-like
* https://github.com/alexdrone/DispatchStore
* https://github.com/StevenLambion/SwiftDux
* https://github.com/ra1028/SwiftUI-Flux
* https://github.com/kitasuke/SwiftUI-Flux

