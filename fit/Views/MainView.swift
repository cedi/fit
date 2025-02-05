//
//  MainView.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import SwiftUI

struct MainView : View {
    @StateObject var viewModel = MainViewViewModel()

    var body: some View {
        if viewModel.isSignedIn && !viewModel.currentUid.isEmpty {
            ContentView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    NavigationView {
        MainView()
    }
}
