# CaptureList - iOS Screenshot Management App

A modern iOS 17+ app built with SwiftUI that helps you organize and manage screenshots using custom folders with interactive drag & drop functionality and a home screen widget.

## 🚀 Features

### Main App
- **Recently Captured Items**: Automatically detects and displays new screenshots
- **Custom Folder Organization**: Create and manage folders to organize screenshots
- **Drag & Drop Interface**: Intuitive drag and drop between recent items and folders
- **Screenshot Reminders**: Long-press on screenshots to schedule local notifications
- **Modern SwiftUI Design**: Clean, grid-based interface with rounded cards

### Home Screen Widget
- **Quick Access**: Shows 3-4 main folders as drop targets
- **New Folder Creation**: "+" area for creating new folders from the widget
- **Interactive Drop Areas**: Support for drag & drop from iOS floating screenshot thumbnails
- **App Groups Integration**: Seamless data sharing between widget and main app

### Data Management
- **Core Data Integration**: Robust local data storage with automatic sync
- **App Groups**: Shared storage container for widget and app communication
- **Photos API**: Efficient screenshot detection and thumbnail generation
- **Automatic Screenshot Detection**: Listens to system screenshot notifications

## 🏗️ Architecture

### Core Components
- **CoreDataManager**: Handles data persistence and App Groups sharing
- **ScreenshotManager**: Manages Photos API access and screenshot detection
- **ScreenshotCard**: Reusable component with drag & drop and reminder functionality
- **FolderListView**: Displays all user-created folders
- **FolderDetailView**: Shows screenshots within a specific folder

### Widget Extension
- **CaptureListWidget**: Main widget configuration and timeline provider
- **CaptureListWidgetView**: Widget UI with folder drop targets
- **App Groups Integration**: Shared data access between app and widget

## 📱 Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Photos permission
- Notification permission

## 🛠️ Setup Instructions

### 1. Clone the Repository
```bash
git clone <repository-url>
cd 2025-aug-capturelist
```

### 2. Open in Xcode
```bash
open CaptureList.xcodeproj
```

### 3. Configure App Groups
1. Select the project in Xcode
2. Go to Signing & Capabilities
3. Add "App Groups" capability to both targets
4. Use group identifier: `group.com.example.CaptureList`

### 4. Build and Run
1. Select your target device/simulator
2. Build the project (⌘+B)
3. Run the app (⌘+R)

### 5. Add Widget to Home Screen
1. Long-press on home screen
2. Tap the "+" button
3. Search for "CaptureList"
4. Add the widget

## 🔧 Configuration

### App Groups
The app uses App Groups to share data between the main app and widget extension. Ensure both targets have the same App Group identifier configured.

### Photo Library Access
The app requires photo library access to detect and manage screenshots. Users will be prompted to grant permission on first launch.

### Notifications
Local notifications are used for screenshot reminders. The app requests notification permission on launch.

## 📁 Project Structure

```
CaptureList/
├── CaptureList.xcodeproj/          # Xcode project file
├── CaptureList/                     # Main app target
│   ├── CaptureListApp.swift        # App entry point
│   ├── ContentView.swift           # Main content view
│   ├── CoreDataManager.swift       # Core Data management
│   ├── ScreenshotManager.swift     # Screenshot handling
│   ├── FolderListView.swift        # Folder list view
│   ├── FolderDetailView.swift      # Folder detail view
│   ├── ScreenshotCard.swift        # Screenshot component
│   ├── CaptureList.xcdatamodeld/   # Core Data model
│   ├── Assets.xcassets/            # App assets
│   └── Info.plist                  # App configuration
└── CaptureListWidget/               # Widget extension target
    ├── CaptureListWidget.swift     # Widget configuration
    ├── CaptureListWidgetBundle.swift # Widget bundle
    ├── CaptureListWidgetView.swift # Widget UI
    ├── CaptureListWidgetLiveActivity.swift # Live Activity
    └── Assets.xcassets/            # Widget assets
```

## 🔄 Data Flow

1. **Screenshot Detection**: App listens to `UIApplication.userDidTakeScreenshotNotification`
2. **Photo Library Access**: Automatically fetches latest screenshot from Photos API
3. **Core Data Storage**: Saves screenshot metadata and generates thumbnails
4. **Widget Updates**: Widget timeline refreshes when data changes
5. **Drag & Drop**: Screenshots can be moved between recent items and folders
6. **App Groups Sync**: Data automatically syncs between app and widget

## 🎨 UI/UX Features

- **Grid Layout**: Responsive grid system for screenshots and folders
- **Rounded Cards**: Modern card-based design with shadows
- **Drag & Drop**: Visual feedback during drag operations
- **Context Menus**: Long-press actions for screenshots
- **Empty States**: Helpful guidance when no content exists
- **Loading States**: Progress indicators for thumbnail generation

## 🚧 Future Enhancements

- [ ] CloudKit sync for cross-device access
- [ ] Advanced folder organization (nested folders, tags)
- [ ] Screenshot search and filtering
- [ ] Export and sharing functionality
- [ ] Custom reminder templates
- [ ] Dark mode optimizations
- [ ] iPad-specific layouts

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For questions or issues, please open an issue on GitHub or contact the development team.

---

**Note**: This is a first iteration implementation. Some features like advanced reminder scheduling and enhanced widget interactions will be implemented in future versions.
