//
//  Dashboard.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import SwiftUI

struct Dashboard: View {
    @State var refreshDone: Bool = false
    @State var logoutActive: Bool = false
    @StateObject var appData: AppData
    
    var notMyRequests: [UserRequest] {
        let new = appData.requests.filter {
            $0.value.user_id != appData.authData.username
        }.map{$0.value}
        
        return new.sorted(by: {$0.date > $1.date})
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BG").ignoresSafeArea()
                
                if !refreshDone {
                    CustomProgress(withText: true)
                } else {
                    
                    ScrollView {
                        LazyVStack {
                            if appData.requests.count < 1 {
                                Text("")
                            }
                            
                            ForEach(notMyRequests, id: \.self) { req in
                                NavigationLink(destination: LobbyDetails(appData: appData, request: req, userDetailEnabled: true)) {
                                    LobbyBox(games: appData.games, request: req)
                                        .frame(height: 120)
                                }
                                .isDetailLink(true)
                                .foregroundColor(.primary)
                                
                            }
                        }.padding(.horizontal)
                    }
                    .refreshable {
                        _ = await appData.fetchUserRequests()
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationTitle("Lobbies")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: GameSelection(appData: appData)) {
                                HStack {
                                    Text("New")
                                    Image(systemName: "plus")
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            await appData.fetchRemoteGames()
            
            refreshDone = await appData.fetchUserRequests()
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard(appData: AppData())
    }
}
