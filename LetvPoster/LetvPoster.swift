//
//  LetvPoster.swift
//  LetvPoster
//
//  Created by YEHWANG-iOS on 2024/3/14.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    
    /// 获取数据
    /// - Parameter completion: 回调block
    private func getData(completion: @escaping ([WallpaperPostItem]) -> ()) {
        WallpaperPosterData.getTodayPoster {
            switch $0 {
            case .success(let posters):
                completion(posters)
            case .failure(_):
                completion([WallpaperPosterData.placeholderPoster()])
            }
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        // 第一次加载placeholder
        return SimpleEntry(date: Date(), posters: [WallpaperPosterData.placeholderPoster()])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        getData {
            let entry: SimpleEntry
            entry = SimpleEntry(date: Date(), posters: $0)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        getData {
            let currentDate = Date()
            let entry: SimpleEntry
            entry = SimpleEntry(date: currentDate,
                                posters: $0)
            
            let after = Calendar.current.date(byAdding: .hour,
                                              value: 1,
                                              to: currentDate)
            
            let timeline = Timeline(entries: [entry], policy: .after(after!))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let posters: [WallpaperPostItem]
}

struct LetvPosterEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            WallpaperWidgetView(item: entry.posters.first ?? WallpaperPosterData.placeholderPoster())
        case .systemMedium:
            WallpaperWidgetView(item: entry.posters.first ?? WallpaperPosterData.placeholderPoster())
        default:
            WallpaperWidgetView(item: entry.posters.first ?? WallpaperPosterData.placeholderPoster())
        }
    }
}

struct LetvPoster: Widget {
    let kind: String = "LetvPoster"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LetvPosterEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LetvPosterEntryView(entry: entry)
            }
        }
        .configurationDisplayName("最美壁纸")
        .description("随机显示一张精美壁纸")
        .supportedFamilies([.systemSmall])
        .disableContentMarginsIfNeeded()
    }
}

extension WidgetConfiguration {
    func disableContentMarginsIfNeeded() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}

struct LetvPoster_Previews: PreviewProvider {
    static var entry: SimpleEntry {
        return SimpleEntry(date: Date(), posters: [WallpaperPosterData.placeholderPoster()])
    }
    static var previews: some View {
        LetvPosterEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}



/**
 clean 一次就好了
 
 SendProcessControlEvent:toPid: encountered an error: Error Domain=com.apple.dt.deviceprocesscontrolservice Code=8 "Failed to show Widget 'com.yehwang.wallpaper.LetvPoster' error: Error Domain=FBSOpenApplicationServiceErrorDomain Code=1 "The request to open "com.apple.springboard" failed." UserInfo={NSLocalizedFailureReason=The request was denied by service delegate (SBMainWorkspace)., BSErrorCodeDescription=RequestDenied, NSUnderlyingError=0xbe09ba750 {Error Domain=SBAvocadoDebuggingControllerErrorDomain Code=1 "Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)" UserInfo={NSLocalizedDescription=Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)}}, FBSOpenApplicationRequestID=0xf4ed, NSLocalizedDescription=The request to open "com.apple.springboard" failed.}." UserInfo={NSLocalizedDescription=Failed to show Widget 'com.yehwang.wallpaper.LetvPoster' error: Error Domain=FBSOpenApplicationServiceErrorDomain Code=1 "The request to open "com.apple.springboard" failed." UserInfo={NSLocalizedFailureReason=The request was denied by service delegate (SBMainWorkspace)., BSErrorCodeDescription=RequestDenied, NSUnderlyingError=0xbe09ba750 {Error Domain=SBAvocadoDebuggingControllerErrorDomain Code=1 "Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)" UserInfo={NSLocalizedDescription=Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)}}, FBSOpenApplicationRequestID=0xf4ed, NSLocalizedDescription=The request to open "com.apple.springboard" failed.}., NSUnderlyingError=0xbe09bb030 {Error Domain=FBSOpenApplicationServiceErrorDomain Code=1 "The request to open "com.apple.springboard" failed." UserInfo={NSLocalizedFailureReason=The request was denied by service delegate (SBMainWorkspace)., BSErrorCodeDescription=RequestDenied, NSUnderlyingError=0xbe09ba750 {Error Domain=SBAvocadoDebuggingControllerErrorDomain Code=1 "Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)" UserInfo={NSLocalizedDescription=Failed to get descriptors for extensionBundleID (com.yehwang.wallpaper.LetvPoster)}}, FBSOpenApplicationRequestID=0xf4ed, NSLocalizedDescription=The request to open "com.apple.springboard" failed.}}}
 Domain: DTXMessage
 Code: 1
 User Info: {
     DVTErrorCreationDateKey = "2024-03-14 07:52:03 +0000";
 }
 --


 System Information

 macOS Version 14.0 (Build 23A344)
 Xcode 15.0.1 (22266) (Build 15A507)
 Timestamp: 2024-03-14T15:52:03+08:00
 */
