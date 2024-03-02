//
//  SettingsItemModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 8/13/23.
//

import Foundation

//MARK: your activity和saved功能暂时没有先注释掉，your activity相当于浏览记录，saved相当于点赞过的帖子，后续都可以看看

enum SettingsItemModel: Int, Identifiable, Hashable, CaseIterable {
    case settings
    //case yourActivity
    //case saved
    case logout
    
    var title: String {
        switch self {
        case .settings:
            return "Settings"
        //case .yourActivity:
        //    return "Your Activity"
        //case .saved:
        //    return "Saved"
        case .logout:
            return "Logout"
        }
    }
    
    var imageName: String {
        switch self {
        case .settings:
            return "gear"
        //case .yourActivity:
        //    return "cursorarrow.click.badge.clock"
        //case .saved:
        //    return "bookmark"
        case .logout:
            return "arrow.left.circle"
        }
    }
    
    var id: Int { return self.rawValue }
}
