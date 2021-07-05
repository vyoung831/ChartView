//
//  MagnifierRect.swift
//  
//
//  Created by Samu András on 2020. 03. 04..
//

import SwiftUI

#if os(iOS) || os(watchOS)

public struct MagnifierRect: View {
    
    let padding: EdgeInsets = EdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)
    let cornerRadius: CGFloat = 12
    static let width: CGFloat = 60
    
    var valueSpecifier: String
    var style: ChartStyle
    
    @Binding var x: String
    @Binding var y: Double
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .frame(width: MagnifierRect.width, height: geometry.size.height)
                    .foregroundColor(self.style.accentColor)
                    .shadow(color: Colors.LegendText, radius: 12, x: 0, y: 6)
                    .blendMode(.multiply)
                
                VStack {
                    if self.x.count > 0 {
                        Text(self.x)
                            .minimumScaleFactor(0.3)
                            .lineLimit(1)
                    }
                    Text("\(self.y, specifier: valueSpecifier)")
                }
                .padding(self.padding)
                .font(.system(size: 18, weight: .bold))
                .offset(x: 0, y: (-geometry.size.height / 2) + 30)
                .foregroundColor(self.style.textColor)
                
            }
            
        }
        
    }
    
}

#endif
