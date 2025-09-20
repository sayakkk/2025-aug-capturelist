//
//  MainView.swift
//  CaptureList
//
//  Target: CaptureList
//

import SwiftUI
import Photos
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.createdAt, ascending: true)],
        animation: .default
    )
    private var folders: FetchedResults<Folder>

    @State private var recentScreenshots: [PHAsset] = []
    @State private var showingPhotoPermissionAlert = false
    @State private var draggedAssetID: String?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Recent Captures")
                    .font(.headline)
                    .padding(.leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        if recentScreenshots.isEmpty {
                            PlaceholderView(message: "No recent screenshots found")
                        } else {
                            ForEach(recentScreenshots, id: \.localIdentifier) { asset in
                                ScreenshotThumbnail(asset: asset, draggedAssetID: $draggedAssetID)
                            }
                        }
                    }.padding(.horizontal)
                }

                Divider().padding(.vertical, 8)

                Text("Folders")
                    .font(.headline)
                    .padding(.leading)

                List {
                    ForEach(folders, id: \.id) { folder in
                        NavigationLink(destination: FolderDetailView(folder: folder)) {
                            Text(folder.name ?? "Untitled")
                        }
                        .onDrop(of: [.text], isTargeted: nil) { providers in
                            handleDropToFolder(providers: providers, folder: folder)
                        }
                        .overlay(
                            draggedAssetID != nil ? 
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                                .background(Color.blue.opacity(0.1))
                            : nil
                        )
                    }
                    .onDelete(perform: deleteFolders)
                }
            }
            .navigationTitle("CaptureList")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Folder") {
                        addFolder()
                    }
                }
            }
            .onAppear {
                checkPhotoPermission()
            }
            .alert("Photo Permission Required", isPresented: $showingPhotoPermissionAlert) {
                Button("Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Please grant photo access in Settings to view your screenshots.")
            }
        }
    }

    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            fetchRecentScreenshots()
        case .denied, .restricted:
            showingPhotoPermissionAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        fetchRecentScreenshots()
                    } else {
                        showingPhotoPermissionAlert = true
                    }
                }
            }
        @unknown default:
            break
        }
    }

    private func fetchRecentScreenshots() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 20
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var result: [PHAsset] = []
        assets.enumerateObjects { obj, _, _ in
            result.append(obj)
        }
        recentScreenshots = result
    }
    
    private func addFolder() {
        withAnimation {
            let newFolder = Folder(context: viewContext)
            newFolder.id = UUID()
            newFolder.name = "New Folder"
            newFolder.createdAt = Date()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteFolders(offsets: IndexSet) {
        withAnimation {
            offsets.map { folders[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func handleDropToFolder(providers: [NSItemProvider], folder: Folder) -> Bool {
        guard let provider = providers.first else { return false }
        
        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { item, error in
            guard let assetID = item as? String else { return }
            
            DispatchQueue.main.async {
                saveScreenshotToFolder(assetID: assetID, folder: folder)
                draggedAssetID = nil
            }
        }
        
        return true
    }
    
    private func saveScreenshotToFolder(assetID: String, folder: Folder) {
        // PHAsset을 찾기
        guard let asset = recentScreenshots.first(where: { $0.localIdentifier == assetID }) else { return }
        
        // Core Data에 Screenshot 엔티티 생성
        let screenshot = Screenshot(context: viewContext)
        screenshot.id = UUID()
        screenshot.phAssetID = assetID
        screenshot.createdAt = Date()
        screenshot.folder = folder
        
        // 최근 스크린샷 목록에서 제거
        recentScreenshots.removeAll { $0.localIdentifier == assetID }
        
        // Core Data 저장
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

struct ScreenshotThumbnail: View {
    var asset: PHAsset
    @Binding var draggedAssetID: String?
    @State private var image: UIImage?
    @State private var isDragging = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                            .scaleEffect(0.8)
                    )
            }
        }
        .scaleEffect(isDragging ? 1.1 : 1.0)
        .opacity(isDragging ? 0.8 : 1.0)
        .onAppear {
            loadImage()
        }
        .draggable(asset.localIdentifier) {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipped()
                        .cornerRadius(6)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .cornerRadius(6)
                }
            }
        }
        .onDrag {
            isDragging = true
            draggedAssetID = asset.localIdentifier
            return NSItemProvider(object: asset.localIdentifier as NSString)
        }
        .onDrop(of: [.text], isTargeted: nil) { _ in
            isDragging = false
            draggedAssetID = nil
            return false
        }
    }
    
    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic
        options.resizeMode = .exact
        
        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 80, height: 80),
            contentMode: .aspectFill,
            options: options
        ) { result, _ in
            DispatchQueue.main.async {
                self.image = result
            }
        }
    }
}
