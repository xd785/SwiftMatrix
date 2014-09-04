//
//  Matrix.swift
//  SwiftMatrixExample
//
//  Created by Daniel Pink on 30/08/2014.
//  Copyright (c) 2014 Electronic Innovations. All rights reserved.
//

import Foundation
import Accelerate

// Lets just worry about 2 dimensional float matrices

public protocol SummableMultipliable: Equatable {
    func +(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
}

extension Int: SummableMultipliable {}
extension Float: SummableMultipliable {}
extension Double: SummableMultipliable {}

public struct Matrix: Equatable {
    var grid: [Double]
    let rows: Int
    let cols: Int
    public var size: (rows: Int, cols: Int) {
        get {
            return (rows, cols)
        }
    }
    
    public init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        grid = Array(count: rows * cols, repeatedValue: 0.0)
    }
    public init(_ data: [Double]) {
        grid = data
        rows = 1
        cols = data.count
    }
    public init(_ data: [[Double]]) {
        var matrix = Matrix(rows: data.count, cols: data[0].count)
        let no_columns = data[0].count
        for (i, row) in enumerate(data) {
            assert(no_columns == row.count, "Each row must be of the same length")
            for (j, value) in enumerate(row) {
                matrix[i, j] = value
            }
        }
        self = matrix
    }
    //public init(_ data: [[[Double]]]) { // Three dimensional array
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < cols
    }
    public subscript(row: Int) -> Double {
        get {
            // assert
            return grid[row]
        }
        set {
            grid[row] = newValue
        }
    }
    public subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * cols) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * cols) + column] = newValue
        }
    }
    
}

// MARK: Literal
extension Matrix: ArrayLiteralConvertible {
    public static func convertFromArrayLiteral(elements: Double...) -> Matrix {
        let data = elements as [Double]
        var matrix = Matrix(data)
        return matrix
    }
/*    public static func convertFromArrayLiteral(elements: [Double]...) -> Matrix {
        let data = elements as [[Double]]
        var matrix = Matrix(data)
        return matrix
    }*/

}

/*public static boolean nearlyEqual(float a, float b, float epsilon) {
    final float absA = Math.abs(a);
    final float absB = Math.abs(b);
    final float diff = Math.abs(a - b);
    
    if (a == b) { // shortcut, handles infinities
        return true;
    } else if (a == 0 || b == 0 || diff < Float.MIN_NORMAL) {
        // a or b is zero or both are extremely close to it
        // relative error is less meaningful here
        return diff < (epsilon * Float.MIN_NORMAL);
    } else { // use relative error
        return diff / (absA + absB) < epsilon;
    }
}
*/



public func nearlyEqual(a: Double, b: Double, epsilon: Double) -> Bool {
    let absA = abs(a)
    let absB = abs(b)
    let diff = abs(a - b)
    
    if (a == b) {
        return true
    //} else if (a == 0 || b == 0 || diff < Double.min) {
        //return diff < (epsilon * Double.)
    } else {
        return (diff / (absA + absB)) < epsilon
    }
}

public func nearlyEqual(a: Double, b: Double) -> Bool {
    return nearlyEqual(a, b, DBL_EPSILON)
}

public func nearlyEqual(a: Float, b: Float, epsilon: Float) -> Bool {
    let absA = abs(a)
    let absB = abs(b)
    let diff = abs(a - b)
    
    if (a == b) {
        return true
        //} else if (a == 0 || b == 0 || diff < Double.min) {
        //return diff < (epsilon * Double.)
    } else {
        return (diff / (absA + absB)) < epsilon
    }
}

public func nearlyEqual(a: Float, b: Float) -> Bool {
    return nearlyEqual(a, b, FLT_EPSILON)
}


// MARK: Operators
public func == (left: Matrix, right: Matrix) -> Bool {
    return (left.grid == right.grid)
}

public func + (left: Matrix, right: Matrix) -> Matrix {
    assert( (left.rows == right.rows) && (left.cols == right.cols) )
    var result = Matrix(rows: left.rows, cols: left.cols)
    vDSP_vaddD( left.grid, 1, right.grid, 1, &result.grid, 1, vDSP_Length(left.grid.count) )
    return result
}

public func - (left: Matrix, right: Matrix) -> Matrix {
    assert( (left.rows == right.rows) && (left.cols == right.cols) )
    var result = Matrix(rows: left.rows, cols: left.cols)
    vDSP_vsubD( right.grid, 1, left.grid, 1, &result.grid, 1, vDSP_Length(left.grid.count) )
    return result
}

public func * (left: Matrix, right:Double) -> Matrix {
    var result = Matrix(rows: left.rows, cols: left.cols)
    //vDSP_vsmulD( left.grid, 1, &right, &result.grid, 1, vDSP_Length(left.grid.count)) // Can't seem to get this to work
    for (i, value) in enumerate(left.grid) {
        result[i] = value * right
    }
    return result
}

public func * (left: Double, right:Matrix) -> Matrix {
    var result = Matrix(rows: right.rows, cols: right.cols)
    //vDSP_vsmulD( left.grid, 1, &right, &result.grid, 1, vDSP_Length(left.grid.count)) // Can't seem to get this to work
    for (i, value) in enumerate(right.grid) {
        result[i] = value * left
    }
    return result
}














