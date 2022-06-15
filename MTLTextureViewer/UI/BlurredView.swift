import Cocoa

class BlurredView: NSVisualEffectView {

    override func viewDidMoveToWindow() {
        self.material = .windowBackground
        self.blendingMode = .behindWindow
        self.state = .active
    }

}
