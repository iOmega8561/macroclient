//
//  TempData.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import Foundation

@MainActor
class AppData: ObservableObject {
    private let webAPI: WebAPI = WebAPI()
    
    @Published var getStartedDone: Bool = false
    
    @Published var authData: LocalAuthData = LocalAuthData()
    @Published var localProfile: UserProfile = UserProfile()
    @Published var games: [String: Game] = [:]
    @Published var requests: [String: UserRequest] = [:]
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("macroclient.data")
    }
    
    func load() async throws {
        let task = Task<LocalAuthData, Error> {
            let fileURL = try Self.fileURL()

            guard let data = try? Data(contentsOf: fileURL) else {
                return LocalAuthData()
            }
            let authData = try JSONDecoder().decode(LocalAuthData.self, from: data)
            return authData
        }
        
        let taskValue = try await task.value
        self.authData = taskValue
    }


    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(self.authData)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
    func updateUser() async {
        do {
            let _ = try await webAPI.updateUser(token: authData.token, profile: localProfile)
        } catch {
            print("Error updating profile \(String(describing: error))")
        }
    }
    
    func getProfile(username: String) async -> UserProfile? {
        do {
            return try await webAPI.getProfile(username: username)
        } catch {
            print("Error retrieving profile \(username) \(String(describing: error))")
            return nil
        }
    }
    
    func updateAuthData(username: String, token: String) async {
        self.objectWillChange.send()
        
        authData.token = token
        authData.username = username
        
        do {
            try await save()
        } catch { print("Error saving authData") }
    }
    
    func refreshProfile() async {
        do {
            self.objectWillChange.send()
            localProfile = try await webAPI.getProfile(username: authData.username)
            
            if localProfile.avatar != "user_generic" && localProfile.fgames.count != 0 && localProfile.region != "n_a" {
                getStartedDone = true
            }
        } catch {
            print("Error retrieving self profile \(String(describing: error))")
        }
    }
    
    func logout() async {
        do {
            let _ = try await webAPI.logout(username: authData.username)
            self.objectWillChange.send()
            authData.token = "na"; authData.username = "na"
        } catch {
            print("Error loggin user out \(String(describing: error))")
        }
    }
    
    func lastsession() async -> String {
        do {
            return try await webAPI.lastsession(username: authData.username, token: authData.token)
        } catch {
            print("Error authenticating user \(String(describing: error))")
            return "Error"
        }
    }
    
    func signin(username: String, password: String) async -> String {
        do {
            let response = try await webAPI.signin(username: username, password: password)
            
            if !response.contains("Invalid") {
                
                self.objectWillChange.send()
                authData.token = response; authData.username = username
            }
            
            return response
        } catch {
            print("Error authenticating user \(String(describing: error))")
            return "Error"
        }
    }
    
    func signup(username: String, password: String) async -> String {
        do {
            return try await webAPI.signup(username: username, password: password)
        } catch {
            print("Error authenticating user \(String(describing: error))")
            return "Error"
        }
    }
    
    func insertUserRequest(newRequest: UserRequest) async {
        do {
            let _: String = try await webAPI.insert(authToken: authData.token, newRequest: newRequest)
        } catch {
            print("Error inserting user request \(String(describing: error))")
        }
    }
    
    func deleteUserRequest(uuid: String) async {
        do {
            let answer: String = try await webAPI.delete(authToken: authData.token, uuid: uuid)
            
            if answer == "Success" {
                let _ = await fetchUserRequests()
            }
        } catch {
            print("Error deleting request with uuid: \(uuid) \(String(describing: error))")
        }
    }
    
    func fetchUserRequests() async -> Bool {
        do {
            let tmp: [String: UserRequest] = try await webAPI.requests()
            
            self.objectWillChange.send()
            requests = tmp
            
            return true
        } catch {
            print("Error fetching user requests \(String(describing: error))")
        }
        
        return false
    }
    
    func fetchRemoteGames() async {
        do {
            let tmp: [String: Game] = try await webAPI.games()
            
            self.objectWillChange.send()
            games = tmp
        } catch {
            print("Error fetching remote games \(String(describing: error))")
        }
    }
}
