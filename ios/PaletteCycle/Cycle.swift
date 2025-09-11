import Foundation

let precision: Float = 100.0
let precisionInt: Int = 100
let PI: Float = 3.141592653589793

struct Cycle: Codable {
    let rate: Int
    private let reverse: Int
    let low: Int
    let high: Int
    
    private let cycleSpeed: Float = 280.0
    
    private var size: Int {
        return high - low + 1
    }
    
    private var adjustedRate: Float {
        return Float(rate) / cycleSpeed
    }
    
    private func dFloatMod(_ a: Float, _ b: Int) -> Float {
        return (floor(a * precision).truncatingRemainder(dividingBy: floor(Float(b) * precision))) / precision
    }
    
    func reverseColorsIfNecessary(_ colors: inout [UInt32]) {
        if reverse == 2 {
            for i in 0..<(size/2) {
                let lowValue = colors[low + i]
                let highValue = colors[high - i]
                colors[low + i] = highValue
                colors[high - i] = lowValue
            }
        }
    }
    
    func getCycleAmount(_ timePassed: Int) -> Float {
        var cycleAmount: Float = 0.0
        
        if reverse < 3 {
            // standard cycle
            cycleAmount = dFloatMod(Float(timePassed) / (1000.0 / adjustedRate), size)
        } else if reverse == 3 {
            // ping pong
            cycleAmount = dFloatMod(Float(timePassed) / (1000.0 / adjustedRate), size * 2)
            if cycleAmount >= Float(size) {
                cycleAmount = Float(size * 2) - cycleAmount
            }
        } else if reverse < 6 {
            // sine wave
            cycleAmount = dFloatMod(Float(timePassed) / (1000.0 / adjustedRate), size)
            cycleAmount = (sin(cycleAmount * PI * 2.0 / Float(size)) + 1.0)
            if reverse == 4 {
                cycleAmount *= Float(size) / 4.0
            } else if reverse == 5 {
                cycleAmount *= Float(size) / 2.0
            }
        }
        
        return cycleAmount
    }
}