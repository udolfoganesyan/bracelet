//
//  ProfileViewController.swift
//  FintechApp
//
//  Created by Rudolf Oganesyan on 13.09.2020.
//  Copyright © 2020 Рудольф О. All rights reserved.
//

import UIKit
import MobileCoreServices

final class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var avatarContainerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var fullNameTextField: UITextField!
    @IBOutlet private weak var aboutLabel: UILabel!
    @IBOutlet private weak var aboutTextView: UITextView!
    @IBOutlet private weak var aboutLabelContainer: UIView!
    @IBOutlet private weak var aboutInfoLabel: UILabel!
    @IBOutlet private weak var gcdSaveButton: UIButton!
    @IBOutlet private weak var operationSaveButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private lazy var avatarView = AvatarImageView(style: .circle)
    private var inEditingMode = false
    private var didChangeAvatar = false
    private let profileInteractor: ProfileInteractorProtocol
    private let presentationAssembly: PresentationAssemblyProtocol
    
    init(profileInteractor: ProfileInteractorProtocol, presentationAssembly: PresentationAssemblyProtocol) {
        self.profileInteractor = profileInteractor
        self.presentationAssembly = presentationAssembly
        super.init(nibName: nil, bundle: nil)
        
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        fetchAndSetUserData()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupSubviews() {
        view.backgroundColor = profileInteractor.currentTheme.backgroundColor
        nameLabel.textColor = profileInteractor.currentTheme.primaryTextColor
        aboutLabel.textColor = profileInteractor.currentTheme.primaryTextColor
        aboutInfoLabel.textColor = profileInteractor.currentTheme.secondaryTextColor
        fullNameTextField.backgroundColor = profileInteractor.currentTheme.incomingCellColor
        fullNameTextField.textColor = profileInteractor.currentTheme.primaryTextColor
        fullNameTextField.attributedPlaceholder =
            NSAttributedString(string: "Full name",
                               attributes: [NSAttributedString.Key.foregroundColor: profileInteractor.currentTheme.secondaryTextColor])
        let padding = aboutTextView.textContainer.lineFragmentPadding
        aboutTextView.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        aboutTextView.delegate = self
        aboutTextView.backgroundColor = profileInteractor.currentTheme.incomingCellColor
        aboutTextView.textColor = profileInteractor.currentTheme.primaryTextColor
        activityIndicator.color = profileInteractor.currentTheme.secondaryTextColor
        setupSaveButton(gcdSaveButton)
        setupSaveButton(operationSaveButton)
        setupAvatarView()
    }
    
    private func setupSaveButton(_ button: UIButton) {
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.backgroundColor = profileInteractor.currentTheme.buttonBackgroundColor
    }
    
    private func setupAvatarView() {
        avatarContainerView.addSubviewInBounds(avatarView)
        avatarView.setupWith(firstName: "Katrin", lastName: "Mailyan", color: #colorLiteral(red: 0.8941176471, green: 0.9098039216, blue: 0.168627451, alpha: 1))
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(handleAvatar))
        avatarView.addGestureRecognizer(avatarTap)
        avatarView.isUserInteractionEnabled = true
        
        avatarContainerView.bringSubviewToFront(editButton)
    }
    
    @objc private func handleAvatar() {
        if inEditingMode {
            presentActionSheet()
        }
    }
    
    private func fetchAndSetUserData() {
        profileInteractor.fetchUserData(completion: { (user) in
            self.nameLabel.text = user.fullName
            self.fullNameTextField.text = self.nameLabel.text
            
            self.aboutLabel.text = user.about
            self.aboutTextView.text = self.aboutLabel.text
            if let avatarImage = user.image {
                self.avatarView.setupWith(image: avatarImage)
            }
        })
    }
    
    @IBAction private func fullNameDidChange(_ sender: UITextField) {
        checkChangesAndSetSaveButtons()
    }
    
    private func checkChangesAndSetSaveButtons() {
        if aboutTextView.text != aboutLabel.text || nameLabel.text != fullNameTextField.text || didChangeAvatar {
            gcdSaveButton.isEnabled = true
            operationSaveButton.isEnabled = true
        } else {
            disableSaveButtons()
        }
    }
    
    private func disableSaveButtons() {
        gcdSaveButton.isEnabled = false
        operationSaveButton.isEnabled = false
    }
    
    @IBAction private func saveViaGCDTouched(_ sender: UIButton) {
        profileInteractor.setServiceType(.gcd)
        save()
    }
    
    @IBAction private func saveViaOperationTouched(_ sender: UIButton) {
        profileInteractor.setServiceType(.operation)
        save()
    }
    
    private func save() {
        disableUI()
        
        let user = User(fullName: fullNameTextField.text,
                        about: aboutTextView.text,
                        image: avatarView.image)
        
        profileInteractor.saveUserData(user: user) { (success) in
            if success {
                self.showOkAlert("Done ✓", nil)
                self.fetchAndSetUserData()
                self.enableUI()
                self.disableSaveButtons()
            } else {
                let alertController = UIAlertController(title: "Error while saving data :(", message: nil, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { _ in
                    self.enableUI()
                    alertController.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default) { _ in
                    self.save()
                })
                self.present(alertController, animated: true)
            }
        }
    }
    
    private func disableUI() {
        activityIndicator.startAnimating()
        setUIAvailability(enabled: false)
    }
    
    private func enableUI() {
        activityIndicator.stopAnimating()
        setUIAvailability(enabled: true)
    }
    
    private func setUIAvailability(enabled: Bool) {
        closeButton.isEnabled = enabled
        editButton.isEnabled = enabled
        gcdSaveButton.isEnabled = enabled
        operationSaveButton.isEnabled = enabled
        fullNameTextField.isEnabled = enabled
        aboutTextView.isEditable = enabled
        avatarView.isUserInteractionEnabled = enabled
    }
    
    @IBAction private func editButtonTouched(_ sender: UIButton) {
        inEditingMode.toggle()
        UIView.animate(withDuration: 0.1) {
            self.fullNameTextField.isHidden.toggle()
            self.nameLabel.isHidden.toggle()
            self.aboutTextView.isHidden.toggle()
            self.aboutLabelContainer.isHidden.toggle()
            self.gcdSaveButton.isHidden.toggle()
            self.operationSaveButton.isHidden.toggle()
        }
        if inEditingMode {
            startWiggling()
        } else {
            stopWiggling()
        }
    }
    
    private func startWiggling() {
        guard editButton.layer.animation(forKey: "wigglingAnimation") == nil else { return }
        let wigglingAnimation = WigglingAnimation()
        editButton.layer.add(wigglingAnimation, forKey: "wigglingAnimation")
    }
    
    private func stopWiggling() {
        editButton.layer.removeAllAnimations()
        editButton.transform = CGAffineTransform.identity
    }
    
    private func presentActionSheet() {
        let alertController = UIAlertController(title: "Choose Image from", message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.showImagePicker(for: .camera)
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.showImagePicker(for: .photoLibrary)
        }
        let downloadAction = UIAlertAction(title: "Download", style: .default) { _ in
            self.presentWebImagesViewController()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        #if !targetEnvironment(simulator)
        alertController.addAction(cameraAction)
        #endif
        alertController.addAction(galleryAction)
        alertController.addAction(downloadAction)
        alertController.addAction(cancelAction)
        alertController.pruneNegativeWidthConstraints()
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func showImagePicker(for type: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            Logger.log("SourceType is unavailable")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = type
        if type == .camera {
            imagePickerController.cameraDevice = .front
        }
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true)
    }
    
    private func presentWebImagesViewController() {
        let webImagesViewController = self.presentationAssembly.webImagesViewController()
        webImagesViewController.delegate = self
        present(webImagesViewController, animated: true)
    }
    
    private func setAvatarImage(_ image: UIImage) {
        avatarView.setupWith(image: image)
        didChangeAvatar = true
        checkChangesAndSetSaveButtons()
    }
    
    @IBAction private func closeButtonTouched(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate

extension ProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkChangesAndSetSaveButtons()
    }
}

// MARK: - WebImagesViewControllerDelegate

extension ProfileViewController: WebImagesViewControllerDelegate {
    
    func didChooseImage(_ image: UIImage) {
        setAvatarImage(image)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        setAvatarImage(image)
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ProfileTransition(type: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        ProfileTransition(type: .dismiss)
    }
}
