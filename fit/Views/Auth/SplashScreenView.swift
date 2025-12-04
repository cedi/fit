//
//  SplashScreenView.swift
//  fit
//
//  Created by Cedric Kienzler on 01.03.25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color("AppIconColor")
                .ignoresSafeArea()
            
            AppIconView()
        }
    }
}

#Preview {
    SplashScreenView()
}
