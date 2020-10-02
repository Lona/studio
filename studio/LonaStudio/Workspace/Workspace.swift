//
//  Workspace.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/1/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

public protocol WorkspaceSetup {
    var window: NSWindow { get }
    var onCancel: (() -> Void)? { get set }
    var onComplete: (() -> Void)? { get set }
}

private class WorkspaceSetupWindow: WorkspaceSetup {
    private var templateBrowser: TemplateBrowser

    public let window: NSWindow

    public var onCancel: (() -> Void)?
    public var onComplete: (() -> Void)?

    fileprivate init() {
        let sheetWindow = Workspace.createSheetWindow(size: .init(width: 924, height: 635))

        self.window = sheetWindow

        let cards = WorkspaceTemplate.allTemplates.map { $0.metadata }
        var selectedTemplateIndex: Int = 0

        let templateBrowser = TemplateBrowser(
            templateTitles: cards.map { $0.titleText },
            templateDescriptions: cards.map { $0.descriptionText },
            templateImages: cards.map { $0.image },
            selectedTemplateIndex: selectedTemplateIndex,
            selectedTemplateFiles: WorkspaceTemplate.allTemplates[selectedTemplateIndex].filePaths
        )

        self.templateBrowser = templateBrowser

        sheetWindow.contentView = templateBrowser

        templateBrowser.onChangeSelectedTemplateIndex = { value in
            selectedTemplateIndex = value
            templateBrowser.selectedTemplateIndex = value
            templateBrowser.selectedTemplateFiles = WorkspaceTemplate.allTemplates[value].filePaths
        }

        func handleCreateTemplate(_ template: WorkspaceTemplate) {
            guard let url = Workspace.createWorkspaceDialog() else { return }

            self.onComplete?()

            if !DocumentController.shared.createWorkspace(url: url, workspaceTemplate: template) {
                Swift.print("Failed to create workspace")
                return
            }

            DocumentController.shared.openDocument(withContentsOf: url, display: true).finalSuccess { _ in
                // We update recent projects here, rather than in DocumentController.noteNewRecentDocumentURL,
                // since we don't want the list to update immediately after clicking a project and before the document opens.
                // We also don't rearrange the list until the application restarts, to avoid things shifting around.
                DocumentController.shared.recentProjectsEmitter.emit(DocumentController.shared.recentDocumentURLs)
            }
        }

        templateBrowser.onClickDone = {
            handleCreateTemplate(WorkspaceTemplate.allTemplates[selectedTemplateIndex])
        }

        templateBrowser.onDoubleClickTemplateIndex = { index in
            handleCreateTemplate(WorkspaceTemplate.allTemplates[index])
        }

        templateBrowser.onClickCancel = { [unowned self] in
            self.onCancel?()
        }
    }
}

public enum Workspace {
    public static func createWorkspaceDialog() -> URL? {
        let dialog = NSSavePanel()

        dialog.title = "Create a workspace directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canCreateDirectories = true

        return dialog.runModal() == NSApplication.ModalResponse.OK ? dialog.url : nil
    }

    public static func openWorkspaceDialog() -> URL? {
        let dialog = NSOpenPanel()

        dialog.title                   = "Choose a workspace"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseFiles          = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false

        guard dialog.runModal() == NSApplication.ModalResponse.OK else { return nil }

        return dialog.url
    }

    public static func createSheetWindow(size: NSSize) -> NSWindow {
        let sheetWindow = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled],
            backing: .buffered,
            defer: false,
            screen: nil)

        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = .ultraDark
        visualEffectView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)

        sheetWindow.contentView = visualEffectView

        return sheetWindow
    }

    public static func createWorkspaceSetupWindow() -> WorkspaceSetup {
        return WorkspaceSetupWindow()
    }
}
