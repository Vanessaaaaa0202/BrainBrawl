//
//  SettingsView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 5/2/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var selectedOption: SettingsItemModel?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            ForEach(SettingsItemModel.allCases) { model in
                SettingsRowView(model: model)
                    .onTapGesture {
                        selectedOption = model
                        dismiss()
                    }
            }
        }
        .listStyle(PlainListStyle())
        .padding(.vertical)
    }
}



struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(selectedOption: .constant(nil))
    }
}
