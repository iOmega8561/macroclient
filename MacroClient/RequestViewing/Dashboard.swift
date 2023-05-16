//
//  Dashboard.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import SwiftUI

struct Dashboard: View {
    let deviceProxy: GeometryProxy
    @StateObject var tempData: TempData
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(tempData.requests.map{$0.value}, id: \.self) { req in
                    
                    RequestBox(tempData: tempData, request: req)
                        .frame(width: deviceProxy.size.width * 0.92, height: deviceProxy.size.height * 0.24)
                        .contextMenu{
                            Button(role: .destructive, action:{
                                let uuid = req.uuid
                                
                                Task {
                                    await tempData.deleteUserRequest(uuid: uuid)
                                }
                            }){
                                Text("Delete request")
                            }
                        }
                    
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: GameSelection(tempData: tempData)) {
                    Text("New Request")
                }
            }
        }
    }
}

struct Dashboard_Previews: PreviewProvider {
    static var previews: some View {
        MainView(tempData: TempData())
    }
}
