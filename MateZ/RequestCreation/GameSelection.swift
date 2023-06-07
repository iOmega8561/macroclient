//
//  GameSelection.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameSelection: View {
    @StateObject var appData: AppData
    @State var searchText: String = ""
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
            ScrollView {
                LazyVStack {
                    ForEach(searchResults, id: \.self) { game in
                        NavigationLink(destination: GameConfig(appData: appData, newRequest: UserRequest(
                            uuid: "localrequest",
                            user_id: appData.authData.username,
                            game: game,
                            time: 5,
                            mic: false,
                            region: appData.localProfile.region,
                            pnumber: 1,
                            skills: [],
                            plat: appData.games[game]!.plat[0],
                            mode: appData.games[game]!.modes[0],
                            date: Date.now
                        ))) {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBG"))
                                    .frame(height: 50)
                                    .overlay {
                                        HStack {
                                            RemoteImage(imgname: appData.games[game]!.imgname, squareSize: 40)
                                                .frame(width: 40, height: 40)
                                                .padding(.trailing)
                                            
                                            Text(game)
                                                .font(.system(size: 17))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }.padding(.horizontal)
                                    }
                            }
                        }
                    }
                }.padding(.horizontal)
            }
            .searchable(text: $searchText)
            .navigationTitle("Select a game")
        }
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return appData.games.map{$0.key}.sorted()
        } else {
            return appData.games.map{$0.key}.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
    }
}

struct GameSelection_Previews: PreviewProvider {
    static var previews: some View {
        GameSelection(appData: AppData())
    }
}
