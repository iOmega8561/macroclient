//
//  Login.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 16/05/23.
//

import SwiftUI

struct Login: View {
    @StateObject var appData: AppData
    @Binding var loggedIn: Bool
    
    @State var username: String = ""
    @State var password: String = ""
    @State var usernameError: Bool = false
    @State var passError: Bool = false
    @State var isLoading: Bool = false
    @State var asyncError: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BG")
                    .ignoresSafeArea()
                
                VStack(spacing: 28) {
                    Spacer()
                    
                    Image("Joypad")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 300.0, minHeight: 250.0)
                        .animation(.spring(), value: 10)
                    
                    Text("Welcome, please log in")
                        .font(.title)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 11) {
                        Text(usernameError ? "Invalid username":"Username")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: usernameError ? 5:0)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .overlay {
                                ZStack {
                                    Color("CardBG_2")
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    TextField("", text: $username)
                                        .frame(height: 44)
                                        .background(Color("CardBG_2"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .font(.system(size: 20.0))
                                        .autocapitalization(.none)
                                        .padding(.horizontal)
                                }
                                .padding(.horizontal)
                                    
                                
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 11) {
                        Text(passError ? "Invalid password":"Password")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: passError ? 5:0)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .overlay {
                                ZStack {
                                    Color("CardBG_2")
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    SecureField("", text: $password)
                                        .frame(height: 44)
                                        .background(Color("CardBG_2"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .font(.system(size: 20.0))
                                        .autocapitalization(.none)
                                        .padding(.horizontal)
                                }
                                .padding(.horizontal)
                                    
                                
                            }
                    }
                    
                    
                    if asyncError {
                        Text("There was an error reaching the server")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if !isLoading {
                        HStack {
                            NavigationLink(destination: Signup(appData: appData)) {
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBG_2"))
                                    .frame(width: 200, height: 50)
                                    .overlay(
                                        Text("Create an account"))
                                
                            }.foregroundColor(.primary)
                            
                            Button {
                                Task { await authenticationManage() }
                            } label: {
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.accentColor)
                                    .frame(width: 150, height: 50)
                                    .overlay(
                                        Text("Log in"))
                                
                            }.foregroundColor(.primary)
                        }
                    } else {
                        CustomProgress(withText: false)
                    }
                    
                    Spacer()
                }
            }
        }.navigationViewStyle(.stack)
    }
    
    func authenticationManage() async {
        if username == "" || username.contains(" ") {
            usernameError = true
            return
        } else if password == "" || password.contains(" ") {
            passError = true
            return
        }
        
        isLoading = true
        
        let response = await appData.signin(username: username, password: password)
        
        if response == "Error" {
            asyncError = true
        } else if response == "Invalid username" {
            usernameError = true
        } else if response == "Invalid password" {
            passError = true
        } else {
            usernameError = false; passError = false; asyncError = false
            
            if let data = await appData.getProfile(username: appData.authData.username) {
                appData.localProfile = data
                
                do {
                    try await appData.save()
                } catch { print("Error saving authData") }
                
                loggedIn = true
            }
        }
        
        isLoading = false
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(appData: AppData(), loggedIn: .constant(false))
    }
}
