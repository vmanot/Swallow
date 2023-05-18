//
// Copyright (c) Vatsal Manot
//

import Swift

public class Slice {
    var start: Int? = nil
    var stop: Int?
    var step: Int? = nil
    
    public func indices(_ length: Int) -> (Int, Int, Int) {
        let (a, b, c, _) = self.adjustIndex(length)
        return (a, b, c)
    }
    
    public init(stop: Int?) {
        self.stop = stop
    }
    
    public init(start: Int?, stop: Int?, step: Int? = nil) {
        self.start = start
        self.stop = stop
        self.step = step
    }
    
    func adjustIndex(_ length: Int) -> (Int, Int, Int, Int) {
        let step: Int = (self.step == 0) ? 1 : self.step ?? 1
        var start: Int = 0
        var stop: Int = 0
        var upper: Int = 0
        var lower: Int = 0
        
        // Convert step to an integer; raise for zero step.
        let step_sign: Int = step.signum()
        let step_is_negative: Bool = step_sign < 0
        
        /* Find lower and upper bounds for start and stop. */
        if (step_is_negative) {
            lower = -1
            upper = length + lower
        }
        else {
            lower = 0
            upper = length
        }
        
        // Compute start.
        if let s = self.start {
            start = s
            
            if (start.signum() < 0) {
                start += length
                
                if (start < lower /* Py_LT */) {
                    start = lower
                }
            }
            else {
                if (start > upper /* Py_GT */) {
                    start = upper
                }
            }
        }
        else {
            start = step_is_negative ? upper : lower
        }
        
        // Compute stop.
        if let s = self.stop {
            stop = s
            
            if (stop.signum() < 0) {
                stop += length
                if (stop < lower /* Py_LT */) {
                    stop = lower
                }
            }
            else {
                if (stop > upper /* Py_GT */) {
                    stop = upper
                }
            }
        }
        else {
            stop = step_is_negative ? lower : upper
        }
        var len = 0
        if (step < 0) {
            if (stop < start) {
                len = (start - stop - 1) / (-step) + 1
            }
        }
        else {
            if (start < stop) {
                len = (stop - start - 1) / step + 1
            }
        }
        return (start, stop, step, len)
    }
}
