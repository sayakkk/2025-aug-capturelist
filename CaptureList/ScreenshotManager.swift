import Foundation
import Photos
import UIKit
import Combine

class ScreenshotManager: ObservableObject {
    static let shared = ScreenshotManager()
    
    @Published var recentScreenshots: [Screenshot] = []
    @Published var isAuthorized = false
    
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupScreenshotNotification()
        checkPhotoLibraryAuthorization()
    }
    
    // MARK: - Photo Library Authorization
    func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        DispatchQueue.main.async {
            self.isAuthorized = status == .authorized || status == .limited
        }
        
        if status == .notDetermined {
            requestPhotoLibraryAccess()
        }
    }
    
    func requestPhotoLibraryAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.isAuthorized = status == .authorized || status == .limited
                if self?.isAuthorized == true {
                    self?.fetchRecentScreenshots()
                }
            }
        }
    }
    
    // MARK: - Screenshot Detection
    private func setupScreenshotNotification() {
        NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)
            .sink { [weak self] _ in
                self?.handleScreenshotTaken()
            }
            .store(in: &cancellables)
    }
    
    private func handleScreenshotTaken() {
        // Add a small delay to ensure the screenshot is saved to Photos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.fetchLatestScreenshot()
        }
    }
    
    private func fetchLatestScreenshot() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let latestAsset = fetchResult.firstObject else { return }
        
        // Check if this screenshot is already in our database
        let existingScreenshots = coreDataManager.fetchScreenshots()
        let alreadyExists = existingScreenshots.contains { $0.assetIdentifier == latestAsset.localIdentifier }
        
        if !alreadyExists {
            // Create thumbnail and save to Core Data
            generateThumbnail(for: latestAsset) { [weak self] thumbnailData in
                let screenshot = self?.coreDataManager.createScreenshot(
                    assetIdentifier: latestAsset.localIdentifier,
                    thumbnailData: thumbnailData
                )
                
                DispatchQueue.main.async {
                    self?.fetchRecentScreenshots()
                }
            }
        }
    }
    
    // MARK: - Thumbnail Generation
    private func generateThumbnail(for asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        
        let targetSize = CGSize(width: 200, height: 200)
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if let image = image {
                let thumbnailData = image.jpegData(compressionQuality: 0.8)
                completion(thumbnailData)
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch Screenshots
    func fetchRecentScreenshots() {
        let screenshots = coreDataManager.fetchRecentScreenshots(limit: 20)
        
        DispatchQueue.main.async {
            self.recentScreenshots = screenshots
        }
    }
    
    // MARK: - Screenshot Operations
    func moveScreenshotToFolder(_ screenshot: Screenshot, folder: Folder?) {
        coreDataManager.moveScreenshot(screenshot, to: folder)
        fetchRecentScreenshots()
    }
    
    func deleteScreenshot(_ screenshot: Screenshot) {
        coreDataManager.deleteScreenshot(screenshot)
        fetchRecentScreenshots()
    }
    
    // MARK: - Asset Retrieval
    func getAsset(for screenshot: Screenshot) -> PHAsset? {
        guard let assetIdentifier = screenshot.assetIdentifier else { return nil }
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        return fetchResult.firstObject
    }
    
    func getImage(for screenshot: Screenshot, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        guard let asset = getAsset(for: screenshot) else {
            completion(nil)
            return
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            completion(image)
        }
    }
} 