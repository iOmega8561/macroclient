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
    @State var showOnboarding: Bool = true
    
    var body: some View {
        Group {
            
            if isLoading {
                ZStack {
                    Color("BG").ignoresSafeArea()
                    CustomProgress(withText: true)
                }
                
            } else if !loggedIn {
                GetStarted(appData: appData, loggedIn: $loggedIn)
                
            } else if loggedIn && showOnboarding {
                InitialConfig(appData: appData)
                
            } else if loggedIn {
                TabView {
                    
                    Dashboard(appData: appData)
                        .tabItem {
                            Label("Lobbies", systemImage: "person.3")
                        }
                    
                    DummyView()
                        .tabItem {
                            Label("Requests", systemImage: "personalhotspot")
                        }
                    
                    DummyView()
                        .tabItem {
                            Label("Messages", systemImage: "bubble.left")
                        }
                    
                    Profile(appData: appData, loggedIn: $loggedIn)
                        .tabItem{
                            Label("Profile", systemImage: "person")
                        }
                    ChatScreen()
                        .tabItem{
                        Label("Chat", systemImage: "message")
                    }
                }
            }
            
        }
        .onChange(of: appData.getStartedDone) { value in
            showOnboarding = !value
        }
        .task {
            do {
                try await appData.load()
                
                if appData.authData.token != "na" && appData.authData.token != "na" {
                    let response = await appData.lastsession()
                    
                    if response == "Success" {
                        if let data = await appData.getProfile(username: appData.authData.username) {
                            appData.localProfile = data
                            
                            if appData.localProfile.avatar != "user_generic" && appData.localProfile.fgames.count != 0 && appData.localProfile.region != "n_a" {
                                appData.getStartedDone = true
                            }
                            
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
