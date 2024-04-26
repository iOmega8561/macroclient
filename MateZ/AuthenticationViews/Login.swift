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
//  Login.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 16/05/23.
//

import SwiftUI

struct Login: View {
    @EnvironmentObject var appData: AppData
    @Binding var loggedIn: Bool
    
    @State var username: String = ""
    @State var password: String = ""
    @State var usernameError: Bool = false
    @State var passError: Bool = false
    @State var isLoading: Bool = false
    @State var asyncError: Bool = false
    
    var body: some View {
        ZStack {
            Color("BG")
                .ignoresSafeArea()
            
        
            VStack {
                 ScrollView {
                     Spacer()
                         .frame(height: 48)
                    
                    
                    VStack(alignment: .leading, spacing: 11) {
                        Text(usernameError ? "Invalid username":"Username")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: usernameError ? 5:0)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .overlay {
                                ZStack {
                                    Color("CardBG")
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    TextField("", text: $username)
                                        .frame(height: 44)
                                        .background(Color("CardBG"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .font(.system(size: 20.0))
                                        .autocapitalization(.none)
                                        .padding(.horizontal)
                                }
                                .padding(.horizontal)
                                
                                
                            }
                    }
                    
                    Spacer()
                        .frame(height: 48)
                    
                    VStack(alignment: .leading, spacing: 11) {
                        Text(passError ? "Invalid password":"Password")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.red, lineWidth: passError ? 5:0)
                            .padding(.horizontal)
                            .frame(height: 44)
                            .overlay {
                                ZStack {
                                    Color("CardBG")
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    
                                    SecureField("", text: $password)
                                        .frame(height: 44)
                                        .background(Color("CardBG"))
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
                    
                    
                    
                }
                
                if !isLoading {
                    HStack {
                        Button {
                            Task { await authenticationManage() }
                        } label: {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.accentColor)
                                .frame(width: 220, height: 50)
                                .overlay {
                                    Text("Sign in")
                                        .foregroundColor(.primary)
                                        .font(.system(size: 17, weight: .bold))
                                }
                            
                        }.foregroundColor(.primary)
                    }
                } else {
                    CustomProgress(withText: false)
                        .frame(width: 220, height: 50)
                }
                
                Spacer()
                    .frame(height: 30)
            }
        }
        .navigationTitle("Sign in")
        .navigationBarTitleDisplayMode(.large)
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
            
            await appData.refreshProfile()
            
            do {
                try await appData.save()
            } catch { print("Error saving authData") }
            
            loggedIn = true
        }
        
        isLoading = false
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(loggedIn: .constant(false))
    }
}
