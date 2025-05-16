//
//  TambahKategoriView.swift
//  SakoKelolaProduk
//
//  Created by Callista on 10/05/25.
//

import SwiftUI
import SwiftData

struct TambahKategoriView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @Binding var isPresented: Bool
    @Query private var kategoris: [Kategori]
    
    @State private var namaKategori: String = ""
    @State private var showCharacterLimitWarning = false
    @State private var showSymbolWarning = false
    @State private var showDuplicateWarning = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nama Kategori")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Contoh: Menu Favorit", text: $namaKategori)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal)
                .padding(.top)
                
                if showCharacterLimitWarning || showSymbolWarning || showDuplicateWarning {
                    VStack(alignment: .leading, spacing: 4) {
                        if showCharacterLimitWarning {
                            Text("Nama kategori maksimal 20 karakter.")
                        }
                        if showSymbolWarning {
                            Text("Gunakan hanya huruf atau angka.")
                        }
                        if showDuplicateWarning {
                            Text("Nama kategori sudah digunakan atau tidak diperbolehkan.")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                Spacer()
                
                Button(action: {
                    let trimmed = namaKategori.trimmingCharacters(in: .whitespaces)
                    if isValid(nama: trimmed) {
                        let newKategori = Kategori(name: trimmed)
                        modelContext.insert(newKategori)
                        isPresented = false
                    }
                }) {
                    Text("Simpan")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isValid(nama: namaKategori) ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(!isValid(nama: namaKategori))
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Tambah Kategori")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Batal")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .onChange(of: namaKategori) { newValue in
                validateInput(newValue)
            }
        }
    }

    func validateInput(_ input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        showCharacterLimitWarning = trimmed.count > 20
        showSymbolWarning = trimmed.range(of: "[^a-zA-Z0-9\\s]", options: .regularExpression) != nil
        showDuplicateWarning = kategoris.contains(where: {
            $0.name.lowercased() == trimmed.lowercased()
        }) || trimmed.lowercased() == "semua produk"
    }

    func isValid(nama: String) -> Bool {
        let trimmed = nama.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty &&
               trimmed.count <= 20 &&
               trimmed.range(of: "[^a-zA-Z0-9\\s]", options: .regularExpression) == nil &&
               !kategoris.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) &&
               trimmed.lowercased() != "semua produk"
    }
}
