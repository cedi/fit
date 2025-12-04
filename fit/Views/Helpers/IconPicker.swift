//
//  IconPicker.swift
//  fit
//
//  Created by Cedric Kienzler on 25.02.25.
//

import SwiftUI

enum EditImageVariant: String {
    case circleFill = "pencil.circle.fill"
    case circle = "pencil.circle"
}

struct IconPickerControl: View {
    @Binding var systemIconName: String
    @State var isPickerPresented: Bool = false

    let editIcon: EditImageVariant
    let size: CGFloat
    let color: Color
    let additionalOffset: CGFloat

    init(
        _ systemIconName: Binding<String>,
        editIcon: EditImageVariant = .circleFill,
        size: CGFloat = 80,
        color: Color = Color.accentColor,
        additionalOffset: CGFloat = 0
    ) {
        _systemIconName = systemIconName

        self.editIcon = editIcon
        self.size = size
        self.color = color
        self.additionalOffset = additionalOffset
    }

    var body: some View {
        Button(action: {
            isPickerPresented.toggle()
        }) {
            ZStack {
                Image(systemName: systemIconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(Color.accentColor)

                    Image(systemName: editIcon.rawValue)
                        .resizable()
                        .frame(width: size * 0.3, height: size * 0.3)
                        .offset(
                            x: size * 0.375 + additionalOffset,
                            y: size * 0.375 + additionalOffset
                        )
                        .foregroundColor(Color.accentColor)
                        .background(
                            Circle()
                                .fill(Color.white)
                                .frame(width: size * 0.35, height: size * 0.35)
                                .offset(
                                    x: size * 0.375 + additionalOffset,
                                    y: size * 0.375 + additionalOffset
                                )
                        )
            }
        }
        .popover(isPresented: $isPickerPresented) {
            IconPickerView(selectedIcon: $systemIconName)
        }
    }
}

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    @State private var searchText: String = ""  // Search query

    struct IconOption: Identifiable {
        let id = UUID()
        let systemName: String
        let displayName: String
    }

    let icons: [IconOption] = [
        IconOption(
            systemName: "figure.strengthtraining.traditional",
            displayName: "Strength Training"),
        IconOption(systemName: "dumbbell.fill", displayName: "Dumbbell"),
        IconOption(
            systemName: "heart.circle.fill", displayName: "Heart Health"),
        IconOption(systemName: "bolt.fill", displayName: "Explosive Power"),
        IconOption(systemName: "timer", displayName: "Timer"),
        IconOption(systemName: "stopwatch.fill", displayName: "Stopwatch"),
        IconOption(systemName: "waveform.path.ecg", displayName: "Cardio"),
        IconOption(
            systemName: "figure.cross.training", displayName: "Cross Training"),
        IconOption(
            systemName: "figure.highintensity.intervaltraining",
            displayName: "HIIT"),
        IconOption(systemName: "figure.pilates", displayName: "Pilates"),
        IconOption(systemName: "figure.yoga", displayName: "Yoga"),
        IconOption(
            systemName: "figure.stair.stepper", displayName: "Stair Stepper"),
        IconOption(systemName: "figure.elliptical", displayName: "Elliptical"),
        IconOption(
            systemName: "figure.track.and.field", displayName: "Track and Field"
        ),
        IconOption(systemName: "figure.hiking", displayName: "Hiking"),
        IconOption(systemName: "figure.run", displayName: "Running"),
        IconOption(systemName: "figure.walk", displayName: "Walking"),
        IconOption(systemName: "figure.rower", displayName: "Rowing"),
        IconOption(systemName: "figure.boxing", displayName: "Boxing"),
        IconOption(
            systemName: "figure.martial.arts", displayName: "Martial Arts"),
        IconOption(systemName: "figure.wrestling", displayName: "Wrestling"),
        IconOption(
            systemName: "figure.american.football", displayName: "Football"),
        IconOption(systemName: "figure.rugby", displayName: "Rugby"),
        IconOption(systemName: "figure.hockey", displayName: "Hockey"),
        IconOption(systemName: "soccerball", displayName: "Soccer"),
        IconOption(systemName: "basketball.fill", displayName: "Basketball"),
        IconOption(systemName: "figure.tennis", displayName: "Tennis"),
        IconOption(
            systemName: "figure.table.tennis", displayName: "Table Tennis"),
        IconOption(systemName: "figure.badminton", displayName: "Badminton"),
        IconOption(systemName: "figure.cricket", displayName: "Cricket"),
        IconOption(systemName: "figure.golf", displayName: "Golf"),
        IconOption(systemName: "figure.archery", displayName: "Archery"),
        IconOption(systemName: "figure.fencing", displayName: "Fencing"),
        IconOption(systemName: "figure.surfing", displayName: "Surfing"),
        IconOption(systemName: "figure.handball", displayName: "Handball"),
        IconOption(systemName: "figure.volleyball", displayName: "Volleyball"),
        IconOption(systemName: "figure.squash", displayName: "Squash"),
        IconOption(systemName: "figure.lacrosse", displayName: "Lacrosse"),
        IconOption(
            systemName: "figure.skateboarding", displayName: "Skateboarding"),
        IconOption(systemName: "figure.skating", displayName: "Skating"),
        IconOption(systemName: "figure.waterpolo", displayName: "Water Polo"),
        IconOption(
            systemName: "figure.skiing.crosscountry",
            displayName: "Cross-Country Skiing"),
        IconOption(
            systemName: "figure.snowboarding", displayName: "Snowboarding"),
        IconOption(systemName: "figure.climbing", displayName: "Climbing"),
        IconOption(systemName: "figure.bowling", displayName: "Bowling"),
        IconOption(systemName: "medal.fill", displayName: "Achievements"),
        IconOption(systemName: "star.fill", displayName: "Favorites"),
        IconOption(systemName: "flag.checkered", displayName: "Race"),
        IconOption(systemName: "target", displayName: "Focus"),
    ]

    var filteredIcons: [IconOption] {
        if searchText.isEmpty {
            return icons
        } else {
            return icons.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Icons", text: $searchText)
                    .padding(10)
                    .cornerRadius(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5).opacity(0.3))
                    )
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .padding(.trailing, 10)
                            }
                        }
                    )
                    .padding(.horizontal)

                List {
                    ForEach(filteredIcons) { icon in
                        ListViewIconRow(
                            text: icon.displayName,
                            icon: icon.systemName,
                            allowSelection: true,
                            isSelected: selectedIcon == icon.systemName
                        )
                        .contentShape(Rectangle())  // Makes the entire row tappable
                        .onTapGesture {
                            selectedIcon = icon.systemName
                        }
                    }
                }
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    dismiss()
                })
        }
    }
}

#Preview {
    @Previewable @State var selected: String = "stopwatch.fill"
    @Previewable @State var selectedNonFill: String = "stopwatch"
    HStack {
        VStack {
            IconPickerControl($selected, editIcon: .circleFill)
            IconPickerControl($selected, editIcon: .circle)
        }
        VStack {
            IconPickerControl($selectedNonFill, editIcon: .circleFill)
            IconPickerControl($selectedNonFill, editIcon: .circle)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    @Previewable @State var selected: String = "stopwatch.fill"

    IconPickerView(
        selectedIcon: $selected
    )
}
