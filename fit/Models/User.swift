//
//  User.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import FirebaseFirestore
import Foundation

struct UserNotifications: Codable {
    var enableNotifications: Bool?
    var enableLiveActivities: Bool?
}

struct User: Codable {
    let email: String
    var firstName: String?
    var lastName: String?
    var bio: String?
    var isOnboarded: Bool?
    var notifications: UserNotifications?

    @ServerTimestamp var createdAt: Date?
    @ServerTimestamp var lastUpdatedAt: Date?

    private func formattedDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: date)
    }

    private func formattedDateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale.autoupdatingCurrent
        return formatter.string(from: date)
    }

    func formatJoinedDate() -> String {
        return formattedDateString(from: createdAt ?? Date())
    }

    func formatUpdatedDate() -> String {
        return formattedDateTimeString(from: lastUpdatedAt ?? Date())
    }
}
