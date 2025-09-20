//
//  CaptureListWidgetBundle.swift
//  CaptureListWidget
//
//  Target: CaptureListWidget
//

import WidgetKit
import SwiftUI

@main
struct CaptureListWidgetBundle: WidgetBundle {
    var body: some Widget {
        CaptureListWidget()
        FolderWidget()
        CaptureListWidgetControl()
        CaptureListWidgetLiveActivity()
    }
}
