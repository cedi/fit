//
//  HeaderView.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import SwiftUI

enum FocusedField {
    case email, password, firstname, lastname, bio
}

struct AppIconView: View {
    static let iconSize: CGFloat = 150

    var body: some View {
        if let appIcon = getAppIcon() {
            Image(uiImage: appIcon)
                .resizable()
                .scaledToFit()
                .frame(
                    width: AppIconView.iconSize, height: AppIconView.iconSize
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
        } else {
            Text("App Icon Not Found")
        }
    }

    func getAppIcon() -> UIImage? {
        guard
            let iconsDict = Bundle.main.infoDictionary?["CFBundleIcons"]
                as? [String: Any],
            let primaryIconDict = iconsDict["CFBundlePrimaryIcon"]
                as? [String: Any],
            let iconFiles = primaryIconDict["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last
        else {
            return nil
        }
        return UIImage(named: lastIcon)
    }
}

#Preview {
    AppIconView()
}
