//
//  RequestBox.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import SwiftUI

struct RequestBox: View {
    @StateObject var tempData: TempData
    
    let request: UserRequest
    
    let rG: RadialGradient = RadialGradient(colors: [ .white, .gray], center: .center, startRadius: 20, endRadius: 500)
    
    var body: some View {
        RoundedRectangle(cornerRadius: 10.0)
            .fill(rG)
            .shadow(radius: 10.0)
            .overlay(
                GeometryReader { proxy in
                    HStack {
                        
                        Spacer().frame(width: proxy.size.width * 0.05)
                        
                        VStack {
                            Spacer().frame(height: proxy.size.height * 0.07)
                            
                            HStack {
                                RemoteImage(imgname: tempData.games[request.game]?.imgname ?? "game_generic")
                                    .frame(width: 60.0, height: 60.0)
                                    .shadow(radius: 4.0)
                                
                                Spacer().frame(maxWidth: proxy.size.width * 0.01)
                                
                                VStack {
                                    Text(request.game)
                                        .frame(width: proxy.size.width * 0.70)
                                        .font(.system(size: 25, weight: .semibold))
                                        .lineLimit(1)
                                    
                                    HStack {
                                        Spacer().frame(maxWidth: proxy.size.width * 0.07)
                                        Text("👤 \(request.pnumber)   \(request.skills.count > 0 ? request.skills.joined(separator: ", "):"Any role")")
                                            .font(.system(size: 20, weight: .semibold))
                                            .lineLimit(1)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            HStack {
                                Spacer().frame(width: proxy.size.width * 0.045)
                                
                                Image(request.plat)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35.0, height: 35.0)
                                
                                Spacer()
                                
                                Text("🎮 \(request.mode)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .lineLimit(1)
                                
                                Spacer().frame(width: proxy.size.width * 0.045)
                                
                                Text("🌎 \(request.region)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .lineLimit(1)
                                
                                Spacer().frame(width: proxy.size.width * 0.045)
                            }
                            
                            Spacer().frame(height: proxy.size.height * 0.07)
                        }
                        
                        Spacer().frame(width: proxy.size.width * 0.05)
                    }
                }
            )
    }
}

struct RequestBox_Previews: PreviewProvider {
    static var previews: some View {
        //RequestBox()
        MainView(tempData: TempData())
    }
}
