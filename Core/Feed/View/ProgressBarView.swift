//
//  ProgressBarView.swift
//  BrainBrawl
//
//  Created by sk_sunflower@163.com on 2023/12/27.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var showProgressBar: Bool
    @Binding var uploadProgress: CGFloat
    @Binding var showCompletionMessage: Bool
    @Binding var uploadComplete: Bool // 新增状态

    var width: CGFloat
    var height: CGFloat
    var color1: Color = .red // 进度条开始的颜色
    var color2: Color = .blue // 进度条结束的颜色
    var imageName: String // 图片名称
    
    init(showProgressBar: Binding<Bool>, uploadProgress: Binding<CGFloat>, showCompletionMessage: Binding<Bool>, uploadComplete: Binding<Bool>, width: CGFloat, height: CGFloat, color1: Color, color2: Color, imageName: String) {
            self._showProgressBar = showProgressBar
            self._uploadProgress = uploadProgress
            self._showCompletionMessage = showCompletionMessage
            self._uploadComplete = uploadComplete
            self.width = width
            self.height = height
            self.color1 = color1
            self.color2 = color2
            self.imageName = imageName

            // 设置通知监听
            //setupNotifications()

        }

    var body: some View {
        VStack{
            if showProgressBar {
                Text("Uploading your topic...")
                    .font(.headline)
                    .fontWeight(.black)
                    .frame(maxWidth:UIScreen.main.bounds.width*0.97, alignment:.leading)
                    .padding(.top)
            }
            if showProgressBar {
                ZStack(alignment: .leading) {
                    
                    // 进度条视图
                    Rectangle()
                        .frame(width: width, height: height)
                        .opacity(0)
                        .foregroundColor(.white)
                    
                    Capsule()
                        .fill(Color.black.opacity(0.08))
                        .frame(width: width, height: height)
                    
                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: width * uploadProgress, height: height)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: uploadProgress)
                    
                    /*Image(imageName)
                     .resizable()
                     .scaledToFit()
                     .frame(width: 30, height: 30)
                     .offset(x: width * uploadProgress + 10, y: 0)
                     */
                    
                    Text("\(Int(uploadProgress * 100))%")
                        .foregroundColor(.white)
                        .font(.body)
                        .fontWeight(.bold)
                        .offset(x: width * uploadProgress - 50, y: 0)
                    
                    //Text("Sending...")
                    //    .font(.system(size: 12))
                    //    .offset(x: width * uploadProgress - 50, y: 0)
                    
                    
                    //if showCompletionMessage {
                    //    Text("Your Topic has been posted")
                    //        .offset(y: -330)
                    //        .transition(.opacity)
                    //        .zIndex(2)
                    //}
                }
                .cornerRadius(24)
             
                .padding(.bottom)
            }
        }
        .onAppear {
            setupNotifications()
        }
        .frame(maxWidth:.infinity)
        .background(.white)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowUploadProgress"), object: nil, queue: .main) { _ in

            simulateProgress()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("HideUploadProgress"), object: nil, queue: .main) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.showProgressBar = false
            }
        }
        
    }

    func simulateProgress() {
        showProgressBar = true
        let progressStages: [CGFloat] = [0.16, 0.32, 0.60, 0.80, 0.97]

        for (index, stage) in progressStages.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index + 1)) {
                withAnimation {
                    self.uploadProgress = stage
                }
            }
        }
    }


    /*
    private func finalizeUploadProgress() {
        // 显示上传成功消息
        print("LOLOLO")
        showCompletionMessage = true
        showProgressBar = false
        // 3秒后隐藏消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showCompletionMessage = false
        }
    }
     */
}
