//
//  DebugView.swift
//  fit
//
//  Created by Cedric Kienzler on 21.02.25.
//

import SwiftUI

struct DebugView: View {
    @StateObject var viewModel: DebugViewModel

    init(profile: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: DebugViewModel(profile: profile))
    }

    var body: some View {
        VStack {
            List {
                Section("User Settings") {
                    HStack {
                        Toggle("User.isOnboarded", isOn: $viewModel.isOnboarded)
                            .onChange(of: viewModel.isOnboarded) {
                            Task {
                                await viewModel.toggleUserOnboarding()
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationTitle("Debug Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        DebugView(profile: ProfileViewModel())
    }
}
