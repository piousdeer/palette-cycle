import Foundation
import UIKit

class Palette {
    let id: String
    private let baseColors: [UInt32]
    private var colors: [UInt32]
    let cycles: [Cycle]
    
    init(id: String = "", colors: [UInt32], cycles: [Cycle]) {
        self.id = id
        self.baseColors = colors
        self.colors = colors
        self.cycles = cycles
    }
    
    convenience init(id: String = "", paletteJson: PaletteJson) {
        self.init(id: id, colors: paletteJson.parsedColors, cycles: paletteJson.cycles)
    }
    
    func blendPalette(previous: Palette, next: Palette, percent: Int) -> Palette {
        var mixedColors = baseColors
        for i in 0..<baseColors.count {
            mixedColors[i] = fadeColors(previous.baseColors[i], next.baseColors[i], percent)
        }
        return Palette(colors: mixedColors, cycles: self.cycles)
    }
    
    func cycle(timePassed: Int) {
        // it's important we copy the base values as each time we cycle it 'starts from 0'; it's not additive
        colors = baseColors
        
        for cycle in cycles {
            if cycle.rate == 0 {
                continue // Similar to break in a conventional loop
            }
            cycle.reverseColorsIfNecessary(&colors)
            let amount = cycle.getCycleAmount(timePassed)
            blendShiftColors(&colors, cycle: cycle, amount: amount)
            cycle.reverseColorsIfNecessary(&colors)
        }
    }
    
    func shiftColors(_ colors: inout [UInt32], cycle: Cycle, amount: Float) {
        let intAmount = Int(amount)
        for _ in 0..<intAmount {
            let temp = colors[cycle.high]
            for j in stride(from: cycle.high - 1, through: cycle.low, by: -1) {
                colors[j + 1] = colors[j]
            }
            colors[cycle.low] = temp
        }
    }
    
    // BlendShift Technology conceived, designed and coded by Joseph Huckaby
    func blendShiftColors(_ colors: inout [UInt32], cycle: Cycle, amount: Float) {
        if amount == 0.0 { return }
        
        let size = cycle.high - cycle.low + 1
        let intAmount = Int(amount)
        let floatAmount = amount - Float(intAmount)
        
        if floatAmount > 0.0 {
            let color1Index = (cycle.low + intAmount) % size + cycle.low
            let color2Index = (cycle.low + intAmount + 1) % size + cycle.low
            let floatPercent = Int(floatAmount * Float(precisionInt))
            
            colors[color1Index] = fadeColors(colors[color1Index], colors[color2Index], floatPercent)
        }
        
        shiftColors(&colors, cycle: cycle, amount: amount)
    }
    
    private func fadeColors(_ source: UInt32, _ dest: UInt32, _ amount: Int) -> UInt32 {
        let red = blendColor(Int((source >> 16) & 0xFF), Int((dest >> 16) & 0xFF), amount)
        let green = blendColor(Int((source >> 8) & 0xFF), Int((dest >> 8) & 0xFF), amount)
        let blue = blendColor(Int(source & 0xFF), Int(dest & 0xFF), amount)
        
        return UInt32((red << 16) | (green << 8) | blue)
    }
    
    private func blendColor(_ source: Int, _ dest: Int, _ amount: Int) -> Int {
        return source + (((dest - source) * amount) / precisionInt)
    }
    
    func getColors() -> [UInt32] {
        return colors
    }
}