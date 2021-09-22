// ASCollectionView. Created by Apptek Studios 2019

import DifferenceKit
import SwiftUI
import UIKit

@available(iOS 13.0, *)
class ASDiffableDataSourceCollectionView<SectionID: Hashable>: ASDiffableDataSource<SectionID>, UICollectionViewDataSource
{
	/// The type of closure providing the cell.
	public typealias Snapshot = ASDiffableDataSourceSnapshot<SectionID>
	public typealias CellProvider = (UICollectionView, IndexPath, ASCollectionViewItemUniqueID) -> ASCollectionViewCell?
	public typealias SupplementaryProvider = (UICollectionView, String, IndexPath) -> ASCollectionViewSupplementaryView

	private weak var collectionView: UICollectionView?
	var cellProvider: CellProvider
	var supplementaryViewProvider: SupplementaryProvider

	public init(collectionView: UICollectionView, cellProvider: @escaping CellProvider, supplementaryViewProvider: @escaping SupplementaryProvider)
	{
		self.collectionView = collectionView
		self.cellProvider = cellProvider
		self.supplementaryViewProvider = supplementaryViewProvider
		super.init()

		collectionView.dataSource = self
	}

	private var firstLoad: Bool = true

	func applySnapshot(_ newSnapshot: Snapshot, animated: Bool = true, completion: (() -> Void)? = nil)
	{
		let changeset = StagedChangeset(source: currentSnapshot.sections, target: newSnapshot.sections)

		guard let collectionView = collectionView else { return }

		let apply = {
			collectionView.reload(using: changeset, interrupt: { $0.changeCount > 100 })
			{ newSections in
				self.currentSnapshot = .init(sections: newSections)
			}
		}
		if firstLoad || !animated
		{
		        UIView.performWithoutAnimation(apply)
		}
		else
		{
			apply()
		}
                completion?()
		firstLoad = false
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int
	{
		currentSnapshot.sections.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		currentSnapshot.sections[section].elements.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	{
		let itemIdentifier = identifier(at: indexPath)
		guard let cell = cellProvider(collectionView, indexPath, itemIdentifier)
		else
		{
			fatalError("ASCollectionView dataSource returned a nil cell for row at index path: \(indexPath), collectionView: \(collectionView), itemIdentifier: \(itemIdentifier)")
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
	{
		return supplementaryViewProvider(collectionView, kind, indexPath)
	}
}
