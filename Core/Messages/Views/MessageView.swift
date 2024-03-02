//
//  MessageView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI
import Kingfisher

struct MessageView: View {
    let viewModel: MessageViewModel
    
    var body: some View {
        HStack {
            if viewModel.isFromCurrentUser {
                Spacer()
                Text(viewModel.message.text)
                    .font(.system(size: 15))
                    .padding(10)
                    .background(Color.blue)
                    .clipShape(ChatBubble(isFromCurrentUser: true))
                    .foregroundColor(.white)
                    .padding(.leading, 100)
                    .padding(.trailing)
            } else {
                HStack(alignment: .bottom) {
                    CircularProfileImageView(user: viewModel.message.user, size: .xSmall)
                    
                    Text(viewModel.message.text)
                        .font(.system(size: 15))
                        .padding(10)
                        .background(Color(.systemGray5))
                        .clipShape(ChatBubble(isFromCurrentUser: false))
                        .foregroundColor(.black)
                }
                .padding(.trailing, 100)
                .padding(.leading)
                
                Spacer()
            }
        }
    }
}
