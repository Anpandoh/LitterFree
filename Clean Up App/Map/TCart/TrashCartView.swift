//
//  TrashCart.swift
//  Clean Up App
//
//  Created by Aneesh Pandoh on 1/18/23.
//

import Foundation
//import UIKit
import SwiftUI

struct TrashCartView: View {
    
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
                    Label("Your Cart", systemImage: "cart").font(.headline).foregroundColor(.green)
                }
            }
            
//        }
    }
}
