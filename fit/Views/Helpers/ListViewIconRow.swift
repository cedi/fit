//
//  SettingsRow.swift
//  fit
//
//  Created by Cedric Kienzler on 01.03.25.
//

import SwiftUI

struct ListViewIconRow: View {
    let icon: String?
    let text: String
    var trailingText: String?
    var allowSelection: Bool
    var isSelected: Bool
    var action: () -> Void

    init(
        text: String, icon: String? = nil, trailingText: String? = nil,
        allowSelection: Bool = false, isSelected: Bool = false,
        action: @escaping () -> Void = {}
    ) {
        self.text = text
        self.icon = icon
        self.trailingText = trailingText
        self.allowSelection = allowSelection
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color.accentColor)
                }

                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)

                Spacer()

                if let trailingText = trailingText {
                    Text(trailingText)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }

                if allowSelection {
                    Image(
                        systemName: isSelected
                            ? "checkmark.circle.fill" : "plus.circle"
                    )
                    .foregroundColor(Color.accentColor)
                }
            }
        }
    }
}

#Preview {
    List {
        ListViewIconRow(
            text: "Hello World",
            icon: "figure.strengthtraining.functional",
            trailingText: "Foo",
            allowSelection: true,
            isSelected: false
        )

        ListViewIconRow(
            text: "Hello World",
            icon: "figure.strengthtraining.functional",
            trailingText: "Bar",
            allowSelection: true,
            isSelected: true
        )

        ListViewIconRow(
            text: "Hello World",
            icon: "figure.strengthtraining.functional",
            trailingText: "Foobar",
            allowSelection: true,
            isSelected: false
        )
    }
}
