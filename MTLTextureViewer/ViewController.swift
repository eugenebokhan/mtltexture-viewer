import Cocoa
import MetalTools
import SIMDTools
import simd
import CoreVideoTools

class ViewController: NSViewController {
    
    struct Configuration {
        let layerColorSpace: CGColorSpace
        let layerPixelFormat: MTLPixelFormat
        let textureColorSpace: MTLTextureManager.ColorSpace
    }

    // MARK: - IB

    @IBOutlet var mtkView: MTKView!

    // MARK: - Properties
    
    var context: MTLContext!
    var renderer: Renderer!
    var textureManager: MTLTextureManager!

    var textureTransform: float4x4 = .identity
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
                              * .translate(value: [zoomPoint.x, zoomPoint.y, 0])
                              * .scale (value: [scale, scale, 1])
                              * .translate(value: [-zoomPoint.x, -zoomPoint.y, 0])
        self.drawTexture()
    }

    override public func scrollWheel(with event: NSEvent) {
        guard let view = self.mtkView
        else { return }
        
        let translation = self.textureTranslation(from: .init(x: event.scrollingDeltaX,
                                                              y: -event.scrollingDeltaY),
                                                  in: view)

        self.textureTransform = self.textureTransform
                              * .translate(value: [translation.x / self.scale, translation.y / self.scale, 0])
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
                               with: finalTransform,
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

        let result: SIMD4<Float> = self.textureTransform.inverse
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
                              in textureView: MTKView) -> float4x4 {
        let textureAspectRatio: Float = .init(texture.width)
                                      / .init(texture.height)
        let textureViewAspectRatio: Float = .init(textureView.frame.width)
                                          / .init(textureView.frame.height)
        let scaleX = textureAspectRatio / textureViewAspectRatio
        return .scale(value: [scaleX, 1, 1])
    }

}
