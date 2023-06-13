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
    @EnvironmentObject var appData: AppData
    
    @State var suggestedRequests: [UserRequest] = []
    @State var searchText: String = ""
    
    @State var platform: String = ""
    @State var region: Bool = true
    
    private let defPlats = ["", "XBOX", "PlayStation", "PC", "Android", "iOS", "Switch"]
    
    var myLatestRequest: UserRequest? {
        let new = appData.requests.filter {
            $0.value.user_id == appData.authData.username
        }.map{$0.value}
        
        return new.sorted(by: {$0.date > $1.date}).first
    }
    
    var filteredRequests: [UserRequest] {
        var new = appData.requests.filter {
            $0.value.user_id != appData.authData.username && $0.value.game.lowercased().contains(searchText.lowercased())
        }.map{$0.value}
        
        if platform != "" {
            new = new.filter {
                $0.plat == platform
            }
        }
        
        if region {
            new = new.filter {
                $0.region == appData.localProfile.region
            }
        }
        
        return new.sorted(by: {$0.date > $1.date})
    }
    
    func suggestRequests() async {
        var new = appData.requests.filter {
            $0.value.user_id != appData.authData.username
        }.map{$0.value}
        
        if platform != "" {
            new = new.filter {
                $0.plat == platform
            }
        }
        
        if region {
            new = new.filter {
                $0.region == appData.localProfile.region
            }
        }
        
        let byDate = new.sorted(by: {$0.date > $1.date})
        
        var first: [UserRequest] = []
        var second: [UserRequest] = []
        var third: [UserRequest] = []
        
        for req in byDate {
            if (appData.localProfile.fgames.firstIndex(of: req.game) != nil) {
                
                if appData.localProfile.region == req.region {
                    first.append(req)
                } else {
                    second.append(req)
                }
                
            } else {
                third.append(req)
            }
        }
        
        suggestedRequests = first + second + third
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BG").ignoresSafeArea()
                
                if !refreshDone {
                    CustomProgress(withText: true)
                } else {
                    
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 25) {
                            
                            if myLatestRequest != nil && searchText.isEmpty {
                                Text("Your latest lobby")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                NavigationLink(destination: LobbyDetails(request: myLatestRequest!, userDetailEnabled: false).environmentObject(appData)) {
                                    LobbyBox(games: appData.games, request: myLatestRequest!)
                                        .frame(height: 110)
                                }
                                .isDetailLink(true)
                                .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text(searchText.isEmpty ? "Suggested lobbies":"Found lobbies")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Menu {
                                    Toggle(isOn: $region) {
                                        Label("Your country", systemImage: "globe.europe.africa")
                                    }
                                    
                                    Divider()
                                    
                                    Menu {
                                        Picker("", selection: $platform) {
                                            ForEach(defPlats, id: \.self) { plat in
                                                Text(plat != "" ? plat:"All")
                                            }
                                        }
                                    } label: {
                                        Label("Platform", systemImage: "macbook.and.iphone")
                                    }
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            
                            ForEach((searchText.isEmpty ? suggestedRequests:filteredRequests), id: \.self) { req in
                                NavigationLink(destination: LobbyDetails(request: req, userDetailEnabled: true).environmentObject(appData)) {
                                    LobbyBox(games: appData.games, request: req)
                                        .frame(height: 110)
                                }
                                .isDetailLink(true)
                                .foregroundColor(.primary)
                                
                            }
                        }.padding(.horizontal)
                    }
                    .searchable(text: $searchText)
                    .refreshable {
                        await appData.fetchUserRequests()
                        await suggestRequests()
                    }
                    .navigationTitle("Lobbies")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: GameSelection().environmentObject(appData)) {
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
        .navigationViewStyle(.stack)
        .onChange(of: platform) { _ in
            refreshDone = false
            
            Task { await suggestRequests(); refreshDone = true }
        }
        .onChange(of: region) { _ in
            refreshDone = false
            
            Task { await suggestRequests(); refreshDone = true }
        }
        .task {
            await appData.fetchRemoteGames()
            await appData.fetchUserRequests()
            await suggestRequests()
            
            refreshDone = true
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        Dashboard()
    }
}
