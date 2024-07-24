//
//  ImageCacheManager.swift
//  ImageCache
//
//  Created by 임주영 on 2024/07/24.
//

import Foundation
import Foundation
import ImageIO
import UIKit
import RxSwift

enum ItemType: Hashable {
    case item(url: String, height: CGFloat, id: String)
}

class CacheModel {
    var id: String
    var url: String
    var data: Data
    var height: CGFloat
    
    init(id: String, url: String, data: Data, height: CGFloat) {
        self.id = id
        self.url = url
        self.data = data
        self.height = height
    }
}

final class CacheManager {
    static let shared = CacheManager()
    private init() { }
    
    private let memoryCache = NSCache<NSString, CacheModel>()
    
    var disposeBag = DisposeBag()
    
    func fetch(items: [ItemType]) {
        items.forEach { item in
            getCacheData(item: item)
        }
    }
    
    func getGifData(item: ItemType) -> Observable<Data> {
        if let memory = memoryCache(item: item) {
            return .just(memory)
        }
        else if let disk = diskMemoryCache(item: item) {
            return .just(disk)
        }
        else {
            return getCacheData(item: item)
        }
    }
    
    private func diskMemoryCache(item: ItemType) -> Data? {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil }
                
        switch item {
        case .item(_,_, let id):
            var filePath = URL(fileURLWithPath: path)
            filePath.appendPathComponent(id)
            guard let data = try? Data(contentsOf: filePath) else { return nil }
            return data
        }
    }
        
    private func memoryCache(item: ItemType) -> Data? {
        switch item {
        case .item(_,_, let id):
            return memoryCache.object(forKey: NSString(string: id))?.data
        }
    }
    
    @discardableResult
    private func getCacheData(item: ItemType) -> Observable<Data> {
        guard diskMemoryCache(item: item) == nil && memoryCache(item: item) == nil else { return .empty() }

        switch item {
        case .item(let phtoUrl, let height, let id):
            return .create { [weak self] single in
                guard let url = URL(string: phtoUrl), let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return Disposables.create() }
                print("cache download : \(id)")

                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error fetching GIF:", error)
                        single.onError(error)
                        single.onCompleted()
                    }
                    
                    guard let data = data else {
                        single.onCompleted()
                        return
                    }
                    let cacheModel = CacheModel(id: id, url: phtoUrl, data: data, height: height)
                    let fileManager = FileManager()

                    //디스크 메모리 적재
                    var filePath = URL(fileURLWithPath: path)
                    filePath.appendPathComponent(id)
                    fileManager.createFile(atPath: filePath.path, contents: cacheModel.data)
                    
                    //캐시 메모리 적재
                    self?.memoryCache.setObject(cacheModel, forKey: .init(string: id))

                    single.onNext(data)
                    single.onCompleted()
                    
                }.resume()
              
                return Disposables.create()
            }
            .asObservable()
        }
    }
    
}
