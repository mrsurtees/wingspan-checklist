// ContentView.swift
import SwiftUI
import UIKit
import Foundation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Application did finish launching")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("Application will resign active - saving all user defaults")
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application entered background - saving all user defaults")
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("Application will terminate - saving all user defaults")
        UserDefaults.standard.synchronize()
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("Application received memory warning - prioritizing data persistence")
        UserDefaults.standard.synchronize()
    }
}

@main
struct WingSpanChecklistApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ManufacturerListView()
                .preferredColorScheme(.dark)
        }
    }
}
 
// View Models
enum AircraftSortOption {
    case modelName
    case manufacturer
}

class AircraftViewModel: ObservableObject {
    @Published var aircraft: [WingSpanAircraft]
    @Published var sortOption: AircraftSortOption = .modelName
    private let userDefaultsKey = "AircraftList"
    
    init() {
        aircraft = AircraftTemplates.defaultAircraft
        loadAircraft()
    }
    
    func saveAircraft() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(aircraft)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving aircraft list: \(error)")
        }
    }
    
    func loadAircraft() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return }
        do {
            let decoder = JSONDecoder()
            aircraft = try decoder.decode([WingSpanAircraft].self, from: data)
            sortAircraft()
        } catch {
            print("Error loading aircraft list: \(error)")
        }
    }
    
    func sortAircraft() {
        switch sortOption {
        case .modelName:
            sortByModelName()
        case .manufacturer:
            sortByManufacturer()
        }
    }
    
    func sortByModelName() {
        sortOption = .modelName
        aircraft.sort { $0.modelName.lowercased() < $1.modelName.lowercased() }
    }
    
    func sortByManufacturer() {
        sortOption = .manufacturer
        aircraft.sort {
            if $0.manufacturer.lowercased() == $1.manufacturer.lowercased() {
                return $0.modelName.lowercased() < $1.modelName.lowercased()
            }
            return $0.manufacturer.lowercased() < $1.manufacturer.lowercased()
        }
    }
}

// Update this part in ContentView.swift:

class ChecklistViewModel: ObservableObject {
    @Published var sections: [ChecklistSection] {
        didSet {
            print("Sections changed in ViewModel - calling save")
            saveChecklist()
        }
    }
    
    private var aircraftId: UUID?
    private var storageKey: String
    
    // Use a shared cache of view models
    private static var sharedInstances: [String: ChecklistViewModel] = [:]
    
    // Factory method to ensure we reuse instances for the same aircraft ID
    static func forAircraft(id: UUID) -> ChecklistViewModel {
        let key = "Checklist_\(id.uuidString)"
        if let existing = sharedInstances[key] {
            print("Reusing existing ChecklistViewModel for aircraft \(id.uuidString)")
            return existing
        } else {
            let newViewModel = ChecklistViewModel(aircraftId: id)
            sharedInstances[key] = newViewModel
            print("Created new ChecklistViewModel for aircraft \(id.uuidString)")
            return newViewModel
        }
    }
    
    init(aircraftId: UUID? = nil) {
        print("Initializing ChecklistViewModel with aircraft ID: \(aircraftId?.uuidString ?? "nil")")
        self.aircraftId = aircraftId
        
        // Create a storage key based on the aircraft ID
        if let id = aircraftId {
            self.storageKey = "Checklist_\(id.uuidString)"
        } else {
            self.storageKey = "DefaultChecklist"
        }
        
        // Initialize with empty sections array
        self.sections = []
        
        // Load data or set default
        loadChecklist()
        if sections.isEmpty {
            resetChecklist()
        }
        
        // Register for app lifecycle notifications
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Save when app enters background
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                print("App entering background - forcing save")
                self?.forceSaveChecklist()
            }
        
        // Save when app terminates
        NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                print("App terminating - forcing save")
                self?.forceSaveChecklist()
            }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func saveChecklist() {
        do {
            print("Saving checklist to UserDefaults with key: \(storageKey)")
            
            // Print detailed debug info before saving
            for (i, section) in sections.enumerated() {
                print("Saving Section \(i+1): \(section.title) with \(section.items.count) items")
                for (j, item) in section.items.enumerated() {
                    print("  Item \(j+1): \(item.title) - Status: \(item.status.rawValue)")
                }
            }
            
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(sections)
            UserDefaults.standard.set(data, forKey: storageKey)
            
            // Force immediate synchronization
            UserDefaults.standard.synchronize()
            
            // Verify the save worked
            if let savedData = UserDefaults.standard.data(forKey: storageKey) {
                print("Successfully saved \(savedData.count) bytes to UserDefaults")
            } else {
                print("WARNING: Save verification failed - no data found after save")
            }
        } catch {
            print("ERROR saving checklist: \(error)")
        }
    }
    
    // Force save with multiple attempts for critical moments
    func forceSaveChecklist() {
        saveChecklist()
        
        // Add a delayed second save for extra protection
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.saveChecklist()
        }
    }
    
    func loadChecklist() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("No saved data found for key: \(storageKey)")
            return
        }
        
        do {
            print("Loading \(data.count) bytes of checklist data from UserDefaults")
            let decoder = PropertyListDecoder()
            sections = try decoder.decode([ChecklistSection].self, from: data)
            print("Successfully loaded \(sections.count) sections with \(sections.flatMap { $0.items }.count) total items")
            
            // Debug: Print loaded data
            for (i, section) in sections.enumerated() {
                print("Loaded Section \(i+1): \(section.title) with \(section.items.count) items")
                for (j, item) in section.items.enumerated() {
                    print("  Item \(j+1): \(item.title) - Status: \(item.status.rawValue)")
                }
            }
        } catch {
            print("ERROR loading checklist: \(error)")
            sections = []
        }
    }
    
    func resetChecklist() {
        print("Resetting checklist to defaults")
        resetChecklist(preservingExpandedSections: Set<UUID>())
    }
    
    func resetChecklist(preservingExpandedSections expandedIds: Set<UUID>) {
        let oldSectionIds = sections.map { $0.id }
        var defaultSections = AircraftTemplates.defaultChecklistSections()
        
        if !sections.isEmpty && !expandedIds.isEmpty {
            let count = min(oldSectionIds.count, defaultSections.count)
            for i in 0..<count {
                if expandedIds.contains(oldSectionIds[i]) {
                    defaultSections[i].id = oldSectionIds[i]
                }
            }
        }
        
        // Set sections - this will trigger didSet and save
        sections = defaultSections
    }
    
    var completedCount: Int {
        sections.flatMap { $0.items }.filter { $0.status == .completed }.count
    }
    
    var totalCount: Int {
        sections.flatMap { $0.items }.count
    }
}
