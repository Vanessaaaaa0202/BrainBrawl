//
//  DebatePowerBar.swift
//  InstagramSwiftUITutorial
//
//  Created by sk_sunflower@163.com on 2023/10/16.
//

import Foundation
import SwiftUI
struct Parallelogram: Shape {
    var slantOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + slantOffset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - slantOffset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

struct DebatePowerBar: View {
    var pro: CGFloat
    var neutral: CGFloat
    var contra: CGFloat
    var proRatio: CGFloat
    var contraRatio: CGFloat
    var barHeight: CGFloat = 39

    var isLoadingBar: Bool

    var body: some View {
        if isLoadingBar {
            LoadingBarView(barHeight: barHeight)
        } else {
            DebateBarView(pro: pro, neutral: neutral, contra: contra, proRatio: proRatio, contraRatio: contraRatio, barHeight: barHeight)
        }
    }

}

struct LoadingBarView: View {
    var barHeight: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.white.opacity(0.3)]), startPoint: .leading, endPoint: .trailing))
            .frame(width: UIScreen.main.bounds.width * 0.97,height: barHeight)
            .padding(.horizontal, UIScreen.main.bounds.width * 0.015)
    }
}

struct DebateBarView: View {
    var pro: CGFloat
    var neutral: CGFloat
    var contra: CGFloat
    var proRatio: CGFloat
    var contraRatio: CGFloat
    // 添加一个变量来表示bar的高度
    var barHeight: CGFloat = 39  // 您可以根据需要设置此值
    
    private var totalWidth: CGFloat {
        UIScreen.main.bounds.width * 0.97
    }

    private var proWidth: CGFloat {
        if pro == 0 { return 0 }
        if pro < 0.15 { return 0.15 * totalWidth }
        if pro <= 0.85 { return pro * totalWidth }
        return contra != 0 ? 0.85 * totalWidth : totalWidth
    }

    private var contraWidth: CGFloat {
        if contra == 0 { return 0 }
        if contra < 0.15 { return 0.15 * totalWidth }
        if contra <= 0.85 { return contra * totalWidth }
        return pro != 0 ? 0.85 * totalWidth : totalWidth
    }

    
   var body: some View {
       ZStack{
        
           ZStack {

               HStack(spacing: 0) {
                   Color(red:25/255.0, green:146/255.0, blue:233/255.0, opacity:1)
                       .frame(width: pro == 0 ? 0 :
                                      (pro < 0.15 ? 0.15 * UIScreen.main.bounds.width * 0.97 :
                                      (pro <= 0.85 ? pro * UIScreen.main.bounds.width * 0.97 :
                                      (contra != 0 ? 0.85 * UIScreen.main.bounds.width * 0.97 : UIScreen.main.bounds.width * 0.97))))


                   
                
                   
                   Color(red: 249/255.0, green: 97/255.0, blue: 103/255.0, opacity: 1)
                       .frame(width: contra == 0 ? 0 :
                                      (contra < 0.15 ? 0.15 * UIScreen.main.bounds.width * 0.97 :
                                      (contra <= 0.85 ? contra * UIScreen.main.bounds.width * 0.97 :
                                      (pro != 0 ? 0.85 * UIScreen.main.bounds.width * 0.97 : UIScreen.main.bounds.width * 0.97))))
                   

               }
               .cornerRadius(24)
           .frame(height: barHeight)
               
               if pro != 0 && contra != 0 {
                   Parallelogram(slantOffset: 3)
                       .fill(Color("debatebarcolor"))
                       .frame(width: 10, height: barHeight)
                       .offset(x: proWidth-UIScreen.main.bounds.width/2+5, y: 0)
               }
           }  // 设置bar的高度
           //MARK: 3D要素搭配的不是很和谐，先放着
           //.overlay(
           //    RoundedRectangle(cornerRadius: 24)
           //        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
           //)
           //.shadow(color: Color.black.opacity(0.45), radius: 3, x: 0, y: 1)
           //.shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 6)
           //.shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: -10)
           
               //if contraRatio > proRatio{
               //    HStack{
               //        Spacer()
               //        VStack{
               //            Text("\(Int(contraRatio * 100.rounded()))%")
               //                .foregroundStyle(.white)
               //                .fontWeight(.bold)
               //                .font(.system(size:15))
               //                //.padding(.trailing,15)
               //            Text("Yes").font(.system(size: //10)).fontWeight(.bold).foregroundStyle(.white)
               //        }.padding(.trailing,21)
               //
               //    }
               //} else if proRatio > contraRatio {
               //    HStack{
               //        VStack{
               //            Text("\(Int(proRatio * 100.rounded()))%")
               //                .foregroundStyle(.white)
               //                .fontWeight(.bold)
               //                .font(.system(size:15))
               //                //.padding(.trailing,15)
               //            Text("No").font(.system(size: //10)).fontWeight(.bold).foregroundStyle(.white)
               //        }.padding(.leading,21)
               //        Spacer()
               //    }
               //} else{
                   HStack{
                       Spacer()
                       VStack{
                           Text("\(Int((contraRatio * 100).rounded(.down)))%")
                               .foregroundStyle(.white)
                               .fontWeight(.bold)
                               .font(.system(size:15))
                               //.padding(.trailing,15)
                           Text("Yes").font(.system(size: 10)).fontWeight(.bold).foregroundStyle(.white)
                       }
                       .opacity(contra == 0 ? 0 : 1)
                       .padding(.trailing,18)
                       
                   }
                   
                   HStack{
                       VStack{
                           Text("\(Int((proRatio * 100).rounded(.up)))%")
                               .foregroundStyle(.white)
                               .fontWeight(.bold)
                               .font(.system(size:15))
                               //.padding(.trailing,15)
                           Text("No").font(.system(size: 10)).fontWeight(.bold).foregroundStyle(.white)
                       }
                       .opacity(pro == 0 ? 0 : 1)
                       .padding(.leading,18)
                       Spacer()
                   }
               //}
               
           
       }
   }
}


struct DebatePowerBar_Preview: PreviewProvider {
    static var previews: some View {
        //DebatePowerBar(pro:0.95,neutral: 0,contra:0.05,proRatio: 0.95,contraRatio: 0.05)
        //DebatePowerBar(pro:0.03,neutral: 0,contra:0.97,proRatio: 0.03,contraRatio: 0.97)
        //DebatePowerBar(pro:1,neutral: 0,contra:0,proRatio: 1,contraRatio: 0)
        DebatePowerBar(pro:0.7,neutral: 0,contra:0.3,proRatio: 0.7,contraRatio: 0.3, isLoadingBar: true)
       // DebatePowerBar(pro:0.565,neutral: 0,contra:0.435,proRatio: //0.565,contraRatio: 0.435)
       // DebatePowerBar(pro:0.31,neutral: 0,contra:0.69,proRatio: 0.31,contraRatio: //0.69)
    }
}

