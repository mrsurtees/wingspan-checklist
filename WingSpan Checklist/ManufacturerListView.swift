// ManufacturerListView.swift
import SwiftUI
import Foundation

// 1. SearchBar
struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
                .padding(.leading, 8)
            
            TextField("Search manufacturers or aircraft", text: $searchText)
                .foregroundColor(.white)
                .padding(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.trailing, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "102040").opacity(0.7))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}

// 2. WelcomeBanner
struct WelcomeBanner: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "2c4a80"))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to WingSpan 🛩️")
                            .font(.system(size: geometry.size.width < 350 ? 20 : 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Select a manufacturer to begin.")
                            .font(.system(size: geometry.size.width < 350 ? 13 : 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
            }
        }
        .frame(height: 100) // Fixed height but responsive width
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
}

// 3. ResetAllButton
struct ResetAllButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14))
                Text("Reset All Checklists")
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color(hex: "d9534f"))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 4. StatusCircle
struct StatusCircle: View {
    let aircraftId: UUID
    @ObservedObject private var checklistVM: ChecklistViewModel

    init(aircraftId: UUID) {
        self.aircraftId = aircraftId
        self.checklistVM = ChecklistViewModel.forAircraft(id: aircraftId)
    }

    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 14, height: 14)
            .onAppear {
                checklistVM.loadChecklist()
            }
    }

    private var statusColor: Color {
        let allItems = checklistVM.sections.flatMap { $0.items }

        if allItems.contains(where: { $0.status == .failed }) {
            return .red
        }

        let allCompleted = !allItems.isEmpty && allItems.allSatisfy { $0.status == .completed }
        if allCompleted {
            return .green
        }

        let hasCompleted = allItems.contains(where: { $0.status == .completed })
        if hasCompleted {
            return .yellow
        }

        return Color(hex: "4a90e2")
    }
}

// 5. SearchResultsView
struct SearchResultsView: View {
    let searchText: String
    let viewModel: AircraftViewModel
    @Binding var selectedAircraft: WingSpanAircraft?
    
    var filteredAircraft: [WingSpanAircraft] {
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return viewModel.aircraft.filter { aircraft in
            aircraft.modelName.lowercased().contains(query) ||
            aircraft.manufacturer.lowercased().contains(query)
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "102040").opacity(0.3))
                .frame(height: 500)
                .padding(.horizontal, 16)
            
            if filteredAircraft.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.bottom, 10)
                    
                    Text("No results found")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(filteredAircraft) { aircraft in
                            Button {
                                selectedAircraft = aircraft
                            } label: {
                                HStack(spacing: 12) {
                                    StatusCircle(aircraftId: aircraft.id)
                                        .padding(.trailing, 10)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(aircraft.modelName)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text(aircraft.manufacturer)
                                            .font(.system(size: 12, weight: .regular, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "airplane")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white.opacity(0.8))
                                        .rotationEffect(.degrees(-45))
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hex: "102040").opacity(0.6))
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// 6. ManufacturerListBlock
struct ManufacturerListBlock: View {
    let viewModel: AircraftViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "102040").opacity(0.3))
                .frame(height: 500)
                .padding(.horizontal, 16)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(uniqueManufacturers(), id: \.self) { manufacturer in
                        NavigationLink(destination: FilteredAircraftListView(manufacturer: manufacturer)) {
                            HStack {
                                Text(manufacturer)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                            Divider().background(Color.white.opacity(0.2))
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.top, 8)
            }
            .frame(height: 500)
            .padding(.horizontal, 16)
        }
    }

    private func uniqueManufacturers() -> [String] {
        let names = viewModel.aircraft.map { $0.manufacturer }
        return Array(Set(names)).sorted()
    }
}

// 7. FilteredAircraftListView
struct FilteredAircraftListView: View {
    let manufacturer: String
    @StateObject private var viewModel = AircraftViewModel()
    @State private var showResetAlert = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.aircraft.filter { $0.manufacturer == manufacturer }) { aircraft in
                        NavigationLink {
                            SimplifiedEnhancedAircraftContentView(aircraft: aircraft)
                                .environmentObject(ChecklistViewModel.forAircraft(id: aircraft.id))
                        } label: {
                            HStack(spacing: 12) {
                                StatusCircle(aircraftId: aircraft.id)
                                    .padding(.trailing, 10)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(aircraft.modelName)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)

                                    Text(aircraft.manufacturer)
                                        .font(.system(size: 12, weight: .regular, design: .rounded))
                                        .foregroundColor(.white.opacity(0.6))
                                }

                                Spacer()

                                Image(systemName: "airplane")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.8))
                                    .rotationEffect(.degrees(-45))

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "102040").opacity(0.6))
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 20)
            }

            Button(action: {
                showResetAlert = true
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 14))
                    Text("Reset All Checklists")
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color(hex: "d9534f"))
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom, 25)
        }
        .background(Color(hex: "1b3b6f").ignoresSafeArea())
        .navigationTitle(manufacturer)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset All Checklists"),
                message: Text("Are you sure you want to reset all checklists for \(manufacturer) aircraft to their default state?"),
                primaryButton: .destructive(Text("Reset")) {
                    resetAllChecklists()
                },
                secondaryButton: .cancel()
            )
        }
    }

    private func resetAllChecklists() {
        let manufacturerAircraft = viewModel.aircraft.filter { $0.manufacturer == manufacturer }

        for aircraft in manufacturerAircraft {
            let checklistVM = ChecklistViewModel.forAircraft(id: aircraft.id)
            checklistVM.resetChecklist()
            checklistVM.saveChecklist()
        }
    }
}

// 8. FINALLY, ManufacturerListView
struct ManufacturerListView: View {
    @StateObject private var viewModel = AircraftViewModel()
    @State private var selectedAircraft: WingSpanAircraft? = nil
    @State private var hasLaunched = false
    @State private var showResetAlert = false
    @State private var showSettings = false
    @State private var searchText: String = ""
    private let themeBlue = Color(hex: "1b3b6f")

    var body: some View {
        NavigationStack {
            ZStack {
                themeBlue.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    header
                    
                    WelcomeBanner()
                    
                    SearchBar(searchText: $searchText)
                    
                    if searchText.isEmpty {
                        ManufacturerListBlock(viewModel: viewModel)
                    } else {
                        SearchResultsView(searchText: searchText, viewModel: viewModel, selectedAircraft: $selectedAircraft)
                    }

                    ResetAllButton {
                        showResetAlert = true
                    }
                }

                NavigationLink(value: selectedAircraft) {
                    EmptyView()
                }
                .opacity(0)
            }
            .navigationBarHidden(true)
            .onAppear {
                if !hasLaunched {
                    hasLaunched = true
                    if let aircraft = loadLastViewedAircraft() {
                        selectedAircraft = aircraft
                    }
                }
            }
            .navigationDestination(for: String.self) { manufacturer in
                FilteredAircraftListView(manufacturer: manufacturer)
            }
            .navigationDestination(for: WingSpanAircraft.self) { aircraft in
                SimplifiedEnhancedAircraftContentView(aircraft: aircraft)
                    .environmentObject(ChecklistViewModel.forAircraft(id: aircraft.id))
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Reset All Checklists"),
                    message: Text("Are you sure you want to reset all checklists for every aircraft in the app? This cannot be undone."),
                    primaryButton: .destructive(Text("Reset All")) {
                        resetAllChecklists()
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Spacer()
            
            // Settings button
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color(hex: "2c4a80")))
            }
            .padding(.trailing, 8)
            
            // About button
            NavigationLink(destination: AboutView()) {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color(hex: "2c4a80")))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private func loadLastViewedAircraft() -> WingSpanAircraft? {
        let url = savedAircraftURL()
        guard let data = try? Data(contentsOf: url),
              let saved = try? JSONDecoder().decode(WingSpanAircraft.self, from: data)
        else {
            print("⚠️ Failed to load last viewed aircraft")
            return nil
        }
        print("✅ Loaded last viewed aircraft: \(saved.modelName)")
        return saved
    }

    private func savedAircraftURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("lastAircraft.json")
    }

    private func resetAllChecklists() {
        print("Resetting all checklists in the app")
        for aircraft in viewModel.aircraft {
            let checklistVM = ChecklistViewModel.forAircraft(id: aircraft.id)
            checklistVM.resetChecklist()
            checklistVM.saveChecklist()
        }
        print("✅ Reset complete for all \(viewModel.aircraft.count) aircraft")
    }
}
