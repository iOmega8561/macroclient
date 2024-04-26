/*
 Copyright (C) 2024  Giuseppe Rocco
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

//
//  Model.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import Foundation

struct SubmittedChatMessage: Encodable {
    let message: String
    let user: String
}

struct ReceivingChatMessage: Decodable, Identifiable {
    let date: Date
    let id: UUID
    let message: String
    let user: String
}

struct LocalAuthData: Codable {
    var token: String = "na"
    var username: String = "na"
}

struct UserProfile: Codable {
    var username: String = "na"
    var avatar: String = "user_generic"
    var region: String = "n_a"
    var fgames: [String] = []
}

struct Game: Codable, Hashable {
    var name: String
    var imgname: String
    var plat: [String]
    var modes: [String]
    var skills: [String]
}

struct ServerGames: Codable {
    var games: [String: Game]
}

struct UserRequest: Codable, Hashable {
    var uuid: String
    var user_id: String
    var game: String
    var time: Int
    var mic: Bool
    var region: String
    var pnumber: Int
    var skills: [String]
    var plat: String
    var mode: String
    var date: Date
}

class ServerRequests: Codable {
    var requests: [String: UserRequest]
}

struct SimpleResponse: Codable {
    var answer: String
}
