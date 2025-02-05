//
//  User.swift
//  fit
//
//  Created by Cedric Kienzler on 05.02.25.
//

import Foundation

struct User: Codable {
    let uid: String
    let email: String
    let joined: TimeInterval
}
