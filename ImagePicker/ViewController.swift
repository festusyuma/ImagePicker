//
//  ViewController.swift
//  ImagePicker
//
//  Created by Festus Agboma on 01/01/2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topMemeTextField: UITextField!
    @IBOutlet weak var bottomMemeTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    var originalFrameY: CGFloat = 0.0
    
    struct Meme {
        var top: String
        var bottom: String
        var originalImage: UIImage
        var mendedImage: UIImage
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let defautlTxtFieldAttributes: [NSAttributedString.Key : Any] = [
            .paragraphStyle: paragraphStyle,
            .strokeColor: UIColor.black,
            .strokeWidth: -2.5,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 25)!,
        ]
        
        shareButton.isEnabled = false
        topMemeTextField.defaultTextAttributes = defautlTxtFieldAttributes
        bottomMemeTextField.defaultTextAttributes = defautlTxtFieldAttributes
        topMemeTextField.delegate = self
        bottomMemeTextField.delegate = self
        originalFrameY = view.frame.origin.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotification()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        unsubscribeToKeyboardNotification()
    }

    @IBAction func pcikImageFromPhoto(_ sender: Any) {
        pickImage(.photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickImage(.camera)
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        let mendedImage = generateMendedImage()
        let ac = UIActivityViewController(activityItems: [mendedImage], applicationActivities: nil)
        ac.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }
        }
        
        present(ac, animated: true, completion: nil)
    }
    
    @IBAction func resetApp(_ sender: Any) {
        topMemeTextField.text = "TOP"
        bottomMemeTextField.text = "BOTTOM"
        imageView.image = nil
        shareButton.isEnabled = false
    }
    
    func pickImage(_ source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let txt = textField.text?.lowercased() {
            if txt == "top" || txt == "bottom" {
                textField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        if let txt: String = textField.text {
            if !txt.isEmpty { return }
        }
       
        textField.text = textField.accessibilityIdentifier == "topTextField" ? "TOP" : "BOTTOM"
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = originalFrameY

    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func saveMeme(_ mendedImage: UIImage) -> Void {
        let meme = Meme(top: topMemeTextField.text!, bottom: bottomMemeTextField.text!, originalImage: imageView.image!, mendedImage: mendedImage)
    }
    
    func generateMendedImage() -> UIImage {
        hideToolbar()
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let mendedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        showToolbar()
        
        return mendedImage
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideToolbar() {
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    func showToolbar() {
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

