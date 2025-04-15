// AircraftTemplates.swift
import Foundation
import SwiftUI
////
///

// Default aircraft data and checklist sections
struct AircraftTemplates {
    static let defaultAircraft: [WingSpanAircraft] = [
        // Cessna Aircraft
        WingSpanAircraft(modelName: "172 Skyhawk", manufacturer: "Cessna", imageName: "cessna172"),
        WingSpanAircraft(modelName: "152", manufacturer: "Cessna", imageName: "cessna152"),
        WingSpanAircraft(modelName: "182 Skylane", manufacturer: "Cessna", imageName: "cessna182"),
        WingSpanAircraft(modelName: "206 Stationair", manufacturer: "Cessna", imageName: "cessna206"),
        WingSpanAircraft(modelName: "Citation M2", manufacturer: "Cessna", imageName: "cessnam2"),
        
        // Daher Aircraft
        WingSpanAircraft(modelName: "TBM 930", manufacturer: "Daher", imageName: "dahertbm930"),
        WingSpanAircraft(modelName: "TBM 910", manufacturer: "Daher", imageName: "dahertbm910"),
        
        // Beechcraft Aircraft
        WingSpanAircraft(modelName: "Bonanza V35", manufacturer: "Beechcraft", imageName: "beechcraftv35"),
        WingSpanAircraft(modelName: "Baron G58", manufacturer: "Beechcraft", imageName: "beechcraftg58"),
        WingSpanAircraft(modelName: "King Air C90", manufacturer: "Beechcraft", imageName: "beechcraftc90"),
        WingSpanAircraft(modelName: "T-34 Mentor", manufacturer: "Beechcraft", imageName: "beechcraftt34"),
        
        // Diamond Aircraft
        WingSpanAircraft(modelName: "DA62", manufacturer: "Diamond", imageName: "diamondda62"),
        WingSpanAircraft(modelName: "DA40 NG", manufacturer: "Diamond", imageName: "diamondda40"),
        WingSpanAircraft(modelName: "DA20 Eclipse", manufacturer: "Diamond", imageName: "diamondda20"),
        
        // Piper Aircraft
        WingSpanAircraft(modelName: "Archer TX", manufacturer: "Piper", imageName: "piperarcher"),
        WingSpanAircraft(modelName: "Seneca V", manufacturer: "Piper", imageName: "piperseneca"),
        WingSpanAircraft(modelName: "M350", manufacturer: "Piper", imageName: "piperm350"),
        WingSpanAircraft(modelName: "Warrior III", manufacturer: "Piper", imageName: "piperwarrior"),
        
        // Cirrus Aircraft
        WingSpanAircraft(modelName: "SR22 G6", manufacturer: "Cirrus", imageName: "cirrussr22"),
        WingSpanAircraft(modelName: "SR20", manufacturer: "Cirrus", imageName: "cirrussr20"),
        
        // Other Manufacturers
        WingSpanAircraft(modelName: "PC-12 NGX", manufacturer: "Pilatus", imageName: "pilatuspc12"),
        WingSpanAircraft(modelName: "M20V Acclaim", manufacturer: "Mooney", imageName: "mooneym20"),
        WingSpanAircraft(modelName: "RV-10", manufacturer: "Vans", imageName: "vansrv10"),
        WingSpanAircraft(modelName: "G120A", manufacturer: "Grob", imageName: "grobg120"),
        WingSpanAircraft(modelName: "EA 400", manufacturer: "Extra", imageName: "extra400")
    ]
    
    static func defaultChecklistSections() -> [ChecklistSection] {
        return [
            ChecklistSection(title: "Preflight Preparation", items: [
                ChecklistItem(title: "Weather Check", description: "Verify current and forecasted weather conditions, including wind, visibility, and precipitation."),
                ChecklistItem(title: "Flight Plan", description: "Ensure the flight plan is filed, reviewed, and includes all necessary waypoints and alternates."),
                ChecklistItem(title: "Aircraft Documents", description: "Check that required documents (Airworthiness Certificate, Registration, POH) are on board."),
                ChecklistItem(title: "Weight & Balance", description: "Calculate and confirm that the aircraft's weight and balance are within limits for the flight.")
            ]),
            ChecklistSection(title: "Cabin Check", items: [
                ChecklistItem(title: "Seat Belts", description: "Inspect seat belts for condition and ensure they are securely fastened and operational."),
                ChecklistItem(title: "Control Movements", description: "Verify free and correct movement of the yoke and rudder pedals, checking for any binding or issues."),
                ChecklistItem(title: "Fuel Selector", description: "Ensure the fuel selector is set to \"Both\" and functioning properly."),
                ChecklistItem(title: "Circuit Breakers", description: "Check that all circuit breakers are in and none are popped; investigate any anomalies.")
            ]),
            ChecklistSection(title: "External Checks", items: [
                ChecklistItem(title: "Left Wing", description: "Inspect the left wing for damage, ice, or debris; check flaps, aileron, and lights for condition."),
                ChecklistItem(title: "Right Wing", description: "Inspect the right wing for damage, ice, or debris; check flaps, aileron, and lights for condition."),
                ChecklistItem(title: "Fuel Levels", description: "Visually check fuel levels in both tanks, ensure caps are secure, and verify no contamination."),
                ChecklistItem(title: "Oil Level", description: "Check the engine oil level via the dipstick, ensuring it's within the recommended range (6-8 qts)."),
                ChecklistItem(title: "Tire Condition", description: "Inspect tires for proper inflation, wear, and any visible damage; ensure no flat spots or cuts.")
            ])
        ]
    }
}
