//
//  KategoriView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct KategoriView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var kategoris: [Kategori]
    @Binding var selectedKategori: Kategori?
    @State private var showingTambahSheet = false
    
    // Sorted categories with "Semua Produk" always first, then alphabetical
    var sortedKategoris: [Kategori] {
        let filtered = kategoris.filter { $0.name != "Semua Produk" }
                               .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        if let semuaProduk = kategoris.first(where: { $0.name == "Semua Produk" }) {
            return [semuaProduk] + filtered
        }
        return filtered
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Kelola Produk")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
                .padding(.top, 25)

            Spacer().frame(height: 8)

            ScrollView {
                VStack(spacing: 0) {
                    // Use sortedKategoris instead of kategoris
                    ForEach(sortedKategoris) { kategori in
                        Button(action: {
                            selectedKategori = kategori
                        }) {
                            HStack {
                                Text(kategori.name)
                                    .foregroundColor(kategori == selectedKategori ? .green : .primary)
                                    .bold(kategori == selectedKategori)
                                    .padding()
                                Spacer()
                                
                                // Show product count except for "Semua Produk"
                                if kategori.name != "Semua Produk" {
                                    Text("\(kategori.products.count)")
                                        .foregroundColor(.gray)
                                        .padding(.trailing)
                                }
                            }
                            .background(kategori == selectedKategori ? Color.white : Color(.systemGray6))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Tambah Kategori Button (unchanged)
                    Button(action: {
                        showingTambahSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Tambah Kategori")
                        }
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingTambahSheet) {
            TambahKategoriView(isPresented: $showingTambahSheet)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Kategori.self, Produk.self, configurations: config)
    
    // Test data with random order
    let context = container.mainContext
    let cat1 = Kategori(name: "Minuman", products: [Produk(name: "Es Teh", price: 5000)])
    let cat2 = Kategori(name: "Makanan", products: [Produk(name: "Nasi Goreng", price: 15000)])
    let cat3 = Kategori(name: "Semua Produk")
    let cat4 = Kategori(name: "Alat Dapur", products: [Produk(name: "Panci", price: 80000)])
    
    [cat2, cat1, cat4, cat3].forEach { context.insert($0) }
    
    return KategoriView(selectedKategori: .constant(cat3))
        .modelContainer(container)
}
