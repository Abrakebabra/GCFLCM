//
//  main.swift
//  GCFLCM
//
//  Created by Keith Lee on 2019/08/29.
//  Copyright © 2019 Keith Lee. All rights reserved.
//
//  Big prime to test with:  109381081209419241

import Foundation

var integerList: [Int] = []
var primesOfInputs: [[Int]] = []

var gcf: Int
var lcm: Int

var run: Bool = true

enum error: Error {
    case intOverflow
}


//  handles re-entry of new inputs.  Clears data and handles user choices.
func restartProgram(){
    var choice: Bool = true
    
    while choice == true {
        print("New numbers?  y / n")
        let choiceInput: String? = readLine()
        
        if choiceInput == "y" {
            print("------------------------------------")
            print("------------------------------------")
            print("\nFactorise me.")
            integerList = []
            primesOfInputs = []
            choice = false
            break
            
        } else if choiceInput == "n" {
            print("\n\nLaters!\n\n")
            run = false
            choice = false
            break
            
        } else {
            continue
        }
    }
}


//  handles the user inputs to ensure they are valid
//  and to converts inputs to integers
func inputHandler() -> Int {
    var inputAccepted: Bool = false
    
    while inputAccepted == false {
        print("Gimme an integer")
        let userInput: String? = readLine()
        
        if let strInput: String = userInput, let intInput: Int = Int(strInput) {
            
            if intInput == 0 || intInput == 1{
                print("Not a valid number")
                
            } else {
                inputAccepted = true
                return abs(intInput)
            }
            
        } else {
            
            if userInput == "end" {
                
                if integerList.count < 1 {
                    print("Needs at least one valid input")
                    
                } else {
                    inputAccepted = true
                    return 0
                }
                
            } else {
                print("Not a valid number")
            }
        }
    }
}


//  handles the entry of multiple numbers until 0 is returned from "end"
func inputAllNumbers() {
    var finishedInput: Bool = false
    print("Input \"end\" when finished")
    
    while finishedInput == false {
        let input: Int = inputHandler()
        
        if input == 0 {
            print("------------------------------------")
            finishedInput = true
            
        } else {
            integerList.append(input)
        }
    }
}


//  finds the GCF using the Euclidean Algorithm.  Recurs until b is 0.
func gcfFind(first: Int, second: Int) -> Int {
    var a: Int
    var b: Int
    
    if first > second {
        a = first
        b = second
        
    } else {
        a = second
        b = first
    }
    
    if b == 0 {
        return a
    }
    
    let r: Int = a % b
    return gcfFind(first: b, second: r)
}


//  finds the LCM
func lcmFind(first: Int, second: Int, gcf: Int) throws -> Int {
    
    let int64overflow = first.multipliedReportingOverflow(by: second)
    
    guard int64overflow.overflow == false else {
        throw error.intOverflow
    }
    
    return ((first * second) / gcf)
}


//  Loops through all inputs to find GCF and LCM of all inputs together.
//  Returns 2 integers.
//  newLCM holds both the current known LCM and
//  the GCF between the previous LCM and the next number to test.
//  Only the LCM is returned (newLCM)
func gcflcmAllNumbers(allNumbers: [Int]) -> [Int] {
    var newLCM: Int = allNumbers[0]
    var newGCF: Int = allNumbers[0]
    
    if allNumbers.count > 1 {
        
        for i in allNumbers {
            newGCF = gcfFind(first: newGCF, second: i)
            
            do {
                try newLCM = lcmFind(first: newLCM, second: i, gcf: newGCF)
            } catch error.intOverflow {
                newLCM = -1
            } catch {
                print("Unexpected Error")
            }
            
        }
    }
    return [newGCF, newLCM]
}


//  Returns what prime an input is divisible by, or returns itself if prime.
func primeTest(test: Int) -> Int {
    
    if test != 2 && test % 2 == 0 {
        return 2
        
    } else {
        let inputSqrt = Int(sqrt(Double(test)))
        
        for i in stride(from: 3, through: inputSqrt, by: 2) {
            
            if test % i == 0 {
                return i
            }
        }
    }
    return test
}


//  Finds all the prime factors of a given number and returns an array.
func findPrimeFactors(num: Int) -> [Int] {
    var factorList: [Int] = [num]
    var primeFactorList: [Int] = []
    var finished: Bool = false
    
    while finished == false {
        
        if let lastFactor: Int = factorList.last {
            let prime: Int = primeTest(test: lastFactor)
            
            if prime == lastFactor {
                primeFactorList.append(prime)
                finished = true
                
            } else {
                primeFactorList.append(prime)
                factorList.append(Int(lastFactor / prime))
            }
        }
    }
    return primeFactorList
}


func commaSeparate(input: Int) -> String {
    // Takes an integer, formats it to a string with commas every 3 digits
    // Convert to decimal otherwise numbers like 11,111,111,111,111,111 are altered.
    // Reasoning: https://stackoverflow.com/questions/45520019/numberformatter-issue-for-large-number
    // formatter uses double arithmetic which uses around 16-17 characters at most which can produce different results.
    let inputDecimal : Decimal = Decimal(input)
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    let formatted : String? = numberFormatter.string(for: inputDecimal)
    
    if let formattedString : String = formatted {
        return formattedString
    } else {
        return ""
    }
}


func commaSeparateArray(input: [Int]) -> String {
    var allNumbers: String = ""
    
    for i in input {
        let formatted = commaSeparate(input: i)
        allNumbers.append("\(formatted)  |  ")
    }
    allNumbers.removeLast(3)
    return allNumbers
}


//  Adds some blank space at the top.
print("")

while run == true {
    inputAllNumbers()
    
    //  get start time of calculations
    let startTime: Double = CFAbsoluteTimeGetCurrent()
    
    //  find all prime factors of all inputs
    for i in integerList {
        let primeOutput: [Int] = findPrimeFactors(num: i)
        primesOfInputs.append(primeOutput)
    }
    
    //  find gcf and lcm
    let gcflcm: [Int] = gcflcmAllNumbers(allNumbers: integerList)
    gcf = gcflcm[0]
    lcm = gcflcm[1]
    
    //  find all prime factors of the lcm
    let lcmPrimes = findPrimeFactors(num: gcf)
    
    let endTime: Double = CFAbsoluteTimeGetCurrent()
    
    
    //  display
    for i in 0..<integerList.count {
        print("Input:          \(commaSeparate(input: (integerList[i])))")
        print("Prime Factors:  \(commaSeparateArray(input: (primesOfInputs[i])))\n")
    }
    
    // Notify overflow Int error
    if lcm > 0 {
        print("\nLowest Common Multiple:  \(commaSeparate(input: (lcm)))")
    } else {
        print("\nError:  LCM is larger than max integer size of \(commaSeparate(input: (Int.max)))")
    }
    
    
    if gcf == 1 {
        print("No common factors")
    } else {
        print("Greatest Common Factor:  \(commaSeparate(input: (gcf)))")
        print("Common Prime Factors:    \(commaSeparateArray(input: (lcmPrimes)))")
    }
    print("\nCalculated in \(Float(endTime - startTime)) seconds")
    print("------------------------------------")
    
    restartProgram()
}
