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
//  WebAPI.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import Foundation

class WebAPI {
    enum APIError: Error {
        case requestURLInvalid(String)
    }
    
    let apiURLBase = "https://yourdomain.something"
    
    func logout(username: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/logout",
            queryItems: [
                URLQueryItem(name: "username", value: username)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func updateUser(token: String, profile: UserProfile)  async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/updateuser",
            queryItems: [
                URLQueryItem(name: "username", value: profile.username),
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "avatar", value: profile.avatar),
                URLQueryItem(name: "region", value: profile.region),
                URLQueryItem(name: "fgames", value: String(decoding: try JSONEncoder().encode(profile.fgames), as: UTF8.self))
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func getProfile(username: String)  async throws -> UserProfile {
        let api = APIRequest<UserProfile>(
            urlString: "\(apiURLBase)/getprofile",
            queryItems: [
                URLQueryItem(name: "username", value: username)
            ])
        
        let response = try await request(api)
        return response
    }
    
    func lastsession(username: String, token: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/lastsession",
            queryItems: [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "token", value: token)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func signin(username: String, password: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/signin",
            queryItems: [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func pwdvalid(username: String, password: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/pwdvalid",
            queryItems: [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func signup(username: String, password: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/signup",
            queryItems: [
                URLQueryItem(name: "username", value: username),
                URLQueryItem(name: "password", value: password)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func games() async throws -> [String: Game] {
        let api = APIRequest<ServerGames>(
            urlString: "\(apiURLBase)/games",
            queryItems: []
        )
        
        let response = try await request(api)
        return response.games
    }
    
    func requests() async throws -> [String: UserRequest] {
        let api = APIRequest<ServerRequests>(
            urlString: "\(apiURLBase)/requests",
            queryItems: []
        )
        
        let response = try await request(api)
        return response.requests
    }
    
    func insert(authToken: String, newRequest: UserRequest) async throws -> String {

        var queryItems = [
            URLQueryItem(name: "token", value: authToken),
            URLQueryItem(name: "user", value: newRequest.user_id),
            URLQueryItem(name: "game", value: newRequest.game),
            URLQueryItem(name: "time", value: "\(newRequest.time)"),
            URLQueryItem(name: "mic", value: "\(newRequest.mic)"),
            URLQueryItem(name: "region", value: newRequest.region),
            URLQueryItem(name: "pnumber", value: "\(newRequest.pnumber)"),
            URLQueryItem(name: "mode", value: newRequest.mode),
            URLQueryItem(name: "plat", value: newRequest.plat),
        ]
        
        for skill in newRequest.skills {
            queryItems.append(URLQueryItem(name: "skills", value: skill))
        }
        
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/insert",
            queryItems: queryItems
        )
        
        let response = try await request(api)
        return response.answer
    }
    
    func delete(authToken: String, uuid: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/delete",
            queryItems: [
                URLQueryItem(name: "token", value: authToken),
                URLQueryItem(name: "uuid", value: uuid)
            ])
        
        let response = try await request(api)
        return response.answer
    }
    
    func request<T>(_ apiRequest: APIRequest<T>) async throws -> T {
        
        guard var requestURL = URLComponents(string: apiRequest.urlString) else {
            throw APIError.requestURLInvalid(apiRequest.urlString)
        }
        
        if apiRequest.queryItems != [] {
            requestURL.queryItems = apiRequest.queryItems
        }
        
        let request = URLRequest(url: requestURL.url!)
        let data = try await URLSession.shared.data(for: request, delegate: nil).0
        return try apiRequest.decodeJSON(data)
    }
}

struct APIRequest<T: Decodable> {
    var urlString: String
    var queryItems: [URLQueryItem]
    let decodeJSON: (Data) throws -> T
}

extension APIRequest {
    init(urlString: String, queryItems: [URLQueryItem]) {
        self.urlString = urlString
        self.queryItems = queryItems
        self.decodeJSON = { data in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            
            return try decoder.decode(T.self, from: data)
        }
    }
}
