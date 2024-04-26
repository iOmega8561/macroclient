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
//  RequestDetails.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI

struct LobbyDetails: View {
    @EnvironmentObject var appData: AppData
    let request: UserRequest
    let userDetailEnabled: Bool
    
    @State var creatorData: UserProfile = UserProfile()
    @State var isLoading: Bool = true
    let dateFormatter: DateFormatter
    var expireDate: Date
    
    
    init(request: UserRequest, userDetailEnabled: Bool) {
        self.request = request
        self.userDetailEnabled = userDetailEnabled
        
        _creatorData = State(wrappedValue: UserProfile())
        _isLoading = State(initialValue: true)
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeStyle = .short
        
        self.expireDate = request.date + TimeInterval(request.time * 60)
    }
    
    var regionName: String {
        let r = regions.first(where: {$0.value == request.region})
        
        return r!.key
    }
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    
                    if !isLoading {
                        NavigationLink(destination: UneditableProfile(userProfile: creatorData).environmentObject(appData)) {
                            VStack(alignment: .center) {
                                RemoteImage(imgname: creatorData.avatar, squareSize: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Text(creatorData.username)
                                    .font(.system(size: 22, weight: .semibold))
                                    .lineLimit(1)
                            }
                        }
                        .isDetailLink(true)
                        .disabled(!userDetailEnabled)
                        .foregroundColor(.primary)
                    }
                    
                    Divider()
                        .background(.primary)
                    
                    HStack(alignment: .bottom) {
                        Image("Bomb")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(expireDate, formatter: dateFormatter)
                    }
                    
                    VStack {
                        Group {
                            HStack {
                                Text("Game:")
                                    .font(.title3)
                                
                                Spacer()
                                
                                Text(request.game)
                                    .font(.headline)
                                
                                RemoteImage(imgname: appData.games[request.game]?.imgname ?? "game_generic", squareSize: 35)
                                
                            }
                            
                            Divider()
                                .background(.primary)
                        }
                        
                        Group {
                            HStack {
                                Text("Platform:")
                                    .font(.title3)
                                Spacer()
                                Text(request.plat)
                                    .font(.headline)
                                ZStack(alignment: .center) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color("BDisabled"))
                                        .frame(width: 31, height: 31)
                                    
                                    Image(request.plat)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 28.0, height: 28.0)
                                }
                            }
                            
                            Divider()
                                .background(.primary)
                            
                            HStack {
                                Text("Region:")
                                    .font(.title3)
                                Spacer()
                                
                                Text(regionName)
                                    .font(.headline)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color("BDisabled"))
                                        .frame(width: 29,height: 22)
                                    
                                    Image(request.region)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                }
                            }
                            
                            Divider()
                                .background(.primary)
                            
                            HStack {
                                Text("Microphone:")
                                    .font(.title3)
                                Spacer()
                                Text(request.mic ? "Required":"Not required")
                                    .font(.headline)
                                Image(systemName: "mic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25.0, height: 25.0)
                            }
                            
                            Divider()
                                .background(.primary)
                            
                            HStack {
                                Text("Game mode:")
                                    .font(.title3)
                                Spacer()
                                Text(request.mode)
                                    .font(.headline)
                                Image(systemName: "flag.2.crossed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35.0, height: 35.0)
                            }
                            
                            Divider()
                                .background(.primary)
                        
                            HStack {
                                Text("Players:")
                                    .font(.title3)
                                Spacer()
                                Text("\(request.pnumber)")
                                    .font(.headline)
                                Image(systemName: "person.2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30.0, height: 30.0)
                            }
                        }
                        
                        Divider()
                            .background(.primary)
                        
                        HStack {
                            Text("Open roles:")
                                .font(.title3)
                            Spacer()
                            
                            if request.skills.count > 0 {
                                
                                Text("\(request.skills.joined(separator: ", "))")
                                    .font(.headline)
                            } else {
                                Text("Any role")
                                    .font(.headline)
                            }
                            
                            
                            Image(systemName: "gamecontroller")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.0, height: 30.0)
                        }
                    }
                    .padding()
                    .background(Color("CardBG"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding([.horizontal, .top])
            }
            .navigationTitle("Lobby details")
            .task {
                if let data = await appData.getProfile(username: request.user_id) {
                    creatorData = data
                    isLoading = false
                }
            }
        }
    }
}

struct LobbyDetails_Previews: PreviewProvider {
    static var previews: some View {
        //LobbyDetails(appData: AppData(), request: UserRequest(uuid: "na", user_id: "Creator username", game: "Game title", time: 5, mic: true, region: "REG", pnumber: 2, skills: [], plat: "PC", mode: "Game mode", date: Date.now))
        
        Dashboard()
    }
}
