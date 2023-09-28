//
//  WebViewController.swift
//  Wallpaper
//
//  Created by YEHWANG-iOS on 2023/9/27.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    let scan = "ScanAction"
    let titleKeyPath = "title"
    let progressKeyPath = "estimatedProgress"
    
    public var urlString: String?
    
    public var htmlName: String?
    
    public var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = ""
        view.backgroundColor = .white
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .clear
        webView.customUserAgent = "iOS"
        
        webView.addObserver(self, forKeyPath: titleKeyPath, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: progressKeyPath, options: .new, context: nil)
        
        var request: URLRequest!
        
        if let urlstr = urlString, let url = URL(string: urlstr) {
            request = URLRequest(url: url)
        }
        
        if let htmlstr = htmlName, let url = Bundle.main.url(forResource: htmlstr, withExtension: "html",subdirectory: nil) {
            request = URLRequest(url: url)
        }
        
        self.webView.load(request)
    }
    
    //添加观察者方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //设置进度条
        if keyPath == progressKeyPath {
            progressView.alpha = 1.0
            let animated = Float(webView.estimatedProgress) > progressView.progress
            progressView.setProgress(Float(webView.estimatedProgress), animated: animated)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { (finish) in
                    self.progressView.setProgress(0.0, animated: false)
                })
            }
        }
            
       //重设标题
        else if keyPath == titleKeyPath {
            self.updateTitle()
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func updateTitle() {
        self.navigationItem.title = self.webView.title
        self.navigationController?.navigationBar.setNeedsLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.webView.configuration.userContentController.add(self, name: scan)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.webView.configuration.userContentController.removeScriptMessageHandler(forName: scan)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: progressKeyPath)
        webView.removeObserver(self, forKeyPath: titleKeyPath)
    }

    
        
}

extension WebViewController: WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {

    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == scan {
            
        }
    }
    
    // MARK: - WKNavigationDelegate
    /// 页面开始加载时调用
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    /// 当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    /// 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateTitle()
        let JSStr = "document.querySelector('video').currentSrc;"
        self.webView.evaluateJavaScript(JSStr) { result, error in
            print(result)
        }
        
    }
    
    /// 页面加载失败时调用
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    ///服务器请求跳转的时候调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    ///服务器开始请求的时候调用
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let urlString = navigationAction.request.url?.absoluteString
        print("===========网址链接=========\(String(describing: urlString))")
        decisionHandler(.allow)
    }
    
    
}

