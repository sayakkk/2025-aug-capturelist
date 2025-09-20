//
//  FolderDetailView.swift
//  CaptureList
//
//  Target: CaptureList
//

import SwiftUI
import CoreData
import Photos

struct FolderDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var folder: Folder

    @FetchRequest var screenshots: FetchedResults<Screenshot>
    @State private var showingPhotoPicker = false
    @State private var showingPhotoPermissionAlert = false

    init(folder: Folder) {
        self.folder = folder
        _screenshots = FetchRequest(
            entity: Screenshot.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Screenshot.createdAt, ascending: false)],
            predicate: NSPredicate(format: "folder == %@", folder),
            animation: .default
        )
    }

    var body: some View {
        VStack {
            if screenshots.isEmpty {
                PlaceholderView(message: "No items in this folder")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                        ForEach(screenshots, id: \.id) { screenshot in
                            ScreenshotView(screenshot: screenshot)
                                .onLongPressGesture {
                                    // Placeholder for scheduling reminder
                                    print("Schedule reminder tapped")
                                }
                        }
                    }.padding()
                }
            }
        }
        .navigationTitle(folder.name ?? "Folder")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add Screenshot") {
                    // Photo access temporarily disabled until privacy permissions are configured
                    print("Photo access will be available after setting up privacy permissions")
                }
            }
        }
        .alert("Photo Permission Required", isPresented: $showingPhotoPermissionAlert) {
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please grant photo access in Settings to add screenshots.")
        }
    }
    
    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            showingPhotoPicker = true
        case .denied, .restricted:
            showingPhotoPermissionAlert = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        showingPhotoPicker = true
                    } else {
                        showingPhotoPermissionAlert = true
                    }
                }
            }
        @unknown default:
            break
        }
    }
}

struct ScreenshotView: View {
    var screenshot: Screenshot
    
    var body: some View {
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(height: 100)
            .cornerRadius(8)
            .overlay(
                Text("Screenshot")
                    .foregroundColor(.secondary)
            )
    }
}
