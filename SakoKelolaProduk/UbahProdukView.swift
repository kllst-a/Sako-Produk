//
//  UbahProdukView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct UbahProdukView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Bindable var product: Produk
    @Query private var allKategoris: [Kategori]
    
    @State private var newName: String
    @State private var rawHargaProduk: String
    @State private var selectedKategori: Kategori?
    @State private var originalKategori: Kategori?
    
    @State private var showNameWarning = false
    @State private var showPriceWarning = false
    @State private var showDuplicateWarning = false
    @State private var showCategoryPicker = false

    init(product: Produk) {
        self._product = Bindable(wrappedValue: product)
        _newName = State(initialValue: product.name)
        _rawHargaProduk = State(initialValue: String(Int(product.price)))
    }

    private var hargaProdukBinding: Binding<String> {
        Binding(
            get: { formatInputHarga(rawHargaProduk) },
            set: { rawHargaProduk = $0.filter { "0123456789".contains($0) } }
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Nama Produk Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nama Produk")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Masukkan nama produk", text: $newName)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .disableAutocorrection(true)
                        
                        if showNameWarning {
                            Text("Nama produk maksimal 20 karakter")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                        if showDuplicateWarning {
                            Text("Nama produk sudah ada")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Harga Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Harga Produk (Rp)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        TextField("Masukkan harga produk", text: hargaProdukBinding)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        if showPriceWarning {
                            Text("Harga harus berupa angka")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal)

                    // Kategori Section - Updated to match TambahProdukView
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Kategori Produk")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            Picker("Pilih Kategori", selection: $selectedKategori) {
                                ForEach(allKategoris.filter { $0.name != "Semua Produk" }) { kategori in
                                    Text(kategori.name).tag(kategori as Kategori?)
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedKategori?.name ?? "Pilih Kategori")
                                    .foregroundColor(selectedKategori == nil ? .gray : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 100)
            }
            .navigationTitle("Ubah Produk")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Batal")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                // Find current category
                originalKategori = allKategoris.first { $0.products.contains { $0.id == product.id } }
                selectedKategori = originalKategori
            }
            .onChange(of: newName) { _ in validate() }
            .onChange(of: rawHargaProduk) { _ in validate() }
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    Button(action: saveChanges) {
                        Text("Simpan")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.green : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                    }
                    .disabled(!isFormValid)
                    .background(Color(.systemBackground))
                }
            }
        }
    }

    private func saveChanges() {
        // Update product details
        product.name = newName.trimmingCharacters(in: .whitespaces)
        product.price = Double(rawHargaProduk) ?? 0
        
        // Handle category change
        if let selectedKategori = selectedKategori, selectedKategori != originalKategori {
            // Remove from old category if it exists
            originalKategori?.products.removeAll { $0.id == product.id }
            
            // Add to new category if not already present
            if !selectedKategori.products.contains(where: { $0.id == product.id }) {
                selectedKategori.products.append(product)
            }
        }
        
        dismiss()
    }

    var isFormValid: Bool {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        let nameChanged = trimmed != product.name
        let priceChanged = rawHargaProduk != String(Int(product.price))
        let kategoriChanged = selectedKategori != originalKategori
        
        return !trimmed.isEmpty &&
               trimmed.count <= 20 &&
               Double(rawHargaProduk) != nil &&
               !showDuplicateWarning &&
               (nameChanged || priceChanged || kategoriChanged) &&
               selectedKategori != nil
    }

    func validate() {
        let trimmed = newName.trimmingCharacters(in: .whitespaces)
        showNameWarning = trimmed.count > 20
        showPriceWarning = Double(rawHargaProduk) == nil
        showDuplicateWarning = allKategoris
            .flatMap { $0.products }
            .contains { $0.name.lowercased() == trimmed.lowercased() && $0.id != product.id }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Kategori.self, Produk.self, configurations: config)
    
    let kategori1 = Kategori(name: "Makanan")
    let kategori2 = Kategori(name: "Minuman")
    let product = Produk(name: "Nasi Goreng", price: 15000)
    kategori1.products.append(product)
    
    return UbahProdukView(product: product)
        .modelContainer(container)
}
