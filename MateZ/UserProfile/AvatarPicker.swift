//
//  AvatarPicker.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 22/05/23.
//

import SwiftUI

struct AvatarPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var appData: AppData
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var selection: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BG").ignoresSafeArea()
                
                Group {
                    GeometryReader { proxy in
                        ScrollView {
                            Spacer().frame(height: 20)
                            
                            LazyVGrid(columns: gridItemLayout, spacing: 3) {
                                ForEach(0..<15) { i in
                                    Button(action: { selection = i }) {
                                        ZStack(alignment: .bottomTrailing) {
                                            RemoteImage(imgname: "user\(i)", squareSize: proxy.size.width / 3)
                                            
                                            if selection == i {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30)
                                                    .padding()
                                                    .foregroundColor(.accentColor)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.horizontal)
            }
            
            .navigationTitle("Choose your avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            appData.localProfile.avatar = "user\(selection)"
                            await appData.updateUser()
                            dismiss()
                        }
                    }) {
                        Text("Save")
                    }
                }
                
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
