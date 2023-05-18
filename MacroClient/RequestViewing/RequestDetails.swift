//
//  RequestDetails.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 18/05/23.
//

import SwiftUI

struct RequestDetails: View {
    @StateObject var appData: AppData
    let request: UserRequest
    
    var body: some View {
        GeometryReader { proxy in
            Form {
                Section(header: Text("Creator details")) {
                    HStack {
                        RemoteImage(imgname: "user_generic")
                        
                        Text(request.user_id)
                            .frame(width: proxy.size.width * 0.67)
                            .font(.system(size: 25, weight: .semibold))
                            .lineLimit(1)
                    }
                }
                
                Section(header: Text("Game")) {
                    
                    HStack {
                        
                        RemoteImage(imgname: appData.games[request.game]?.imgname ?? "game_generic")
                            .frame(width: 60, height: 60)
                        
                            Text(request.game)
                                .frame(width: proxy.size.width * 0.67)
                                .font(.system(size: 25, weight: .semibold))
                                .lineLimit(1)
                    }
                }
                
                Section(header: Text("Available roles")) {
                    
                    ForEach(appData.games[request.game]?.skills ?? [], id: \.self) { skill in
                        
                        
                        HStack {
                            Text(skill).foregroundColor(.black)
                            
                            if request.skills.isEmpty || request.skills.firstIndex(of: skill) != nil {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .renderingMode(.template)
                                    .foregroundColor(.blue)
                            } else {
                                Spacer()
                                Image(systemName: "xmark")
                                    .renderingMode(.template)
                                    .foregroundColor(.red)
                            }
                        }
                        
                    }
                }
                
                Section(header: Text("Request")) {
                    HStack {
                        Text("🕹️ Platform:")
                            .font(.title3)
                        Spacer()
                        Image(request.plat)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35.0, height: 35.0)
                    }
                    
                    HStack {
                        Text("🎮 Gamemode:")
                            .font(.title3)
                        Spacer()
                        Text(request.mode)
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("👤 Players:")
                            .font(.title3)
                        Spacer()
                        Text("\(request.pnumber)")
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("🌎 Region:")
                            .font(.title3)
                        Spacer()
                        Text("\(request.region)")
                            .font(.headline)
                    }
                    
                    HStack {
                        Text("🎙️ Microphone:")
                            .font(.title3)
                        Spacer()
                        Text(request.mic ? "Required":"Not required")
                            .font(.headline)
                    }
                }
            }
        }
        .navigationTitle("Request details")
    }
}

struct RequestDetails_Previews: PreviewProvider {
    static var previews: some View {
        RequestDetails(appData: AppData(), request: UserRequest(uuid: " ", user_id: "Example", game: "League of Legends", time: 120, mic: true, region: "ITA", pnumber: 2, skills: [], plat: "PC", mode: "Draft pick"))
    }
}
