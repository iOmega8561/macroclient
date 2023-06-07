//
//  NewRequest.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameConfig: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var appData: AppData
    @State var newRequest: UserRequest
    @State var showModal: Bool = false
    
    private let defPlats = ["XBOX", "PlayStation", "PC", "Android", "iOS", "Switch"]
    
    var body: some View {
        ZStack {
            Color("BG")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Platform")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            ForEach(defPlats, id: \.self) { plat in
                                VStack {
                                    Button(action: {newRequest.plat = plat}) {
                                        Image(appData.games[newRequest.game]!.plat.contains(plat) ? plat:"\(plat)DIS")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 45)
                                            .grayscale(appData.games[newRequest.game]!.plat.contains(plat) ? 0:1)
                                        
                                    }
                                    .disabled(!appData.games[newRequest.game]!.plat.contains(plat))
                                    .frame(width: 45)
                                    
                                    if newRequest.plat == plat {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color.accentColor)
                                            .frame(width: 42, height: 3)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("Game mode")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        Picker("Gamemodes", selection: $newRequest.mode) {
                            ForEach(appData.games[newRequest.game]!.modes, id: \.self) { mode in
                                Text(mode)
                            }
                        }
                        .pickerStyle(.wheel)
                        .background(Color("CardBG"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal)
                    }
                    
                    if appData.games[newRequest.game]!.skills.count > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Game roles")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                            
                            ForEach(appData.games[newRequest.game]!.skills, id: \.self) { skill in
                                
                                Button {
                                    if let index = newRequest.skills.firstIndex(of: skill) {
                                        newRequest.skills.remove(at: index)
                                    } else { newRequest.skills.append(skill) }
                                } label: {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color("CardBG"))
                                        .frame(height: 40.0)
                                        .overlay {
                                            HStack {
                                                Text(skill).foregroundColor(.primary)
                                                
                                                Spacer()
                                                
                                                if newRequest.skills.firstIndex(of: skill) != nil {
                                                    
                                                    Image(systemName: "checkmark")
                                                }
                                            }.padding(.horizontal)
                                        }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Other details")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBG"))
                            .frame(height: 40.0)
                            .overlay {
                                Toggle("Microphone required", isOn: $newRequest.mic)
                                    .padding(.horizontal)
                                    .tint(.accentColor)
                            }
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBG"))
                            .frame(height: 40.0)
                            .overlay {
                                Stepper("Players needed: \(newRequest.pnumber)", value: $newRequest.pnumber, in: 1...20, step: 1)
                                    .padding(.horizontal)
                            }
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBG"))
                            .frame(height: 40.0)
                            .overlay {
                                Stepper("Expiration time: \(newRequest.time) min", value: $newRequest.time, in: 5...120, step: 5)
                                    .padding(.horizontal)
                            }
                            .padding(.horizontal)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("CardBG"))
                            .frame(height: 40.0)
                            .overlay {
                                Button(action: {showModal.toggle()}) {
                                    HStack {
                                        Text("Region")
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(regions.first(where: {$1 == newRequest.region})?.key ?? "N/A")
                                            .foregroundColor(.primary)
                                        
                                        Image(newRequest.region)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 35)
                                        
                                        Image(systemName: "chevron.up.chevron.down")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.secondary)
                                            .scaledToFit()
                                            .frame(width: 10)
                                    }
                                }
                                .padding(.horizontal)
                                .sheet(isPresented: $showModal) {
                                    GameRegion(alpha2Bind: $newRequest.region)
                                }
                            }
                            .padding(.horizontal)
                        
                        
                    }
                }
            }
        }
        .navigationTitle(newRequest.game)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await appData.insertUserRequest(newRequest: newRequest)
                        _ = await appData.fetchUserRequests()
                    }
                    dismiss()
                } label: {
                    Text("Create")
                }
            }
        }
    }
}

struct GameConfig_Previews: PreviewProvider {
    static var previews: some View {
        GameSelection(appData: AppData())
    }
}
