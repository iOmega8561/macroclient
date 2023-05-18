//
//  TestView.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import SwiftUI

struct MainView: View {
    @StateObject var appData: AppData
    @State var refreshDone: Bool = false
    
    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                
                if !refreshDone {
                    CustomProgress(withText: true)
                    
                } else if appData.requests.count < 1 {
                    GameSelection(appData: appData)
                    
                } else {
                    Dashboard(deviceProxy: proxy, appData: appData)
                        .navigationBarTitleDisplayMode(.large)
                        .navigationTitle("Requests")
                        .refreshable {
                            refreshDone = await appData.fetchUserRequests()
                        }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .task {
            // This needs to go once the App is build
            await appData.fetchRemoteGames()
            
            refreshDone = await appData.fetchUserRequests()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(appData: AppData())
    }
}
