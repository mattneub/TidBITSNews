/// A Cycler is a dispatcher to help with testing when a processor sends `receive` to itself, i.e. one
/// action is a consequence of another. Instead of sending `receive` _directly_ to itself, it sends
/// `receive` to its cycler, which sends it on to itself. So when we write our tests for the first
/// action, we don't have to check all the effects of the second action, thus repeating a whole
/// bunch of tests; it is enough to check that the second action was sent (using a MockCycler).
/// This problem arises so often, I'm surprised I didn't think of it sooner.
class Cycler<ActionType, P: Processor> where P.Received == ActionType {
    weak var processor: P?
    init(processor: P) {
        self.processor = processor
    }
    func receive(_ action: ActionType) async {
        await processor?.receive(action)
    }
}
