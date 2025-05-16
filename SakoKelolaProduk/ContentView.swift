//
//  ContentView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var kategoris: [Kategori]
    @State private var selectedKategori: Kategori?
    @State private var showTambahProdukSheet = false

    var body: some View {
        HStack(spacing: 0) {
            KategoriView(selectedKategori: $selectedKategori)
                .frame(width: 260)
                .background(Color(.systemGroupedBackground))

            Divider()

            if let kategori = selectedKategori {
                ProdukView(kategori: kategori)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    Spacer()
                    Text("Belum ada Produk")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            if selectedKategori == nil {
                selectedKategori = kategoris.first
            }
            
            if kategoris.isEmpty {
                let semuaProduk = Kategori(name: "Semua Produk")
                modelContext.insert(semuaProduk)
                selectedKategori = semuaProduk
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Kategori.self, Produk.self], inMemory: true)
}
