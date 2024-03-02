//
//  ConversationCell.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI
import Kingfisher

struct ConversationCell: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {                CircularProfileImageView(user: message.user, size: .small)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let user = message.user {
                        Text(user.fullname ?? "")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Text(message.text)
                        .font(.system(size: 15))
                        .lineLimit(2)
                }
                .foregroundColor(.black)
                .padding(.trailing)
                
                Spacer()
            }
            
            Divider()
        }
        
    }
}
