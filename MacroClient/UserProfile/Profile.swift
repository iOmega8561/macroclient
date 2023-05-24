//
//  Profile.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 19/05/23.
//

import SwiftUI

struct Profile: View {
    @StateObject var appData: AppData
    @Binding var loggedIn: Bool
    
    @State var showDialog: Bool = false
    @State var showModal: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Spacer()
                        VStack {
                            ZStack(alignment: .bottomTrailing) {
                                RemoteImage(imgname: appData.localProfile.avatar, squareSize: 130)
                                    .clipShape(Circle())
                                    .frame(width: 130, height: 130)
                                
                                Button(action: {showModal = true}) {
                                    Image(systemName: "pencil.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30)
                                        .padding(.horizontal)
                                }.sheet(isPresented: $showModal) {
                                    AvatarPicker(appData: appData)
                                }
                            }
                            
                            Text(appData.localProfile.username)
                                .font(.title)
                        }
                        Spacer()
                    }
                }.listRowBackground(Color.clear)
                
                Section(header: Text("Authentication")) {
                    Button(action: { showDialog.toggle() }) {
                        HStack {
                            Spacer()
                            Text("Log out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .confirmationDialog("Are you sure?", isPresented: $showDialog, titleVisibility: .visible) {
                        Button(role: .destructive) {
                            Task {
                                await appData.logout()
                                showDialog = false; loggedIn = false
                            }
                        } label: {
                            Text("Yes, log me out.")
                        }
                    }
                }
            }
        }.navigationViewStyle(.stack)
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(appData: AppData(), loggedIn: .constant(true))
    }
}
