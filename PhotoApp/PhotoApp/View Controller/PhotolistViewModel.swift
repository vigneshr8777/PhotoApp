//
//  PhotolistViewModel.swift
//  PhotoApp
//
//  Created by Vignesh Radhakrishnan on 02/06/20.
//  Copyright © 2020 Sample. All rights reserved.
//

import Foundation

enum FetchMode : Int {
    case Normal
    case PullUp
}

protocol ListCellViewModel {
    var profilePicturePath: String? {get}
}

struct CellViewModel : ListCellViewModel {
    let profilePicturePath: String?
    
    init(photo : Photo) {
           self.profilePicturePath = String(format: Server.ImageDownloadPath.ImagePath, photo.farm,photo.server,photo.id,photo.secret)
       }
}

final class PhotolistViewModel  {
    
    var indexesToInsertData: [Int] = []
    private let api: PhotoListAPI
    private var list: [Photo] = []
    var currentPageNo : Int = 1
    private var totalRecords : Int = 0
    
    init(api: PhotoListAPI = PhotoListAPIManager()) {
        self.api = api
    }
    
    func beginningFetch(_ fetchMode: FetchMode) {
        switch fetchMode {
        case .Normal:
            currentPageNo = 1
        case .PullUp:
            currentPageNo += 1
        }
    }
    
    func fetchItems(searchTerm : String,fetchMode: FetchMode,completion: @escaping ((Result<Bool, Error>) -> Void)) {
        api.getPhotoList(searchTerm: searchTerm, pageNo: "\(currentPageNo)") { [weak self](result) in
            switch result {
            case .success(let photos) :
                if fetchMode == .PullUp {
                    self?.indexesToInsertData =  self?.calculateIndexToInsertData(photos: photos.photo ?? [] ) ?? []
                    self?.list += photos.photo ?? []
                } else {
                    self?.list = photos.photo ?? []
                    self?.indexesToInsertData .removeAll()
                }
                self?.totalRecords = Int(photos.total) ?? 0
                completion(.success(true))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
extension PhotolistViewModel {
    
    func canLoadNextPage() ->Bool {
        return list.count < totalRecords
    }
    func numberOfSections() -> Int {
        return 1
    }
    func numberOfItems(inSection index: Int) -> Int {
        guard index < list.count else {
            return 0
        }
        return list.count
    }
    
    func getCellViewModel(atIndex index: Int, inSection sectionIndex: Int) -> ListCellViewModel? {
        let item = list[index]
        let viewModel: CellViewModel = CellViewModel(photo: item)
        return viewModel
    }
    
    
    func getItem(atIndex index: Int, inSection sectionIndex: Int) -> Photo? {
        return list[index]
    }
    
    private func calculateIndexToInsertData(photos : [Photo]) -> [Int]? {
        if self.currentPageNo > 1 {
            let lasIndex = self.list.count
            var latestIndexes = [Int]()
            for (index,_) in photos.enumerated() {
                latestIndexes.append(lasIndex+index)
            }
            return latestIndexes
        } else {
            return nil
        }
    }
}
