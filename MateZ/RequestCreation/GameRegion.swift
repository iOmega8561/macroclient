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
                    .filter { $0.contains(searchText) }
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
