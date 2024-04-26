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
//  NewRequest.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameConfig: View {
    @Environment(\.dismiss) private var dismiss

    @EnvironmentObject var appData: AppData
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
                        /*VStack(alignment: .leading, spacing: 5) {
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
                        }*/
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Game roles")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(appData.games[newRequest.game]!.skills, id: \.self) { skill in
                                        
                                        if !(newRequest.skills.firstIndex(of: skill) != nil) {
                                            Button {
                                                newRequest.skills.append(skill)
                                            } label: {
                                                Text(skill)
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                }
                            }
                            .padding(.horizontal)
                            
                            TagCloud(tags: $newRequest.skills)
                                .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Other details")
                            .font(.title2)
                            .foregroundColor(.primary)
                            
                        
                        VStack(alignment: .leading, spacing: 5) {
                            
                            
                            Toggle("Microphone required", isOn: $newRequest.mic)
                                .tint(.accentColor)
                                .padding(.bottom, 5)
                            
                            Divider()
                                .background(.primary)
                            
                            Stepper("Players needed: \(newRequest.pnumber)", value: $newRequest.pnumber, in: 1...20, step: 1)
                                .frame(height: 40)
                            
                            Divider()
                                .background(.primary)
                            
                            Stepper("Expiration time: \(newRequest.time) min", value: $newRequest.time, in: 5...120, step: 5)
                                .frame(height: 40)
                            
                            Divider()
                                .background(.primary)
                            
                            Button(action: {showModal.toggle()}) {
                                HStack {
                                    Text("Region")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(regions.first(where: {$1 == newRequest.region})?.key ?? "N/A")
                                        .foregroundColor(.primary)
                                    
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color("BDisabled"))
                                            .frame(width: 29,height: 22)
                                        
                                        Image(newRequest.region)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25)
                                    }
                                    
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(.secondary)
                                        .scaledToFit()
                                        .frame(width: 10)
                                }
                            }
                            .sheet(isPresented: $showModal) {
                                GameRegion(alpha2Bind: $newRequest.region)
                            }
                            .padding(.top, 5)
                            
                        }
                        .padding()
                        .background(Color("CardBG"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(newRequest.game)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await appData.insertUserRequest(newRequest: newRequest)
                        await appData.fetchUserRequests()
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
        GameSelection()
    }
}
