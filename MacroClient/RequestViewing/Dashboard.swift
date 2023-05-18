//
//  Dashboard.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import SwiftUI

struct Dashboard: View {
    let deviceProxy: GeometryProxy
    @State var logoutActive: Bool = false
    @StateObject var appData: AppData
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(appData.requests.map{$0.value}, id: \.self) { req in
                    NavigationLink(destination: RequestDetails(appData: appData, request: req)) {
                        RequestBox(games: appData.games, request: req)
                            .frame(width: deviceProxy.size.width * 0.92, height: deviceProxy.size.height * 0.24)
                            .contextMenu{
                                Button(role: .destructive, action:{
                                    let uuid = req.uuid
                                    
                                    Task {
                                        await appData.deleteUserRequest(uuid: uuid)
                                    }
                                }){
                                    Text("Delete request")
                                }.disabled(req.user_id != appData.username)
                            }
                    }.foregroundColor(.black)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink(destination: Login(appData: appData).navigationBarBackButtonHidden(true), isActive: $logoutActive) {
                    Text("Log out")
                        .foregroundColor(.red)
                }.onChange(of: logoutActive) { (_) in
                    Task {await appData.logout()}
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GameSelection(appData: appData)) {
                    HStack {
                        Text("New")
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        MainView(appData: AppData())
    }
}
