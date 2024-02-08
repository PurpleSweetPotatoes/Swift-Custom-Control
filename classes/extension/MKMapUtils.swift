//
//  MKMapUtils.swift
//  Pods
//  
//  Created by Bai, Payne on 2024/2/7.
//  Copyright © 2024 Garmin All rights reserved
//  

import MapKit

struct MKMapUtils {
    static func convert(from points: [CLLocationCoordinate2D]) -> MKMapRect {
        var boundBox = MKMapRect.null
        for location in points {
            let point = MKMapPoint(location)
            boundBox = boundBox.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        return boundBox
    }

    static func convertToGCJ02Points(from points: [CLLocationCoordinate2D]) -> [CLLocationCoordinate2D] {
        points.map { $0.transformWGS84ToGCJ02() }
    }
}

public extension MKMapView {
    func fit(points: [CLLocationCoordinate2D], animated: Bool, insets: UIEdgeInsets = .zero) {
        var boundingBox = MKMapUtils.convert(from: points)
        let mapWidth = bounds.width
        let mapHeight = bounds.height
        if insets != .zero,
           insets.left + insets.right < mapWidth,
           insets.top + insets.bottom < mapHeight {
            let widthUnit = boundingBox.width / (mapWidth - insets.left - insets.right)
            let heightUnit = boundingBox.height / (mapHeight - insets.top - insets.bottom)
            let maxUnit = max(widthUnit, heightUnit)
            let scaleInsets = UIEdgeInsets(top: insets.top * maxUnit,
                                           left: insets.left * maxUnit,
                                           bottom: insets.bottom * maxUnit,
                                           right: insets.right * maxUnit)
            boundingBox = MKMapRect(x: boundingBox.origin.x - scaleInsets.left, y: boundingBox.origin.y - scaleInsets.top, width: boundingBox.size.width + scaleInsets.left + scaleInsets.right, height: boundingBox.size.height + scaleInsets.top + scaleInsets.bottom)
        }
        let region = MKCoordinateRegion(boundingBox)
        setRegion(region, animated: animated)
    }
}

public extension CLLocationCoordinate2D {

    // MARK: - Constants
    private struct Constants {
        static let oblateness: Double = 0.00669342162296594323
        static let semiMajorAxis: Double = 6378245.0
    }

    // MARK: - Methods
    /// Transform location from `WGS84` to `GCJ02`
    ///
    /// Due to the legal concern, this converter only do one way transformation.
    func transformWGS84ToGCJ02() -> CLLocationCoordinate2D {
        var adjustedLat = transformLatWith(x: longitude - 105.0,
                                           y: latitude - 35.0)
        var adjustedLon = transformLonWith(x: longitude - 105.0,
                                           y: latitude - 35.0)
        let radLat = latitude / 180.0 * Double.pi
        var magic = sin(radLat)
        magic = 1 - Constants.oblateness * magic * magic
        let sqrtMagic = sqrt(magic)

        adjustedLat = (adjustedLat * 180.0) /
            ((Constants.semiMajorAxis * (1 - Constants.oblateness)) / (magic * sqrtMagic) * Double.pi)
        adjustedLon = (adjustedLon * 180.0) /
            (Constants.semiMajorAxis / sqrtMagic * cos(radLat) * Double.pi)

        return CLLocationCoordinate2DMake(latitude + adjustedLat, longitude + adjustedLon)
    }

    /// Transfrom latitude with the given latitude and longitude
    ///
    /// - Parameters:
    ///   - x: The input latitude
    ///   - y: The input longitude
    /// - Returns: The adjusted latitude
    private func transformLatWith(x: Double, y: Double) -> Double {
        let tempSqrtLat = 0.2 * sqrt(abs(x))

        var lat: Double = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + tempSqrtLat
        lat += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        lat += (20.0 * sin(y * Double.pi) + 40.0 * sin(y / 3.0 * Double.pi)) * 2.0 / 3.0
        lat += (160.0 * sin(y / 12.0 * Double.pi) + 320 * sin(y * Double.pi / 30.0)) * 2.0 / 3.0

        return lat
    }

    /// Transfrom longitude with the given latitude and longitude
    ///
    /// - Parameters:
    ///   - x: The input latitude
    ///   - y: The input longitude
    /// - Returns: The adjusted longitude
    private func transformLonWith(x: Double, y: Double) -> Double {
        let tempSqrtLon = 0.1 * sqrt(abs(x))

        var lon: Double = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + tempSqrtLon
        lon += (20.0 * sin(6.0 * x * Double.pi) + 20.0 * sin(2.0 * x * Double.pi)) * 2.0 / 3.0
        lon += (20.0 * sin(x * Double.pi) + 40.0 * sin(x / 3.0 * Double.pi)) * 2.0 / 3.0
        lon += (150.0 * sin(x / 12.0 * Double.pi) + 300.0 * sin(x / 30.0 * Double.pi)) * 2.0 / 3.0

        return lon
    }
}
