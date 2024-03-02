//
//  ExpandableText.swift
//  InstagramSwiftUITutorial
//
//  Created by Vanessa on 2023/10/16.
//

import SwiftUI

struct ExpandableText: View {
    @State private var expanded: Bool = false
    var postCaption: String
    @State private var textHeight: CGFloat = .zero
    private let lineHeight: CGFloat = 15 // 估算的单行文本高度，需要根据实际字体大小调整
    private let maxLineCount: Int = 5

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(postCaption)
                .lineLimit(expanded ? nil : 5)
                //.fixedSize(horizontal: false, vertical: true)
                .background(GeometryReader { geometryProxy in
                    Color.clear.onAppear {
                        self.textHeight = geometryProxy.size.height
                    }
                })
            
            
            if shouldShowToggleButton { 
                Button(action: {
                    withAnimation {
                        expanded.toggle()
                    }
                }) {
                    Text(expanded ? "Read less" : "Read more")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 9)
    }

    private var shouldShowToggleButton: Bool {
        let estimatedLineCount = Int(textHeight / lineHeight)
        print(estimatedLineCount)
        return estimatedLineCount >= maxLineCount
    }
}
