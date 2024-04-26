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
//  AvatarPicker.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 22/05/23.
//

import SwiftUI

struct AvatarPicker: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var appData: AppData
    
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
                                                ZStack(alignment: .center) {
                                                    Circle()
                                                        .fill(Color("BDisabled"))
                                                        .frame(width: 33)
                                                    
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
        AvatarPicker()
    }
}
