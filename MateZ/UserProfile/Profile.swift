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
                    Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                    
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
                                            NavigationLink(destination: RequestDetails(appData: appData, request: req)) {
                                                RequestBox(games: appData.games, request: req)
                                                    .frame(width: proxy.size.width * 0.92, height: proxy.size.height * 0.24)
                                            }
                                            .foregroundColor(.primary)
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    Task {
                                                        await appData.deleteUserRequest(uuid: req.uuid)
                                                    }
                                                } label: {
                                                    Label("Delete request", systemImage: "x.circle")
                                                }
                                            }
                                        }
                                    }.padding(.horizontal)
                                }
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
                                                RemoteImage(imgname: appData.games[g.name]?.imgname ?? "game_default")
                                                    .frame(width: 60, height: 60)
                                                    .padding()
                                                HStack {
                                                    ForEach(g.plat, id: \.self) { p in
                                                        Image(p)
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 20)
                                                    }
                                                }.padding(.bottom)
                                            }
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
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
                                    }.padding(.horizontal)
                                }
                            }.padding(.bottom)
                            
                            Button(action: { showDialog.toggle() }) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                    .frame(height: 40.0)
                                    .overlay {
                                        Text("Log out")
                                            .foregroundColor(.red)
                                    }
                            }
                            .padding(.horizontal)
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
