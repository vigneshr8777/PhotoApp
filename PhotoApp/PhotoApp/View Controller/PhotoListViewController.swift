//
//  ViewController.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import UIKit

class `PhotoListViewController`: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var searchBarView: UISearchBar!
    
    private var searchText : String = ""
    private var viewModel = PhotolistViewModel()
    private var currentFetchMode : FetchMode = .Normal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpCollectionView()
        setupSearchBar()
    }

    private func setupSearchBar() {
        searchBarView.delegate =  self
    }
    
    func setUpCollectionView() {
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout .init()
        layout.scrollDirection = .vertical
        photoCollectionView.collectionViewLayout = layout
        photoCollectionView.register(UINib(nibName: "PhotolistCell", bundle: nil), forCellWithReuseIdentifier: "PhotolistCell")
    }
    
    private func fetchPhotoList() {
       
        self.viewModel.beginningFetch(currentFetchMode)
        
        viewModel.fetchItems(searchTerm: searchText, fetchMode: currentFetchMode) { (result) in
            switch result {
            case .success(_) :
                self.photoCollectionView.reloadData()
            case .failure(let error) :
                print(error)
            }
        }
    }
    
    private func searchByText(fetchMode : FetchMode) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PhotoListViewController.performSearchList), object: nil)
        self.perform(#selector(PhotoListViewController.performSearchList), with: nil, afterDelay: 0.3)
    }
    
    @objc func performSearchList() {
        self.fetchPhotoList()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotolistCell", for: indexPath)
        if let cell = cell as? PhotolistCell, let cellViewModel = viewModel.getCellViewModel(atIndex: indexPath.row, inSection: indexPath.section) {
            cell.configureCell(withViewModel: cellViewModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width:collectionView.bounds.size.width / 3 - 10, height:100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension `PhotoListViewController` : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if Float(scrollView.contentOffset.y) >= roundf(Float(scrollView.contentSize.height - scrollView.frame.size.height)) && self.viewModel.canLoadNextPage() {
            currentFetchMode = .PullUp
            fetchPhotoList()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchText  = ""
        } else {
            self.searchText = searchText
        }
        currentFetchMode = .Normal
        searchByText(fetchMode: .Normal)
    }
}
