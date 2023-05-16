//
//  Model.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import Foundation

struct Game: Codable, Hashable {
    var name: String
    var imgname: String
    var plat: [String]
    var modes: [String]
    var skills: [String]
    
    private enum CodingKeys: String, CodingKey {
        case name
        case imgname
        case plat
        case modes
        case skills
    }
}

struct ServerGames: Codable {
    var games: [String: Game]
    
    private enum CodingKeys: String, CodingKey {
        case games
    }
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
    
    private enum CodingKeys: String, CodingKey {
        case uuid
        case user_id
        case game
        case time
        case mic
        case region
        case pnumber
        case skills
        case plat
        case mode
    }
}

class ServerRequests: Codable {
    var requests: [String: UserRequest]
    
    private enum CodingKeys: String, CodingKey {
        case requests
    }
}

struct APIRequest<T: Decodable> {
    var urlString: String
    let decodeJSON: (Data) throws -> T
}

extension APIRequest {
    init(urlString: String) {
        self.urlString = urlString
        self.decodeJSON = { data in
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
}

extension String {
    func sanitazedHttp() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
    }
}

struct ResponseMessage: Codable {
    var answer: String
    
    private enum CodingKeys: String, CodingKey {
        case answer
    }
}
