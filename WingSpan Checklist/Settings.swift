// SettingsView.swift
import SwiftUI
import Foundation

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("animationsEnabled") private var animationsEnabled = true
    @AppStorage("textSize") private var textSize: TextSize = .medium
    @AppStorage("accentColor") private var accentColor: AccentColor = .blue
    @AppStorage("autoExpandSections") private var autoExpandSections = false
    @AppStorage("confirmResets") private var confirmResets = true
    @AppStorage("useSystemTime") private var useSystemTime = true
    @AppStorage("manualTimeOfDay") private var manualTimeOfDay: TimeOfDay = .day
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1b3b6f").ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Display Settings
                        settingsSection("Display") {
                            Toggle("Enable Animations", isOn: $animationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: accentColor.color))
                            
                            Picker("Text Size", selection: $textSize) {
                                ForEach(TextSize.allCases, id: \.self) { size in
                                    Text(size.rawValue).tag(size)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Picker("Accent Color", selection: $accentColor) {
                                ForEach(AccentColor.allCases, id: \.self) { color in
                                    HStack {
                                        Circle()
                                            .fill(color.color)
                                            .frame(width: 20, height: 20)
                                        Text(color.rawValue)
                                    }
                                    .tag(color)
                                }
                            }
                        }
                        
                        // Background Settings
                        settingsSection("Background") {
                            Toggle("Use System Time", isOn: $useSystemTime)
                                .toggleStyle(SwitchToggleStyle(tint: accentColor.color))
                            
                            if !useSystemTime {
                                Picker("Time of Day", selection: $manualTimeOfDay) {
                                    ForEach(TimeOfDay.allCases, id: \.self) { time in
                                        Text(time.rawValue).tag(time)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                            }
                        }
                        
                        // Checklist Settings
                        settingsSection("Checklists") {
                            Toggle("Auto-expand Sections", isOn: $autoExpandSections)
                                .toggleStyle(SwitchToggleStyle(tint: accentColor.color))
                            
                            Toggle("Confirm Resets", isOn: $confirmResets)
                                .toggleStyle(SwitchToggleStyle(tint: accentColor.color))
                        }
                        
                        // About / Version
                        settingsSection("About") {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("1.2.0")
                                    .foregroundColor(.gray)
                            }
                            
                            NavigationLink(destination: AboutView()) {
                                HStack {
                                    Text("About WingSpan")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                content()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "102040").opacity(0.7))
            )
        }
    }
}

// MARK: - Settings Enums
enum TextSize: String, CaseIterable, Codable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var scaleFactor: CGFloat {
        switch self {
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.2
        }
    }
}

enum AccentColor: String, CaseIterable, Codable {
    case blue = "Blue"
    case red = "Red"
    case green = "Green"
    case orange = "Orange"
    
    var color: Color {
        switch self {
        case .blue: return Color(hex: "4a90e2")
        case .red: return Color(hex: "FF6F61")
        case .green: return Color(hex: "4CD964")
        case .orange: return Color(hex: "FF9500")
        }
    }
}

enum TimeOfDay: String, CaseIterable, Codable {
    case dawn = "Dawn"
    case day = "Day"
    case dusk = "Dusk"
    case night = "Night"
    
    var colorPhase: Double {
        switch self {
        case .dawn: return 0.5
        case .day: return 1.0
        case .dusk: return 1.5
        case .night: return 2.0
        }
    }
}
