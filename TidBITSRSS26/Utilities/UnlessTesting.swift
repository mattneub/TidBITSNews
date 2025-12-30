import Foundation

/// Global methods that help us avoid delays and animations during testing.

func unlessTesting(_ double: Double) -> Double {
    if NSClassFromString("XCTest") != nil {
        return 0
    }
    return double
}

func unlessTesting(_ bool: Bool) -> Bool {
    if NSClassFromString("XCTest") != nil {
        return false
    }
    return bool
}

func unlessTesting(_ handler: () -> Void) {
    if NSClassFromString("XCTest") != nil {
        return
    }
    handler()
}

func unlessTesting(_ handler: () async throws -> Void) async throws {
    if NSClassFromString("XCTest") != nil {
        return
    }
    try await handler()
}
