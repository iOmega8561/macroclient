//
//  NewRequest.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 10/05/23.
//

import SwiftUI

struct GameConfig: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var appData: AppData
    
    @State var newRequest: UserRequest
    
    var body: some View {
        Form {
            Section(header: Text("Select platform and game mode")) {
                Picker("Platform", selection: $newRequest.plat) {
                    ForEach(appData.games[newRequest.game]!.plat, id: \.self) { plat in
                        Text(plat)
                    }
                }.pickerStyle(.segmented)
                
                Picker("Gamemodes", selection: $newRequest.mode) {
                    ForEach(appData.games[newRequest.game]!.modes, id: \.self) { mode in
                        Text(mode)
                    }
                }.pickerStyle(.wheel)
            }
            
            Section(header: Text("Select roles to search for")) {
                ForEach(appData.games[newRequest.game]!.skills, id: \.self) { skill in
                    
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
        }
        .navigationTitle(newRequest.game)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                /*NavigationLink(destination: MainView(appData: appData)
                    .task {
                        await appData.insertUserRequest(newRequest: newRequest)
                    }
                    .navigationBarBackButtonHidden(true)
                ) {
                    Text("Save and Exit")
                }*/
                
                Button {
                    Task {await appData.insertUserRequest(newRequest: newRequest)}
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save and Exit")
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
