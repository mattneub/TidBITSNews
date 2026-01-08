import Foundation

extension String {
    /// Deal with entities; in real life we seem to get just one sort of case,
    /// which I can find and convert with a single regular expression
    /// that catches three or four digit decimal encodings.
    nonisolated var dealingWithEntities: String {
        var result = self
        for match in result.matches(of: /&#(\d\d\d\d?);/).reversed() {
            if let code = Int(match.output.1), let scalar = UnicodeScalar(code) {
                result.replaceSubrange(match.range, with: String(scalar))
            }
        }
        return result
    }
}
