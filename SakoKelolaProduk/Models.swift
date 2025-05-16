//
//  Models.swift
//  SakoKelolaProduk
//
//  Created by Callista on 11/05/25.
//

import Foundation
import SwiftData

@Model
class Produk: Hashable {
    var id: UUID
    var name: String
    var price: Double
    
    init(id: UUID = UUID(), name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
    
    static func == (lhs: Produk, rhs: Produk) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Model
class Kategori: Hashable {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var products: [Produk]
    
    init(id: UUID = UUID(), name: String, products: [Produk] = []) {
        self.id = id
        self.name = name
        self.products = products
    }
    
    static func == (lhs: Kategori, rhs: Kategori) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
