//
//  TrashCart.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 1/18/23.
//

import Foundation
import SwiftUI

struct TrashCartView: View {
    
    var TrashCart = [Trashmarkers]()
    
    @State var isPresented = false
    
    var body: some View {
//        VStack {
//            Spacer()
            List {
                Section {
                    ForEach(0..<5) { _ in
                        Text("\(Image(systemName: "calendar")) Trash")
                            //.foregroundColor(.green)
                    }
                } header: {
                    HStack {
                        Label("Your Cart", systemImage: "cart").font(.headline).foregroundColor(.green)
                        Button("Submit Cart") {
                            isPresented = true
                        }
                        .fullScreenCover(isPresented: $isPresented) {
                            ViewPresenter(TrashCart: TrashCart)
                            
                        }
                    }
                }
            }
            
//        }
    }
    
}

struct ViewPresenter: UIViewControllerRepresentable {
    
    var TrashCart = [Trashmarkers]()

    init(TrashCart: [Trashmarkers]){
        self.TrashCart = TrashCart
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = TrashCanViewController(TrashCart: TrashCart)
        let navVC = UINavigationController(rootViewController: vc)

        return navVC
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UINavigationController
    
}
