//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by saad on 29/01/2020.
//  Copyright © 2020 touti. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var classifier: UILabel!
    
    override func viewDidLoad() {
        classifier.text = "No image selected"
    }

    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
       if let image = info[.originalImage] as? UIImage {
        
            imageView.image = image
            classifier.text = "Loading ..."
        
            /// 1 - Load CoreML Model
            guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {
              fatalError("can't load Places ML model")
            }

            /// 2 - Create request with callback action
            ///     Set text label after getting result
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
              guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                  fatalError("unexpected result type from VNCoreMLRequest")
              }

              DispatchQueue.main.async { [weak self] in
                self?.classifier.text = "I'm \(Int(topResult.confidence * 100))% i'm confident \n This is a \(topResult.identifier)"
              }
            }
            
            /// 3 - Convert image to CIImage
            guard let ciImage = CIImage(image: image) else {
              fatalError("couldn't convert UIImage to CIImage")
            }
        
            /// 4 - Run an ImageRequestHandler with our request & ciImage
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInteractive).async {
              do {
                try handler.perform([request])
              } catch {
                print(error)
              }
            }
        }
    }
}

