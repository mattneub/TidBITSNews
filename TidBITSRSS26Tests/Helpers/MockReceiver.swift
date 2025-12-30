@testable import TidBITSRSS26

final class MockReceiver<T>: Receiver {
    var thingsReceived: [T] = []

    func receive(_ thingReceived: T) async {
        thingsReceived.append(thingReceived)
    }
}

final class MockReceiverPresenter<T, U>: @MainActor ReceiverPresenter, Sendable {
    var statesPresented = [U]()
    var thingsReceived: [T] = []

    func present(_ state: U) async {
        statesPresented.append(state)
    }

    func receive(_ thingReceived: T) async {
        thingsReceived.append(thingReceived)
    }
}

final class MockProcessor<T, U, V>: @MainActor Processor, Sendable {
    var thingsReceived: [T] = []

    var presenter: (any ReceiverPresenter<V, U>)?

    func receive(_ thingReceived: T) async {
        thingsReceived.append(thingReceived)
    }
}
