import UIKit

var greeting = "Hello, playground"

let b = "33..44"

let r = b.components(separatedBy: "..").compactMap{Int($0)}

let v = r[0] < r[1]
