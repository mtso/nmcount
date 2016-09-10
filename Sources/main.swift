
import Foundation

//let dataPath = "/Users/matthewtso/git/swift/card-counter/data-avatars"
//
//
//let fileManager = FileManager.default
//let enumerator = fileManager.enumerator(atPath: dataPath)


func totalCards(atPath cardDataPath: String) -> Int? {
    
    var total = 0
    
    let basePath = "/Users/matthewtso/git/swift/card-counter"
    
    guard let stream = StreamReader(path: basePath + cardDataPath) else { return nil }
    // "/160909-drak-the-unfathomable.txt")!
    
    /*
     // Primadonna Format:
     while(!stream.atEof) {
     guard let line = stream.nextLine() else { continue }
     for component in line.components(separatedBy: " ")
                          .filter({ $0.range(of: "×") != nil }) {
         total += Int(component.replacingOccurrences(of: "×", with: ""))!
         }
     }
     */
    
    while(!stream.atEof) {
        
        guard let line = stream.nextLine() else { continue }
        
        let components = line.components(separatedBy: " ")
        for component in components {
            
            guard component.range(of:"×") != nil else { continue }
            
            let integer = component.replacingOccurrences(of: "×", with: "")
            if let count = Int(integer) {
                total += count
            }
        }
    }
    
    return total
}

print(totalCards(atPath: "/160909-drak-the-unfathomable.txt")!)
