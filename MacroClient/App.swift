//
//  App.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 25/04/23.
//

import SwiftUI

@main
struct MacroClient: App {
    @StateObject var appData: AppData = AppData()
    
    var body: some Scene {
        WindowGroup {
            Login(appData: appData)
                /*.task {
                    await tempData.fetchRemoteGames()
                }*/
        }
    }
}
