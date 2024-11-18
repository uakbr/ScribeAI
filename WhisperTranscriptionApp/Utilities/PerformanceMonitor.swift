import Foundation

class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    private let metricsStore = MetricsStore()
    
    func startMeasurement(name: String) {
        metricsStore.start(name: name)
    }
    
    func endMeasurement(name: String) {
        metricsStore.end(name: name)
    }
    
    func printMetrics() {
        for (name, average) in metricsStore.averages {
            print("Average time for \(name): \(average) seconds")
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
} 