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
    
    func games() async throws -> [String: Game] {
        let api = APIRequest<ServerGames>(urlString: "\(apiURLBase)/games")
        let response = try await request(api)
        return response.games
    }
    
    func requests() async throws -> [String: UserRequest] {
        let api = APIRequest<ServerRequests>(urlString: "\(apiURLBase)/requests")
        let response = try await request(api)
        return response.requests
    }
    
    func insert(newRequest: UserRequest) async throws -> String {
        var urlString = "\(apiURLBase)/insert?user=\(newRequest.user_id)&game=\(newRequest.game.sanitazedHttp())&time=\(newRequest.time)&mic=\(newRequest.mic)&region=\(newRequest.region)&pnumber=\(newRequest.pnumber)&mode=\(newRequest.mode.sanitazedHttp())&plat=\(newRequest.plat)"
        
        for skill in newRequest.skills {
            urlString = urlString + "&skills=\(skill.sanitazedHttp())"
        }
        
        let api = APIRequest<SimpleResponse>(urlString: urlString)
        let response = try await request(api)
        return response.answer
    }
    
    func delete(uuid: String) async throws -> String {
        let api = APIRequest<SimpleResponse>(urlString: "\(apiURLBase)/delete?uuid=\(uuid)")
        let response = try await request(api)
        return response.answer
    }
    
    func request<T>(_ apiRequest: APIRequest<T>) async throws -> T {
        
        guard let requestURL = URL(string: apiRequest.urlString) else {
            throw APIError.requestURLInvalid(apiRequest.urlString)
        }
        
        guard URLComponents(string: apiRequest.urlString) != nil else {
            throw APIError.requestURLInvalid(apiRequest.urlString)
        }
        
        let request = URLRequest(url: requestURL)
        let data = try await URLSession.shared.data(for: request, delegate: nil).0
        return try apiRequest.decodeJSON(data)
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
