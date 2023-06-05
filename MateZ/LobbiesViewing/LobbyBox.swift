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
                    RemoteImage(imgname: games[request.game]?.imgname ?? "game_generic", squareSize: 80)
                        .frame(width: 80.0, height: 80.0)
                        .shadow(radius: 4.0)
                        .padding(.trailing)
                    
                    VStack(alignment: .leading) {
                        Text(request.game)
                            .lineLimit(1)
                            .font(.system(size: 23, weight: .semibold))
                        
                        HStack {
                            Image(systemName: "hourglass")
                            Text(expireDate, formatter: dateFormatter)
                        }
                        
                        Spacer()
                        
                        HStack {
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: 29,height: 22)
                                    
                                    Image(request.region)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25)
                                }
                                
                                Text(request.region.uppercased())
                                    .font(.system(size: 18))
                            }
                            Spacer()
                            HStack {
                                Image(systemName: "mic")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                                
                                Text(request.mic ? "On":"Off")
                            }
                            Spacer()
                            HStack {
                                Image(systemName: "person.2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 28)
                                
                                Text("\(request.pnumber)")
                            }
                            Spacer()
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
