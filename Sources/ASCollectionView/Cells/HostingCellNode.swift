import AsyncDisplayKit
import SwiftUI

@available(iOS 13, *)
final class Proxy<State>: ObservableObject {
  @Published var state: State
  @Published var content: (State) -> SwiftUI.AnyView? = { _ in nil }
  
  init(state: State) {
    self.state = state
  }
}

@available(iOS 13, *)
struct RootView<State>: SwiftUI.View {
  @ObservedObject var proxy: Proxy<State>
  
  var body: some View {
    proxy.content(proxy.state)
  }
}

@available(iOS 13, *)
public final class HostingCellNode: ASCellNode {
        
    override public final var isSelected: Bool {
        didSet {
            if proxy.state.isSelected != isSelected {
                proxy.state.isSelected = isSelected
            }
        }
    }
    
    override public final var isHighlighted: Bool {
        didSet {
            if proxy.state.isHighlighted != isHighlighted {
                proxy.state.isHighlighted = isHighlighted
            }
        }
    }
    
    private let proxy: Proxy<State> = .init(state: .init())
    
    private let contentNode: ContentNode
    
    // MARK: - Init
    override public init() {
        contentNode = .init(proxy: proxy)
        
        super.init()
        
        automaticallyManagesSubnodes = true
    }
    
    public convenience init<Content: View>(@ViewBuilder content: @escaping (State) -> Content) {
        self.init()
        contentNode.setContent(content: content)
    }
    
    override public func didLoad() {
        super.didLoad()
    }
    
    override public func layoutSpecThatFits(_: ASSizeRange) -> ASLayoutSpec {
        ASWrapperLayoutSpec(layoutElement: contentNode)
    }
    
    // MARK: -
    public final func setContent<Content: SwiftUI.View>(
        @ViewBuilder content: @escaping (State) -> Content
    ) {
        contentNode.setContent(content: content)
    }
}

@available(iOS 13, *)
final class HostingController<Content: View>: UIHostingController<Content> {
  private var _intrinsicContentSize: CGSize?

  var onInvalidated: () -> Void = {}
    
    var didLoad: Bool = false

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    do {
      if _intrinsicContentSize != view.intrinsicContentSize {
        _intrinsicContentSize = view.intrinsicContentSize
        view.invalidateIntrinsicContentSize()
        onInvalidated()
      }
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
  }
    
    func sizeThatFits(in size: CGSize, maxSize: ASOptionalSize, selfSizeHorizontal: Bool, selfSizeVertical: Bool) -> CGSize
    {
        guard selfSizeHorizontal || selfSizeVertical
        else
        {
            return size.applyMaxSize(maxSize)
        }
        self.view.layoutIfNeeded()
        let fittingSize = CGSize(
            width: selfSizeHorizontal ? maxSize.width ?? .greatestFiniteMagnitude : size.width.applyOptionalMaxBound(maxSize.width),
            height: selfSizeVertical ? maxSize.height ?? .greatestFiniteMagnitude : size.height.applyOptionalMaxBound(maxSize.height))

        // Find the desired size
        var desiredSize = self.sizeThatFits(in: fittingSize)

        // Accounting for 'greedy' swiftUI views that take up as much space as they can
        switch (desiredSize.width, desiredSize.height)
        {
        case (.greatestFiniteMagnitude, .greatestFiniteMagnitude):
            desiredSize = self.sizeThatFits(in: size.applyMaxSize(maxSize))
        case (.greatestFiniteMagnitude, _):
            desiredSize = self.sizeThatFits(in: CGSize(
                width: size.width.applyOptionalMaxBound(maxSize.width),
                height: fittingSize.height))
        case (_, .greatestFiniteMagnitude):
            desiredSize = self.sizeThatFits(in: CGSize(
                width: fittingSize.width,
                height: size.height.applyOptionalMaxBound(maxSize.height)))
        default: break
        }

        // Ensure correct dimensions in non-self sizing axes
        if !selfSizeHorizontal { desiredSize.width = size.width }
        if !selfSizeVertical { desiredSize.height = size.height }

        return desiredSize.applyMaxSize(maxSize)
    }
}

@available(iOS 13, *)
extension HostingCellNode {
    public struct State {
        public var isSelected: Bool
        public var isHighlighted: Bool
        
        public init(isSelected: Bool = false, isHighlighted: Bool = false) {
            self.isSelected = isSelected
            self.isHighlighted = isHighlighted
        }
    }
    
    final class ContentNode: ASDisplayNode {
        /// won't be loaded until didLoad
        private var hostingController: HostingController<RootView<State>>!
        
        private let proxy: Proxy<State>
        
        private var id: UUID = UUID()

        
        // MARK: - Init
        init(proxy: Proxy<State>) {
            self.proxy = proxy
            
            super.init()
            
            backgroundColor = .clear
            
            setViewBlock { [unowned self] in
                
                self.hostingController = HostingController(
                    rootView: RootView(proxy: proxy)
                )
                
                self.hostingController.onInvalidated = { [weak self] in
                    guard let self = self else { return }
                    self.setNeedsLayout()
                    self.supernode?.setNeedsLayout()
                }
                
                return self.hostingController.view
            }
        }
        
        // MARK: -
        final func setContent<Content: SwiftUI.View>(
            @ViewBuilder content: @escaping (State) -> Content
        ) {
            proxy.content = { state in
                SwiftUI.AnyView(content(state).id(self.id))
            }
        }
        
        override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
//            let size = hostingController?.sizeThatFits(in: CGSize(width: constrainedSize.width, height: 0), maxSize: ASOptionalSize(), selfSizeHorizontal: false, selfSizeVertical: true) ?? .init(width: 1, height: 1)
//            let size = hostingController?.sizeThatFits(in: CGSize(width: constrainedSize.width, height: 0)) ?? .init(width: 1, height: 1)
//            print("\(id.uuidString) ConstrainedSize: \(constrainedSize) vs Actual Size \(size)")
            return CGSize(width: 428, height: 300)
        }
    }
}
