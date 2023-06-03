//
//  UneditableProfile.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 03/06/23.
//

import SwiftUI

struct UneditableProfile: View {
    @StateObject var appData: AppData
    let userProfile: UserProfile
    
    @State var error: Bool = false
    
    let gradient: LinearGradient = LinearGradient(colors: [Color("CardBG_2"), Color("CardBG_1")], startPoint: .bottom, endPoint: .top)
    
    var theirRequests: [UserRequest] {
        let new = appData.requests.filter {
            $0.value.user_id == userProfile.username
        }.map{$0.value}
        
        return new.sorted(by: {$0.date > $1.date})
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color("BG").ignoresSafeArea()
                
                ScrollView {
                    VStack {
                        HStack {
                            Spacer()
                            VStack {
                                
                                RemoteImage(imgname: userProfile.avatar, squareSize: 130)
                                    .clipShape(Circle())
                                    .frame(width: 130, height: 130)
                                
                                Text(userProfile.username)
                                    .font(.title)
                            }
                            Spacer()
                        }
                        
                        VStack(alignment: .leading) {
                            Text("THEIR REQUESTS")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(theirRequests, id: \.self) { req in
                                        NavigationLink(destination: LobbyDetails(appData: appData, request: req, userDetailEnabled: false)) {
                                            LobbyBox(games: appData.games, request: req)
                                                .frame(width: proxy.size.width * 0.92, height: 120)
                                        }
                                        .foregroundColor(.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("FAVOURITE GAMES")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                Spacer()
                            }
                            .padding(.trailing)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(userProfile.fgames, id: \.self) { g in
                                        VStack {
                                            RemoteImage(imgname: appData.games[g]?.imgname ?? "game_default")
                                                .frame(width: 60, height: 60)
                                                .padding()
                                        }
                                        .background(gradient)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("\(userProfile.username)'s Profile")
        }
    }
}

struct UneditableProfile_Previews: PreviewProvider {
    static var previews: some View {
        UneditableProfile(appData: AppData(), userProfile: UserProfile())
    }
}
