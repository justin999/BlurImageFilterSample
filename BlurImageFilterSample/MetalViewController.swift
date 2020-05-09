//
//  MetalViewController.swift
//  BlurImageFilterSample
//
//  Created by Justin Sato on 2020/05/09.
//  Copyright © 2020 justin. All rights reserved.
//

import UIKit
import MetalKit
import Metal

class MetalViewController: UIViewController {
    
    @IBOutlet weak var mtkView: MTKView!
    
    private var device: MTLDevice! = MTLCreateSystemDefaultDevice()!
    private var context: CIContext!
    private var texture: MTLTexture!
    private var commandQueue: MTLCommandQueue!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        applyBlur()
        
        mtkView.framebufferOnly = false
    }
    
    private func applyBlur() {
        context = CIContext(mtlDevice: device)
        loadTexture()
        
        
        
        mtkView.enableSetNeedsDisplay = true

        // ビューの更新依頼 → draw(in:)が呼ばれる
        mtkView.setNeedsDisplay()
        
        
    }
    
    private func setupMetal() {
        // MTLCommandQueueを初期化
        commandQueue = device.makeCommandQueue()
        
        // MTKViewのセットアップ
        mtkView.device = device
        mtkView.delegate = self
    }
    
    private func loadTexture() {
        // MTKTextureLoaderを初期化
        let textureLoader = MTKTextureLoader(device: device)
        // テクスチャをロード
        texture = try! textureLoader.newTexture(
            name: "coco_singing",
            scaleFactor: view.contentScaleFactor,
            bundle: nil)
        
//        // ピクセルフォーマットを合わせる
//        mtkView.colorPixelFormat = texture.pixelFormat
    }

    
}

extension MetalViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("\(self.classForCoder)/" + #function)
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else { return }
        // コマンドバッファを作成
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {fatalError()}

        let ciImage = CIImage(mtlTexture: texture, options: nil)!
        let filter = CIFilter(name: "CIGaussianBlur",
          parameters: [
            kCIInputImageKey: ciImage,
            kCIInputRadiusKey: 5.0 as NSNumber,
        ])!
        guard let outputImage = filter.outputImage else {return}

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        context.render(outputImage, to: drawable.texture, commandBuffer: commandBuffer, bounds: outputImage.extent, colorSpace: colorSpace)

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
}
