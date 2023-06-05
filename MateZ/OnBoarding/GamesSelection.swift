//
//  GamesSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct GamesSelection: View {
    @StateObject var appData: AppData
    @Binding var onBoardingDone: Bool
    
    @State var searchText: String = ""
    @State var showError: Bool = false
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
            
            VStack(alignment: .leading) {
                Text("SELECT YOUR GAMES")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
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
                                        .frame(height: 70)
                                        .overlay {
                                            HStack {
                                                RemoteImage(imgname: appData.games[game]!.imgname, squareSize: 55)
                                                    .frame(width: 55, height: 55)
                                                    .padding(.trailing)
                                                
                                                Text(game)
                                                    .font(.system(size: 20))
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
            }
            .navigationTitle("Games")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !appData.localProfile.fgames.isEmpty {
                            Task {
                                await appData.updateUser()
                                onBoardingDone = true
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
        GamesSelection(appData: AppData(), onBoardingDone: .constant(false))
    }
}