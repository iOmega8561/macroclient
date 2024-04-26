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
//  GameSelection.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameSelection: View {
    @EnvironmentObject var appData: AppData
    @State var searchText: String = ""
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
            ScrollView {
                LazyVStack {
                    ForEach(searchResults, id: \.self) { game in
                        NavigationLink(destination: GameConfig(newRequest: UserRequest(
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
                        )).environmentObject(appData)) {
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
        GameSelection()
    }
}
