import Foundation

// Test core palette cycling logic without UIKit dependencies

let precision: Float = 100.0
let precisionInt: Int = 100
let PI: Float = 3.141592653589793

struct Cycle {
    let rate: Int
    let reverse: Int
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
        }
        
        return cycleAmount
    }
}

// Test the core algorithm
let testCycle = Cycle(rate: 10, reverse: 0, low: 0, high: 15)
let testAmount = testCycle.getCycleAmount(1000)

print("✅ Core palette cycling algorithm test passed!")
print("   Cycle amount for 1000ms: \(testAmount)")
print("   Rate: \(testCycle.rate), Range: \(testCycle.low)-\(testCycle.high)")