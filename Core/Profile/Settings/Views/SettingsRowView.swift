//
//  SettingsRowView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 8/13/23.
//

import SwiftUI

struct SettingsRowView: View {
    let model: SettingsItemModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: model.imageName)
                .resizable()
                .scaledToFill()
                .frame(width:20 , height:20)
            
            Text(model.title)
                .font(.subheadline)
        }
    }
}

struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(model: .settings)
    }
}
