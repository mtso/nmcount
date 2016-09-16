
import Foundation

var verbose = false
var printHighest = false
var pathArg: String?

for arg in CommandLine.arguments {
    if arg.replacingOccurrences(of: "/", with: "").hasSuffix(".nmdata") {
        pathArg = arg + "/"
    }
    if arg.characters.first == "-" {
        if arg.characters.contains("v") {
            verbose = true
        }
        if arg.characters.contains("h") {
            printHighest = true
        }
    }
}

guard let path = pathArg else {
    print("Please supply a path to the .nmdata")
    exit(EXIT_FAILURE)
}
if !path.replacingOccurrences(of: "/", with: "").hasSuffix(".nmdata") {
    print("Package type needs to be .nmdata")
    exit(EXIT_FAILURE)
}

let fileManager = FileManager.default
let currentWorkingDirectory = fileManager.currentDirectoryPath + "/"
let enumerator = fileManager.enumerator(atPath: path)

let dataPath = (path.hasPrefix("/Users")) ? path : currentWorkingDirectory + path

guard fileManager.fileExists(atPath: dataPath) else {
    print("\(path.substring(to: path.index(before: path.endIndex))) does not exist")
    exit(EXIT_FAILURE)
}

func padIntToString(_ number: Int, paddedBy padding: Int = 2) -> String {
    var string = String(number)
    while string.characters.count < padding {
        string = " " + string
    }
    return string
}


func totalCards(atPath cardDataPath: String) -> (total: Int, highest: Int)? {
    
    var highest = 0
    var total = 0
    
    guard let stream = StreamReader(path: cardDataPath) else { return nil }
    
    while !stream.atEof {
        
        guard let line = stream.nextLine() else { continue }
        
        let lineReplaced = line.replacingOccurrences(of: "\t", with: " ")
        let components = lineReplaced.components(separatedBy: " ")
        for component in components {
            
            guard component.range(of:"×") != nil else { continue }
            
            let integer = component.replacingOccurrences(of: "×", with: "")
            if let count = Int(integer) {
                total += count
                
                if count > highest {
                    highest = count
                }
            }
        }
    }
    
    return (total, highest)
}


var totalCommon = 0
var totalUncommon = 0
var totalRare = 0
var totalVeryRare = 0
var totalExtremelyRare = 0
var totalChase = 0
var totalVariant = 0


while let element = enumerator?.nextObject() as? String {
    if element.hasSuffix("txt") {
        guard let cardCount = totalCards(atPath: dataPath + element) else { continue }
        
        if verbose && printHighest {
            print("\(element) : \(cardCount.total) (\(cardCount.highest))")
        } else if printHighest {
            print("\(element) : (\(cardCount.highest))")
        } else if verbose {
            print("\(element) : \(cardCount.total)")
        }

        if element.hasPrefix(Rarity.common.rawValue) {
            totalCommon += cardCount.total
        } else if element.hasPrefix(Rarity.uncommon.rawValue) {
            totalUncommon += cardCount.total
        } else if element.hasPrefix(Rarity.rare.rawValue) {
            totalRare += cardCount.total
        } else if element.hasPrefix(Rarity.veryRare.rawValue) {
            totalVeryRare += cardCount.total
        } else if element.hasPrefix(Rarity.extremelyRare.rawValue) {
            totalExtremelyRare += cardCount.total
        } else if element.hasPrefix(Rarity.chase.rawValue) {
            totalChase += cardCount.total
        } else if element.hasPrefix(Rarity.variant.rawValue) {
            totalVariant += cardCount.total
        }
    }
}

if verbose || printHighest { print("") }
print("Common: \(totalCommon)")
print("Uncomm: \(totalUncommon)")
print("Rare  : \(totalRare)")
print("VeryRa: \(totalVeryRare)")
print("ExRare: \(totalExtremelyRare)")
print("Chase : \(totalChase)")
if totalVariant > 0 {
    print("Varian: \(totalVariant)")
}
print("TOTAL : \(totalCommon + totalUncommon + totalRare + totalVeryRare + totalExtremelyRare + totalChase + totalVariant)")
