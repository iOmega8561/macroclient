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
//  GamesSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct GamesSelection: View {
    @EnvironmentObject var appData: AppData
    
    @State var searchText: String = ""
    @State var showError: Bool = false
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
            
            ScrollView {
                LazyVStack {
                    ForEach(searchResults, id: \.self) { game in
                        Button {
                            if appData.localProfile.fgames.contains(game) {
                                if let idx = appData.localProfile.fgames.firstIndex(of: game) {
                                    
                                    appData.localProfile.fgames.remove(at: idx)
                                }
                            } else {
                                appData.localProfile.fgames.append(game)
                            }
                        } label: {
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
                                            
                                            if appData.localProfile.fgames.contains(game) {
                                                Image(systemName: "checkmark")
                                            }
                                        }.padding(.horizontal)
                                    }
                            }
                        }
                    }
                }.padding(.horizontal)
            }
            .searchable(text: $searchText)
            .navigationTitle("Select your games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !appData.localProfile.fgames.isEmpty {
                            Task {
                                await appData.updateUser()
                            }
                        } else {
                            showError.toggle()
                        }
                    } label: {
                        Text("All set!")
                    }
                    .alert("Select at least one game", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
        }
        .task {
            await appData.fetchRemoteGames()
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

struct GamesSelection_Previews: PreviewProvider {
    static var previews: some View {
        GamesSelection()
    }
}
