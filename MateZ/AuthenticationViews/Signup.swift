//
//  Signup.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI

struct Signup: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var appData: AppData
    
    @State var username: String = ""
    @State var password: String = ""
    @State var password2: String = ""
    @State var isUnlocked: Bool = false
    @State var usernameError: Bool = false
    @State var usernameTaken: Bool = false
    @State var invalidChar: Bool = false
    @State var passError: Bool = false
    @State var pass2Error: Bool = false
    @State var isLoading: Bool = false
    @State var asyncError: Bool = false
    
    var body: some View {
        ZStack {
            Color("BG")
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                
                Image("Joypad")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 300.0, minHeight: 200.0)
                    .animation(.spring(), value: 10)
                
                Text("Account creation")
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 11) {
                    Text(usernameError ? "Invalid username":(usernameTaken ? "Username already in use":(invalidChar ? "Special characters are not accepted":"Username")))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: usernameError || usernameTaken || invalidChar ? 5:0)
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
                
                VStack(alignment: .leading, spacing: 11) {
                    Text(pass2Error ? "Passwords are not the same":"Confirm password")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.red, lineWidth: pass2Error ? 5:0)
                        .padding(.horizontal)
                        .frame(height: 44)
                        .overlay {
                            ZStack {
                                Color("CardBG")
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                SecureField("", text: $password2)
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
                
                if !isLoading {
                    Button(action: {Task { await signupManage() }}) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.accentColor)
                            .frame(width: 350, height: 50)
                            .overlay(
                                Text("Create your account"))
                    }.foregroundColor(.primary)
                } else {
                    CustomProgress(withText: false)
                }
            }
        }
    }
    
    func signupManage() async {
        if username == "" || username.contains(" ") {
            usernameError = true
            return
        } else if password == "" || password.contains(" ") {
            passError = true
            return
        } else if password != password2 {
            pass2Error = true
            return
        }
        
        pass2Error = false
        isLoading = true
        
        let response = await appData.signup(username: username, password: password)
        
        if response == "Error" {
            asyncError = true
        } else if response == "Invalid or missing username" {
            usernameError = true; invalidChar = false; usernameTaken = false
        } else if response == "Invalid username chars" {
            invalidChar = true; usernameError = false; usernameTaken = false
        } else if response == "User exists already" {
            usernameTaken = true; usernameError = false; invalidChar = false;
        } else if response == "Invalid or missing password" {
            passError = true
        } else {
            usernameError = false; passError = false; asyncError = false; pass2Error = false; usernameTaken = false
        }
        
        if response == "Success" {
            self.presentationMode.wrappedValue.dismiss()
        }
        
        isLoading = false
    }
}

struct Signup_Previews: PreviewProvider {
    static var previews: some View {
        Signup(appData: AppData())
    }
}
