import Cocoa
import MetalTools
import SwiftMath
import CoreVideoTools

class ViewController: NSViewController {
    
    struct Configuration: CustomStringConvertible {
        let layerColorSpace: CGColorSpace
        let layerPixelFormat: MTLPixelFormat
        let textureColorSpace: MTLTextureManager.ColorSpace
        
        var description: String {
            let layerColorSpaceName: String
            switch self.layerColorSpace {
            case CGColorSpaceCreateDeviceRGB(): layerColorSpaceName = "CGColorSpaceCreateDeviceRGB()"
            case CGColorSpace(name: CGColorSpace.sRGB)!: layerColorSpaceName = "CGColorSpace(name: CGColorSpace.sRGB)"
            default: layerColorSpaceName = "unknown"
            }
            
            let layerPixelFormatName: String
            switch self.layerPixelFormat {
            case .bgra8Unorm: layerPixelFormatName = ".bgra8Unorm"
            case .bgra8Unorm_srgb: layerPixelFormatName = ".bgra8Unorm_srgb"
            default: layerPixelFormatName = "unknown"
            }
            
            
            return """
                layerColorSpace: \(layerColorSpaceName),
                layerPixelFormat: \(layerPixelFormatName),
                textureColorSpace: \(self.textureColorSpace.rawValue)
            """
        }
    }

    // MARK: - IB

    @IBOutlet var mtkView: MTKView!

    // MARK: - Properties
    
    var context: MTLContext!
    var renderer: Renderer!
    var textureManager: MTLTextureManager!

    var textureTransform: Matrix4x4f = .identity
    var scale: Float = 1.0
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try self.setup(configuration: .init(
                layerColorSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
                layerPixelFormat: .bgra8Unorm_srgb,
                textureColorSpace: .srgb
            ))
        } catch { displayAlert(message: "ViewController setup failed, error: \(error)") }
    }

    override public func viewDidLayout() {
        super.viewDidLayout()
        self.drawTexture()
    }

    override public func magnify(with event: NSEvent) {
        guard let view = self.mtkView
        else { return }

        let zoomPoint = self.texturePoint(from: event.locationInWindow,
                                          in: view)
        let scale = 1 + Float(event.magnification)
        self.scale *= scale

        self.textureTransform = self.textureTransform
                              * .translate(tx: zoomPoint.x,
                                           ty: zoomPoint.y,
                                           tz: 0)
                              * .scale(sx: scale,
                                       sy: scale,
                                       sz: 1)
                              * .translate(tx: -(zoomPoint.x),
                                           ty: -(zoomPoint.y),
                                           tz: 0)
        self.drawTexture()
    }

    override public func scrollWheel(with event: NSEvent) {
        guard let view = self.mtkView
        else { return }
        
        let translation = self.textureTranslation(from: .init(x: event.scrollingDeltaX,
                                                              y: -event.scrollingDeltaY),
                                                  in: view)

        self.textureTransform = self.textureTransform
                              * .translate(tx: translation.x / self.scale,
                                           ty: translation.y / self.scale,
                                           tz: 0)
        self.drawTexture()
    }

    // MARK: - Setup

    func setup(configuration: Configuration) throws {
        self.context = try .init()
        Renderer.configure(mtkView: self.mtkView,
                           device: self.context.device,
                           colorspace: configuration.layerColorSpace,
                           pixelFormat: configuration.layerPixelFormat)
        self.textureManager = .init(context: self.context, colorSpace: configuration.textureColorSpace)
        self.renderer = try .init(context: self.context, pixelFormat: configuration.layerPixelFormat)
        
        print(configuration.description)
    }

    // MARK: - Draw

    func drawTexture() {
        guard let texture = self.textureManager
                                .texture
        else { return }

        let finalTransform = self.textureTransform
                           * self.aspectRatioTransform(for: texture,
                                                       in: self.mtkView)

        let textureSize = CGSize(width: texture.width,
                                 height: texture.height)
        self.mtkView.drawableSize = textureSize

        try? self.context.scheduleAndWait { commandBuffer in
            self.renderer.draw(texture: texture,
                               with: .init(finalTransform),
                               on: self.mtkView,
                               in: commandBuffer)
        }

        self.mtkView.needsDisplay = true
    }

    func texturePoint(from windowPoint: CGPoint,
                      in textureView: MTKView) -> SIMD2<Float> {
        let textureViewSize: SIMD2<Float> = .init(.init(textureView.frame.width),
                                                  .init(textureView.frame.height))
        var point: SIMD2<Float> = .init(.init(windowPoint.x),
                                        .init(windowPoint.y))
        point /= textureViewSize // normalize
        point *= 2               // convert
        point -= 1               // to metal

        let result: SIMD4<Float> = simd_float4x4(self.textureTransform.inversed)
                                 * .init(point.x, point.y, 0, 1)
        return .init(result.x,
                     result.y)
    }

    func textureTranslation(from viewTranslation: CGPoint,
                            in textureView: MTKView) -> SIMD2<Float> {
        let textureViewSize: SIMD2<Float> = .init(.init(textureView.frame.width),
                                                  .init(textureView.frame.height))
        var translation: SIMD2<Float> = .init(.init(viewTranslation.x),
                                        .init(viewTranslation.y))
        translation /= textureViewSize // normalize

        return translation
    }

    func aspectRatioTransform(for texture: MTLTexture,
                              in textureView: MTKView) -> Matrix4x4f {
        let textureAspectRatio: Float = .init(texture.width)
                                      / .init(texture.height)
        let textureViewAspectRatio: Float = .init(textureView.frame.width)
                                          / .init(textureView.frame.height)
        let scaleX = textureAspectRatio / textureViewAspectRatio
        return .scale(sx: scaleX,
                      sy: 1,
                      sz: 1)
    }

}
