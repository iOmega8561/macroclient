//
//  CredentialCheck.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI

struct StartupView: View {
    @StateObject var appData: AppData
    @State var isLoading: Bool = true
    @State var loggedIn: Bool = false
    
    var body: some View {
        Group {
            
            if isLoading {
                ZStack {
                    Color("BG").ignoresSafeArea()
                    CustomProgress(withText: true)
                }
            } else if !loggedIn {
                Login(appData: appData, loggedIn: $loggedIn)
            } else {
                TabView {
                    
                    Dashboard(appData: appData)
                        .tabItem {
                            Label("Lobbies", systemImage: "person.3")
                        }
                    
                    Profile(appData: appData, loggedIn: $loggedIn)
                        .tabItem{
                            Label("Profile", systemImage: "person")
                        }
                }
            }
            
        }.task {
            do {
                try await appData.load()
                
                if appData.authData.token != "na" && appData.authData.token != "na" {
                    let response = await appData.lastsession()
                    
                    if response == "Success" {
                        if let data = await appData.getProfile(username: appData.authData.username) {
                            appData.localProfile = data
                            loggedIn = true
                        }
                    }
                }
                
                isLoading = false
            } catch {
                print("Error loading data")
            }
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView(appData: AppData())
    }
}
