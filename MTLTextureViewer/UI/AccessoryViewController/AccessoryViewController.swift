import Cocoa

class AccessoryViewController: NSViewController {

    var exportType: MTLTextureManager.ExportType = .texture

    @IBAction func selectFormatAction(_ sender: NSPopUpButton) {
        self.exportType = MTLTextureManager.ExportType.allCases[sender.indexOfSelectedItem]
    }
    
}
