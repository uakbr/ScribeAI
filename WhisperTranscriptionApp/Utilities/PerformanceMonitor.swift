class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    private let metrics = MetricsStore()
    
    func startMetric(name: String) -> OSSignpostID {
        let signpostID = OSSignpostID(log: .default)
        os_signpost(.begin, log: .default, name: name, signpostID: signpostID)
        metrics.start(name: name)
        return signpostID
    }
    
    func endMetric(name: String, signpostID: OSSignpostID) {
        os_signpost(.end, log: .default, name: name, signpostID: signpostID)
        metrics.end(name: name)
    }
    
    func reportMetrics() -> [String: TimeInterval] {
        return metrics.averages
    }
}

private class MetricsStore {
    var measurements: [String: [TimeInterval]] = [:]
    var averages: [String: TimeInterval] {
        measurements.mapValues { times in
            times.reduce(0, +) / Double(times.count)
        }
    }
    
    func start(name: String) {
        if measurements[name] == nil {
            measurements[name] = []
        }
    }
    
    func end(name: String) {
        // Calculate and store duration
    }
} 