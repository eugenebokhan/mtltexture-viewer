import QuickLookThumbnailing
import MetalTools
import MetalPerformanceShaders

class ThumbnailProvider: QLThumbnailProvider {
    
    let textureManager = try! MTLTextureManager(context: .init(), colorSpace: .rgb)
    
    override func provideThumbnail(for request: QLFileThumbnailRequest,
                                   _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        let reply = QLThumbnailReply(contextSize: request.maximumSize) {
            return self.drawThumbnail(for: request.fileURL, context: $0)
        }
        handler(reply, nil)
    }
    
    private func drawThumbnail(for fileURL: URL,
                               context: CGContext) -> Bool {
        try? self.textureManager.read(from: fileURL)
        guard let texture = self.textureManager.texture,
              let cgImage = try? texture.cgImage()
        else { return false }
        
        let newWidth = texture.width > texture.height
                     ? context.width
                     : Int(Float(texture.width) * Float(context.height) / Float(texture.height))
        let newHeight = texture.height > texture.width
                     ? context.height
                     : Int(Float(texture.height) * Float(context.width) / Float(texture.width))
        
        let origin = CGPoint(x: (context.width - newWidth) / 2,
                             y: (context.height - newHeight) / 2)
        let size = CGSize(width: newWidth,
                          height: newHeight)
        let rect = CGRect(origin: origin, size: size)
        context.draw(cgImage, in: rect)
        return true
    }
}
