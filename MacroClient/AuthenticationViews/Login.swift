//
//  Login.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 16/05/23.
//

import SwiftUI

struct Login: View {
    @StateObject var appData: AppData
    
    @State var username: String = ""
    @State var password: String = ""
    @State var isUnlocked: Bool = false
    @State var usernameError: Bool = false
    @State var passError: Bool = false
    @State var isLoading: Bool = false
    @State var asyncError: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color(red: 0.949, green: 0.949, blue: 0.971)
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
                        
                        TextField("", text: $username)
                            .frame(height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .font(.system(size: 17.0))
                            .autocapitalization(.none)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.red, lineWidth: usernameError ? 3:0)
                                    .padding(.horizontal)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 11) {
                        Text(passError ? "Invalid password":"Password")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        SecureField("", text: $password)
                            .frame(height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                            .font(.system(size: 17.0))
                            .autocapitalization(.none)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.red, lineWidth: passError ? 3:0)
                                    .padding(.horizontal)
                            )
                    }
                    
                    
                    if asyncError {
                        Text("There was an error reaching the server")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if !isLoading {
                        if !isUnlocked {
                            HStack {
                                NavigationLink(destination: Signup(appData: appData)) {
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                        .frame(width: 200, height: 50)
                                        .overlay(
                                            Text("Create an account"))
                                    
                                }.foregroundColor(.black)
                                
                                Button {
                                    Task { await authenticationManage() }
                                } label: {
                                    
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(hue: 0.24, saturation: 0.109, brightness: 0.885))
                                        .frame(width: 150, height: 50)
                                        .overlay(
                                            Text("Log in"))
                                    
                                }.foregroundColor(.black)
                                
                            }
                        } else {
                            NavigationLink(destination: MainView(appData: appData).navigationBarBackButtonHidden(true)) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: 350, height: 50)
                                    .overlay(
                                        Text("Proceed to dashboard"))
                            }.foregroundColor(.black)
                        }
                        
                    } else {
                        CustomProgress(withText: false)
                    }
                    
                    Spacer()
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
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
            isUnlocked.toggle()
        }
        
        isLoading = false
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(appData: AppData())
    }
}
