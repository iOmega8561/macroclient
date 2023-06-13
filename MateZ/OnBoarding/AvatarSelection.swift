//
//  AvatarSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct AvatarSelection: View {
    @EnvironmentObject var appData: AppData
    
    private let gridItemLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    @State var selection: Int = -1
    @State var navigationActive: Bool = false
    @State var showError: Bool = false
    
    var body: some View {
        
        ZStack {
            Color("BG").ignoresSafeArea()
            
            GeometryReader { proxy in
                ScrollView {
                    VStack(alignment: .leading) {
                        LazyVGrid(columns: gridItemLayout, spacing: 3) {
                            ForEach(0..<15) { i in
                                Button {
                                    selection = i
                                    appData.localProfile.avatar = "user\(i)"
                                } label: {
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
        .navigationTitle("Select your avatar")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if appData.localProfile.avatar != "user_generic" {
                        navigationActive = true
                    } else {
                        showError.toggle()
                    }
                } label: {
                    NavigationLink(destination: RegionSelection().environmentObject(appData), isActive: $navigationActive) {EmptyView() }
                    
                    HStack {
                        Text("Next")
                        Image(systemName: "chevron.right")
                    }
                    
                }
                .alert("Select an avatar", isPresented: $showError) {
                    Button("OK", role: .cancel) { }
                }
            }
        }
    }
}

struct AvatarSelection_Previews: PreviewProvider {
    static var previews: some View {
        AvatarSelection()
    }
}
