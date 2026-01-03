/// Protocol describing our use of Bundle, so we can mock it for testing.
protocol BundleType {
    func url(forResource: String?, withExtension: String?) -> URL?
}

extension Bundle: BundleType {}
