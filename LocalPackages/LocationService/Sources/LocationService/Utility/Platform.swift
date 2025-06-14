//
//  Platform.swift
//  LocationService
//
//  Created by Igor Nikolaev on 14.06.2025.
//

enum Platform {
  static let isSimulator: Bool = {
#if targetEnvironment(simulator)
    true
#else
    false
#endif // targetEnvironment(simulator)
  }()
}
