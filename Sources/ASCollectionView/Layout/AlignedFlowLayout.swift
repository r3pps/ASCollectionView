//
//  File.swift
//  
//
//  Created by Rashid Epps on 2/24/22.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
public class AlignedFlowLayout: UICollectionViewFlowLayout
{
    public override init()
    {
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        true
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        let attributes = super.layoutAttributesForElements(in: rect)

        attributes?.forEach
        { layoutAttribute in
            switch layoutAttribute.representedElementCategory
            {
            case .cell:
                layoutAttributesForItem(at: layoutAttribute.indexPath).map { layoutAttribute.frame = $0.frame }
            default: break
            }
        }

        return attributes
    }

    private var leftEdge: CGFloat
    {
        guard let insets = collectionView?.adjustedContentInset
        else
        {
            return sectionInset.left
        }
        return insets.left + sectionInset.left
    }

    private var contentWidth: CGFloat?
    {
        guard let collectionViewWidth = collectionView?.frame.size.width,
            let insets = collectionView?.adjustedContentInset
        else
        {
            return nil
        }
        return collectionViewWidth - insets.left - insets.right - sectionInset.left - sectionInset.right
    }

    public override var collectionViewContentSize: CGSize
    {
        CGSize(width: contentWidth ?? super.collectionViewContentSize.width, height: super.collectionViewContentSize.height)
    }

    fileprivate func isFrame(for firstItemAttributes: UICollectionViewLayoutAttributes, inSameLineAsFrameFor secondItemAttributes: UICollectionViewLayoutAttributes) -> Bool
    {
        guard let lineWidth = contentWidth
        else
        {
            return false
        }
        let firstItemFrame = firstItemAttributes.frame
        let lineFrame = CGRect(
            x: leftEdge,
            y: firstItemFrame.origin.y,
            width: lineWidth,
            height: firstItemFrame.size.height)
        return lineFrame.intersects(secondItemAttributes.frame)
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let attributes = super.layoutAttributesForItem(at: indexPath)
        else
        {
            return nil
        }
        guard
            indexPath.item > 0,
            let previousAttributes = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))
        else
        {
            attributes.frame.origin.x = leftEdge // first item of the section should always be left aligned
            return attributes
        }

        if isFrame(for: attributes, inSameLineAsFrameFor: previousAttributes)
        {
            attributes.frame.origin.x = previousAttributes.frame.maxX + minimumInteritemSpacing
        }
        else
        {
            attributes.frame.origin.x = leftEdge
        }

        return attributes
    }
}
