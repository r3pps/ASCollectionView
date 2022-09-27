// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI
import UIKit
import AsyncDisplayKit

@available(iOS 13.0, *)
class ASDKTableViewCell: ASCellNode, ASDKDataSourceConfigurableCell
{
    var itemID: ASCollectionViewItemUniqueID?
    
    let contentNode: ContentNode
//    var skipNextRefresh: Bool = false
    
    private let proxy: Proxy<State> = .init(state: .init())
    
    override public init() {
        contentNode = .init(proxy: proxy)
        
        super.init()
        
        automaticallyManagesSubnodes = true
    }

    convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        self.init()
        backgroundColor = nil
        selectionStyle = .default
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    weak var tableViewController: ASDK_TableViewController?
    {
        didSet
        {
            if contentNode.hostingController == nil { return }
            if tableViewController != oldValue
            {
                contentNode.hostingController.didMove(toParent: tableViewController)
                tableViewController?.addChild(contentNode.hostingController)
            }
        }
    }
    
    public convenience init<Content: View>(itemID: ASCollectionViewItemUniqueID, content: Content) {
        self.init()
        self.itemID = itemID
        contentNode.setContent(itemID: itemID, content: content)
    }

    func setContent<Content: View>(itemID: ASCollectionViewItemUniqueID, content: Content)
    {
        self.itemID = itemID
        contentNode.setContent(itemID: itemID, content: content)
    }

    override public var safeAreaInsets: UIEdgeInsets
    {
        .zero
    }
    
    override public func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        //ASAbsoluteLayoutSpec(sizing: .sizeToFit, children: [contentNode])
        ASWrapperLayoutSpec(layoutElement: contentNode)
    }
    
    override public func didLoad() {
        super.didLoad()
    }

//    override func layoutSubviews()
//    {
//        super.layoutSubviews()
//
//        hostingController.viewController.view.frame = contentView.bounds
//    }

//    var disableSwiftUIDropInteraction: Bool
//    {
//        get { contentNode.hostingController.disableSwiftUIDropInteraction }
//        set { contentNode.hostingController.disableSwiftUIDropInteraction = newValue }
//    }
//
//    var disableSwiftUIDragInteraction: Bool
//    {
//        get { contentNode.hostingController.disableSwiftUIDragInteraction }
//        set { contentNode.hostingController.disableSwiftUIDragInteraction = newValue }
//    }
}

@available(iOS 13, *)
extension ASDKTableViewCell {
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
        var hostingController: HostingController<RootView<State>>!
        
        var itemID: ASCollectionViewItemUniqueID?
        
        private let proxy: Proxy<State>
        
        // MARK: - Init
        init(proxy: Proxy<State>) {
            self.proxy = proxy
            
            super.init()
            
            backgroundColor = .clear
            
            setViewBlock { [unowned self] in
                
                self.hostingController = .init(rootView: RootView(proxy: proxy))
                
//                self.view.addSubview(hostingController.viewController.view)
//                hostingController.viewController.view.frame = self.view.bounds
                
                self.hostingController.onInvalidated = { [weak self] in
                    guard let self = self else { return }
                    self.supernode?.setNeedsLayout()
                    self.setNeedsLayout()
                }
                
                return self.hostingController.view
            }
        }
        
        // MARK: -
        final func setContent<Content: SwiftUI.View>(itemID: ASCollectionViewItemUniqueID?, content: Content
        ) {
            self.itemID = itemID
            proxy.content = { _ in
                SwiftUI.AnyView(content.id(itemID))
            }
            //hostingController?.setView(SwiftUI.AnyView(content.id(itemID)))
        }
        
        override func calculateSizeThatFits(_ constrainedSize: CGSize) -> CGSize {
            let size = hostingController?.sizeThatFits(in: CGSize(width: constrainedSize.width, height: 0)) ?? .init(width: 1, height: 1)
//            let size = hostingController?.sizeThatFits(in: CGSize(width: constrainedSize.width, height: 0), maxSize: ASOptionalSize(), selfSizeHorizontal: false, selfSizeVertical: true) ?? .init(width: 1, height: 1)
//            let size = hostingController?.sizeThatFits(in: CGSize(width: constrainedSize.width, height: 0)) ?? .init(width: 1, height: 1)
            print("\(String(describing: itemID)) ConstrainedSize: \(constrainedSize) vs Actual Size \(size)")
            return size
        }
    }
}
