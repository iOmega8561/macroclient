//
//  NewRequest.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameConfig: View {
    @StateObject var tempData: TempData
    
    @State var newRequest: UserRequest
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Select platform and game mode")) {
                    Picker("Platform", selection: $newRequest.plat) {
                        ForEach(tempData.games[newRequest.game]!.plat, id: \.self) { plat in
                            Text(plat)
                        }
                    }.pickerStyle(.segmented)
                    
                    Picker("Gamemodes", selection: $newRequest.mode) {
                        ForEach(tempData.games[newRequest.game]!.modes, id: \.self) { mode in
                            Text(mode)
                        }
                    }.pickerStyle(.wheel)
                }
                
                Section(header: Text("Select roles to search for")) {
                    ForEach(tempData.games[newRequest.game]!.skills, id: \.self) { skill in
                        
                        Button {
                            if let index = newRequest.skills.firstIndex(of: skill) {
                                newRequest.skills.remove(at: index)
                            } else { newRequest.skills.append(skill) }
                        } label: {
                            HStack {
                                Text(skill).foregroundColor(.black)
                                
                                if newRequest.skills.firstIndex(of: skill) != nil {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .renderingMode(.template)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Other details")) {
                    Toggle("Microphone required", isOn: $newRequest.mic)
                    
                    Stepper("Players needed: \(newRequest.pnumber)", value: $newRequest.pnumber, in: 1...20, step: 1)
                    
                    Stepper("Expiration time: \(newRequest.time) min", value: $newRequest.time, in: 5...120, step: 5)
                    
                    Picker("Region", selection: $newRequest.region) {
                        ForEach(mainRegions, id: \.self) { region in
                            Text(region)
                        }
                    }.pickerStyle(.menu)
                }
                
                /*Section(header: Text("Brief description")) {
                    TextField("Description text", text: $newRequest.desc, axis: .vertical)
                        .lineLimit(5)
                        .padding(10)
                        .font(.system(size: 20.0))
                        .cornerRadius(10.0)
                }*/
            }
            .navigationTitle(newRequest.game)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: MainView(tempData: tempData)
                        .task {
                            await tempData.insertUserRequest(newRequest: newRequest)
                        }
                        .navigationBarBackButtonHidden(true)
                    ) {
                            Text("Save and Exit")
                        }
                }
            }

        }
    }
}

struct GameConfig_Previews: PreviewProvider {
    static var previews: some View {
        GameSelection(tempData: TempData())
    }
}
