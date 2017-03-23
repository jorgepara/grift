
import Foundation
import SourceKittenFramework

func filesInDirectory(at path: String, using fileManager: FileManager = .default) -> [String] {
    let contents = try! fileManager.contentsOfDirectory(atPath: path)

    return contents.flatMap({ (filename: String) -> String? in
        guard filename.hasSuffix(".swift") else {
            return nil
        }

        return (path as NSString).appendingPathComponent(filename)

    })
}

public func structures(at path: String, using fileManager: FileManager = .default) -> [Structure] {

    let filePaths = filesInDirectory(at: path, using: fileManager)

    return filePaths.flatMap({ structure(forFile: $0) })
}

func structures(for code: String) -> [Structure] {
    return [Structure(file: File(contents: code))]
}

public func structure(forFile path: String) -> Structure? {
    guard let file = File(path: path) else {
        return nil
    }
    return Structure(file: file)
}

//private protocol StringType {}
//extension String: StringType {}

extension Dictionary {
    subscript (keyEnum: SwiftDocKey) -> Value? {
        guard let key = keyEnum.rawValue as? Key else {
            return nil
        }
        return self[key]
    }
}

extension Graphviz {
    init(structures: [Structure]) {
        self.init(type: .directed, statements: structures.flatMap({ createStatements(dict: $0.dictionary) }))
    }
}

private func createStatements(dict: [String: SourceKitRepresentable], name: String = "") -> [Statement] {

    var statements: [Statement] = []
    var name = name

    if let typeName = dict[.typeName] as? String, !name.isEmpty {
        statements.append(Node(name) >> Node(typeName))
    }

    if let newName = dict[.name] as? String, kindIsEnclosingType(kind: dict[.kind]) {
        name = newName
    }

    if let substructures = dict[.substructure] as? [SourceKitRepresentable] {
        for substructure in substructures {
            if let substructureDict = substructure as? [String: SourceKitRepresentable] {
                statements.append(contentsOf: createStatements(dict: substructureDict, name: name))
            }
        }
    }

    return statements
}

private func kindIsEnclosingType(kind: SourceKitRepresentable?) -> Bool {
    guard let kind = kind as? String,
        let declarationKind = SwiftDeclarationKind(rawValue: kind) else {
        return false
    }

    switch declarationKind {
    case .`struct`, .`class`, .`enum`, .`protocol`:
        return true
    default:
        return false
    }
}