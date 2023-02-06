//
//  ViewController2.swift
//  iOSEngineerCodeCheck
//
//  Created by 史 翔新 on 2020/04/21.
//  Copyright © 2020 YUMEMI Inc. All rights reserved.
//

import UIKit
import WebKit
import SnapKit
import SFSafeSymbols
import Ink

final class DetailViewController: UIViewController {
    private var htmlData = ""
    
    private let avorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.1
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    private let languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let discriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isSelectable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .white
        return textView
    }()
    
    private let starsCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let forkCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let createrLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    private let starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemSymbol: .star)
        imageView.tintColor = .systemGray2
        return imageView
    }()
    
    private let forkImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemSymbol: .point3ConnectedTrianglepathDotted)
        imageView.tintColor = .systemGray2
        return imageView
    }()
    
    private lazy var readMeView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
      let css = "body { transform: scale(1.5) !important; transform-origin: 0 0 !important; }"
        let script = WKUserScript(source: "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(script)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.tintColor = .white
        webView.allowsBackForwardNavigationGestures = true
        webView.uiDelegate = self
        return webView
    }()
    
    private let backToReadMeButton: UIButton = {
        let button = UIButton()
        button.setTitle("README", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(.none, action: #selector(goToReadMe), for: .touchUpInside)
        return button
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemSymbol: .chevronBackward), for: .normal)
        button.addTarget(.none, action: #selector(goBackward), for: .touchUpInside)
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemSymbol: .chevronForward), for: .normal)
        button.addTarget(.none, action: #selector(goFoward), for: .touchUpInside)
        return button
    }()
    
    private lazy var webButtonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [backToReadMeButton, backButton, forwardButton])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        return stackView
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, languageLabel, discriptionTextView, countStackView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        stackView.spacing = 10
        return stackView
    }()
    
    private let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    private let parser = MarkdownParser()
    var repository: Repository?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTexts()
        setupViews()
        getImage()
        getReadMeData()
    }
}

//MARK: - viewDidLoad()で呼ばれるもの

private extension DetailViewController {
    func setupViews() {
        view.backgroundColor = .black
        self.overrideUserInterfaceStyle = .dark
       
        createStackView(imageView: starImage, label: starsCountLabel)
        createStackView(imageView: forkImage, label: forkCountLabel)
        view.addSubview(avorImageView)
        view.addSubview(createrLabel)
        view.addSubview(headerStackView)
        view.addSubview(readMeView)
        view.addSubview(webButtonStackView)
        
        guard let guide = view.rootSafeAreaLayoutGuide else { return }
        avorImageView.snp.makeConstraints { make in
            make.top.equalTo(guide)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.leading.equalToSuperview().offset(5)
        }
        
        createrLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avorImageView.snp.centerY)
            make.leading.equalTo(avorImageView.snp.trailing).offset(20)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.top.equalTo(avorImageView.snp.bottom).offset(10)
            make.centerX.width.equalToSuperview()
        }
        
        discriptionTextView.snp.makeConstraints { make in
            make.height.equalTo(discriptionTextView.textInputView.snp.height)
            make.centerX.equalToSuperview()
        }
        
        readMeView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(20)
            make.leading.equalTo(headerStackView.snp.leading).offset(10)
            make.trailing.equalTo(headerStackView.snp.trailing).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        webButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(readMeView.snp.bottom).offset(10)
            make.bottom.equalTo(guide)
            make.leading.equalTo(headerStackView.snp.leading).offset(10)
            make.trailing.equalTo(headerStackView.snp.trailing).offset(-10)
            make.centerX.equalToSuperview()
        }
    }
    
    func setTexts() {
        guard let repository else { return }
        guard let createrName = repository.fullName.components(separatedBy: "/").first else { return }
        languageLabel.text = "Written in \(repository.language ?? "")"
        starsCountLabel.text = "\(repository.stargazersCount) Star"
        forkCountLabel.text = "\(repository.forksCount) フォーク"
        discriptionTextView.text = repository.description
        createrLabel.text = createrName
    }
    
    func getImage(){
        titleLabel.text = repository?.fullName
        if let imgURL = repository?.avatarImageUrl {
            URLSession.shared.dataTask(with: imgURL) { (data, res, err) in
                guard let data else { return }
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.avorImageView.image = image
                }
            }.resume()
        }
    }
    
    func createStackView(imageView: UIImageView, label: UILabel) {
        lazy var stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.spacing = 5
        countStackView.addArrangedSubview(stackView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 15, height: 15))
        }
    }
}

extension DetailViewController: WKUIDelegate {
    func getReadMeData() {
        guard let repository else { return }
        ApiCaller.shared.fetchReadme(repository: repository) { result in
            switch result {
            case .success(let data):
                self.displayMarkdown(input: data)
            case .failure(let error):
                assertionFailure("error: \(error.localizedDescription)")
            }
        }
    }
    
    func displayMarkdown(input: String) {
        guard let decodedData = Data(base64Encoded: input, options: .ignoreUnknownCharacters),
              let markdown = String(data: decodedData, encoding: .utf8) else { return }
        let htmlBody = parser.parse(markdown).html
        self.htmlData = "<html><head><style>body {color: white;} a {color: #82bbed;}</style></head><body>\(htmlBody)</body></html>"
        DispatchQueue.main.async { [weak self] in
            self?.readMeView.loadHTMLString(self?.htmlData ?? "", baseURL: nil)
        }
    }
    
    @objc func goToReadMe(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.readMeView.loadHTMLString(self?.htmlData ?? "", baseURL: nil)
        }
    }
    
    @objc func goBackward(_ sender: UIButton) {
        if readMeView.canGoBack {
            readMeView.goBack()
        }
    }
    
    @objc func goFoward(_ sender: UIButton) {
        if readMeView.canGoForward {
            readMeView.goForward()
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
           if navigationAction.targetFrame == nil {
               readMeView.load(navigationAction.request)
           }
           return nil
       }
}
