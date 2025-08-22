import SwiftUI
import WidgetKit

struct CaptureListWidgetView: View {
    let folders: [Folder]
    
    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("CaptureList")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "camera.viewfinder")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            // Folders Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                // Existing folders (up to 3)
                ForEach(Array(folders.prefix(3)), id: \.id) { folder in
                    FolderDropTarget(folder: folder)
                }
                
                // New folder creation area
                NewFolderDropTarget()
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
}

struct FolderDropTarget: View {
    let folder: Folder
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 40)
                
                Image(systemName: "folder.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            Text(folder.name ?? "Untitled")
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .widgetURL(URL(string: "capturelist://folder/\(folder.id?.uuidString ?? "")"))
    }
}

struct NewFolderDropTarget: View {
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.green.opacity(0.1))
                    .frame(height: 40)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
            }
            
            Text("New Folder")
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .widgetURL(URL(string: "capturelist://newfolder"))
    }
}

#Preview {
    CaptureListWidgetView(folders: [])
} 