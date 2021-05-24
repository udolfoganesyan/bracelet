//
//  ConversationViewController.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 26.09.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit

final class ConversationViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.delaysContentTouches = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = conversationInteractor.currentTheme.backgroundColor
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()
    
    private lazy var inputContainerView: InputAccessoryContainerView = {
        let inputContainerView = InputAccessoryContainerView(theme: conversationInteractor.currentTheme)
        inputContainerView.delegate = self
        return inputContainerView
    }()
    
    private lazy var scrollButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "scrollToTheBottom"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.isHidden = true
        button.addTarget(self, action: #selector(scrollToTheBottom), for: .touchUpInside)
        return button
    }()
    
    private var lastIndexPath: IndexPath? {
        guard let numberOfSections = conversationInteractor.fetchedResultsController.sections?.count,
              numberOfSections > 0 else { return nil }
        guard let numberOfObjectsInTheLastSection = conversationInteractor.fetchedResultsController.sections?[numberOfSections - 1].numberOfObjects,
              numberOfObjectsInTheLastSection > 0 else { return nil }
        
        let indexPath = IndexPath(row: numberOfObjectsInTheLastSection - 1, section: numberOfSections - 1)
        return indexPath
    }
    
    private lazy var frcDelegate = FetchedResultsControllerDelegate<MessageDB>(tableView: tableView)
    private let conversationInteractor: ConversationInteractorProtocol
    
    override var inputAccessoryView: UIView? {
        return inputContainerView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    init(conversationInteractor: ConversationInteractorProtocol) {
        self.conversationInteractor = conversationInteractor
        super.init(nibName: nil, bundle: nil)
        
        title = conversationInteractor.channelTitle
        
        frcDelegate.didUpdateTable = { [weak self] in
            self?.scrollToTheBottom()
        }
        conversationInteractor.fetchedResultsController.delegate = frcDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = conversationInteractor.currentTheme.backgroundColor
        
        setupKeyboardObservers()
        setupEndEditingTap()
        layoutTableView()
        setupScrollToTheBottomButton()
        
        conversationInteractor.fetchSavedMessages()
        conversationInteractor.fetchNewMessagesAndSaveToDB()
    }
    
    @objc private func scrollToTheBottom() {
        guard let lastIndexPath = lastIndexPath else { return }
        
        tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: true)
    }
    
    private func setupKeyboardObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func handleKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputContainerView.frame.height - view.safeAreaInsets.bottom, right: 0)
        } else {
            let keyboardScreenEndFrame = keyboardValue.cgRectValue
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scrollToTheBottom()
        
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    private func setupEndEditingTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        inputContainerView.endEditing()
    }
    
    private func setupScrollToTheBottomButton() {
        view.addSubview(scrollButton)
        scrollButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        scrollButton.widthAnchor.constraint(equalTo: scrollButton.heightAnchor).isActive = true
        scrollButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26).isActive = true
        scrollButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -72).isActive = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let lastIndexPath = lastIndexPath else { return }
        
        scrollButton.isHidden = tableView.indexPathsForVisibleRows?.contains(lastIndexPath) ?? true
    }
    
    private func layoutTableView() {
        view.addSubviewWithSameSizeAndSafeTop(tableView)
    }
}

// MARK: - InputDelegate

extension ConversationViewController: InputDelegate {
    
    func handleSend(text: String, completion: @escaping BoolClosure) {
        conversationInteractor.sendMessage(text) { (success) in
            if !success {
                self.showOkAlert("Error", "Could not send message :(")
            }
            completion(success)
        }
    }
}

// MARK: - UITableViewDelegate

extension ConversationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionDate = conversationInteractor.fetchedResultsController.sections?[section].name else { return nil }
        
        let headerView = ConversationDateHeader(dateString: sectionDate, theme: conversationInteractor.currentTheme)
        return headerView
    }
}

// MARK: - UITableViewDataSource

extension ConversationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        conversationInteractor.fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = conversationInteractor.fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier, for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        let messageDB = conversationInteractor.fetchedResultsController.object(at: indexPath)
        let model = MessageCellModel(messageDB: messageDB, theme: conversationInteractor.currentTheme)
        cell.configure(with: model)
        
        return cell
    }
}
