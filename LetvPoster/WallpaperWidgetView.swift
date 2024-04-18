//
//  WallpaperWidgetView.swift
//  LetvPosterExtension
//
//  Created by YEHWANG-iOS on 2024/3/15.
//

import SwiftUI
import WidgetKit

struct WallpaperWidgetView: View {
    
    let item: WallpaperPostItem
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            GeometryReader { geo in
                Image(uiImage: item.src.pic ?? UIImage(named: "snapback")!)
                    .resizable()
                    .cornerRadius(0)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .aspectRatio(contentMode: .fill)
                
                VStack(alignment: .leading) {
                    Image("yehwang_adlogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 22, height: 22)
                        .cornerRadius(11)
                    
                    Spacer()//上下撑开
                    
                    HStack {
                        Text(item.source)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .font(.system(size: 13, weight: .medium))
                        
                        Spacer() //文字撑到左边
                    }.hidden()
                }
                .frame(width: geo.size.width - 12*2)
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            }
        }
        .padding(0)
        .background(Color.white)
        .widgetURL(URL(string: item.src.rawSrc))
    }
}

struct WallpaperWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WallpaperWidgetView(item: WallpaperPosterData.placeholderPoster())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            WallpaperWidgetView(item: WallpaperPosterData.placeholderPoster())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
        
    }
}


/**
 
 内研距离，background与cornerRadius一起cornerRadius不生效
 HStack {
     Text(item.source)
         .lineLimit(1)
         .foregroundColor(.white)
         .font(.system(size: 12, weight: .medium))
         .frame(width: .infinity, height: 18)
         .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
 }
 .frame(width: .infinity, height: 18)
 .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.black.opacity(0.5)))
 */
