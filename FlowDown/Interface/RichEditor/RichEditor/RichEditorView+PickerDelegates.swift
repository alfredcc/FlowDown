//
//  RichEditorView+PickerDelegates.swift
//  RichEditor
//
//  Created by 秋星桥 on 1/17/25.
//

import Foundation
import PhotosUI
import UIKit
import UniformTypeIdentifiers

extension RichEditorView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any],
    ) {
        let image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            if let image {
                process(image: image)
                focus()
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension RichEditorView: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let shouldFocus = !results.isEmpty
        picker.dismiss(animated: true) { [weak self] in
            if shouldFocus {
                self?.focus()
            }
        }
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, _ in
                guard let image = reading as? UIImage else { return }
                Task { @MainActor [weak self] in
                    self?.process(image: image)
                }
            }
        }
    }
}

extension RichEditorView: UIDocumentPickerDelegate {
    public func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            process(file: url)
        }
    }
}
