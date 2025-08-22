import SwiftUI

struct FolderDetailView: View {
    let folder: Folder
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var screenshots: [Screenshot] = []
    
    private let columns = [
        GridItem(.adaptive(minimum: 120), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(folder.name ?? "Untitled Folder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(screenshots.count) screenshots")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Screenshots Grid
                if screenshots.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No screenshots yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Drag screenshots here to organize them")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(screenshots, id: \.id) { screenshot in
                            ScreenshotCard(
                                screenshot: screenshot,
                                size: CGSize(width: 120, height: 120)
                            )
                            .contextMenu {
                                Button("Move to Recent") {
                                    moveToRecent(screenshot)
                                }
                                
                                Button("Delete", role: .destructive) {
                                    deleteScreenshot(screenshot)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadScreenshots()
        }
        .dropDestination(for: Screenshot.self) { items, location in
            handleDrop(items: items)
        }
    }
    
    private func loadScreenshots() {
        screenshots = coreDataManager.fetchScreenshots(in: folder)
    }
    
    private func handleDrop(items: [Screenshot]) -> Bool {
        for screenshot in items {
            coreDataManager.moveScreenshot(screenshot, to: folder)
        }
        loadScreenshots()
        return true
    }
    
    private func moveToRecent(_ screenshot: Screenshot) {
        coreDataManager.moveScreenshot(screenshot, to: nil)
        loadScreenshots()
    }
    
    private func deleteScreenshot(_ screenshot: Screenshot) {
        coreDataManager.deleteScreenshot(screenshot)
        loadScreenshots()
    }
}

#Preview {
    let context = CoreDataManager.shared.viewContext
    let folder = Folder(context: context)
    folder.id = UUID()
    folder.name = "Test Folder"
    folder.createdAt = Date()
    
    return NavigationView {
        FolderDetailView(folder: folder)
            .environment(\.managedObjectContext, context)
    }
} 