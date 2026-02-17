import SwiftUI

struct ContentView: View {
    @State private var showingAddEntry = false
    @State private var showingExport = false

    var body: some View {
        NavigationStack {
            LogView()
                .navigationTitle("Skills")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingExport = true
                        } label: {
                            Image(systemName: "arrow.up.doc")
                                .fontWeight(.medium)
                        }
                        .tint(.primary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddEntry = true
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                        .tint(.primary)
                    }
                }
                .sheet(isPresented: $showingAddEntry) {
                    AddEntryView()
                }
                .sheet(isPresented: $showingExport) {
                    ExportView()
                }
        }
    }
}
