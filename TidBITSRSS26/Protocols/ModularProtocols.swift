/*
 This is the basis for our mini-Pentimento modular architecture (see https://livefront.com/pentimento/):

 * A view or view controller is a presenter; the logic goes into the corresponding processor.
 * A view or view controller sends an _action_ to the processor via `receive`, in response to the user.
 * The processor sends a _state_ to the presenter via `present`; the presenter portrays it in the interface.
 * Sometimes the processor may send an _effect_ to the presenter via `receive` to make it perform a
   behavior without the overhead of a state presentation.

 */

/// Protocol for classes with a `receive` method; this allows us to slot a mock in place of
/// a processor or presenter, for testing. `Received` should be an action or effect enum.
protocol Receiver<Received>: AnyObject {
    associatedtype Received
    func receive(_: Received) async
}

/// Extension with injection so that if a receiver doesn't actually receive, it doesn't
/// have to write a `receive` a method.
extension Receiver where Received == Void {
    func receive(_: Void) async {}
}

/// Protocol for classes with a `present` method; this allows us to slot a mock in place of
/// a processor or presenter, for testing. `State` should be a state struct.
protocol Presenter<State>: AnyObject {
    associatedtype State
    func present(_: State) async
}

/// Compositional protocol for types that adopt both Receiver and Presenter (it is not currently
/// possible to do this with an actual composition operator).
protocol ReceiverPresenter<Received, State>: Receiver, Presenter {}

/// A Processor is a Receiver that also has a `presenter` property.
protocol Processor<Received, PresenterState, Effect>: Receiver {
    associatedtype PresenterState
    associatedtype Effect
    var presenter: (any ReceiverPresenter<Effect, PresenterState>)? { get set }
}
