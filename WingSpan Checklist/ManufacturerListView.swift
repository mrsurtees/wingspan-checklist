import SwiftUI
import Foundation

struct ManufacturerListView: View {
    @StateObject private var viewModel = AircraftViewModel()
    @State private var selectedAircraft: WingSpanAircraft? = nil
    @State private var hasLaunched = false
    @State private var showResetAlert = false
    private let themeBlue = Color(hex: "1b3b6f")

    var body: some View {
        NavigationStack {
            ZStack {
                themeBlue.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    header

                    ManufacturerListBlock(viewModel: viewModel)

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
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        Text("Manufacturers")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundColor(.white)
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

// MARK: Included Inline for Compiler Visibility
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

// MARK: - StatusCircle
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
 
