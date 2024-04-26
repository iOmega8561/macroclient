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
//  RegionSelect.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 31/05/23.
//

import SwiftUI

struct GameRegion: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var alpha2Bind: String
    @State var searchText: String = ""
    
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
        NavigationView {
            ZStack {
                Color("BG").ignoresSafeArea()
                
                ScrollView {
                    LazyVStack {
                        ForEach(searchResults, id: \.self) { region in
                            Button {
                                alpha2Bind = regions[region] ?? "na"
                                dismiss()
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
                                                
                                                if alpha2Bind == regions[region] ?? "na" {
                                                    Image(systemName: "checkmark")
                                                }
                                            }.padding(.horizontal)
                                        }
                                }
                            }
                        }
                    }.padding(.horizontal)
                }
                .searchable(text: $searchText)
                .navigationTitle("Select a region")
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
}

struct GameRegion_Previews: PreviewProvider {
    static var previews: some View {
        GameRegion(alpha2Bind: .constant(""))
    }
}
