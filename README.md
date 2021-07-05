# SwiftUICharts
`SwiftUICharts` is a Swift package for displaying charts in an iOS or watchOS project using SwiftUI.  
![SwiftUI Charts](./Resources/showcase1.gif "SwiftUI Charts")

# Table of contents
1. [Getting started](#getting-started)
1. [Installation and usage](#installation-and-usage)
1. [Package structure](#package-structure)
1. [Overview and key components](#overview-and-key-components)
    1. [ChartData](#chartdata)
1. [Charts](#charts)
    1. [Line charts](#line-charts)
        1. [LineView](#line-view)
    1. [Bar charts](#bar-charts)
    1. [Pie charts](#pie-charts)
1. [WatchOS support](#watchos-support)

# Getting started

# Installation and usage
To use `SwiftUICharts` in your project, do the following:
1. In XCode, add `https://github.com/vyoung831/ChartView` as a package dependency.
1. Import the package

# Package structure
Given SPM's usage of default minimum platform versions, building `ChartView` for only watchOS and iOS is currently impossible.  
Instead, source files are [framed in conditional compilation blocks](https://docs.swift.org/swift-book/ReferenceManual/Statements.html) to compile for only iOS or watchOS. Although this package will compile for MacOS usage, that library is functionally empty.  
* To build the package, run `swift build`
* To run unit tests, run `swift test`

# Overview and key components

## ChartData

# Charts

## Line charts
`SwiftUICharts` contains the following line chart types:
| Struct name | Description | Supported? |
|-|-|-|
| LineView | View containing single line | Y |
| LineChartView | Widget view containing single line | N |
| MultiLineChartView | Widget view containing multiple Lines. | N |

## LineView


## Bar charts

## Pie charts

# WatchOS support

