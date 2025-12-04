//
//  SectionView.swift
//  fit
//
//  Created by Cedric Kienzler on 25.02.25.
//

import SwiftUI

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .fontWeight(.medium)
            content()
        }
    }
}

#Preview {
    SectionView(title: "Test") { Text("Test") }
}
