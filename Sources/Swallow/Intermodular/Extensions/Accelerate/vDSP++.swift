//
// Copyright (c) Vatsal Manot
//

import Accelerate
import Foundation

extension vDSP {
    @inlinable
    public static func euclideanDistance<U: AccelerateMutableBuffer>(
        lhs: U,
        rhs: U
    ) -> Double where U.Element == Double {
        vDSP.distanceSquared(lhs, rhs).squareRoot()
    }
    
    @inlinable
    public static func euclideanDistance<U: AccelerateMutableBuffer>(
        lhs: U,
        rhs: U
    ) -> Float where U.Element == Float {
        vDSP.distanceSquared(lhs, rhs).squareRoot()
    }
    
    @inlinable
    public static func cosineSimilarity<U: AccelerateBuffer>(
        lhs: U,
        rhs: U
    ) -> Double where U.Element == Double {
        let dotProduct = vDSP.dot(lhs, rhs)
        
        let lhsMagnitude = vDSP.sumOfSquares(lhs).squareRoot()
        let rhsMagnitude = vDSP.sumOfSquares(rhs).squareRoot()
        
        return dotProduct / (lhsMagnitude * rhsMagnitude)
    }
    
    @inlinable
    public static func cosineSimilarity<U: AccelerateBuffer>(
        lhs: U,
        rhs: U
    ) -> Float where U.Element == Float {
        let dotProduct = vDSP.dot(lhs, rhs)
        
        let lhsMagnitude = vDSP.sumOfSquares(lhs).squareRoot()
        let rhsMagnitude = vDSP.sumOfSquares(rhs).squareRoot()
        
        return dotProduct / (lhsMagnitude * rhsMagnitude)
    }
    
    /// Returns the standard deviation of the supplied single-precision vector.
    ///
    /// - Parameter vector: The input vector.
    @inlinable
    public static func standardDeviation<U: AccelerateBuffer>(
        _ vector: U
    ) -> U.Element where U.Element == Double {
        let mean = vDSP.mean(vector)
        let meanVector = [U.Element](repeating: mean, count: vector.count)
        
        var deviations = [U.Element](repeating: 0, count: vector.count)
        vDSP.subtract(vector, meanVector, result: &deviations)
        var squaredDeviations = [U.Element](repeating: 0, count: vector.count)
        vDSP.square(deviations, result: &squaredDeviations)
        
        let variance = vDSP.mean(squaredDeviations)
        let standardDeviation = variance.squareRoot()
        
        return standardDeviation
    }
    
}

extension vDSP {
    @inlinable
    public static func normalize(
        _ data: [[Double]]
    ) -> [[Double]] {
        let rowCount = data.count
        let columnCount = data[0].count
        
        var flattenedData = data.flatMap { $0 }
        
        for j in 0..<columnCount {
            let startIndex = j
            let stride = columnCount
            
            var mean = 0.0
            var stdDev = 0.0
            
            vDSP_normalizeD(
                flattenedData.withUnsafeBufferPointer { $0.baseAddress! + startIndex },
                stride,
                &flattenedData[startIndex],
                stride,
                &mean,
                &stdDev,
                vDSP_Length(rowCount)
            )
        }
        
        return stride(from: 0, to: flattenedData.count, by: columnCount).map {
            Array(flattenedData[$0..<$0 + columnCount])
        }
    }

    public static func normalize(
        _ vector: [Double],
        rowCount: Int,
        columnCount: Int
    ) -> [Double] {
        var normalizedVector = [Double](repeating: 0.0, count: vector.count)
        
        for i in 0..<columnCount {
            let start = i * rowCount
            let end = start + rowCount
            let subVector = Array(vector[start..<end])
            
            let mean = vDSP.mean(subVector)
            var centeredSubVector = [Double](repeating: 0.0, count: rowCount)
            vDSP.subtract(subVector, [Double](repeating: mean, count: rowCount), result: &centeredSubVector)
            
            let squaredSubVector = vDSP.square(centeredSubVector)
            let variance = vDSP.mean(squaredSubVector)
            let standardDeviation = sqrt(variance)
            
            vDSP.divide(centeredSubVector, [Double](repeating: standardDeviation, count: rowCount), result: &normalizedVector[start..<end])
        }
        
        return normalizedVector
    }
    
    public static func transpose(
        _ matrix: [Double],
        rowCount: Int,
        columnCount: Int
    ) -> [Double] {
        var result = [Double](repeating: 0.0, count: matrix.count)
        
        vDSP_mtransD(matrix, 1, &result, 1, vDSP_Length(columnCount), vDSP_Length(rowCount))
        
        return result
    }
}

extension vDSP {
    public static func mmul(
        _ matrixA: [Double],
        matrixB: [Double],
        rowCount: Int,
        columnCount: Int,
        commonDimension: Int
    ) -> [Double] {
        var result = [Double](repeating: 0.0, count: rowCount * columnCount)
        cblas_dgemm(
            CblasColMajor,
            CblasNoTrans,
            CblasNoTrans,
            Int32(rowCount),
            Int32(columnCount),
            Int32(commonDimension),
            1.0,
            matrixA,
            Int32(rowCount),
            matrixB,
            Int32(commonDimension),
            0.0,
            &result,
            Int32(rowCount)
        )
        
        return result
    }
    
    // Multiplies each element of the vector by the scalar, storing the result in a new vector
    public static func vsmul(
        _ vector: [Double],
        scalar: Double
    ) -> [Double] {
        // Resulting vector after multiplication
        var result = [Double](repeating: 0.0, count: vector.count)
        
        // Unsafe buffer pointers for vector and result to use with vDSP_vsmulD
        vector.withUnsafeBufferPointer { vectorBuffer in
            result.withUnsafeMutableBufferPointer { resultBuffer in
                vDSP_vsmulD(
                    vectorBuffer.baseAddress!, // Pointer to the first element of the vector
                    1, // Stride within the vector (use every element)
                    [scalar], // Scalar value to multiply with
                    resultBuffer.baseAddress!, // Pointer to the first element of result
                    1, // Stride within result (use every element)
                    vDSP_Length(vector.count) // Number of elements in the vector
                )
            }
        }
        
        return result
    }
}

extension vDSP {
    fileprivate enum EigenDecompositionError: Error {
        case computationFailed(resultCode: Int32)
        case invalidMatrixOrder
        case complexEigenvaluesDetected
        case invalidMatrixLayout
    }
    
    public struct EigenDecomposition {
        public let eigenvalues: [Double]
        public let eigenvectors: [[Double]]
    }
    
    public static func eigenDecomposition(
        of matrix: [Double]
    ) throws -> EigenDecomposition {
        let order = Int(sqrt(Double(matrix.count)))
        
        var N = __CLPK_integer(order)
        var A = matrix
        var realEigenvalues = [Double](repeating: 0.0, count: order)
        var imaginaryEigenvalues = [Double](repeating: 0.0, count: order)
        var leftEigenvectors = [Double](repeating: 0.0, count: order * order)
        var rightEigenvectors = [Double](repeating: 0.0, count: order * order)
        var workspaceQuery = 0.0
        var workspaceSize = __CLPK_integer(-1)
        var error = __CLPK_integer(0)
        
        let jobvl = UnsafeMutablePointer<CChar>(mutating: ("N" as NSString).utf8String)
        let jobvr = UnsafeMutablePointer<CChar>(mutating: ("V" as NSString).utf8String)
        
        var lda = N
        var ldvl = N
        var ldvr = N
        dgeev_(jobvl, jobvr, &N, &A, &lda, &realEigenvalues, &imaginaryEigenvalues, &leftEigenvectors, &ldvl, &rightEigenvectors, &ldvr, &workspaceQuery, &workspaceSize, &error)
        
        if error != 0 {
            throw EigenDecompositionError.computationFailed(resultCode: error)
        }
        
        workspaceSize = __CLPK_integer(workspaceQuery)
        var workspace = [Double](repeating: 0.0, count: Int(workspaceSize))
        
        dgeev_(jobvl, jobvr, &N, &A, &lda, &realEigenvalues, &imaginaryEigenvalues, &leftEigenvectors, &ldvl, &rightEigenvectors, &ldvr, &workspace, &workspaceSize, &error)
        
        if error != 0 {
            throw EigenDecompositionError.computationFailed(resultCode: error)
        }
        
        let eigenvectors = stride(from: 0, to: rightEigenvectors.count, by: order).map { Array(rightEigenvectors[$0..<$0 + order]) }
        
        return EigenDecomposition(
            eigenvalues: realEigenvalues,
            eigenvectors: eigenvectors
        )
    }
    
    public enum _EigenDecompositionTargetMatrixLayout {
        case rowMajor
        case columnMajor
    }

    static func eigenDecomposition(
        matrix: [Double],
        order: Int,
        layout: _EigenDecompositionTargetMatrixLayout
    ) throws -> (eigenvalues: [Double], eigenvectors: [Double]) {
        func _transpose(
            _ matrix: [Double],
            rows: Int,
            columns: Int
        ) throws -> [Double] {
            guard matrix.count == rows * columns else {
                throw EigenDecompositionError.invalidMatrixLayout
            }
            
            var transposedMatrix = [Double](repeating: 0.0, count: rows * columns)
            
            for i in 0..<rows {
                for j in 0..<columns {
                    transposedMatrix[j * rows + i] = matrix[i * columns + j]
                }
            }
            
            return transposedMatrix
        }
        
        guard order > 0 else {
            throw EigenDecompositionError.invalidMatrixOrder
        }
        
        var jobvl: Int8 = Int8(Unicode.Scalar("N").value) // 'N' for no left eigenvectors
        var jobvr: Int8 = Int8(Unicode.Scalar("V").value) // 'V' for computing right eigenvectors
        var n: __CLPK_integer = __CLPK_integer(order)
        var lda: __CLPK_integer = n
        var matrix = matrix
        
        // Transpose the matrix if it is in row-major order
        if layout == .rowMajor {
            matrix = try _transpose(matrix, rows: Int(n), columns: Int(n))
        }
        
        var wr: [Double] = [Double](repeating: 0.0, count: Int(n))
        var wi: [Double] = [Double](repeating: 0.0, count: Int(n))
        var vl: [Double] = [Double](repeating: 0.0, count: Int(n * n))
        var ldvl: __CLPK_integer = n
        var vr: [Double] = [Double](repeating: 0.0, count: Int(n * n))
        var ldvr: __CLPK_integer = n
        var lwork: __CLPK_integer = __CLPK_integer(max(1, 4 * n)) // Increase the workspace size
        var work: [Double] = [Double](repeating: 0.0, count: Int(lwork))
        var info: __CLPK_integer = 0
        
        _ = withUnsafeMutablePointer(to: &jobvl) { jobvlPtr in
            withUnsafeMutablePointer(to: &jobvr) { jobvrPtr in
                withUnsafeMutablePointer(to: &n) { nPtr in
                    withUnsafeMutablePointer(to: &lda) { ldaPtr in
                        withUnsafeMutablePointer(to: &ldvl) { ldvlPtr in
                            withUnsafeMutablePointer(to: &ldvr) { ldvrPtr in
                                withUnsafeMutablePointer(to: &lwork) { lworkPtr in
                                    withUnsafeMutablePointer(to: &info) { infoPtr in
                                        matrix.withUnsafeMutableBufferPointer { matrixBuffer in
                                            wr.withUnsafeMutableBufferPointer { wrBuffer in
                                                wi.withUnsafeMutableBufferPointer { wiBuffer in
                                                    vl.withUnsafeMutableBufferPointer { vlBuffer in
                                                        vr.withUnsafeMutableBufferPointer { vrBuffer in
                                                            work.withUnsafeMutableBufferPointer { workBuffer in
                                                                return dgeev_(jobvlPtr, jobvrPtr, nPtr, matrixBuffer.baseAddress, ldaPtr, wrBuffer.baseAddress, wiBuffer.baseAddress, vlBuffer.baseAddress, ldvlPtr, vrBuffer.baseAddress, ldvrPtr, workBuffer.baseAddress, lworkPtr, infoPtr)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        guard info == 0 else {
            throw EigenDecompositionError.computationFailed(resultCode: Int32(info))
        }
        
        // Check for complex eigenvalues
        for i in 0..<Int(n) {
            if wi[i] != 0.0 {
                throw EigenDecompositionError.complexEigenvaluesDetected
            }
        }
        
        return (eigenvalues: wr, eigenvectors: vr)
    }
}
