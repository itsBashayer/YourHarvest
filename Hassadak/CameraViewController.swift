import SwiftUI
import AVFoundation
import Vision

class CameraViewController: UIViewController {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var detectionOverlay: CALayer! = nil
    private var objectCounts: [String: Int] = [:]
    var userName: String = "" // ✅ Added userName
    
    private var isPhotoCaptured = false
    private var retakeButton: UIButton!
    private var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlayUI()
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }
        
        session.addInput(input)
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        
        detectionOverlay = CALayer()
        detectionOverlay.frame = view.layer.bounds
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.masksToBounds = true
        view.layer.addSublayer(detectionOverlay)
        
        session.startRunning()
    }
    

    private func setupOverlayUI() {
        let cloudKitHelper = CloudKitHelper() // ✅ Ensure CloudKitHelper is initialized

        let hostingController = UIHostingController(rootView: CamButton(
            userName: userName, // ✅ Pass userName
            capturePhotoAction: capturePhoto,
            cloudKitHelper: cloudKitHelper // ✅ Pass CloudKitHelper instance
        ))

        hostingController.view.frame = view.bounds

        // ✅ Explicitly set the background color correctly
        hostingController.view.backgroundColor = UIColor.clear

        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    
    func capturePhoto() {
        guard !isPhotoCaptured else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        isPhotoCaptured = true
        session.stopRunning()
        
        showActionButtons()
    }
    
    private func showActionButtons() {
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 50
        let spacing: CGFloat = 20
        let totalWidth = (buttonWidth * 2) + spacing

        let buttonYPosition = view.bounds.maxY - 220

        retakeButton = UIButton(frame: CGRect(x: (view.bounds.width - totalWidth) / 2, y: buttonYPosition, width: buttonWidth, height: buttonHeight))
        retakeButton.setTitle(NSLocalizedString("Retake", comment: "Button title for retaking a photo"), for: .normal)

        retakeButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        retakeButton.layer.cornerRadius = 12
        retakeButton.layer.borderWidth = 2
        retakeButton.layer.borderColor = UIColor.red.cgColor
        retakeButton.addTarget(self, action: #selector(retakeCapture), for: .touchUpInside)

        saveButton = UIButton(frame: CGRect(x: retakeButton.frame.maxX + spacing, y: buttonYPosition, width: buttonWidth, height: buttonHeight))
        saveButton.setTitle(NSLocalizedString("Save", comment: "Button title for saving data"), for: .normal)

        saveButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        saveButton.layer.cornerRadius = 12
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = UIColor.green.cgColor
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)

        // ✅ Bring the buttons to the front
        DispatchQueue.main.async {
            self.view.addSubview(self.retakeButton)
            self.view.addSubview(self.saveButton)
            self.view.bringSubviewToFront(self.retakeButton)
            self.view.bringSubviewToFront(self.saveButton)
        }
    }


    
    @objc private func retakeCapture() {
        isPhotoCaptured = false
        objectCounts.removeAll()
        detectionOverlay.sublayers?.removeAll()
        session.startRunning()
        retakeButton.removeFromSuperview()
        saveButton.removeFromSuperview()
    }

  
    @objc private func saveImage() {
        guard let firstDetectedObject = objectCounts.first else {
            print("❌ No objects detected to save.")
            return
        }

        let itemName = firstDetectedObject.key
        let totalProducts = firstDetectedObject.value
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)

        print("📸 Saving: \(itemName) - Count: \(totalProducts) - Date: \(date) - User: \(userName)")

        // ✅ Save to CloudKit
        let cloudKitHelper = CloudKitHelper()
        cloudKitHelper.saveHistory(userName: userName, totalProducts: totalProducts, itemName: itemName)

        // ✅ Notify HistoryView to refresh
        NotificationCenter.default.post(name: NSNotification.Name("HistoryUpdated"), object: nil)

        // ✅ Show "Saved!" confirmation on screen
        let alert = UIAlertController(
            title: NSLocalizedString("Saved!", comment: "Alert title for successful save"),
            message: String(format: NSLocalizedString("%@ saved successfully.", comment: "Alert message when an item is saved"), itemName),
            preferredStyle: .alert
        )


        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: "Alert button to confirm action"),
            style: .default
        ))

        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }

        // ✅ Close CameraViewController after confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.dismiss(animated: true)
        }
    }



        
        private func updateCapturedImage(_ image: UIImage) {
        self.detectionOverlay.sublayers?.removeAll()
        processImage(image)
    }
    
    private func processImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
        
        guard let modelURL = Bundle.main.url(forResource: "ObjectDetector", withExtension: "mlmodelc"),
              let visionModel = try? VNCoreMLModel(for: MLModel(contentsOf: modelURL)) else { return }
        
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, _ in
            DispatchQueue.main.async {
                self?.handleResults(request.results)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
    
    private func handleResults(_ results: [Any]?) {
        DispatchQueue.main.async {
            self.detectionOverlay.sublayers?.removeAll()
            self.objectCounts.removeAll()
            
            guard let results = results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                print("❌ No objects detected.")
                return
            }
            
            for result in results {
                let bestLabel = result.labels.first?.identifier ?? "Unknown"
                self.objectCounts[bestLabel, default: 0] += 1
            }

            self.displayObjectCounts() // ✅ Call function to display object counts
        }
    }
    
    // ✅ Re-added: Display Object Counts on Camera Overlay
    private func displayObjectCounts() {
        let countText = objectCounts.map { "\($0.key): \($0.value)" }.joined(separator: "\n")

        let countLayer = CATextLayer()
        countLayer.string = countText
        countLayer.fontSize = 26
        countLayer.foregroundColor = UIColor.white.cgColor
        countLayer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        countLayer.alignmentMode = .center
        countLayer.contentsScale = UIScreen.main.scale

        let boxWidth: CGFloat = 200
        let boxHeight: CGFloat = 70

        countLayer.frame = CGRect(x: 10, y: 130, width: boxWidth, height: boxHeight)
        countLayer.bounds = CGRect(x: 0, y: -10, width: boxWidth, height: boxHeight)
        countLayer.position = CGPoint(x: 10 + boxWidth / 2, y: 130 + boxHeight / 2)
        countLayer.cornerRadius = 12

        let borderLayer = CALayer()
        borderLayer.frame = countLayer.bounds
        borderLayer.borderColor = UIColor.green.withAlphaComponent(0.4).cgColor
        borderLayer.borderWidth = 3
        borderLayer.cornerRadius = 12

        countLayer.addSublayer(borderLayer)

        countLayer.font = UIFont.boldSystemFont(ofSize: 26)

        detectionOverlay.addSublayer(countLayer)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        updateCapturedImage(image)
    }
}
