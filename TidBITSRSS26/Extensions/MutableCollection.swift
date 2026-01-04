/// Extension that makes it a whole lot easier to cycle through arrays of structs, changing them.
/// https://forums.swift.org/t/inout-variables-in-for-in-loops/61380/6
///
extension MutableCollection {
    mutating func modifyEach(_ modify: (inout Element) throws -> Void) rethrows {
        var i = startIndex
        while i != endIndex {
            try modify(&self[i])
            formIndex(after: &i)
        }
    }
}
