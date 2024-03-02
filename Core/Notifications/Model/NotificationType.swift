//
//  NotificationType.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 8/13/23.
//

import Foundation

enum NotificationType: Int, Codable {
    case like
    case comment
    case likeComment
    case follow
    case likeReply
    case replyToReply
    //case likeCommentReply
    case replyToComment
    
    var notificationMessage: String {
        switch self {
        case .like: return " liked one of your posts."
        case .comment: return " commented on one of your posts."
        case .likeComment: return " liked your comment."
        case .follow: return " started following you."
        case .likeReply: return " liked your reply."
        case .replyToReply: return " replied to your reply."
        //case .likeCommentReply: return " liked your comment"
        case .replyToComment: return " replied to your comment."
        //case 点赞comment
        }
    }
}
