//
//  ARContainerView.swift
//  arqrscanner
//
//  Created by Yasuhito Nagatomo on 2022/05/26.
//

import SwiftUI

struct ARContainerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ARViewController

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> ARViewController {
        return ARViewController()
    }

    func updateUIViewController(_ uiViewController: ARViewController,
                                context: Context) {
    }

    class Coordinator: NSObject {
        var parent: ARContainerView
        init(_ parent: ARContainerView) {
            self.parent = parent
        }
    }
}

struct ARContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ARContainerView()
    }
}
