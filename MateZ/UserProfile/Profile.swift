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
    
    @State var deleteDialog: Bool = false
    @State var logOutDialog: Bool = false
    @State var avatarPicker: Bool = false
    @State var showModal: Bool = false
    @State var error: Bool = false
    
    var myRequests: [UserRequest] {
        let new = appData.requests.filter {
            $0.value.user_id == appData.authData.username
        }.map{$0.value}
        
        return new.sorted(by: {$0.date > $1.date})
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    Color("BG").ignoresSafeArea()
                    
                    ScrollView {
                        VStack {
                            HStack {
                                Spacer()
                                VStack {
                                    ZStack(alignment: .bottomTrailing) {
                                        RemoteImage(imgname: appData.localProfile.avatar, squareSize: 130)
                                            .clipShape(Circle())
                                            .frame(width: 130, height: 130)
                                        
                                        Button(action: {avatarPicker = true}) {
                                            Image(systemName: "pencil.circle.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30)
                                                .padding(.horizontal)
                                        }.sheet(isPresented: $avatarPicker) {
                                            AvatarPicker(appData: appData)
                                        }
                                    }
                                    
                                    Text(appData.localProfile.username)
                                        .font(.title)
                                }
                                Spacer()
                            }
                            
                            VStack(alignment: .leading) {
                                Text("YOUR REQUESTS")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        ForEach(myRequests, id: \.self) { req in
                                            NavigationLink(destination: LobbyDetails(appData: appData, request: req, userDetailEnabled: false)) {
                                                LobbyBox(games: appData.games, request: req)
                                                    .frame(width: proxy.size.width * 0.92, height: 120)
                                            }
                                            .foregroundColor(.primary)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    deleteDialog.toggle()
                                                } label: {
                                                    Label("Delete request", systemImage: "x.circle")
                                                }
                                                
                                            }
                                            .confirmationDialog("Are you sure?", isPresented: $deleteDialog, titleVisibility: .visible) {
                                                Button(role: .destructive) {
                                                    deleteDialog = false
                                                    Task {
                                                        await appData.deleteUserRequest(uuid: req.uuid)
                                                    }
                                                } label: {
                                                    Text("Yes, delete it.")
                                                }
                                            }
                                        }
                                    }//.padding(.horizontal)
                                }.padding(.horizontal)
                            }.padding(.vertical)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("FAVOURITE GAMES")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    Button {
                                        if appData.games.count == appData.localProfile.fgames.count {
                                            error.toggle()
                                        } else {
                                            showModal.toggle()
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                    }
                                    .foregroundColor(.secondary)
                                    .sheet(isPresented: $showModal) {
                                        FavouritePicker(appData: appData)
                                    }
                                    .alert("No other games to pin", isPresented: $error) {
                                        Button("OK", role: .cancel) { }
                                    }
                                    
                                    
                                }.padding(.trailing)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        ForEach(appData.localProfile.fgames, id: \.self) { g in
                                            VStack {
                                                RemoteImage(imgname: appData.games[g]?.imgname ?? "game_default")
                                                    .frame(width: 60, height: 60)
                                                    .padding()
                                            }
                                            .background(Color("CardBG"))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    Task {
                                                        let idx = appData.localProfile.fgames.firstIndex(of: g)
                                                        
                                                        appData.localProfile.fgames.remove(at: idx!)
                                                        await appData.updateUser()
                                                    }
                                                } label: {
                                                    Label("Delete game", systemImage: "x.circle")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom)
                            
                            Button(action: { logOutDialog.toggle() }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBG"))
                                    .frame(height: 40.0)
                                    .overlay {
                                        Text("Log out")
                                            .foregroundColor(.red)
                                    }
                            }
                            .padding(.horizontal)
                            .confirmationDialog("Are you sure?", isPresented: $logOutDialog, titleVisibility: .visible) {
                                Button(role: .destructive) {
                                    Task {
                                        await appData.logout()
                                        logOutDialog = false; loggedIn = false
                                    }
                                } label: {
                                    Text("Yes, log me out.")
                                }
                            }
                        }
                    }.padding(.top)
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
