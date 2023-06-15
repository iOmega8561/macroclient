//
//  CredentialCheck.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI
import LocalAuthentication

struct StartupView: View {
    @EnvironmentObject var appData: AppData
    
    @State var isLoading: Bool = true
    @State var loggedIn: Bool = false
    @State var biometricSuccess: Bool = false
    
    var body: some View {
        Group {
            
            if isLoading {
                ZStack {
                    Color("BG").ignoresSafeArea()
                    CustomProgress(withText: true)
                }
                
            } else if !loggedIn {
                GetStarted(loggedIn: $loggedIn)
                    .environmentObject(appData)
                
            } else if loggedIn && !appData.getStartedDone {
                NavigationView {
                    InitialConfig()
                        .environmentObject(appData)
                }
                .navigationViewStyle(.stack)
                
            } else if loggedIn && appData.getStartedDone {
                TabView {
                    
                    Dashboard()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Lobbies", systemImage: "person.3")
                        }
                    
                    DummyView()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Requests", systemImage: "personalhotspot")
                        }
                    
                    ChatScreen()
                        .environmentObject(appData)
                        .tabItem{
                            Label("Messages", systemImage: "bubble.left")
                        }
                    
                    Profile(loggedIn: $loggedIn)
                        .environmentObject(appData)
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
                        biometricLogin()
                    }
                    
                } else {
                    isLoading = false
                }
            } catch {
                print("Error loading data")
            }
        }
    }
}

extension StartupView {
    private func biometricLogin() -> Void {
        
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "Security Reasons"
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {
                    Task {
                        await appData.refreshProfile()
                        loggedIn = true
                        isLoading = false
                    }
                } else {
                    Task {
                        await appData.logout()
                        isLoading = false
                    }
                }
            }
        } else {
            Task {
                await appData.refreshProfile()
                loggedIn = true
                isLoading = false
            }
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}
