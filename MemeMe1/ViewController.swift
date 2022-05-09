//
//  ViewController.swift
//  MemeMe1
//
//  Created by Ashrakat Sherif on 03/09/2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        shareButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(textField: topTextField, defaultText:"TOP")
        prepareTextField(textField: bottomTextField, defaultText:"BOTTOM")
    }
    

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    
    
    @IBAction func pickImageViaCamera(_ sender: Any) {
        pickAnImage (source: .camera)
    }
    
    @IBAction func pickImageViaAlbum(_ sender: Any) {
        pickAnImage (source: .photoLibrary)
    }
    
    @IBAction func shareAnImage(_ sender: Any) {
        let activityController = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityController.completionWithItemsHandler = { activity, completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func doneToShareMeme(_ sender: Any) {
        showMemeInBetween()
    }
    
    @IBAction func topTextField(_ sender: Any) {
        textFieldDidBeginEditing(topTextField)
    }
    @IBAction func bottomTextField(_ sender: Any) {
        textFieldDidBeginEditing(bottomTextField)
    }
    func textFieldDidBeginEditing(_ textField:UITextField){
        if (textField == topTextField && textField.text == "TOP") || (textField == bottomTextField && textField.text == "BOTTOM"){
            textField.text = " "
        }
    }
    func prepareTextField(textField: UITextField, defaultText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.delegate = self
        textField.textAlignment = .center
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor:UIColor.black,
        NSAttributedString.Key.foregroundColor:UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -2.0
    ]
    
    
    func pickAnImage(source: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
            present(pickerController, animated: true, completion: nil)

        }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image Selected")
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
    }
        else if let editedImage = info[.editedImage] as? UIImage{
            imagePickerView.image = editedImage
        }
        shareButton.isEnabled = true
        print ("Share button action is active")
        dismiss(animated:true, completion: nil)
    
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomTextField.isFirstResponder {
        view.frame.origin.y = -getKeyboardHeight (notification)
    }
    }
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unSubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func save() {
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }
        
    
    func generateMemedImage() -> UIImage {
        
        self.navigationController?.navigationBar.isHidden = true;
        self.tabBarController?.tabBar.isHidden = true;
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.navigationController?.navigationBar.isHidden = false;
        self.tabBarController?.tabBar.isHidden = false;

        return memedImage
    }
    
    func showMemeInBetween() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
        
        initialState()
    }
   
    func initialState() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
    }

}




