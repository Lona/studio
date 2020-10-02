//
//  WelcomeWindow.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/10/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - WelcomeWindow

public class WelcomeWindow: NSWindow {
    public override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {

        let size = NSSize(width: 720, height: 460)

        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.closable, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        let window = self

        window.center()
        window.title = "Welcome"
        window.isReleasedWhenClosed = false
        window.minSize = size
        window.isMovableByWindowBackground = true
        window.hasShadow = true
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = Colors.windowBackground
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.standardWindowButton(.closeButton)?.backgroundFill = CGColor.clear

        let view = NSBox()
        view.boxType = .custom
        view.borderType = .noBorder
        view.contentViewMargins = .zero
        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalToConstant: 720).isActive = true
        view.heightAnchor.constraint(equalToConstant: 460).isActive = true

        let viewController = NSViewController(view: view)

        window.contentViewController = viewController

        // Set up welcome screen

        let welcome = Welcome()

        view.addSubview(welcome)

        welcome.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        welcome.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        welcome.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        welcome.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        welcome.onCreateProject = {
            var workspaceSetup = Workspace.createWorkspaceSetupWindow()

            workspaceSetup.onCancel = { [unowned self] in
                self.endSheet(workspaceSetup.window)
            }

            self.beginSheet(workspaceSetup.window)
        }

        welcome.onOpenProject = {
            let sheetWindow = NSWindow(
                contentRect: NSRect(origin: .zero, size: .init(width: 720, height: 100)),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false,
                screen: nil
            )

            sheetWindow.contentViewController = OpenWorkspaceViewController.shared
            OpenWorkspaceViewController.shared.initializeState()
            OpenWorkspaceViewController.shared.onRequestClose = {
                OpenWorkspaceViewController.shared.dismiss(nil)
            }
            self.contentViewController?.presentAsModalWindow(OpenWorkspaceViewController.shared)
        }

        welcome.onOpenExample = {
            guard let url = URL(string: "https://github.com/airbnb/Lona/tree/master/examples/material-design") else { return }
            NSWorkspace.shared.open(url)
        }

        welcome.onOpenDocumentation = {
            guard let url = URL(string: "https://github.com/airbnb/Lona/blob/master/README.md") else { return }
            NSWorkspace.shared.open(url)
        }
    }
}

// MARK: - Dialogs

extension WelcomeWindow {

}
