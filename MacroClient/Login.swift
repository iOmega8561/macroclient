//
//  Login.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 16/05/23.
//

import SwiftUI

struct Login: View {
    @StateObject var tempData: TempData
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(tempData: TempData())
    }
}
