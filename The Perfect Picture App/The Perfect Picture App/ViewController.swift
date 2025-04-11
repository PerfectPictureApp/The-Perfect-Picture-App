// ViewController.swift
// The Perfect Picture App
// Created by Jessica Ellerbe on 2/17/25.

import UIKit
import AVFoundation
import UniformTypeIdentifiers
import Photos

class WelcomeViewController: UIViewController {
    
    var uploadedSoundURL: URL? // Store uploaded sound URL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue // Blue background!
        print("WelcomeViewController - viewDidLoad: Setting up the welcome screen!")
        
        // Logo Image
        if let logo = UIImage(named: "logo") {
            let logoImage = UIImageView(image: logo)
            logoImage.frame = CGRect(x: 87, y: 100, width: 220, height: 220)
            view.addSubview(logoImage)
            print("Added logo image—looking fab!")
        } else {
            print("Oopsie! Couldn’t find 'logo' in Assets.xcassets!")
            let missingLogoLabel = UILabel()
            missingLogoLabel.text = "Logo Missing!"
            missingLogoLabel.textColor = .white // White text on blue
            missingLogoLabel.frame = CGRect(x: 137, y: 100, width: 120, height: 40)
            view.addSubview(missingLogoLabel)
        }
        
        // Welcome Text
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome!"
        welcomeLabel.font = UIFont.boldSystemFont(ofSize: 30)
        welcomeLabel.textColor = .white // White text on blue
        welcomeLabel.frame = CGRect(x: 120, y: 350, width: 160, height: 40) // Full "Welcome!"
        view.addSubview(welcomeLabel)
        print("Added Welcome! text—full and fab!")
        
        // Take Picture Button
        let takePictureButton = UIButton(type: .system)
        takePictureButton.setTitle("Take Picture", for: .normal)
        takePictureButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        takePictureButton.setTitleColor(.white, for: .normal)
        takePictureButton.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1) // Light blue!
        takePictureButton.frame = CGRect(x: 97, y: 420, width: 200, height: 50)
        takePictureButton.layer.cornerRadius = 25
        takePictureButton.addTarget(self, action: #selector(goToCamera), for: .touchUpInside)
        view.addSubview(takePictureButton)
        print("Added Take Picture button—light blue and ready!")
        
        // Upload Sound Button
        let uploadSoundButton = UIButton(type: .system)
        uploadSoundButton.setTitle("Upload Sound", for: .normal)
        uploadSoundButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        uploadSoundButton.setTitleColor(.white, for: .normal)
        uploadSoundButton.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1) // Light blue!
        uploadSoundButton.frame = CGRect(x: 97, y: 490, width: 200, height: 50)
        uploadSoundButton.layer.cornerRadius = 25
        uploadSoundButton.addTarget(self, action: #selector(uploadSound), for: .touchUpInside)
        view.addSubview(uploadSoundButton)
        print("Added Upload Sound button—light blue vibes!")
        
        // World Beta Text
        let betaLabel = UILabel()
        betaLabel.text = "World Beta"
        betaLabel.font = UIFont.systemFont(ofSize: 16)
        betaLabel.textColor = .white // White text on blue
        betaLabel.frame = CGRect(x: 147, y: 560, width: 100, height: 30)
        view.addSubview(betaLabel)
        print("Added World Beta text—cute and subtle!")
    }
    
    @objc func goToCamera() {
        print("Going to camera!")
        let cameraVC = CameraViewController()
        cameraVC.uploadedSoundURL = uploadedSoundURL // Pass the uploaded sound
        cameraVC.modalPresentationStyle = .fullScreen
        present(cameraVC, animated: true)
    }
    
    @objc func uploadSound() {
        print("Tapped Upload Sound—picking a tune!")
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.audio])
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
}

extension WelcomeViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            _ = url.startAccessingSecurityScopedResource() // Start accessing the file
            uploadedSoundURL = url
            print("Picked sound: \(url.lastPathComponent)")
            goToCamera() // Go to camera after picking sound
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Upload cancelled—staying on welcome screen!")
    }
}

class CameraViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput!
    var audioPlayer: AVAudioPlayer?
    var isFlashOn = false // Track flash state
    var flashButton: UIButton!
    var isFrontCamera = false // Track camera facing
    var flipButton: UIButton!
    var uploadedSoundURL: URL? // Store uploaded sound URL
    var uploadSoundButton: UIButton!
    
    // Preloaded sounds as MP3s
    let preloadedSounds = ["balloon_1", "dog_1", "sqeakertoy2", "squeaker-toy"]
    // Match sounds to images
    let soundImages = [
        "balloon_1": "fart",
        "dog_1": "dogicon",
        "sqeakertoy2": "toy2",
        "squeaker-toy": "toyicon"
    ]
    var soundButtons: [UIButton] = []
    var zoomButtons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        print("CameraViewController - viewDidLoad: Setting up camera!")
        
        setupAudioSession()
        setupCamera()
        setupSoundButtons()
        setupZoomButtons()
        
        // Add pinch gesture for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(pinchGesture)
        
        // Add tap gesture for focus/exposure
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Capture Button (bluedot1 image)
        let captureButton = UIButton(type: .custom)
        if let bluedotImage = UIImage(named: "bluedot1") {
            captureButton.setImage(bluedotImage, for: .normal)
            captureButton.imageView?.contentMode = .scaleAspectFit
        } else {
            captureButton.setTitle("Capture", for: .normal)
            captureButton.setTitleColor(.white, for: .normal)
        }
        captureButton.frame = CGRect(x: 172, y: 700, width: 50, height: 50)
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        view.addSubview(captureButton)
        print("Added bluedot1 capture button—ready to snap!")
        
        // Done Button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.frame = CGRect(x: 20, y: 50, width: 100, height: 50)
        doneButton.addTarget(self, action: #selector(exitCamera), for: .touchUpInside)
        view.addSubview(doneButton)
        print("Added Done button—top-left and ready!")
        
        // Flash Button (flash_icon (1))
        flashButton = UIButton(type: .custom)
        if let flashImage = UIImage(named: "flash_icon (1)")?.withRenderingMode(.alwaysTemplate) {
            flashButton.setImage(flashImage, for: .normal)
            flashButton.imageView?.contentMode = .scaleAspectFit
        } else {
            flashButton.setTitle("Flash", for: .normal)
            flashButton.setTitleColor(.white, for: .normal)
        }
        flashButton.frame = CGRect(x: view.frame.width - 70, y: 50, width: 50, height: 50)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        updateFlashButtonAppearance()
        view.addSubview(flashButton)
        print("Added flash_icon (1) button—top-right and flashy!")
        
        // Flip Button
        flipButton = UIButton(type: .system)
        flipButton.setTitle("Flip", for: .normal)
        flipButton.setTitleColor(.white, for: .normal)
        flipButton.frame = CGRect(x: view.frame.width - 140, y: 50, width: 50, height: 50)
        flipButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        view.addSubview(flipButton)
        print("Added Flip button—top-right next to flash!")
        
        // Upload Sound Button (upload (1) icon)
        uploadSoundButton = UIButton(type: .custom)
        if let uploadImage = UIImage(named: "upload (1)") {
            uploadSoundButton.setImage(uploadImage, for: .normal)
            uploadSoundButton.imageView?.contentMode = .scaleAspectFit
        } else {
            uploadSoundButton.setTitle("U", for: .normal) // Fallback
            uploadSoundButton.setTitleColor(.white, for: .normal)
        }
        uploadSoundButton.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1) // Light blue!
        uploadSoundButton.frame = CGRect(x: (view.frame.width - 250) / 2 + 230, y: 760, width: 50, height: 50)
        uploadSoundButton.layer.cornerRadius = 8
        uploadSoundButton.addTarget(self, action: #selector(playUploadedSound), for: .touchUpInside)
        view.addSubview(uploadSoundButton)
        print("Added upload (1) icon button for uploaded sound—next to sound icons!")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let url = uploadedSoundURL {
            url.stopAccessingSecurityScopedResource() // Release access when leaving
            print("Stopped accessing uploaded sound: \(url.lastPathComponent)")
        }
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session ready!")
        } catch {
            print("Audio session oopsie: \(error)")
        }
    }
    
    func setupCamera() {
        captureSession.sessionPreset = .photo
        switchCamera(zoomLevel: 1.0) // Start with wide-angle at 1x
    }
    
    func switchCamera(zoomLevel: Float) {
        captureSession.beginConfiguration()
        
        // Remove existing input
        if let currentInput = captureSession.inputs.first {
            captureSession.removeInput(currentInput)
        }
        
        // Choose camera based on zoom level
        let deviceType: AVCaptureDevice.DeviceType = (zoomLevel < 1.0 && !isFrontCamera) ? .builtInUltraWideCamera : .builtInWideAngleCamera
        let position: AVCaptureDevice.Position = isFrontCamera ? .front : .back
        guard let newCamera = AVCaptureDevice.default(deviceType, for: .video, position: position) else {
            print("CameraViewController: No \(isFrontCamera ? "front" : "back") \(deviceType == .builtInUltraWideCamera ? "ultra-wide" : "wide") camera available!")
            captureSession.commitConfiguration()
            return
        }
        captureDevice = newCamera
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            // Ensure photo output is added
            if photoOutput == nil {
                photoOutput = AVCapturePhotoOutput()
                if captureSession.canAddOutput(photoOutput) {
                    captureSession.addOutput(photoOutput)
                }
            }
            
            // Update preview layer
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer.frame = view.bounds
                previewLayer.videoGravity = .resizeAspectFill
                view.layer.addSublayer(previewLayer)
            }
            
            captureSession.commitConfiguration()
            
            // Set zoom after switching
            try captureDevice.lockForConfiguration()
            if zoomLevel >= 1.0 {
                captureDevice.videoZoomFactor = CGFloat(zoomLevel)
            } // No zoom for ultra-wide (.5x)
            captureDevice.unlockForConfiguration()
            
            // Start session on background thread
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession.startRunning()
                print("CameraViewController: Camera started (\(self?.isFrontCamera ?? false ? "front" : "back"), \(deviceType == .builtInUltraWideCamera ? "ultra-wide" : "wide"), \(zoomLevel)x)!")
            }
        } catch {
            print("Camera setup oopsie: \(error)")
            captureSession.commitConfiguration()
        }
    }
    
    func setupSoundButtons() {
        let buttonSize: CGFloat = 50
        let spacing: CGFloat = 10
        let totalWidth = (buttonSize * 4) + (spacing * 3) // 4 preloaded sounds
        let startX = (view.frame.width - (totalWidth + spacing + 50)) / 2 // Adjust for upload button
        var xOffset: CGFloat = startX
        let yPosition: CGFloat = 760
        
        for (index, sound) in preloadedSounds.enumerated() {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: xOffset, y: yPosition, width: buttonSize, height: buttonSize)
            if let imageName = soundImages[sound], let image = UIImage(named: imageName) {
                button.setImage(image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            } else {
                button.setTitle(sound, for: .normal)
                button.setTitleColor(.white, for: .normal)
            }
            button.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(playSound(_:)), for: .touchUpInside)
            view.addSubview(button)
            soundButtons.append(button)
            xOffset += buttonSize + spacing
            print("Added image button for \(sound)—bottom and chic!")
        }
    }
    
    func setupZoomButtons() {
        let zoomLevels: [Float] = isFrontCamera ? [1.0, 2.0] : [0.5, 1.0, 2.0, 3.0]
        let buttonSize: CGFloat = 40
        let spacing: CGFloat = 20
        let totalWidth = (buttonSize * CGFloat(zoomLevels.count)) + (spacing * CGFloat(zoomLevels.count - 1))
        let startX = (view.frame.width - totalWidth) / 2
        var xOffset: CGFloat = startX
        let yPosition: CGFloat = 650
        
        // Clear existing zoom buttons
        zoomButtons.forEach { $0.removeFromSuperview() }
        zoomButtons.removeAll()
        
        for (index, level) in zoomLevels.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle("\(level)x", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            button.frame = CGRect(x: xOffset, y: yPosition, width: buttonSize, height: buttonSize)
            button.tag = index
            button.addTarget(self, action: #selector(setZoom(_:)), for: .touchUpInside)
            view.addSubview(button)
            zoomButtons.append(button)
            xOffset += buttonSize + spacing
            print("Added zoom button: \(level)x")
        }
    }
    
    @objc func playSound(_ sender: UIButton) {
        let soundName = preloadedSounds[sender.tag]
        print("Playing sound: \(soundName)")
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Oopsie! Couldn’t find \(soundName).mp3 in the project!")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
            print("\(soundName) is playing—woohoo!")
        } catch {
            print("Sound oopsie: \(error)")
        }
    }
    
    @objc func playUploadedSound() {
        guard let soundURL = uploadedSoundURL else {
            print("No uploaded sound to play!")
            return
        }
        print("Attempting to play uploaded sound: \(soundURL.lastPathComponent)")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay() // Preload for smoother playback
            audioPlayer?.play()
            print("Uploaded sound is playing—fab!")
        } catch {
            print("Uploaded sound playback failed: \(error.localizedDescription)")
        }
    }
    
    @objc func capturePhoto() {
        print("CameraViewController: Capturing photo!")
        let settings = AVCapturePhotoSettings()
        settings.flashMode = isFlashOn ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    @objc func exitCamera() {
        print("CameraViewController: Exiting camera!")
        captureSession.stopRunning()
        dismiss(animated: true)
    }
    
    @objc func toggleFlash() {
        isFlashOn.toggle()
        updateFlashButtonAppearance()
        print("Flash toggled to: \(isFlashOn ? "ON" : "OFF")")
    }
    
    func updateFlashButtonAppearance() {
        if isFlashOn {
            flashButton.tintColor = .yellow
        } else {
            flashButton.tintColor = .white
        }
    }
    
    @objc func flipCamera() {
        isFrontCamera.toggle()
        switchCamera(zoomLevel: 1.0) // Default to 1x on flip
        setupZoomButtons()
        print("Flipped to \(isFrontCamera ? "front" : "back") camera!")
    }
    
    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let device = captureDevice else { return }
        let currentZoom = device.videoZoomFactor
        let maxZoom = min(device.maxAvailableVideoZoomFactor, isFrontCamera ? 2.0 : 3.0)
        let minZoom: CGFloat = isFrontCamera ? 1.0 : 0.5
        
        let newZoom = min(max(gesture.scale * currentZoom, minZoom), maxZoom)
        
        if !isFrontCamera && newZoom < 1.0 {
            switchCamera(zoomLevel: 0.5) // Switch to ultra-wide
        } else {
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoom
                device.unlockForConfiguration()
                print("Zoom adjusted to: \(newZoom)x")
            } catch {
                print("Zoom oopsie: \(error)")
            }
        }
        gesture.scale = 1.0
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let device = captureDevice else { return }
        let point = gesture.location(in: view)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = devicePoint
                device.focusMode = .autoFocus
                print("Focus set at: \(devicePoint)")
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = devicePoint
                device.exposureMode = .autoExpose
                print("Exposure set at: \(devicePoint)")
            }
            device.unlockForConfiguration()
        } catch {
            print("Focus/Exposure oopsie: \(error)")
        }
    }
    
    @objc func setZoom(_ sender: UIButton) {
        let zoomLevel = (isFrontCamera ? [1.0, 2.0] : [0.5, 1.0, 2.0, 3.0])[sender.tag]
        switchCamera(zoomLevel: Float(zoomLevel))
        print("Zoom set to: \(zoomLevel)x")
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture oopsie: \(error)")
            return
        }
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("Couldn’t process photo data!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        print("CameraViewController: Photo saved!")
    }
}
