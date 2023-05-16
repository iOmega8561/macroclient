//
//  App.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import SwiftUI

@main
struct MacroClient: App {
    @StateObject var tempData: TempData = TempData()
    
    var body: some Scene {
        WindowGroup {
            TestView(tempData: tempData)
                .task {
                    await tempData.fetchRemoteGames()
                }
        }
    }
}
