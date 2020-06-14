import Foundation

extension URL {

    var importType: MTLTextureManager.ImportType? {
        return MTLTextureManager.ImportType(rawValue: self.pathExtension)
    }

    var exportType: MTLTextureManager.ExportType? {
        return MTLTextureManager.ExportType(rawValue: self.pathExtension)
    }

}
