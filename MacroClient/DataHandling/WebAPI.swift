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
    
    let apiURLBase = "https://test.casarocco.keenetic.link"
    
    func logout(username: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(
            urlString: "\(apiURLBase)/logout",
            queryItems: [
                URLQueryItem(name: "username", value: username)
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
            return try JSONDecoder().decode(T.self, from: data)
        }
    }
}
