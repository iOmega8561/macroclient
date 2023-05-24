//
//  AvatarPicker.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 22/05/23.
//

import SwiftUI

struct AvatarPicker: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var appData: AppData
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var selection: Int = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                ScrollView {
                    LazyVGrid(columns: gridItemLayout, spacing: 10) {
                        ForEach(0..<6) { i in
                            Button(action: { selection = i }) {
                                ZStack(alignment: .bottomTrailing) {
                                    RemoteImage(imgname: "user\(i)", squareSize: proxy.size.width / 3)
                                    
                                    if selection == i {
                                        Image(systemName: "checkmark.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30)
                                            .padding()
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose your avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            appData.localProfile.avatar = "user\(selection)"
                            await appData.updateUser()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Save")
                    }
                }
            }
        }
        .task {
            if appData.localProfile.avatar != "user_generic" {
                let avatar = appData.localProfile.avatar
                selection = Int(avatar.replacingOccurrences(of: "user", with: ""))!
            }
        }
    }
}

struct AvatarPicker_Previews: PreviewProvider {
    static var previews: some View {
        AvatarPicker(appData: AppData())
    }
}
