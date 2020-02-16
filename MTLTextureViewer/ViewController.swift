//
//  ViewController.swift
//  MTLTextureViewer
//
//  Created by Eugene Bokhan on 20.12.2019.
//  Copyright © 2019 Eugene Bokhan. All rights reserved.
//

import Cocoa
import Alloy
import MetalKit
import SwiftMath

class ViewController: NSViewController {

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

        do { try self.setup() }
        catch { displayAlert(message: "ViewController setup failed, error: \(error)") }
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

    func setup() throws {
        self.context = .init()

        Renderer.configure(self.mtkView,
                           with: self.context.device)

        self.renderer = try .init(context: self.context)
        self.textureManager = .init(context: self.context)
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
