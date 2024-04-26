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
//  RemoteImage.swift
//  MacroClient
//
//  Created by Giuseppe Rocco on 29/04/23.
//

import SwiftUI

struct RemoteImage: View {
    private let baseUrl: String = "https://yourdomain.something"
    let imgname: String
    var squareSize: CGFloat?
    
    var body: some View {
        if UIImage(named: imgname) != nil {
            Image(imgname)
                .resizable()
                .scaledToFit()
                .frame(width: squareSize ?? 60)
        } else {
            AsyncImage(url: URL(string: "\(baseUrl)/img?name=\(imgname)")) { phase in
                switch phase {
                    
                case .empty:
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.accentColor))
                    Spacer()
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: squareSize ?? 60)
                    
                case .failure(_):
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Spacer()
                    
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

struct RemoteImage_Previews: PreviewProvider {
    static var previews: some View {
        RemoteImage(imgname: "game_generic")
    }
}
