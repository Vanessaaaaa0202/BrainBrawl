//
//  CommentsView.swift
//  InstagramSwiftUITutorial
//
import SwiftUI
import Kingfisher

struct CommentsView: View {
    
    let post: Post
    let replies: [Reply]
    let maximumVisibleComments = 6 // 根据您的界面设计调整这个值
    @State private var forceUpdate: Bool = false

    @StateObject var viewModel: CommentViewModel
    @State private var commentText: String = ""
    @State private var isKeyboardShowing: Bool = false
    @State private var navigateToComments: Bool = false
    @State private var redClicks: Int = 0
    @State private var blueClicks: Int = 0
    @State private var showRedCommentInput: Bool = false
    @State private var showBlueCommentInput: Bool = false
    var showColorCommentsButtons: Bool
    @State private var selectedColorType: Comment.CommentColorType? = nil
    @State private var isBlueComment: Bool = true // 初始设为蓝色
    @State private var isSticky: Bool = false // 用于检测红蓝灰条是否固定
    @State private var selectedFilter: Comment.CommentColorType? = nil
    @State private var isAtBottom: Bool = false //最后一条评论显示 The End
    @Environment(\.presentationMode) var presentationMode
    @State private var hasScrolledToTarget = false
    var targetCommentId: String?
    var targetReplyId: String?
    @State private var isPostAvailable: Bool = true  // 新增状态变量
    @GestureState private var scale: CGFloat = 1.0 //初始的缩放比例
    private let minScale: CGFloat = 1.0  // 最小缩放比例
    @State private var isZoomed: Bool = false
    @State private var currentScale: CGFloat = 1.0  // 添加一个 @State 来持久化当前的缩放级别
    @StateObject private var imageLoadingViewModel = ImageLoadingViewModel()
    @State private var showingPDFView = false

    
    
   // @State private var isLoadMoreTriggered = false
    
    private var user: User? {
        return viewModel.post.user
    }
    
    //MARK：为解决Invalid frame dimension的问题，排除除以0的特殊情况
    var blueCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfBlueComments) / CGFloat(viewModel.totalComments)
        } else {
            return 0.5
        }
    }
    var redCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfRedComments) / CGFloat(viewModel.totalComments)
        } else {
            return 0.5
        }
    }
    
    var filteredComments: [Comment] {
        if let filter = selectedFilter {
            return viewModel.comments.filter { $0.colorType == filter }
        } else {
            return viewModel.comments
        }
    }
    
    init(post: Post, replies: [Reply] = [], showColorCommentsButtons: Bool = true, targetCommentId: String?, targetReplyId: String?) {
        self.post = post
        self.replies = replies
        self.showColorCommentsButtons = showColorCommentsButtons
        self.targetCommentId = targetCommentId
        self.targetReplyId = targetReplyId
        self._viewModel = StateObject(wrappedValue: CommentViewModel(post: post))
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            if isPostAvailable {
                // 内容滚动区域
                ScrollView {
                    VStack {
                        // feedcell view
                        ZStack {
                            VStack(alignment: .leading) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        if let user = user {
                                            NavigationLink(value: user) {
                                                CircularProfileImageView(user: user, size: .xSmall)
                                            }
                                            NavigationLink(value:user) {
                                                Text(user.username )
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundColor(Color.theme.systemBackground)
                                            }
                                        }
                                        Spacer()
                                        //==================================新增的三个点option
                                        Menu {
                                            
                                                Button(role: .destructive) {
                                                    // Do something
                                                } label: {
                                                    Label("Report", systemImage: "flag.fill")
                                                }
                                       
                                          //  //Block this user
                                          //  Button {
                                          //      // Do something
                                          //  } label: {
                                          //      Label("Block", systemImage: "eye.slash")
                                          //  }
                                            
                                            //Share
                                            Button {
                                                // Do something
                                            } label: {
                                                Label("Share", systemImage: "square.and.arrow.up")
                                            }
                                            
                                            //Cancel
                                            Button("Cancel", role: .destructive) {
                                                // Do something
                                            }
                                            
                                        } label: {
                                            Label("", systemImage: "ellipsis").padding(.bottom,6)
                                        }
                                    }
                                    .padding(.leading,1.5)
                                    
                                    Text(post.title)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color.theme.systemBackground)
                                        .padding([.leading,.trailing],2)
                                }
                                .padding([.leading], 8)
                                
                                VStack {
                                    DebatePowerBar(
                                        pro: blueCommentRatio,
                                        neutral: CGFloat(0),
                                        contra: redCommentRatio,
                                        proRatio: blueCommentRatio,
                                        contraRatio: redCommentRatio,
                                        isLoadingBar: viewModel.isLoadingBar  
                                    )
                                    .padding(.top,0)
                                    .padding([.bottom], 7)
                                    //.padding([.leading, .trailing], 5)
                                    
                                    KFImage(URL(string: post.imageUrl))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width * 0.97 )
                                        .frame(maxHeight: UIScreen.main.bounds.width * 0.97 * 1.2) // 设定图片的最大高度
                                        .cornerRadius(24)
                                        .clipped()
                                                .onTapGesture{self.showingPDFView = true
                                                    imageLoadingViewModel.loadImage(from: post.imageUrl)
                                                }
                                                .sheet(isPresented: $showingPDFView, onDismiss:{
                                                    self.showingPDFView = false
                                                }){
                                                    EnlargedImagePdfVersion( image: imageLoadingViewModel.loadedImage ?? UIImage(systemName: "network.slash")!)
                                                    
                                                }
                                    
                                }
                                
                                Text(post.caption).padding(.horizontal, 10)
                                
                                HStack(spacing: 2) {
                                    Button(action: {
                                        Task {
                                            viewModel.post.didLike ?? false ? try await viewModel.unlike() : try await viewModel.like()
                                        }
                                    }, label: {
                                        Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(3)
                                    })
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    
                                    Text(viewModel.likeString)
                                        .font(.system(size: 14, weight: .semibold))
                                        .padding(.trailing, 6)
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "flame")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding(2)
                                        
                                        Text("\(viewModel.formattedTotalComments)")
                                            .font(.system(size: 14, weight: .semibold))
                                    }
                                    
                                    Spacer()
                                    
                                }
                                .padding(.leading, 4)
                                
                                Text(post.timestamp.timestampString())
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                                Divider()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: isZoomed ? 20 : 0)
                        // 红蓝灰条
                        //MARK: 12.29 Redesign
                        GeometryReader { geometry in
                            VStack(alignment:.center){
                                Spacer()
                                HStack {
                                    
                                    Button(action: { withAnimation{selectedFilter = .red} }) {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .fill(selectedFilter == .red ? Color(red: 249/255.0, green: 97/255.0, blue: 103/255.0, opacity: 1) : .black.opacity(0))
                                            .frame(height: 45)
                                        //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                            .overlay(Text("Yes").foregroundColor(.white).fontWeight(.bold))
                                        //.scaleEffect()
                                        
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width*0.33)
                                    
                                    Spacer()
                                    
                                    Button(action: { withAnimation{selectedFilter = nil} }) {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .fill(selectedFilter == nil ? LinearGradient(gradient: Gradient(colors: [Color(red:25/255.0, green:146/255.0, blue:233/255.0).opacity(1), Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1)]), startPoint: .trailing, endPoint: .leading) : LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0),Color.black.opacity(0)]), startPoint: .trailing, endPoint: .leading))
                                            .frame(height: 45)
                                        //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                            .overlay(Text("All").foregroundColor(.white).fontWeight(.bold))
                                    }
                                    .frame(maxWidth:UIScreen.main.bounds.width*0.33)
                                    
                                    Spacer()
                                    
                                    Button(action: { withAnimation{selectedFilter = .blue} }) {
                                        RoundedRectangle(cornerRadius: 25.0)
                                            .fill(selectedFilter == .blue ? Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1) : .black.opacity(0))
                                            .frame(height: 45)
                                        //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                            .overlay(Text("No").foregroundColor(.white).fontWeight(.bold))
                                        
                                    }
                                    .frame(maxWidth: UIScreen.main.bounds.width*0.33)
                                    
                                }
                                .frame(width:UIScreen.main.bounds.width*0.98,height: 45, alignment: .center)
                                //.border(.red)
                                //.padding(.bottom, 3)
                                .background(Color(red: 39/255.0, green: 39/255.0, blue: 39/255.0, opacity: 1))
                                .cornerRadius(25)
                                .onChange(of: geometry.frame(in: .global).minY) { value in
                                    isSticky = value <= 0
                                }
                                Spacer()
                            }.frame(maxWidth:.infinity)
                        }
                        .frame(height: 45)
                        .padding(.bottom, 27)
                        
                        
                        LazyVStack {
                            ForEach(viewModel.comments.filter { selectedFilter == nil || $0.colorType == selectedFilter }, id: \.id) { comment in
                                CommentCell(comment: comment, post: post, viewModel: viewModel)
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            if viewModel.comments.count >= maximumVisibleComments {
                                                isAtBottom = viewModel.isLastPage && geo.frame(in: .global).maxY < UIScreen.main.bounds.height + 50
                                            }
                                        }
                                }
                            }
                            if !viewModel.isLastPage {
                                ProgressView()
                                    .onAppear {
                                        Task {
                                            try await viewModel.fetchPageComments()
                                    }
                                }
                            }
                        }
                    }
                    .onAppear {
                        Task {
                            try await viewModel.checkIfUserHasCommented()
                            try await viewModel.fetchComments()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                if let targetCommentId = targetCommentId, viewModel.comments.contains(where: { $0.id == targetCommentId }) {
                                    viewModel.moveToTop(commentId: targetCommentId)

                                    if let targetReplyId = targetReplyId {
                                        viewModel.moveReplyToTop(replyId: targetReplyId)
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        withAnimation {
                                            scrollViewProxy.scrollTo(viewModel.comments.first?.id, anchor: .top)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if isAtBottom {
                        Text("—— The End ——")
                            .foregroundColor(.gray)
                            .font(.system(size: 14))
                            .padding(.top, 10)
                    }
                }
                .padding(.top)

                if viewModel.hasCommented {
                    // 用户已经发表过评论
                    Text("You have picked your side")
                        .foregroundColor(.gray)
                        .padding(.vertical,12)
                        .padding(.horizontal)
                } else {
                    HStack {
                        // 选择评论类型的开关
                        Toggle(isOn: $isBlueComment.animation()) {
                            EmptyView()
                        }
                        .padding(.leading,0)
                        .padding(.trailing,3)
                        .toggleStyle(ColorToggleStyle())
                        .disabled(viewModel.hasUserChosenColor) // 如果用户已经选择了颜色，则禁用切换
                        .onChange(of: isBlueComment) { newValue in
                            viewModel.commentColor = newValue ? .blue : .red
                        }
                        // 文本输入框，点击时弹出MainCommentView
                        NavigationLink(destination: MainCommentView(post: post, commentType: isBlueComment ? .blue : .red, sourceView: .commentsView, onCommentSuccessFromFeed: {})) {
                            HStack(){Text("Share your thoughts...")
                                    .foregroundColor(Color(UIColor.systemGray3))
                                    .padding(.leading, 15)
                                    .padding(.vertical, 5)
                                
                            }
                            .frame(width: UIScreen.main.bounds.width*0.78,alignment:.leading)
                            //.background(Capsule().stroke(Color.gray))
                            .background(RoundedRectangle(cornerRadius: 25.0).fill(Color(red:242/255, green:242/255, blue:242/255)))
                        }
                    }.padding(.vertical,6)
                }
                
            }
            else {
                // 如果 post 不存在，仅显示提示信息
                Text("Post has been deleted")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
        .overlay(
            //MARK: 12.29 Change on comment section redesign
            VStack {
                if isSticky {
                    HStack {
                        
                        Button(action: { withAnimation{selectedFilter = .red} }) {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(selectedFilter == .red ? Color(red: 249/255.0, green: 97/255.0, blue: 103/255.0, opacity: 1) : Color.black.opacity(0))
                                           .frame(height: 45)
                                           //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                           .overlay(Text("Yes").foregroundColor(.white).fontWeight(.bold))
                                           //.scaleEffect()
                            
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width*0.33)
                        
                        Spacer()
                        
                        Button(action: { withAnimation{selectedFilter = nil} }) {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(selectedFilter == nil ? LinearGradient(gradient: Gradient(colors: [Color(red:25/255.0, green:146/255.0, blue:233/255.0).opacity(1), Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1)]), startPoint: .trailing, endPoint: .leading) : LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0),Color.black.opacity(0)]), startPoint: .trailing, endPoint: .leading))
                                           .frame(height: 45)
                                           //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                           .overlay(Text("All").foregroundColor(.white).fontWeight(.bold))
                        }
                        .frame(maxWidth:UIScreen.main.bounds.width*0.33)
                        
                        Spacer()
                        
                        Button(action: { withAnimation{selectedFilter = .blue} }) {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(selectedFilter == .blue ? Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1) :  Color.black.opacity(0))
                                           .frame(height: 45)
                                           //.shadow(color: .gray, radius: 1, x: 0, y: 0)
                                           .overlay(Text("No").foregroundColor(.white).fontWeight(.bold))
                           
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width*0.33)
                        
                    }
                    .frame(width:UIScreen.main.bounds.width*0.98,height: 45, alignment: .center)
                    //.border(.red)
                    //.padding(.bottom, 3)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(25)
                }
            }.animation(.easeInOut, value: isSticky)
            .transition(.move(edge: .top)),
            alignment: .top
        )
        
        //.padding()
        .navigationTitle("Comments")
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            Task {
                do {
                    // 先尝试获取 post
                    let postExists = try await viewModel.checkPostComments(viewModel.post.id ?? "")
                    isPostAvailable = postExists
                    if postExists {
                        // Post 存在，执行现有逻辑
                        try await viewModel.fetchComments()
                        if viewModel.hasUserChosenColor, let chosenColorType = viewModel.chosenColorType {
                            isBlueComment = chosenColorType == .blue
                        }
                        isAtBottom = viewModel.comments.count < maximumVisibleComments
                    } else {
                        // Post 不存在，打印消息
                        print("The post is no longer available.")
                    }
                }
                catch {
                    print("Error occurred: \(error)")
                }
            }
        }
    }
    
    struct ColorToggleStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.label
                
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(configuration.isOn ? Color(red:25/255.0, green:146/255.0, blue:233/255.0, opacity:1) :
                                Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1))
                    
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.2))
                        .padding(2)
                    
                    HStack {
                        if configuration.isOn {
                            Spacer()
                        }
                        Circle()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                            .overlay(
                                Image(systemName: configuration.isOn ? "xmark" : "checkmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .font(.title.weight(.bold))
                                    .frame(width: 10,
                                           height: 10)
                                    .foregroundColor(configuration.isOn ? Color(red:25/255.0, green:146/255.0, blue:233/255.0, opacity:1) : Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1))
                            )
                        if !configuration.isOn {
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .frame(width: 52, height: 32)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
            }
        }
    }
    
    // 单独的放大手势识别函数
    private func magnificationGesture() -> some Gesture {
        MagnificationGesture()
            .updating($scale) { (currentScale, scale, _) in
                // 使用 @GestureState 跟踪手势过程中的缩放变化
                scale = currentScale
            }
            .onChanged { value in
                // 在手势过程中实时更新图片的缩放比例，此时应该修改 currentScale 而不是 scale
                // 因为 scale (@GestureState) 在手势结束时会自动重置
                //注意：这里的逻辑确保了在手势过程中只有当缩放比例大于当前比例时才更新，以允许放大操作
                let newScale = currentScale * value
                if newScale > currentScale {
                    currentScale = newScale
                }
            }
            .onEnded { value in
                // 手势结束时，再次更新 currentScale 以保留放大状态
                // 这里不需要重置 currentScale 或 scale，因为我们希望保留用户的放大操作
                let finalScale = currentScale * value
                currentScale = max(1.0, finalScale) // 确保缩放比例不会小于1
                // 不自动重置 zoom 状态，允许用户通过点击退出全屏模式
            }
    }

    // 重置缩放状态的函数
    private func resetZoom() {
        isZoomed = false
    }

    // 全屏显示放大图片的视图
    private func fullScreenZoomView() -> some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .zIndex(2)
                .gesture(magnificationGesture())

            KFImage(URL(string: post.imageUrl))
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .zIndex(3)
        }
        .contentShape(Rectangle()) // 确保整个区域都可以响应点击事件
        .onTapGesture {
            withAnimation {
                // 点击时退出全屏模式
                isZoomed = false
                currentScale = 1.0 // 重置缩放比例
            }
        }
    }
}

class ImageLoadingViewModel: ObservableObject {
    @Published var loadedImage: UIImage?

    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        KingfisherManager.shared.retrieveImage(with: url) { result in
            switch result {
            case .success(let value):
                DispatchQueue.main.async {
                    self.loadedImage = value.image
                }
            case .failure(let error):
                print(error) // Handle the error appropriately
            }
        }
    }
}
