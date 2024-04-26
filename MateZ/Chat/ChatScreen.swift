/*
 Copyright (C) 2024  Giuseppe Rocco & Aryan Garg
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
//  ChatScreen.swift
//  MateZ
//
//  Created by Aryan Garg on 01/06/23.
//

import Combine
import Foundation
import SwiftUI

struct ChatScreen: View {
    @StateObject private var model = ChatScreenModel()
    @State private var message = ""
    
    @EnvironmentObject var appData: AppData
    
    // MARK: - Events
    private func onAppear() {
        model.connect(username: appData.authData.username)
    }
    
    private func onDisappear() {
        model.disconnect()
    }
    
    private func onCommit() {
        if !message.isEmpty {
            model.send(text: message)
            message = ""
        }
    }
    
    private func scrollToLastMessage(proxy: ScrollViewProxy) {
        if let lastMessage = $model.messages.last {
            withAnimation(.easeOut(duration: 0.4)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }

    // MARK: -
    var body: some View {
        NavigationView {
            ZStack {
                Color("BG")
                    .ignoresSafeArea()
                
                VStack {
                    // Chat history.
                    ScrollView {
                        ScrollViewReader{ proxy in
                            LazyVStack(spacing: 8) {
                                ForEach(model.messages) { message in
                                    ChatMessageRow(message: message, isUser: message.user == appData.authData.username)
                                        .id(message.id)
                                }
                            }
                            .padding(10)
                            .onChange(of: model.messages.count) { _ in
                                scrollToLastMessage(proxy: proxy)
                            }
                        }
                    }
                    
                    // Message field.
                    HStack {
                        TextField("Message", text: $message, onEditingChanged: { _ in }, onCommit: onCommit)
                            .padding(10)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(5)
                        
                        Button(action: onCommit) {
                            Image(systemName: "arrowshape.turn.up.right")
                                .font(.system(size: 20))
                                .padding(6)
                        }
                        .cornerRadius(5)
                        .disabled(message.isEmpty)
                        .hoverEffect(.highlight)
                    }
                    .padding()
                }
                .navigationTitle("Global chat")
                .onAppear(perform: onAppear)
                .onDisappear(perform: onDisappear)
            }
        }
    }
}

// MARK: - Individual chat message balloon
private struct ChatMessageRow: View {
    static private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    let message: ReceivingChatMessage
    let isUser: Bool
    
    var body: some View {
        HStack {
            if isUser {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(message.user)
                        .fontWeight(.bold)
                        .font(.system(size: 12))
                    
                    Text(Self.dateFormatter.string(from: message.date))
                        .font(.system(size: 10))
                        .opacity(0.7)
                }
                
                Text(message.message)
            }
            .foregroundColor(.white)
            .padding(10)
            .background(isUser ? Color("Self") : Color("Interlocutor"))
            .cornerRadius(5)
            
            if !isUser {
                Spacer()
            }
        }
        .transition(.scale(scale: 0, anchor: isUser ? .topTrailing : .topLeading))
    }
}

// MARK: - Chat Screen model
/**
 * All business logic is performed in this Observable Object.
 */
private final class ChatScreenModel: ObservableObject {
    
    var filter = ProfanityFilter()
    
    private var username: String?
    private var userID: UUID?
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    @Published var messages: [ReceivingChatMessage] = []

    // MARK: - Connection
    func connect(username: String) {
        guard webSocketTask == nil else {
            return
        }

        self.username = username

        let url = URL(string: "ws://yourdomain.something:9132/chat")!
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.receive(completionHandler: onReceive)
        webSocketTask?.resume()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    // MARK: - Sending / recieving
    private func onReceive(incoming: Result<URLSessionWebSocketTask.Message, Error>) {
        webSocketTask?.receive(completionHandler: onReceive)

        if case .success(let message) = incoming {
            onMessage(message: message)
        }
        else if case .failure(let error) = incoming {
            print("Error", error)
        }
    }
    
    private func onMessage(message: URLSessionWebSocketTask.Message) {
        if case .string(let text) = message {
            guard let data = text.data(using: .utf8),
                  let chatMessage = try? JSONDecoder().decode(ReceivingChatMessage.self, from: data)
            else {
                return
            }

            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    self.messages.append(chatMessage)
                }
            }
        }
    }
    
    func send(text: String) {
        guard let username = username
        else {
            return
        }
        
        let text = filter.maskProfanity(text: text)
        
        let message = SubmittedChatMessage(message: text, user: username)
        guard let json = try? JSONEncoder().encode(message),
              let jsonString = String(data: json, encoding: .utf8)
        else {
            return
        }
        
        webSocketTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Error sending message", error)
                
                if self.username != nil && self.username != "" {
                    self.webSocketTask = nil
                    self.connect(username: self.username!)
                    
                    self.send(text: text)
                }
            }
        }
    }
    
    deinit {
        disconnect()
    }
}

