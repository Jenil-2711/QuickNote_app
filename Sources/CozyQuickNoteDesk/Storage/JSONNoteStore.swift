import Foundation

protocol NoteStoring {
    func load() throws -> [Note]
    func save(_ notes: [Note]) throws
}

enum NoteStoreError: LocalizedError {
    case corrupted(movedTo: URL?)

    var errorDescription: String? {
        switch self {
        case .corrupted(let url):
            let place = url?.lastPathComponent ?? "a backup file"
            return "The notes file was damaged. It was set aside as \(place) and was not deleted."
        }
    }
}

/// Stores every note in one JSON file inside Application Support.
/// Writes are atomic (temp file, then swap) so a crash cannot leave a half-written file.
final class JSONNoteStore: NoteStoring {
    private struct FileFormat: Codable {
        var version: Int
        var notes: [Note]
    }

    let fileURL: URL

    static var defaultDirectory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("CozyQuickNoteDesk", isDirectory: true)
    }

    init(directory: URL = JSONNoteStore.defaultDirectory, fileName: String = "notes.json") {
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func load() throws -> [Note] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        do {
            return try makeDecoder().decode(FileFormat.self, from: data).notes
        } catch {
            throw NoteStoreError.corrupted(movedTo: setAsideDamagedFile())
        }
    }

    func save(_ notes: [Note]) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let data = try makeEncoder().encode(FileFormat(version: 1, notes: notes))
        try data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Helpers

    private func setAsideDamagedFile() -> URL? {
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let target = fileURL.deletingLastPathComponent().appendingPathComponent("notes.damaged-\(stamp).json")
        do {
            try FileManager.default.moveItem(at: fileURL, to: target)
            return target
        } catch {
            return nil
        }
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
