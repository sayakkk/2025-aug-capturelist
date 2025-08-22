import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var screenshotManager = ScreenshotManager.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    @State private var showingPhotoPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Recently Captured Items Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recently Captured Items")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            if !screenshotManager.isAuthorized {
                                Button("Grant Access") {
                                    requestPhotoAccess()
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if !screenshotManager.isAuthorized {
                            PhotoPermissionView()
                        } else if screenshotManager.recentScreenshots.isEmpty {
                            EmptyRecentView()
                        } else {
                            RecentScreenshotsGrid()
                        }
                    }
                    
                    // Folder List Section
                    FolderListView()
                }
                .padding(.vertical)
            }
            .navigationTitle("CaptureList")
            .onAppear {
                if screenshotManager.isAuthorized {
                    screenshotManager.fetchRecentScreenshots()
                }
            }
            .alert("Photo Library Access Required", isPresented: $showingPhotoPermissionAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This app needs access to your photo library to manage screenshots. Please grant access in Settings.")
            }
        }
        .environment(\.managedObjectContext, coreDataManager.viewContext)
    }
    
    private func requestPhotoAccess() {
        screenshotManager.requestPhotoLibraryAccess()
    }
}

struct RecentScreenshotsGrid: View {
    @ObservedObject private var screenshotManager = ScreenshotManager.shared
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(screenshotManager.recentScreenshots, id: \.id) { screenshot in
                ScreenshotCard(
                    screenshot: screenshot,
                    size: CGSize(width: 100, height: 100)
                )
                .contextMenu {
                    Button("Delete") {
                        screenshotManager.deleteScreenshot(screenshot)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct PhotoPermissionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Photo Access Required")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Grant access to your photo library to start managing screenshots")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}

struct EmptyRecentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No Screenshots Yet")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("Take a screenshot to see it appear here")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
} 