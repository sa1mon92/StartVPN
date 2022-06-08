//
//  Units.swift
//  StartVPN
//
//  Created by Дмитрий Садырев on 02.04.2021.
//

import Foundation

public struct Units {
  
  public let bytes: Int64
  
  public var kilobytes: Double {
    return Double(bytes) / 1_024
  }
  
  public var megabytes: Double {
    return kilobytes / 1_024
  }
  
  public var gigabytes: Double {
    return megabytes / 1_024
  }
  
  public init(bytes: Int64) {
    self.bytes = bytes
  }
  
  public func getReadableUnit() -> String {
    
    switch bytes {
    case 0..<1_024:
      return "\(bytes) bytes"
    case 1_024..<(1_024 * 1_024):
      return "\(String(format: "%.2f", kilobytes)) KiB"
    case 1_024..<(1_024 * 1_024 * 1_024):
      return "\(String(format: "%.2f", megabytes)) MiB"
    case (1_024 * 1_024 * 1_024)...Int64.max:
      return "\(String(format: "%.2f", gigabytes)) GiB"
    default:
      return "\(bytes) bytes"
    }
  }
}
