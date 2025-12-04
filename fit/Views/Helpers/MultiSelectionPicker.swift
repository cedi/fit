//
//  MultiSelectionPicker.swift
//  fit
//
//  Created by Cedric Kienzler on 25.02.25.
//

import SwiftUI

struct MultiSelectionOption: Identifiable, Equatable, Hashable {
    let id: String
    var icon: String?
    var text: String
    var data: String?

    init(
        _ text: String, icon: String? = nil, data: String? = nil
    ) {
        self.id = "\(text)\(icon ?? "")"
        self.text = text
        self.icon = icon
        self.data = data
    }

    // Conform to `Equatable`
    static func == (lhs: MultiSelectionOption, rhs: MultiSelectionOption)
        -> Bool
    {
        return lhs.id == rhs.id
    }

    // Conform to `Hashable`
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MultiSelectionTagView: View {
    let option: MultiSelectionOption
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            if let icon = option.icon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(Color.accentColor)
                    .padding(.leading, 5)
            }

            Text(option.text)
                .font(.caption)
                .padding(.leading, option.icon == nil ? 5 : 0)

            Button(action: onDelete) {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 14, height: 14)
                    .foregroundColor(
                        Color.red
                            .opacity(0.8)
                    )
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    Color.accentColor,
                    lineWidth: 1,
                    antialiased: true
                )
                .fill(
                    Color.accentColor
                        .opacity(0.1)
                )
        )
    }
}

struct MultiSelectionControl: View {
    @State var showPicker: Bool = false

    let text: String
    @Binding var selection: [MultiSelectionOption]
    let options: [MultiSelectionOption]
    let isAddingAllowed: Bool
    let onAddOption: (MultiSelectionOption) -> Bool  // Function to add a new option

    var body: some View {
        Button(
            action: {
                showPicker.toggle()
            }) {
                HStack {
                    if selection.isEmpty {
                        Text(text)
                            .foregroundColor(.gray)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 5) {
                                ForEach(selection) { option in
                                    MultiSelectionTagView(option: option) {
                                        removeSelection(option)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10).fill(Color(.systemGray6))
                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        Color.accentColor,
                        lineWidth: selection.isEmpty ? 0 : 1
                    )
            )
            .popover(isPresented: $showPicker) {
                MultiSelectionPicker(
                    title: text,
                    options: options,
                    selectedItems: $selection,
                    isAddingAllowed: isAddingAllowed,
                    onAddOption: onAddOption  // Pass the function
                )
            }
    }

    private func removeSelection(_ option: MultiSelectionOption) {
        selection.removeAll { $0.id == option.id }
    }
}

struct MultiSelectionPicker: View {
    @Environment(\.presentationMode) private var presentationMode

    let title: String
    let options: [MultiSelectionOption]
    @Binding var selectedItems: [MultiSelectionOption]
    let isAddingAllowed: Bool
    let onAddOption: (MultiSelectionOption) -> Bool  // Function to handle adding new items

    @State private var isAddingNewItemShown: Bool = false
    @State private var searchText: String = ""

    var filteredOptions: [MultiSelectionOption] {
        if searchText.isEmpty {
            return options
        } else {
            return options.filter {
                $0.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchText)
                    .padding(10)
                    .cornerRadius(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(
                            Color(.systemGray5).opacity(0.3))
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
                    if isAddingNewItemShown {
                        AddSelectionOptionView(
                            existingOptions: options,
                            onAdd: { newOption in
                                isAddingNewItemShown = false
                                return onAddOption(newOption)
                            }
                        )
                    }

                    ForEach(filteredOptions, id: \.self) { option in
                        ListViewIconRow(
                            text: option.text,
                            icon: option.icon,
                            allowSelection: true,
                            isSelected: selectedItems.contains(option)
                        ) {
                            toggleSelection(option)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isAddingAllowed {
                        Button(action: {
                            isAddingNewItemShown.toggle()
                        }) {
                            Image(systemName: isAddingNewItemShown ? "xmark" : "plus")
                                .foregroundColor(Color.accentColor)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if isAddingAllowed {
                        Button("Done") {
                            isAddingNewItemShown.toggle()
                        }
                    }
                }
            }
        }
    }

    private func toggleSelection(_ option: MultiSelectionOption) {
        if let index = selectedItems.firstIndex(of: option) {
            selectedItems.remove(at: index)
        } else {
            selectedItems.append(option)
        }
    }
}

struct AddSelectionOptionView: View {
    @Environment(\.presentationMode) private var presentationMode

    @State private var icon: String = "photo.stack"
    @State private var text: String = ""

    let hasIcon: Bool
    let onAdd: (MultiSelectionOption) -> Bool

    init(
        existingOptions: [MultiSelectionOption],
        onAdd: @escaping (MultiSelectionOption) -> Bool
    ) {
        self.onAdd = onAdd
        if let firstOption = existingOptions.first {
            self.hasIcon = firstOption.icon != nil
        } else {
            self.hasIcon = false
        }
    }

    var body: some View {
        HStack(alignment: .center) {
            if hasIcon {
                IconPickerControl($icon, size: 20)
            }

            TextField("Text", text: $text)
                .autocapitalization(.words)
                .padding(.vertical, 12)
                .padding(.horizontal, 10)
                .background(Color(.systemGray5).opacity(0.3))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            Color.accentColor,
                            lineWidth: text.isEmpty ? 0 : 1
                        )
                )

            Spacer()

            Button(action: {
                if addOption() {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(Color.accentColor)
            }
        }
    }

    private func addOption() -> Bool {
        let newOption = MultiSelectionOption(
            text,
            icon: hasIcon ? icon : nil
        )
        return onAdd(newOption)
    }
}

#Preview {
    @Previewable @State var selectedItems: [MultiSelectionOption] = [
        MultiSelectionOption("Loreum", icon: "tray.2"),
        MultiSelectionOption("Ipsum", icon: "tray.2"),
    ]
    @Previewable @State var options: [MultiSelectionOption] = [
        MultiSelectionOption("Loreum", icon: "tray.2"),
        MultiSelectionOption("Ipsum", icon: "tray.2"),
        MultiSelectionOption("Dolor", icon: "tray.2"),
        MultiSelectionOption("Sit", icon: "tray.2"),
        MultiSelectionOption("Amet", icon: "tray.2"),
    ]

    NavigationView {
        SectionView(title: "Select foobar") {
            MultiSelectionControl(
                text: "Select foobar",
                selection: $selectedItems,
                options: options,
                isAddingAllowed: true,
                onAddOption: { newOption in
                    options.append(newOption)
                    return true
                }
            )
        }
    }
    .padding()
}

#Preview {
    @Previewable @State var selectedItems: [MultiSelectionOption] = []
    var options: [MultiSelectionOption] = [
        MultiSelectionOption("Loreum", icon: "tray.2"),
        MultiSelectionOption("Ipsum", icon: "tray.2"),
        MultiSelectionOption("Dolor", icon: "tray.2"),
        MultiSelectionOption("Sit", icon: "tray.2"),
        MultiSelectionOption("Amet", icon: "tray.2"),
    ]

    MultiSelectionPicker(
        title: "Select",
        options: options,
        selectedItems: $selectedItems,
        isAddingAllowed: true,
        onAddOption: { newOption in
            options.append(newOption)
            return true
        }
    )
}
