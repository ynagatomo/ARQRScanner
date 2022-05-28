//
//  QRCode.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/27.
//

import Foundation
import simd

struct QRCode {
    var vertices: [matrix_float4x4] // top-L/R, bottom-L/R in AR scene
    let payload: String?            // Barcode payload sting

    var center: SIMD3<Float> {
        var center: SIMD3<Float> = .zero
        for vertex in vertices {
            center.x += vertex[3].x
            center.y += vertex[3].y
            center.z += vertex[3].z
        }
        center /= Float(vertices.count)
        return center
    }

    static func isValid(vertices: [matrix_float4x4]) -> Bool {
        var valid = true
        if vertices.count != 4 {
            valid = false
        }

        // checks the size here if necessary

        return valid
    }
}
