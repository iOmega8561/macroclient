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
                GetStarted(appData: appData, loggedIn: $loggedIn)
                
            } else if loggedIn && !appData.getStartedDone {
                InitialConfig(appData: appData)
                
            } else if loggedIn && appData.getStartedDone {
                TabView {
                    
                    Dashboard(appData: appData)
                        .tabItem {
                            Label("Lobbies", systemImage: "person.3")
                        }
                    
                    DummyView()
                        .tabItem {
                            Label("Requests", systemImage: "personalhotspot")
                        }
                    
                    ChatScreen()
                        .tabItem{
                            Label("Messages", systemImage: "bubble.left")
                        }
                    
                    Profile(appData: appData, loggedIn: $loggedIn)
                        .onAppear {
                            Task {
                                await appData.refreshProfile()
                            }
                        }
                        .tabItem{
                            Label("Profile", systemImage: "person")
                        }
                   
                }
            }
        }
        .task {
            do {
                try await appData.load()
                
                if appData.authData.username != "na" && appData.authData.token != "na" {
                    let response = await appData.lastsession()
                    
                    if response == "Success" {
                        await appData.refreshProfile()
                        
                        loggedIn = true
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
