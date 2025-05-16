//
//  ProdukView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct ProdukView: View {
    var kategori: Kategori
    @Query private var allKategoris: [Kategori]
    
    @State private var searchText = ""
    @State private var showTambahProduk = false
    @State private var showUbahProduk = false
    @State private var selectedProduct: Produk?

    enum SortOption {
        case nameAscending, nameDescending, priceAscending, priceDescending
    }
    @State private var sortOption: SortOption = .nameAscending

    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var displayedProducts: [Produk] {
        if kategori.name == "Semua Produk" {
            var seen = Set<UUID>()
            var all: [Produk] = []
            for kategori in allKategoris {
                for product in kategori.products {
                    if !seen.contains(product.id) {
                        seen.insert(product.id)
                        all.append(product)
                    }
                }
            }
            return all
        } else {
            return kategori.products
        }
    }

    var filteredProducts: [Produk] {
        let filtered = displayedProducts.filter {
            searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
        }

        switch sortOption {
        case .nameAscending: return filtered.sorted { $0.name < $1.name }
        case .nameDescending: return filtered.sorted { $0.name > $1.name }
        case .priceAscending: return filtered.sorted { $0.price < $1.price }
        case .priceDescending: return filtered.sorted { $0.price > $1.price }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Add Product Button
            Button(action: { showTambahProduk = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Tambah")
                }
                .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 25)
            .padding(.trailing, 30)

            // Search and Sort Bar
            HStack(spacing: 12) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Cari Produk", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                
                // Sort Menu
                Menu {
                    Button("Nama (A–Z)") { sortOption = .nameAscending }
                    Button("Nama (Z–A)") { sortOption = .nameDescending }
                    Button("Harga Terendah") { sortOption = .priceAscending }
                    Button("Harga Tertinggi") { sortOption = .priceDescending }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding(.horizontal)

            // Product Grid or Empty State
            if filteredProducts.isEmpty {
                if searchText.isEmpty {
                    // Empty Category State
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "shippingbox.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(.systemGray4))
                        
                        Text("\(kategori.name) masih kosong.\nTambahkan produk untuk mulai.")
                            .foregroundColor(Color(.systemGray4))
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                } else {
                    // Search Not Found State
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color(.systemGray3))
                        
                        Text("Produk tidak ditemukan\nCoba periksa kembali ejaan atau gunakan kata kunci lain.")
                            .foregroundColor(Color(.systemGray2))
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                }
            } else {
                // Product Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProducts) { produk in
                            CardProdukView(produk: produk) {
                                selectedProduct = produk
                                showUbahProduk = true
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .padding(.top)
        .sheet(isPresented: $showTambahProduk) {
            TambahProdukView(kategori: kategori)
        }
        .sheet(isPresented: $showUbahProduk) {
            if let product = selectedProduct {
                UbahProdukView(product: product)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Kategori.self, Produk.self, configurations: config)
    
    let kategori = Kategori(name: "Semua Produk")
    let products = [
        Produk(name: "Nasi Goreng", price: 15000),
        Produk(name: "Es Teh", price: 5000)
    ]
    kategori.products = products
    
    return ProdukView(kategori: kategori)
        .modelContainer(container)
}
