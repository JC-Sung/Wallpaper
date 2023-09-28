//
//  SettingController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/22.
//

import Foundation
import UIKit
import Kingfisher
import ETNavBarTransparent

class SettingController: UITableViewController {
    
    @IBOutlet weak var cacheSize: UILabel!
    
    @IBOutlet weak var totalSize: UILabel!
    @IBOutlet weak var useSize: UILabel!
    @IBOutlet weak var freeSize: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "设置"
        imageCaheSize()
    }
    
    func imageCaheSize() {
        totalSize.text = UIDevice.current.totalDiskSpaceInGB
        freeSize.text = UIDevice.current.freeDiskSpaceInGB
        useSize.text = UIDevice.current.usedDiskSpaceInGB
        KingfisherManager.shared.cache.calculateDiskStorageSize { (result) in
            switch result {
            case .success(let value):
                //let size = Double(Double(value) / 1024.0 / 1024.0 / 1024)
                //不用自己去设置G,M，KB等
                self.cacheSize.text = ByteCountFormatter.string(fromByteCount: Int64(value), countStyle: ByteCountFormatter.CountStyle.binary)
                //String(format: "%.1fM", size)
            case .failure(_):
                self.cacheSize.text = ""
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alter = UIAlertController(title: "⚠️警告", message: "删除缓存，会清除本地所有已下载图片", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "删除", style: .destructive) { _ in
            self.clearImageCahe()
        }
        let cancel = UIAlertAction(title: "取消", style: .default)
        
        alter.addAction(delete)
        alter.addAction(cancel)
        self.present(alter, animated: true)
    }
    
    //千万不要删除，为的是保存
    func clearImageCahe() {
        KingfisherManager.shared.cache.clearDiskCache {
            ShowMessages.showToast(msg: "清理成功")
            self.cacheSize.text = "0.0M"
        }
        KingfisherManager.shared.cache.cleanExpiredDiskCache()
        imageCaheSize()
    }
}


extension UIDevice {
    
    func MBFormatter(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = ByteCountFormatter.Units.useMB
        formatter.countStyle = ByteCountFormatter.CountStyle.decimal
        formatter.includesUnit = false
        return formatter.string(fromByteCount: bytes) as String
    }
    
    //MARK: Get String Value
    var totalDiskSpaceInGB:String {
       return ByteCountFormatter.string(fromByteCount: totalDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var freeDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: freeDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var usedDiskSpaceInGB:String {
        return ByteCountFormatter.string(fromByteCount: usedDiskSpaceInBytes, countStyle: ByteCountFormatter.CountStyle.decimal)
    }
    
    var totalDiskSpaceInMB:String {
        return MBFormatter(totalDiskSpaceInBytes)
    }
    
    var freeDiskSpaceInMB:String {
        return MBFormatter(freeDiskSpaceInBytes)
    }
    
    var usedDiskSpaceInMB:String {
        return MBFormatter(usedDiskSpaceInBytes)
    }
    
    //MARK: Get raw value
    var totalDiskSpaceInBytes:Int64 {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let space = (systemAttributes[FileAttributeKey.systemSize] as? NSNumber)?.int64Value else { return 0 }
        return space
    }
    
    /*
     Total available capacity in bytes for "Important" resources, including space expected to be cleared by purging non-essential and cached resources. "Important" means something that the user or application clearly expects to be present on the local system, but is ultimately replaceable. This would include items that the user has explicitly requested via the UI, and resources that an application requires in order to provide functionality.
     Examples: A video that the user has explicitly requested to watch but has not yet finished watching or an audio file that the user has requested to download.
     This value should not be used in determining if there is room for an irreplaceable resource. In the case of irreplaceable resources, always attempt to save the resource regardless of available capacity and handle failure as gracefully as possible.
     */
    var freeDiskSpaceInBytes:Int64 {
        if #available(iOS 11.0, *) {
            if let space = try? URL(fileURLWithPath: NSHomeDirectory() as String).resourceValues(forKeys: [URLResourceKey.volumeAvailableCapacityForImportantUsageKey]).volumeAvailableCapacityForImportantUsage {
                return space
            } else {
                return 0
            }
        } else {
            if let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSpace = (systemAttributes[FileAttributeKey.systemFreeSize] as? NSNumber)?.int64Value {
                return freeSpace
            } else {
                return 0
            }
        }
    }
    
    var usedDiskSpaceInBytes:Int64 {
       return totalDiskSpaceInBytes - freeDiskSpaceInBytes
    }
}
