//
//  RequestDetails.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI

struct LobbyDetails: View {
    @StateObject var appData: AppData
    let request: UserRequest
    let userDetailEnabled: Bool
    
    @State var creatorData: UserProfile = UserProfile()
    @State var isLoading: Bool = true
    let dateFormatter: DateFormatter
    var expireDate: Date
    
    
    init(appData: AppData, request: UserRequest, userDetailEnabled: Bool) {
        _appData = StateObject(wrappedValue: appData)
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
                        NavigationLink(destination: UneditableProfile(appData: appData, userProfile: creatorData)) {
                            VStack(alignment: .center) {
                                RemoteImage(imgname: creatorData.avatar, squareSize: 110)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                
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
                    
                    HStack {
                        Image(systemName: "hourglass")
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
                                Image(request.plat)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35.0, height: 35.0)
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
        
        Dashboard(appData: AppData())
    }
}
