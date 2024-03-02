//
//  UserStatView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/27/20.
//

import SwiftUI

struct UserStatView: View {
    let value: Int?
    let title: String
    
    var body: some View {
        VStack {
            Text("\(value ?? 0)")
                .font(.system(size: 30, weight: .semibold))
            
            Text(title)
                .font(.system(size: 15))
        }
        .opacity(value == 0 ? 0.5 : 1.0)
        .frame(width: 80, alignment: .center)
        .foregroundColor(Color.theme.systemBackground)
    }
}

struct UserStatView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatView(value: 1, title: "Post")
    }
}
