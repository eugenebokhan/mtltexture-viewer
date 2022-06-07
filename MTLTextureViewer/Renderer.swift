import MetalTools
import SwiftMath

class Renderer {

    // MARK: - Properties

    private let renderPipelineState: MTLRenderPipelineState

    // MARK: - Init

    public init(context: MTLContext) throws {
        let library = try context.library(for: Self.self)
        let renderStateDescriptor = MTLRenderPipelineDescriptor()
        renderStateDescriptor.vertexFunction = library.makeFunction(name: Self.vertexFuntionName)
        renderStateDescriptor.fragmentFunction = library.makeFunction(name: Self.fragmentFuntionName)
        renderStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderStateDescriptor.colorAttachments[0].isBlendingEnabled = false
        self.renderPipelineState = try context.device.makeRenderPipelineState(descriptor: renderStateDescriptor)
    }

    // MARK: - Draw

    func draw(texture: MTLTexture,
              with transform: simd_float4x4 = matrix_identity_float4x4,
              on mtkView: MTKView,
              in commandBuffer: MTLCommandBuffer) {
        guard let drawable = mtkView.currentDrawable,
              let renderPassDescriptor = mtkView.currentRenderPassDescriptor
        else { return }

        commandBuffer.render(descriptor: renderPassDescriptor) { encoder in
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.minFilter = .nearest
            samplerDescriptor.magFilter = .nearest

            let sampler = self.renderPipelineState
                              .device
                              .makeSamplerState(descriptor: samplerDescriptor)

            encoder.setVertexValue(transform, at: 0)
            encoder.setFragmentTextures([texture])
            encoder.setFragmentSamplerState(sampler, index: 0)

            encoder.setRenderPipelineState(self.renderPipelineState)

            encoder.drawPrimitives(type: .triangleStrip,
                                   vertexStart: 0,
                                   vertexCount: 4)
        }
        commandBuffer.present(drawable)
    }

    private static let vertexFuntionName = "vertexFunction"
    private static let fragmentFuntionName = "fragmentFunction"

    public static func configure(_ mtkView: MTKView,
                                 with device: MTLDevice) {
        mtkView.device = device
        mtkView.autoResizeDrawable = false
        mtkView.enableSetNeedsDisplay = true
        mtkView.isPaused = true
        mtkView.clearColor = MTLClearColor(red: 0, green: 0,
                                         blue: 0, alpha: 0)
        mtkView.layer?.isOpaque = false
    }
}
