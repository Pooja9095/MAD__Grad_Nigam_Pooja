//
//  ViewController.swift
//  MAD_Grad_Nigam_Pooja
//
//  Created by Pooja Nigam on 5/3/23.
//

// Import necessary modules
import UIKit
import CoreML
import Vision

// Define the ViewController class
class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Link the result label from storyboard
    @IBOutlet weak var resultLabel: UILabel!
    
    // Create a variable for the CoreML model
    var model: VNCoreMLModel!
    
    // Define what should happen when the view loads
    override func viewDidLoad() {
            super.viewDidLoad()
       
        // Load the CoreML model
        do {
                let configuration = MLModelConfiguration()
                let model = try RailroadBoxCarModel(configuration: configuration)
                self.model = try VNCoreMLModel(for: model.model)
            } catch {
                fatalError("Could not load the Core ML model")
            }
        }

    // Function to classify an image
    func classifyImage(_ image: UIImage) {
        // Convert the UIImage to a CIImage
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage")
        }
        
        // Create a CoreML request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            // Process the results
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                fatalError("Unexpected results from the VNCoreMLRequest")
            }

            // Update the UI on the main thread
            DispatchQueue.main.async {
                self.resultLabel.text = "Classification: \(topResult.identifier) - Confidence: \(topResult.confidence)"
            }
        }

        // Perform the CoreML request
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification: \(error.localizedDescription)")
        }
    }
    

    // Define what happens when the select image button is tapped
    @IBAction func selectImageButtonisTapped(_ sender: Any) {
    
        // Create an action sheet to choose the image source
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.presentImagePickerController(sourceType: .photoLibrary)
            }
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                self.presentImagePickerController(sourceType: .camera)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
        // Add the actions to the alert controller
            alertController.addAction(photoLibraryAction)
            alertController.addAction(cameraAction)
            alertController.addAction(cancelAction)
            
        // Present the action sheet
            present(alertController, animated: true, completion: nil)
    }
    
    // Function to present the image picker
    func presentImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        
        // Check if the selected source type is available
        if sourceType == .camera && !UIImagePickerController.isSourceTypeAvailable(.camera) {
            print("Camera not available")
            return
        }
        // Present the image picker
        present(imagePickerController, animated: true, completion: nil)
    }

    
    // Define what happens when an image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
        
        // Retrieve the selected image
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Perform image classification on the selected image
        classifyImage(selectedImage)
    }
}


