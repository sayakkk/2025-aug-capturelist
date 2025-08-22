import SwiftUI

struct FolderListView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var showingCreateFolder = false
    @State private var newFolderName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Folders")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showingCreateFolder = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            if coreDataManager.fetchFolders().isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text("No folders yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Create your first folder to organize screenshots")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(coreDataManager.fetchFolders(), id: \.id) { folder in
                        FolderCard(folder: folder)
                    }
                }
                .padding(.horizontal)
            }
        }
        .alert("Create New Folder", isPresented: $showingCreateFolder) {
            TextField("Folder Name", text: $newFolderName)
            Button("Create") {
                createFolder()
            }
            Button("Cancel", role: .cancel) {
                newFolderName = ""
            }
        } message: {
            Text("Enter a name for your new folder")
        }
    }
    
    private func createFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let trimmedName = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        _ = coreDataManager.createFolder(name: trimmedName)
        newFolderName = ""
    }
}

struct FolderCard: View {
    let folder: Folder
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationLink(destination: FolderDetailView(folder: folder)) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "folder.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                
                VStack(spacing: 4) {
                    Text(folder.name ?? "Untitled")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("\(coreDataManager.fetchScreenshots(in: folder).count) screenshots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .dropDestination(for: Screenshot.self) { items, location in
            handleDrop(items: items)
        }
    }
    
    private func handleDrop(items: [Screenshot]) -> Bool {
        for screenshot in items {
            coreDataManager.moveScreenshot(screenshot, to: folder)
        }
        return true
    }
}

#Preview {
    NavigationView {
        FolderListView()
            .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
    }
} 