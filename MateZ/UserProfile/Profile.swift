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
    @State var error2: Bool = false
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
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
                            HStack(alignment: .center) {
                                
                                VStack(alignment: .center) {
                                    RemoteImage(imgname: appData.localProfile.avatar, squareSize: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .frame(width: 100, height: 100)
                                    
                                    Button(action: {avatarPicker = true}) {
                                        
                                        Text("Edit Avatar")
                                            .font(.system(size: 12, weight: .semibold))
                                        
                                    }.sheet(isPresented: $avatarPicker) {
                                        AvatarPicker(appData: appData)
                                    }
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(appData.localProfile.username)
                                        .font(.system(size: 25))
                                        
                                    HStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color("BDisabled"))
                                                .frame(width: 26,height: 20)
                                            
                                            Image(appData.localProfile.region)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 21)
                                        }
                                        
                                        Text(appData.localProfile.region.uppercased())
                                            .font(.system(size: 18))
                                    }
                                    
                                }
                                .padding([.horizontal, .bottom])
                                
                                Spacer()
                            }.padding([.horizontal, .top])
                            
                            VStack(alignment: .leading) {
                                Text("Your requests")
                                    .font(.title2)
                                    .foregroundColor(.primary)
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
                                    Text("Favourite games")
                                        .font(.title2)
                                        .foregroundColor(.primary)
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
                                            .renderingMode(.template)
                                            .foregroundColor(.primary)
                                    }
                                    .foregroundColor(.secondary)
                                    .sheet(isPresented: $showModal) {
                                        FavouritePicker(appData: appData)
                                    }
                                    .alert("No other games to pin", isPresented: $error) {
                                        Button("OK", role: .cancel) { }
                                    }
                                    
                                    
                                }.padding(.trailing)
                                
                                
                                LazyVGrid(columns: gridItemLayout, spacing: 10) {
                                    ForEach(appData.localProfile.fgames, id: \.self) { g in
                                        VStack {
                                            RemoteImage(imgname: appData.games[g]?.imgname ?? "game_default", squareSize: 70)
                                                .frame(width: 80, height: 80)
                                                .padding()
                                        }
                                        .background(Color("CardBG"))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                Task {
                                                    if appData.localProfile.fgames.count > 1 { if let idx = appData.localProfile.fgames.firstIndex(of: g) {
                                                        
                                                        appData.localProfile.fgames.remove(at: idx)
                                                        await appData.updateUser()
                                                    }
                                                    } else {
                                                        error2.toggle()
                                                    }
                                                }
                                            } label: {
                                                Label("Delete game", systemImage: "x.circle")
                                            }
                                            
                                        }
                                        .alert("You need at least one game!", isPresented: $error2) {
                                            Button("OK", role: .cancel) { }
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
                    }
                }
            }
            .navigationTitle("Profile")
        }.navigationViewStyle(.stack)
    }
}

struct Profile_Previews: PreviewProvider {
    static var previews: some View {
        Profile(appData: AppData(), loggedIn: .constant(true))
    }
}
