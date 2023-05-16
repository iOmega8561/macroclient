//
//  GameSelection.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameSelection: View {
    @StateObject var tempData: TempData    
    @State var searchText: String = ""
    
    
    
    var body: some View {
        NavigationStack {
            List(searchResults, id: \.self) { game in
                NavigationLink(destination: GameConfig(tempData: tempData, newRequest: UserRequest(
                    uuid: "localrequest",
                    user_id: "localuser",
                    game: game,
                    time: 10,
                    mic: false,
                    region: mainRegions[0],
                    pnumber: 1,
                    skills: [],
                    plat: tempData.games[game]!.plat[0],
                    mode: tempData.games[game]!.modes[0]
                ))) {
                    HStack {
                        Text(game)
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Select a game")
        }
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return tempData.games.map{$0.key}
        } else {
            return tempData.games.map{$0.key}.filter { $0.contains(searchText) }
        }
    }
}

struct GameSelection_Previews: PreviewProvider {
    static var previews: some View {
        GameSelection(tempData: TempData())
    }
}
