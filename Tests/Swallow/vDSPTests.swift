//
// Copyright (c) Vatsal Manot
//

import Accelerate
import XCTest
import Swallow

import XCTest
import Accelerate

class vDSPExtensionsTests: XCTestCase {
    
    func testEuclideanDistance() {
        let lhs: [Double] = [1.0, 2.0, 3.0]
        let rhs: [Double] = [4.0, 5.0, 6.0]
        
        let expectedDistance = sqrt(27.0)
        let distance = vDSP.euclideanDistance(lhs: lhs, rhs: rhs)
        
        XCTAssertEqual(distance, expectedDistance, accuracy: 1e-6)
    }
    
    func testCosineSimilarity() {
        let lhs: [Float] = [1.0, 2.0, 3.0]
        let rhs: [Float] = [4.0, 5.0, 6.0]
        
        let expectedSimilarity: Float = 0.9746318
        let similarity = vDSP.cosineSimilarity(lhs: lhs, rhs: rhs)
        
        XCTAssertEqual(similarity, expectedSimilarity, accuracy: 1e-6)
    }
    
    func testNormalize() {
        let vector: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        let rowCount = 3
        let columnCount = 2
        
        let expectedNormalizedVector: [Double] = [-1.2247448713915892, 0.0, 1.2247448713915892, -1.2247448713915892, 0.0, 1.2247448713915892]
        let normalizedVector = vDSP.normalize(vector, rowCount: rowCount, columnCount: columnCount)
        
        XCTAssertEqual(normalizedVector.count, expectedNormalizedVector.count)
        for (index, value) in normalizedVector.enumerated() {
            XCTAssertEqual(value, expectedNormalizedVector[index], accuracy: 1e-6)
        }
    }
    
    func testTranspose() {
        let matrix: [Double] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
        let rowCount = 2
        let columnCount = 3
        
        let expectedTransposedMatrix: [Double] = [1.0, 4.0, 2.0, 5.0, 3.0, 6.0]
        let transposedMatrix = vDSP.transpose(matrix, rowCount: rowCount, columnCount: columnCount)
        
        XCTAssertEqual(transposedMatrix, expectedTransposedMatrix)
    }
        
    func testVsmul() {
        let vector: [Double] = [1.0, 2.0, 3.0]
        let scalar: Double = 2.0
        
        let expectedResult: [Double] = [2.0, 4.0, 6.0]
        let result = vDSP.vsmul(vector, scalar: scalar)
        
        XCTAssertEqual(result, expectedResult)
    }
}

/*class EigenDecompositionTests: XCTestCase {
    
    func testEigenDecomposition() {
        // Define the test matrix
        let matrix: [Double] = [
            4.0, 1.0,
            -2.0, 1.0
        ]
        let order = 2
        let layout: vDSP._EigenDecompositionTargetMatrixLayout = .rowMajor
        
        // Define the expected eigenvalues and eigenvectors
        let expectedEigenvalues = [3.0, 2.0]
        let expectedEigenvectors = [
            [0.7071, -0.7071], // normalized eigenvector corresponding to eigenvalue 3
            [-0.4472, 0.8944]  // normalized eigenvector corresponding to eigenvalue 2
        ]
        
        do {
            let (eigenvalues, eigenvectors) = try vDSP.eigenDecomposition(matrix: matrix, order: order, layout: layout)
            
            // Reshape computed eigenvectors to 2D array
            let reshapedEigenvectors = reshape(eigenvectors, order: order)
            
            // Debugging: print eigenvalues and eigenvectors
            print("Computed eigenvalues: \(eigenvalues)")
            print("Computed eigenvectors: \(reshapedEigenvectors)")
            
            // Sort the eigenvalues and eigenvectors for comparison
            let sortedExpected = sortEigenPairs(values: expectedEigenvalues, vectors: expectedEigenvectors)
            let sortedComputed = sortEigenPairs(values: eigenvalues, vectors: reshapedEigenvectors)
            
            // Debugging: print sorted eigenvalues and eigenvectors
            print("Sorted expected eigenvalues: \(sortedExpected.values)")
            print("Sorted expected eigenvectors: \(sortedExpected.vectors)")
            print("Sorted computed eigenvalues: \(sortedComputed.values)")
            print("Sorted computed eigenvectors: \(sortedComputed.vectors)")
            
            // Verify eigenvalues
            verifyEigenvalues(computed: sortedComputed.values, expected: sortedExpected.values)
            
            // Verify eigenvectors
            verifyEigenvectors(computed: sortedComputed.vectors, expected: sortedExpected.vectors)
            
        } catch {
            XCTFail("Eigen decomposition failed with error: \(error)")
        }
    }

    // Helper function to sort eigenvalues and their corresponding eigenvectors
    private func sortEigenPairs(values: [Double], vectors: [[Double]]) -> (values: [Double], vectors: [[Double]]) {
        // Create pairs of eigenvalues and their corresponding eigenvectors
        var pairs = [(value: Double, vector: [Double])]()
        for i in 0..<values.count {
            pairs.append((value: values[i], vector: vectors[i]))
        }
        
        // Sort pairs by eigenvalues
        pairs.sort { $0.value < $1.value }
        
        // Extract sorted eigenvalues and eigenvectors
        let sortedValues = pairs.map { $0.value }
        let sortedVectors = pairs.map { $0.vector }
        
        return (sortedValues, sortedVectors)
    }
    
    // Helper function to reshape flat eigenvector array into 2D array
    private func reshape(_ vectors: [Double], order: Int) -> [[Double]] {
        var reshaped = [[Double]]()
        for i in 0..<order {
            let vector = Array(vectors[i*order..<(i+1)*order])
            reshaped.append(vector)
        }
        return reshaped
    }
    
    // Helper function to verify eigenvalues
    private func verifyEigenvalues(computed: [Double], expected: [Double]) {
        for (computedValue, expectedValue) in zip(computed, expected) {
            XCTAssertEqual(computedValue, expectedValue, accuracy: 1e-4, "Eigenvalue \(computedValue) is not close to the expected \(expectedValue)")
        }
    }
    
    // Helper function to verify eigenvectors
    private func verifyEigenvectors(computed: [[Double]], expected: [[Double]]) {
        for i in 0..<expected.count {
            for j in 0..<expected[i].count {
                let expectedValue = expected[i][j]
                let computedPositive = computed[i][j]
                let computedNegative = -computed[i][j]
                XCTAssertTrue(abs(computedPositive - expectedValue) < 1e-4 || abs(computedNegative - expectedValue) < 1e-4,
                              "Eigenvector element \(computedPositive) or \(computedNegative) is not close to the expected \(expectedValue)")
            }
        }
    }
}
*/
