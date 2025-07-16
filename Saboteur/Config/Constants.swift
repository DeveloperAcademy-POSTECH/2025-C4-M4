//
//  Constants.swift
//  Saboteur
//
//  Created by kirby on 7/15/25.
//

let cardSet: [Card] = [
    Card(directions: [true, false, true, false], connect: true, symbol: "│"),
    Card(directions: [false, true, false, true], connect: true, symbol: "─"),
    Card(directions: [true, true, false, false], connect: true, symbol: "└"),
    Card(directions: [false, true, true, false], connect: true, symbol: "┌"),
    Card(directions: [true, true, true, true], connect: true, symbol: "┼"),
    Card(directions: [false, false, false, false], connect: false, symbol: "💣"),
    Card(directions: [true, true, true, true], connect: false, symbol: "⦻"),
]
