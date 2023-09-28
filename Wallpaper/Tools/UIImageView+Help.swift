//
//  UIImageView+Help.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/19.
//

import Foundation
import Kingfisher
import UIKit


enum LoadingStyle {
    case noani //默认无等待动画
    case activity //系统菊花
}

extension UIImageView {
    
    /// 加载网络图片
    /// - Parameters:
    ///   - url: 图片地址
    ///   - dominantColor: 主题颜色
    ///   - placeholder: 站位图片
    ///   - needLoading: 是否需要加载状态
    
    @discardableResult
    func setImage(fromURL: String?,
                  placeholder: UIImage? = nil,
                  needBlurRadius: CGFloat? = 0,
                  forceRefresh: Bool? = false,
                  forceTransition: Bool? = false,
                  loadingStyle: LoadingStyle? = .noani,
                  progressBlock: DownloadProgressBlock? = nil,
                  resize: CGFloat? = 0,
                  keepCurrentImageWhileLoading: Bool? = false,
                  completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
        

        if let url = fromURL, url.count > 0 {
            if url.hasPrefix("http") {
                
                //如果使用urlQueryAllowed，地址中原本就有%会再次转成%25，导致加载不了
                //自定义需要转义的字符
                let customAllowedSet =  NSCharacterSet(charactersIn:" !#`^<>@[]|").inverted
                let sourceUrl = fromURL?.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
                if let urlString = sourceUrl, let url = URL(string: urlString) {
                    
                
                    if let style = loadingStyle {
                        switch style {
                        case .noani:
                            self.kf.indicatorType = .none
                        case .activity:
                            self.kf.indicatorType = .activity
                        }
                    }
                        
                        var optionsInfo = KingfisherOptionsInfo()
                        
                        //完全自定义图片加载效果
                        /**
                         let transition = ImageTransition.custom(duration: 0.5, options: UIView.AnimationOptions.curveEaseOut) { imageView, image in
                         
                         } completion: { completed in
                         
                         }
                         */
                        
                        optionsInfo.append(.transition(.fade(0.5)))
                    
                    
                    if let force = forceTransition, force == true {
                        optionsInfo.append(.forceTransition)
                    }
                    
                    if let keep = keepCurrentImageWhileLoading, keep == true {
                        optionsInfo.append(.keepCurrentImageWhileLoading)
                    }
                    
                    if let size = resize, size > 0 {
                        optionsInfo.append(.processor(DownsamplingImageProcessor(size: CGSize(width: size, height: size))))
                        optionsInfo.append(.scaleFactor(UIScreen.main.scale))
                        optionsInfo.append(.cacheOriginalImage)
                        
                        //transition滑动会很卡
                    }
                    
                        optionsInfo.append(.cacheOriginalImage)
                    
                        
                        if let radius = needBlurRadius, radius > 0 {
                            let processor = BlurImageProcessor(blurRadius: radius)
                            optionsInfo.append(.processor(processor))
                        }
                        
                        if let force = forceRefresh, force == true {
                            optionsInfo.append(.forceRefresh)
                        }
                        
                        //指定一个cacheKey缓存图片,默认的cacheKey = url
                        //let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                        
                        return self.kf.setImage(with: url, placeholder: placeholder, options: optionsInfo) { receivedSize, totalSize in
                            
                            
                            if let prog = progressBlock {
                                prog(receivedSize, totalSize)
                            }
                            
                            //自定义加载进度
                            //let progress = Double(receivedSize) / Double(totalSize)
                            
                        } completionHandler: { result in
                            
                            //加载完图片，自定义一些处理
                            
                            if let comp = completionHandler {
                                comp(result)
                            }
                            
                            /**
                             switch result {
                             case .success(let value):
                             SJCLog(value.cacheType,value.source)
                             case .failure(let error):
                             SJCLog(error)
                             }
                             */
                        }
                        
                    } else {
                        if let place = placeholder {
                            self.image = place
                        }else{
                            //这句很重要，不写，cell的复用会导致图像不设置而错乱
                            self.image = nil
                        }
                    }
                
                }else{
                    self.image = UIImage(named: url)
                }
            }else{
                if let place = placeholder {
                    self.image = place
                }else{
                    //这句很重要，不写，cell的复用会导致图像不设置而错乱
                    self.image = nil
                }
            }
            return nil
        }
}

