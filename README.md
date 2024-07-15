
# Network Operation Performer and Network Monitor 
Simple network operation class that allows for operation to wait until connection is available and timeout if necessary.

I have chosen to use a modern approach with `async/await` to avoid thread safety issues. I have gotten rid of the Timer and the Observer. The timeout will be handled with a `Task.sleep`. We will also observe the `NetworkMonitor` connection status and, cancel the timeout and set the closure so it's executed immediately. 
The network monitor has also been improved with Combine.

Regarding cancellation I have decided to store the tasks (both the timeout and the actual task) and cancel them using a public method in the `NetworkOperationPerformer`.

Some unit tests added.

# Network Monitor App
This is a demo app that uses the Network Operation Performer.

I have included 2 approachs:

- One using a Flow pattern to encapsulate the loading and navigation logic. This way it can be injected to be unit tested.

- Second approach uses TCA with `swift-composable-architecture`. In this case the architecture itself allows to test Reducer logic with its own framework in an elegant way. Some unit tests also added to test the logic.
