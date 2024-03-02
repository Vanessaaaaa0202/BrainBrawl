//
//  ChatView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI

struct ChatView: View {
    let user: User
    @StateObject var viewModel: ChatViewModel
    @State var messageText: String = ""
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageView(viewModel: MessageViewModel(message: message))
                    }
                }
            }.padding(.top)
            
            CustomInputView(inputText: $messageText,
                            placeholder: "Message...",
                            buttonTitle: "Send",
                            action: sendMessage)
            
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func sendMessage() {
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}
