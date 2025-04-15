// ✅ ManufacturerListView.swift — Patched for reliable resume and checklist persistence
import SwiftUI
import Foundation

struct FilteredAircraftListView: View {
    let manufacturer: String
    @StateObject private var viewModel = AircraftViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(viewModel.aircraft.filter { $0.manufacturer == manufacturer }) { aircraft in
                    NavigationLink {
                        SimplifiedEnhancedAircraftContentView(aircraft: aircraft)
                            .environmentObject(ChecklistViewModel.forAircraft(id: aircraft.id))
                            .onAppear {
                                saveLastViewedAircraft(aircraft)
                            }
                    } label: {
                        HStack(spacing: 12) {
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
            .padding(.bottom, 40)
        }
        .background(Color(hex: "1b3b6f").ignoresSafeArea())
        .navigationTitle(manufacturer)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func saveLastViewedAircraft(_ aircraft: WingSpanAircraft) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("lastAircraft.json")
        if let data = try? JSONEncoder().encode(aircraft) {
            try? data.write(to: url)
        }
    }
}

struct ManufacturerListView: View {
    @StateObject private var viewModel = AircraftViewModel()
    @State private var selectedAircraft: WingSpanAircraft? = nil
    @State private var hasLaunched = false
    private let themeBlue = Color(hex: "1b3b6f")

    var body: some View {
        NavigationStack {
            ZStack {
                themeBlue.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    Text("Manufacturers")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.top, 24)

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
        }
        .preferredColorScheme(.dark)
    }

    private func uniqueManufacturers() -> [String] {
        let names = viewModel.aircraft.map { $0.manufacturer }
        return Array(Set(names)).sorted()
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
}
