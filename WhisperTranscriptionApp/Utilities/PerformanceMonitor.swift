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
    private var startTimes: [String: Date] = [:]
    
    var averages: [String: TimeInterval] {
        measurements.mapValues { times in
            times.reduce(0, +) / Double(times.count)
        }
    }
    
    func start(name: String) {
        startTimes[name] = Date()
    }
    
    func end(name: String) {
        guard let startTime = startTimes[name] else { return }
        let duration = Date().timeIntervalSince(startTime)
        measurements[name, default: []].append(duration)
        startTimes.removeValue(forKey: name)
    }
} 