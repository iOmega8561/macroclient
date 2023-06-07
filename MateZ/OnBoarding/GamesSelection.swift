//
//  GamesSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct GamesSelection: View {
    @StateObject var appData: AppData
    
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
                                appData.getStartedDone = true
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
        GamesSelection(appData: AppData())
    }
}
