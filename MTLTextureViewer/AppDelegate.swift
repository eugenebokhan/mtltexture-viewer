import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func openAction(_ sender: NSMenuItem) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false

        guard openPanel.runModal() == .OK,
              let url = openPanel.url
        else { return }

        self.readFile(from: url)
    }

    @IBAction func exportAsAction(_ sender: NSMenuItem) {
        guard let activeWindow = NSApp.orderedWindows.first,
              let viewController = activeWindow.contentViewController as? ViewController
        else { return }

        let savePanel = NSSavePanel()
        let accessoryViewController = AccessoryViewController()
        savePanel.accessoryView = accessoryViewController.view
        savePanel.isExtensionHidden = true
        savePanel.begin { (result) -> Void in
            guard result == .OK,
                  var url = savePanel.url
            else { NSSound.beep(); return }

            let exportType = accessoryViewController.exportType
            url = url.deletingPathExtension()
                     .appendingPathExtension(exportType.rawValue)

            do { try viewController.textureManager.write(to: url) }
            catch { displayAlert(message: "File write failed, error: \(error)") }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach { self.readFile(from: $0) }
    }

    func readFile(from url: URL) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "TextureViewer") as? NSWindowController,
              let viewController = windowController.contentViewController as? ViewController
        else { displayAlert(message: "ViewController initialization falied"); return }

        do {
            try viewController.textureManager.read(from: url)
            viewController.drawTexture()
        }
        catch { displayAlert(message: "File read failed, error: \(error)") }

        windowController.window?.title = url.lastPathComponent
        windowController.showWindow(self)
    }

}
