import Cocoa
import Quartz
import MetalTools

class PreviewViewController: NSViewController, QLPreviewingController {

    override var nibName: NSNib.Name? {
        return NSNib.Name("PreviewViewController")
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let windowController = storyboard.instantiateController(withIdentifier: "TextureViewer") as? NSWindowController,
              let viewController = windowController.contentViewController as? ViewController
        else { return }

        addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.frame = .init(origin: .zero,
                                          size: self.view.bounds.size)

        do { try viewController.textureManager.read(from: url) }
        catch { displayAlert(message: "File read failed, error: \(error)") }
        viewController.drawTexture()

        handler(nil)
    }
    
}
