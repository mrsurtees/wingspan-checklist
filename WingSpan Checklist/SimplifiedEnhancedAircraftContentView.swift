// SimplifiedEnhancedAircraftContentView.swift
import SwiftUI
import UIKit
import Foundation

struct SimplifiedEnhancedAircraftContentView: View {
    let aircraft: WingSpanAircraft
    @EnvironmentObject private var viewModel: ChecklistViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var expandedSectionIds: Set<UUID> = []
    @State private var showResetAlert = false

    private var completionPercentage: Double {
        guard viewModel.totalCount > 0 else { return 0 }
        return Double(viewModel.completedCount) / Double(viewModel.totalCount)
    }

    var body: some View {
        ZStack {
            Color(hex: "1b3b6f").edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("\(aircraft.manufacturer) \(aircraft.modelName)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top)

                    Text("Pre-Flight Checklist")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))

                    HStack {
                        Text("Completed: \(viewModel.completedCount)/\(viewModel.totalCount)")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(Int(completionPercentage * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal)

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: max(0, CGFloat(completionPercentage) * geometry.size.width), height: 8)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal)
                }
                .padding(.bottom, 10)

                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "102040").opacity(0.7))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach($viewModel.sections) { $section in
                                SimplifiedSectionView(section: $section, expandedSectionIds: $expandedSectionIds)
                            }

                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 14))
                                    Text("Reset Checklist")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(Color(hex: "d9534f"))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 15)
                        .padding(.horizontal, 15)
                    }
                    .padding(.vertical, 2)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(aircraft.modelName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    viewModel.saveChecklist()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(hex: "1b3b6f"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Checklist"),
                message: Text("Are you sure you want to reset all checklist items to their default state?"),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetChecklist(preservingExpandedSections: expandedSectionIds)
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            print("SimplifiedEnhancedAircraftContentView appeared")
            // Force a fresh load when the view appears
            viewModel.loadChecklist()
        }
        .onDisappear {
            print("SimplifiedEnhancedAircraftContentView disappeared")
            // Force a save when the view disappears
            viewModel.saveChecklist()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            print("App becoming inactive from checklist view")
            viewModel.saveChecklist()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
            print("App terminating from checklist view")
            viewModel.saveChecklist()
        }
    }
}

struct SimplifiedSectionView: View {
    @Binding var section: ChecklistSection
    @State private var isExpanded: Bool = false
    @State private var showAllDetails: Bool = false
    @Binding var expandedSectionIds: Set<UUID>

    private var completedCount: Int {
        section.items.filter { $0.status == .completed }.count
    }

    private var sectionStatusColor: Color {
        let hasFailedItems = section.items.contains { $0.status == .failed }
        let allCompleted = section.items.allSatisfy { $0.status == .completed }
        let noneCompleted = section.items.allSatisfy { $0.status == .notCompleted }

        if hasFailedItems {
            // Using brighter red color
            return .red
        } else if allCompleted {
            // Using brighter green color
            return .green
        } else if noneCompleted {
            // Using blue color for untouched sections
            return Color(hex: "4a90e2")
        } else {
            // Using brighter yellow color
            return .yellow
        }
    }

    init(section: Binding<ChecklistSection>, expandedSectionIds: Binding<Set<UUID>>) {
        self._section = section
        self._expandedSectionIds = expandedSectionIds
        self._isExpanded = State(initialValue: expandedSectionIds.wrappedValue.contains(section.wrappedValue.id))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isExpanded.toggle()
                    if isExpanded {
                        expandedSectionIds.insert(section.id)
                    } else {
                        expandedSectionIds.remove(section.id)
                    }
                }
            }) {
                HStack {
                    // Made the circle slightly larger and removed any opacity modifiers
                    Circle()
                        .fill(sectionStatusColor)
                        .frame(width: 14, height: 14)

                    Text(section.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(completedCount)/\(section.items.count)")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.leading, 8)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "2c4a80"))
                )
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button(action: {
                            showAllDetails.toggle()
                        }) {
                            Text(showAllDetails ? "Hide All Details" : "Show All Details")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                    }

                    ForEach($section.items) { $item in
                        SimplifiedItemView(item: $item, showAllDetails: $showAllDetails)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color(hex: "16294d").opacity(0.7))
                .cornerRadius(8)
                .transition(.opacity)
            }
        }
    }
}

struct SimplifiedItemView: View {
    @Binding var item: ChecklistItem
    @State private var showDescription = false
    @Binding var showAllDetails: Bool
    @EnvironmentObject var viewModel: ChecklistViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)

                Spacer()

                if !showAllDetails && !item.description.isEmpty {
                    Button(action: {
                        withAnimation { showDescription.toggle() }
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 14))
                    }
                    .padding(.trailing, 8)
                }

                HStack(spacing: 8) {
                    Button(action: {
                        print("Setting item '\(item.title)' status to NOT COMPLETED")
                        item.status = .notCompleted
                        UserDefaults.standard.synchronize()
                        viewModel.saveChecklist()
                    }) {
                        ZStack {
                            // Changed color from gray to blue and increased line width
                            Circle().stroke(Color(hex: "4a90e2"), lineWidth: 2.0).frame(width: 28, height: 28)
                            if item.status == .notCompleted {
                                // Changed fill from gray to blue
                                Circle().fill(Color(hex: "4a90e2")).frame(width: 20, height: 20)
                            }
                        }
                    }

                    Button(action: {
                        print("Setting item '\(item.title)' status to COMPLETED")
                        item.status = .completed
                        UserDefaults.standard.synchronize()
                        viewModel.saveChecklist()
                    }) {
                        ZStack {
                            // Removed opacity modifier and increased line width
                            Circle().stroke(Color.green, lineWidth: 2.0).frame(width: 28, height: 28)
                            if item.status == .completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    // Full brightness green
                                    .foregroundColor(.green)
                            }
                        }
                    }

                    Button(action: {
                        print("Setting item '\(item.title)' status to FAILED")
                        item.status = .failed
                        UserDefaults.standard.synchronize()
                        viewModel.saveChecklist()
                    }) {
                        ZStack {
                            // Removed opacity modifier and increased line width
                            Circle().stroke(Color.red, lineWidth: 2.0).frame(width: 28, height: 28)
                            if item.status == .failed {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    // Full brightness red
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.05))
            .cornerRadius(6)

            if (showDescription || showAllDetails) && !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(6)
                    .transition(.opacity)
            }
        }
    }
}
 
