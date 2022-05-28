//
//  ScanView.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/28.
//

import SwiftUI

struct ScanView: View {
    var body: some View {
        ZStack {
            ARContainerView()

            VStack {
                Text("Scanning QR code ...")
                    .foregroundColor(.green)
                Spacer()
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
