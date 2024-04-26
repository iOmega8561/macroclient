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
    @State var biometricFailed: Bool = false
    
    @State var password: String = ""
    @State var passError: Bool = false
    
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
        .alert("Recover session", isPresented: $biometricFailed) {
            SecureField("Password", text: $password)
            Button("OK", action: {Task { await authenticate()}})
            Button("Cancel", role: .cancel) {
                Task {
                    await appData.logout()
                    isLoading = false
                }
            }
        } message: {
            Text("Please enter your password.")
        }
        .alert("Invalid password", isPresented: $passError) {
            Button("Retry") { biometricFailed = true }
        }
        .task {
            do {
                try await appData.load()
                
                if appData.authData.username != "na" && appData.authData.token != "na" {
                    let response = await appData.lastsession()
                    
                    if response == "Success" {
                        biometricLogin()
                    } else {
                        isLoading = false
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
    private func authenticate() async {
        if password == "" || password.contains(" ") {
            passError = true
            return
        }
        
        let isValid = await appData.checkPassword(password: password)
        
        if isValid {
            await appData.refreshProfile()
            loggedIn = true
            isLoading = false
        } else {
            passError = true
        }
    }
    
    private func biometricLogin() {
        
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
            biometricFailed = true
        }
    }
}

struct StartupView_Previews: PreviewProvider {
    static var previews: some View {
        StartupView()
    }
}
