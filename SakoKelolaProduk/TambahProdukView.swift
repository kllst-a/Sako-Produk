//
//  TambahProdukView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct TambahProdukView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    var kategori: Kategori
    
    @Query private var availableKategoris: [Kategori]
    
    @State private var namaProduk: String = ""
    @State private var rawHargaProduk: String = ""
    @State private var selectedKategori: Kategori?

    @State private var showCharacterLimitWarning = false
    @State private var showSymbolWarning = false
    @State private var showDuplicateWarning = false
    @State private var showHargaWarning = false

    private var hargaProdukBinding: Binding<String> {
        Binding(
            get: {
                formatInputHarga(rawHargaProduk)
            },
            set: { newValue in
                rawHargaProduk = newValue.filter { "0123456789".contains($0) }
                showHargaWarning = newValue.range(of: "[^0-9]", options: .regularExpression) != nil
            }
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nama Produk")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Contoh: Nasi Goreng", text: $namaProduk)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .disableAutocorrection(true)
                            if showCharacterLimitWarning {
                                Text("Nama produk maksimal 20 karakter")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            if showSymbolWarning {
                                Text("Gunakan hanya huruf atau angka")
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

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Harga Produk (Rp)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("Contoh: 10.000", text: hargaProdukBinding)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            if showHargaWarning {
                                Text("Harga harus berupa angka")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kategori Produk")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Menu {
                                Picker("Pilih Kategori", selection: $selectedKategori) {
                                    ForEach(availableKategoris.filter { $0.name != "Semua Produk" }) {
                                        Text($0.name).tag($0 as Kategori?)
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
                        }
                        .padding(.horizontal)
                        Spacer().frame(height: 100)
                    }
                }

                VStack {
                    Button(action: {
                        let trimmedName = namaProduk.trimmingCharacters(in: .whitespaces)
                        let newProduct = Produk(name: trimmedName, price: Double(rawHargaProduk) ?? 0)
                        
                        if let selectedKategori = selectedKategori {
                            selectedKategori.products.append(newProduct)
                        } else if kategori.name != "Semua Produk" {
                            kategori.products.append(newProduct)
                        }
                        
                        if let semuaProduk = availableKategoris.first(where: { $0.name == "Semua Produk" }) {
                            semuaProduk.products.append(newProduct)
                        }
                        
                        dismiss()
                    }) {
                        Text("Simpan")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.green : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Tambah Produk")
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
            .onChange(of: namaProduk) { _ in validateInput() }
            .onChange(of: rawHargaProduk) { _ in validateInput() }
            .onAppear {
                if kategori.name != "Semua Produk" {
                    selectedKategori = kategori
                }
            }
        }
    }

    var isFormValid: Bool {
        let trimmed = namaProduk.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty &&
               trimmed.count <= 20 &&
               !showCharacterLimitWarning &&
               !showSymbolWarning &&
               !showDuplicateWarning &&
               !showHargaWarning &&
               !rawHargaProduk.isEmpty
    }

    func validateInput() {
        let trimmed = namaProduk.trimmingCharacters(in: .whitespaces)
        showCharacterLimitWarning = trimmed.count > 20
        showSymbolWarning = trimmed.range(of: "[^a-zA-Z0-9\\s]", options: .regularExpression) != nil
        showDuplicateWarning = availableKategoris.contains { kategori in
            kategori.products.contains { $0.name.lowercased() == trimmed.lowercased() }
        }
        showHargaWarning = rawHargaProduk.isEmpty || Double(rawHargaProduk) == nil
    }
}
