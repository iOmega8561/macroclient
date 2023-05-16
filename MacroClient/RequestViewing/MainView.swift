//
//  TestView.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var tempData: TempData
    @State var refreshDone: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                
                if !refreshDone {
                    CustomProgress(withText: true)
                    
                } else if tempData.requests.count < 1 {
                    GameSelection(tempData: tempData)
                    
                } else {
                    Dashboard(deviceProxy: proxy, tempData: tempData)
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle("Requests")
                        .refreshable {
                            refreshDone = await tempData.fetchUserRequests()
                        }
                }
            }
        }
        .task {
            // This needs to go once the App is build
            await tempData.fetchRemoteGames()
            
            refreshDone = await tempData.fetchUserRequests()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(tempData: TempData())
    }
}
