import Foundation
import HealthKit

/// Manages all interactions with Apple HealthKit
@Observable
final class HealthKitManager: Sendable {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    var isAuthorized = false
    var dailySteps: Int = 0
    var hoursOfSleep: Double = 0.0
    var latestWeight: Double?
    var errorMessage: String?
    
    init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        // Currently, HealthKit doesn't have a simple "is fully authorized" boolean property, 
        // you just check if you can request authorization. 
        // We'll rely on reading data and catching errors or checking specific type auth statuses.
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let status = healthStore.authorizationStatus(for: stepType)
        DispatchQueue.main.async {
            self.isAuthorized = (status == .sharingAuthorized)
        }
    }
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            await MainActor.run { errorMessage = "HealthKit is not available on this device" }
            return
        }
        
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let typesToRead: Set<HKObjectType> = [stepType, sleepType, weightType]
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            await MainActor.run { self.isAuthorized = true }
            await fetchAllData()
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
    
    func fetchAllData() async {
        await fetchTodaySteps()
        await fetchLastNightSleep()
        await fetchLatestWeight()
    }
    
    // MARK: - Fetchers
    
    private func fetchTodaySteps() async {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType,
                                          quantitySamplePredicate: predicate,
                                          options: .cumulativeSum) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                DispatchQueue.main.async {
                    self.dailySteps = Int(steps)
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchLastNightSleep() async {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        let now = Date()
        let startOfYesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: now))!
        let predicate = HKQuery.predicateForSamples(withStart: startOfYesterday, end: now, options: .strictStartDate)
        
        return await withCheckedContinuation { continuation in
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: sleepType,
                                      predicate: predicate,
                                      limit: HKObjectQueryNoLimit,
                                      sortDescriptors: [sortDescriptor]) { _, samples, _ in
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    DispatchQueue.main.async { continuation.resume() }
                    return
                }
                
                // Sum the "asleep" states
                let totalAsleep = sleepSamples
                    .filter { $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue ||
                              $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                
                let hours = totalAsleep / 3600.0
                
                DispatchQueue.main.async {
                    self.hoursOfSleep = hours
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }
    
    private func fetchLatestWeight() async {
        guard let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: weightType,
                                      predicate: nil,
                                      limit: 1,
                                      sortDescriptors: [sortDescriptor]) { _, samples, _ in
                
                guard let sample = samples?.first as? HKQuantitySample else {
                    DispatchQueue.main.async { continuation.resume() }
                    return
                }
                
                let weightKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                
                DispatchQueue.main.async {
                    self.latestWeight = weightKg
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }
}
