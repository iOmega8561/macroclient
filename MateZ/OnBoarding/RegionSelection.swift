//
//  RegionSelection.swift
//  MateZ
//
//  Created by Giuseppe Rocco on 05/06/23.
//

import SwiftUI

struct RegionSelection: View {
    @StateObject var appData: AppData
    
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
                    .filter { $0.contains(searchText) }
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
                        NavigationLink(destination: GamesSelection(appData: appData), isActive: $navigationActive) {EmptyView() }
                        
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
        RegionSelection(appData: AppData())
    }
}
