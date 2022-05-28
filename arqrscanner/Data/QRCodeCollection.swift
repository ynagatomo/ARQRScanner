//
//  QRCodeCollection.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/27.
//

import Foundation

final class QRCodeCollection {
    private var collection: [QRCode] = []

    func isIncluded(_ qrcode: QRCode) -> Bool {
        collection.first {
            $0.payload == qrcode.payload
        } != nil
    }

    func add(_ qrcode: QRCode) {
        collection.append(qrcode)
    }
}
