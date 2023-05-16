//
//  Login.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 16/05/23.
//

import SwiftUI

struct Login: View {
    @StateObject var tempData: TempData
    @Environment(\.colorScheme) var colorScheme
    
    @State var username: String = ""
    @State var password: String = ""
    
    @State var isUnlocked: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme != .dark {
                    Color(red: 0.949, green: 0.949, blue: 0.971).ignoresSafeArea()
                    
                }
                
                VStack {
                    Spacer()
                    
                    Image("Joypad")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 350.0, minHeight: 300.0)
                    
                    Text("🔫🔫 Log in 🔫🔫")
                        .font(.title)
                    
                    Spacer()
                    
                    Form {
                        
                        Section(header: Text("Username")) {
                            TextField("Type your username here", text: $username)
                        }
                        
                        Section(header: Text("Password")) {
                            SecureField("Type your password here", text: $password)
                        }.onSubmit {
                            isUnlocked.toggle()
                        }
                    }.frame(maxHeight: 300.0)
                    
                    Spacer()
                    
                    if !isUnlocked {
                        Button(action: {}) {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: 350, height: 50)
                                .overlay(
                                    Text("I don't have an account"))
                            
                        }.foregroundColor(.black)
                        
                    } else {
                        NavigationLink(destination: MainView(tempData: tempData).navigationBarBackButtonHidden(true)) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: 350, height: 50)
                                .overlay(
                                    Text("Proceed to dashboard"))
                        }.foregroundColor(.black)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(tempData: TempData())
    }
}
