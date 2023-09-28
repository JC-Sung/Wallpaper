//
//  PhotoSaveTool.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import Photos
import UIKit

public struct PhotoSaveTool {
    
    public static func savePhotoWithImage(_ image: UIImage, _ customAlbumName: String = "最美壁纸") {
        PhotoSaveTool.sjcSaveSystemAlbum(
            type: .image(image),
            customAlbumName: customAlbumName,
            location: nil
        ) {
            if $0 != nil {
                DispatchQueue.main.async {
                    ShowMessages.showToast(msg: "已保存到相册")
                }
            }else {
                DispatchQueue.main.async {
                    ShowMessages.showToast(msg: "保存失败")
                }
            }
        }
    }
    
    public enum SaveType {
        case image(UIImage)
        case imageURL(URL)
        case videoURL(URL)
        case livePhoto(imageURL: URL, videoURL: URL)
    }
    
    public enum SaveError: Error {
        case notDetermined
        case phAssetIsNull
    }
    
    /// 保存资源到系统相册
    /// - Parameters:
    ///   - type: 保存类型
    ///   - customAlbumName: 需要保存到自定义相册的名称，默认BundleName
    ///   - creationDate: 创建时间，默认当前时间
    ///   - location: 位置信息
    ///   - completion: PHAsset为空则保存失败
    public static func sjcSaveSystemAlbum(
        type: SaveType,
        customAlbumName: String? = nil,
        creationDate: Date = Date(),
        location: CLLocation? = nil,
        completion: @escaping (PHAsset?) -> Void
    ) {
        saveSystemAlbum(
            type: type,
            customAlbumName: customAlbumName,
            creationDate: creationDate,
            location: location
        ) {
            switch $0 {
            case .success(let phAsset):
                completion(phAsset)
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    /// 保存资源到系统相册
    /// - Parameters:
    ///   - type: 保存类型
    ///   - customAlbumName: 需要保存到自定义相册的名称，默认BundleName
    ///   - creationDate: 创建时间，默认当前时间
    ///   - location: 位置信息
    ///   - completion: 保存之后的结果
    public static func saveSystemAlbum(
        type: SaveType,
        customAlbumName: String? = nil,
        creationDate: Date = Date(),
        location: CLLocation? = nil,
        completion: @escaping (Result<PHAsset, Error>) -> Void
    ) {
        var albumName: String?
        if let customAlbumName = customAlbumName, customAlbumName.count > 0 {
            albumName = customAlbumName
        }else {
            albumName = displayName()
        }
        requestAuthorization {
            switch $0 {
            case .denied, .notDetermined, .restricted:
                completion(.failure(SaveError.notDetermined))
                return
            default:
                break
            }
            DispatchQueue.global().async {
                var placeholder: PHObjectPlaceholder?
                do {
                    try PHPhotoLibrary.shared().performChangesAndWait {
                        var creationRequest: PHAssetCreationRequest?
                        switch type {
                        case .image(let image):
                            creationRequest = PHAssetCreationRequest.creationRequestForAsset(
                                from: image
                            )
                        case .imageURL(let url):
                            creationRequest = PHAssetCreationRequest.creationRequestForAssetFromImage(
                                atFileURL: url
                            )
                        case .videoURL(let url):
                            creationRequest = PHAssetCreationRequest.creationRequestForAssetFromVideo(
                                atFileURL: url
                            )
                        case .livePhoto(let imageURL, let videoURL):
                            creationRequest = PHAssetCreationRequest.forAsset()
                            creationRequest?.addResource(with: .photo, fileURL: imageURL, options: nil)
                            creationRequest?.addResource(with: .pairedVideo, fileURL: videoURL, options: nil)
                        }
                        creationRequest?.creationDate = creationDate
                        creationRequest?.location = location
                        placeholder = creationRequest?.placeholderForCreatedAsset
                    }
                    if let placeholder = placeholder,
                       let phAsset = self.fetchAsset(
                        withLocalIdentifier: placeholder.localIdentifier
                       ) {
                        DispatchQueue.main.async {
                            completion(.success(phAsset))
                        }
                        if let albumName = albumName, !albumName.isEmpty {
                            saveCustomAlbum(for: phAsset, albumName: albumName)
                        }
                    }else {
                        DispatchQueue.main.async {
                            completion(.failure(SaveError.phAssetIsNull))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    private static func displayName() -> String {
        if let displayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return displayName.count > 0 ? displayName : "PhotoPicker"
        }else if let bundleName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String {
            return bundleName.count > 0 ? bundleName : "PhotoPicker"
        }else {
            return "PhotoPicker"
        }
    }
    
    private static func saveCustomAlbum(
        for asset: PHAsset,
        albumName: String
    ) {
        if let assetCollection = createAssetCollection(for: albumName) {
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetCollectionChangeRequest(
                    for: assetCollection
                )?.insertAssets(
                    [asset] as NSFastEnumeration,
                    at: IndexSet.init(integer: 0)
                )
            }
        }
    }
    
    private init() { }
}






public extension PhotoSaveTool {
    
    /// 获取当前相册权限状态
    /// - Returns: 权限状态
    static func authorizationStatus() -> PHAuthorizationStatus {
        let status: PHAuthorizationStatus
        if #available(iOS 14, *) {
            status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        return status
    }
    
    /// 获取相机权限
    /// - Parameter completionHandler: 获取结果
    static func requestCameraAccess(
        completionHandler: @escaping (Bool) -> Void
    ) {
        AVCaptureDevice.requestAccess(
            for: .video
        ) { (granted) in
            DispatchQueue.main.async {
                completionHandler(granted)
            }
        }
    }
    
    /// 当前相机权限状态
    /// - Returns: 权限状态
    static func cameraAuthorizationStatus() -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    /// 当前相册权限状态是否是Limited
    static func authorizationStatusIsLimited() -> Bool {
        if #available(iOS 14, *) {
            if authorizationStatus() == .limited {
                return true
            }
        }
        return false
    }
    
    /// 请求获取相册权限
    /// - Parameters:
    ///   - handler: 请求权限完成
    static func requestAuthorization(
        with handler: @escaping (PHAuthorizationStatus) -> Void
    ) {
        let status = authorizationStatus()
        if status == PHAuthorizationStatus.notDetermined {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(
                    for: .readWrite
                ) { (authorizationStatus) in
                    DispatchQueue.main.async {
                        handler(authorizationStatus)
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                    DispatchQueue.main.async {
                        handler(authorizationStatus)
                    }
                }
            }
        }else {
            handler(status)
        }
    }
}


public extension PhotoSaveTool {
    
    /// 根据 Asset 的本地唯一标识符获取 Asset
    /// - Parameter withLocalIdentifiers: 本地唯一标识符
    /// - Returns: 对应获取的 PHAsset
    static func fetchAssets(
        withLocalIdentifiers: [String]
    ) -> PHFetchResult<PHAsset> {
        PHAsset.fetchAssets(
            withLocalIdentifiers: withLocalIdentifiers,
            options: nil
        )
    }
    
    /// 根据 Asset 的本地唯一标识符获取 Asset
    /// - Parameter withLocalIdentifiers: 本地唯一标识符
    /// - Returns: 对应获取的 PHAsset
    static func fetchAsset(
        withLocalIdentifier: String
    ) -> PHAsset? {
        return fetchAssets(
            withLocalIdentifiers: [withLocalIdentifier]
        ).firstObject
    }
    

    /// 创建相册
    /// - Parameter collectionName: 相册名
    /// - Returns: 对应的 PHAssetCollection 数据
    static func createAssetCollection(
        for collectionName: String
    ) -> PHAssetCollection? {
        let collections = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .albumRegular,
            options: nil
        )
        var assetCollection: PHAssetCollection?
        collections.enumerateObjects { (collection, index, stop) in
            if collection.localizedTitle == collectionName {
                assetCollection = collection
                stop.pointee = true
            }
        }
        if assetCollection == nil {
            do {
                var createCollectionID: String?
                try PHPhotoLibrary.shared().performChangesAndWait {
                    createCollectionID = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(
                        withTitle: collectionName
                    ).placeholderForCreatedAssetCollection.localIdentifier
                }
                if let createCollectionID = createCollectionID {
                    assetCollection = PHAssetCollection.fetchAssetCollections(
                        withLocalIdentifiers: [createCollectionID],
                        options: nil
                    ).firstObject
                }
            }catch {}
        }
        return assetCollection
    }
}
