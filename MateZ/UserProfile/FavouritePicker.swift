//
//  FavouritePicker.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/05/23.
//

import SwiftUI

struct FavouritePicker: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @StateObject var appData: AppData
    @State var searchText: String = ""
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ZStack {
                    Color("BG").ignoresSafeArea()
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(searchResults, id: \.self) { game in
                                
                                
                                Button {
                                    Task {
                                        appData.localProfile.fgames.append(game)
                                        await appData.updateUser()
                                    }
                                    dismiss()
                                } label: {
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
                                                Image(systemName: "plus")
                                            }.padding(.horizontal)
                                        }
                                }
                            }
                        }.padding(.horizontal)
                    }
                    .searchable(text: $searchText)
                    .navigationTitle("Select a game")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {dismiss()}) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15)
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            UITableView.appearance().backgroundColor = UIColor(Color("BG"))
        }
        .onChange(of: scenePhase) { _ in
            if searchResults.count < 1 {
                dismiss()
            }
        }
    }
    
    var fgamesList: [String] {
        return appData.localProfile.fgames
    }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return appData.games.map{$0.key}.filter{
                !fgamesList.contains($0)
            }.sorted()
        } else {
            return appData.games.map{$0.key}.filter {
                $0.lowercased().contains(searchText.lowercased()) && !fgamesList.contains($0)
            }.sorted()        }
    }
}

struct FavouritePicker_Previews: PreviewProvider {
    static var previews: some View {
        FavouritePicker(appData: AppData())
    }
}
