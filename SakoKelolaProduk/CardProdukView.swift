//
//  CardProdukView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 11/05/25.
//

import SwiftUI

struct CardProdukView: View {
    var produk: Produk
    var onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(produk.name)
                    .font(.system(size: 17))
                Text("Rp \(Int(produk.price))")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .bold()
            }
            Spacer()
            Button(action: onEdit) {
                Text("Ubah")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.white)))
    }
}
