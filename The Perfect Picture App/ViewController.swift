//
//  ViewController.swift
//  The Perfect Picture App
//
//  Created by Jessica Ellerbe on 2/17/25.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    let imagePicker = UIImagePickerController()
    var audioPlayer: AVAudioPlayer?
    var uploadedAudioURL: URL? // Store user-uploaded sound

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }

    // 📸 Open Camera with Flash & Sound
    @IBAction func openCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            toggleFlashlight(on: true)  // Flash ON before camera opens
            
            // Play user-uploaded sound if available, else play default sound
            if let soundURL = uploadedAudioURL {
                playUploadedSound(url: soundURL)
            } else {
                playSound(name: "camera_click") // Default camera sound
            }
            
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true) {
                self.toggleFlashlight(on: false) // Flash OFF after camera opens
            }
        } else {
            print("Camera not available")
        }
    }

    // 📷 Handle Captured Image & Save to Photos
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) // Save photo
            print("Image captured & saved!")
        }
        picker.dismiss(animated: true, completion: nil)
    }

    // 🔦 Flashlight Effect
    func toggleFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
            print("Flashlight not available")
            return
        }
        do {
            try device.lockForConfiguration()
            device.torchMode = .on
            device.unlockForConfiguration()
        } catch {
            print("Flashlight could not be used: \(error.localizedDescription)")
        }
    }

    // 🔊 Play Default Sound Effect
    func playSound(name: String) {
        guard let soundURL = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sound file not found")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }

    // 🎶 Upload and Play Custom Sound
    @IBAction func uploadSound(_ sender: UIButton) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.mp3])
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }

    // 🎵 Store & Play Uploaded Sound
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            uploadedAudioURL = url // Save the uploaded sound URL
            print("User uploaded a new sound!")
        }
    }

    // 🔊 Play Uploaded Sound
    func playUploadedSound(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing uploaded sound: \(error.localizedDescription)")
        }
    }
}
