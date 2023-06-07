//
//  LobbyBox2.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 03/06/23.
//

import SwiftUI

struct LobbyBox: View {
    let games: [String: Game]
    let request: UserRequest
    let dateFormatter: DateFormatter
    var expireDate: Date
    
    init(games: [String: Game], request: UserRequest) {
        self.games = games
        self.request = request
        self.dateFormatter = DateFormatter()
        
        self.dateFormatter.dateStyle = .none
        self.dateFormatter.timeStyle = .short
        
        self.expireDate = request.date + TimeInterval(request.time * 60)
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(Color("CardBG"))
            .overlay {
                HStack {
                    RemoteImage(imgname: games[request.game]?.imgname ?? "game_generic", squareSize: 70)
                        .frame(width: 70.0, height: 70.0)
                        .shadow(radius: 4.0)
                        .padding(.trailing)
                    
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(request.game)
                                .lineLimit(1)
                                .font(.system(size: 17, weight: .semibold))
                            
                            Spacer()
                            
                            ZStack(alignment: .center) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("BDisabled"))
                                    .frame(width: 32, height: 32)
                                
                                Image(request.plat)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28.0, height: 28.0)
                            }
                        }
                        
                        
                        HStack {
                            Image(systemName: "hourglass")
                            Text(expireDate, formatter: dateFormatter)
                        }
                        Spacer()
                        
                        HStack {
                            
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color("BDisabled"))
                                        .frame(width: 26,height: 20)
                                    
                                    Image(request.region)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                }
                                
                                Text(request.region.uppercased())
                                    .font(.system(size: 17))
                            }
                            
                            Spacer()
                            HStack {
                                Image(systemName: "mic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                                
                                Text(request.mic ? "On":"Off")
                                    .font(.system(size: 17))
                            }
                            Spacer()
                            HStack {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                
                                Text("\(request.pnumber)")
                                    .font(.system(size: 17))
                            }
                            //Spacer()
                        }
                    }
                    
                    
                    Spacer()
                }.padding()
            }
    }
}

struct LobbyBox_Previews: PreviewProvider {
    static var previews: some View {
        //LobbyBox2(games: [:], request: UserRequest(uuid: "na", user_id: "Creator username", game: "Game title", time: 5, mic: true, region: "IT", pnumber: 2, skills: [], plat: "PC", mode: "Game mode", date: Date.now))
        
        Dashboard(appData: AppData())
    }
}
