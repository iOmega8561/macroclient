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
//  RegionSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct RegionSelection: View {
    @EnvironmentObject var appData: AppData
    
    @State var searchText: String = ""
    @State var navigationActive: Bool = false
    @State var showError: Bool = false
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return regions
                    .map{$0.key}
                    .sorted()
        } else {
            return regions
                    .map{$0.key}
                    .filter { $0.lowercased().contains(searchText.lowercased()) }
                    .sorted()
        }
    }
    
    var body: some View {
        ZStack {
            Color("BG").ignoresSafeArea()
               
            ScrollView {
                LazyVStack(alignment: .leading) {
                    
                    ForEach(searchResults, id: \.self) { region in
                        Button {
                            appData.localProfile.region = regions[region] ?? "n/a"
                        } label: {
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color("CardBG"))
                                    .frame(height: 50)
                                    .overlay {
                                        HStack {
                                            Image(regions[region]!)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40)
                                                .padding(.trailing)
                                            
                                            Text(region)
                                                .lineLimit(1)
                                                .font(.system(size: 17))
                                                .foregroundColor(.primary)
                                            Spacer()
                                            
                                            if appData.localProfile.region == regions[region] ?? "na" {
                                                Image(systemName: "checkmark")
                                            }
                                        }.padding(.horizontal)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .searchable(text: $searchText)
            }
            .navigationTitle("Select your country")
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button {
                        if appData.localProfile.region != "n_a" {
                            navigationActive = true
                        } else {
                            showError.toggle()
                        }
                    } label: {
                        NavigationLink(destination: GamesSelection().environmentObject(appData), isActive: $navigationActive) {EmptyView() }
                        
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                        
                    }
                    .alert("Select your country", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
        }
    }
}

struct RegionSelection_Previews: PreviewProvider {
    static var previews: some View {
        RegionSelection()
    }
}
