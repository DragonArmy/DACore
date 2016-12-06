//
//  BaseModel.swift
//  trace
//
//  Created by Edie Woelfle on 4/13/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

// wch 2/22/16
// might be worth looking at this ActiveRecord implementation -- https://github.com/qutheory/fluent
// they use a Protocol with a Category, which allows slightly nicer syntax for finds by returing Self

import UIKit

class BaseModel
{
    // static variables for the basemodel
    static var allCache = Dictionary<String, Dictionary<String, AnyObject>>()
    static var allData = Dictionary<String, [AnyObject]>()
    
    // private variables for each object
    var objectVariables = Dictionary<String, Any>()
    
    // not sure what I needed this for in here, but it's important
    required init()
    {
        
    }
    
    // get the key for the current class
    static var allKey : String
    {
        return "\(self)"
    }
    
    // get all the variables from one type
    static func all<T : AnyObject>() -> [T]
    {
        return allData[allKey] as! [T]
    }
    
    // load all the data from the file
    static func loadFromData(_ filename:String)
    {
        allData[allKey] = [AnyObject]()
        allCache[allKey] = Dictionary<String, AnyObject>()
        
        // load the data from the bundle
        do
        {
            let url = Bundle.main.url(forResource: filename, withExtension: ".csv")
            var data:String = try String(contentsOf: url!, encoding: String.Encoding.utf8)
            // removing the trailing whitespace if there is any
            data = data.trimmingCharacters(in: NSCharacterSet.whitespaces)
            
            // split the data based on a newline character
            let text:[String] = data.split("\n")
            
            //we require 2 rows:
            // 1) column name
            // 2) column type
            if(text.count < 2)
            {
                print("ERROR: \(filename) does not contain enough information. Please update the google spreadsheet and try again.")
                return
            }
            
            // get the variable names and types -- simple split! no commas allowed in name/type fields
            let variableNames:[String] = text[0].components(separatedBy: ",")
            let variableTypes:[String] = text[1].components(separatedBy: ",")
            
            // if there isn't an id, remove it
            if (variableNames.count == 0)
            {
                print("ERROR: no data found in \(filename)")
                return
            }
            
            // parse through all the data
            for i in (2..<text.count)
            {
                let objectData:String = text[i]
                
                // if the string is empty, skip it
                if(objectData.isEmpty)
                {
                    continue
                }
                
                //create an object and assign variables from
                let object = self.init();
                
                // get the variables from the data
                var raw_data = objectData.components(separatedBy: ",")
                var dataVariables = [String]()
                
                while(raw_data.count > 0)
                {
                    var working_string = raw_data.removeFirst()
                    
                    if(working_string  == "\"\""){
                        //empty string kinda screws up the logic below
                        dataVariables.append(working_string)
                    }else if(raw_data.count > 0 && working_string.hasPrefix("\"")){
                        
                        working_string = working_string.replace("\"", withString: "")
                        
                        while(raw_data.count > 0)
                        {
                            if(raw_data.first!.hasSuffix("\""))
                            {
                                working_string = working_string + "," + raw_data.removeFirst().replace("\"", withString: "")
                                break
                            }else{
                                working_string = working_string + "," + raw_data.removeFirst()
                            }
                        }
                        dataVariables.append(working_string)
                    }else{
                        //default: take me as i am
                        dataVariables.append(working_string)
                    }
                }
                
//                for var j in (0..<raw_data.count)
//                {
//                    //check to see if we have quotes
//                    if(raw_data[j] == "\"\""){
//                        //empty string kinda screws up the logic below
//                        dataVariables.append(raw_data[j])
//                    }else if(j < raw_data.count - 1 && raw_data[j].hasPrefix("\"")){
//                        var working_string = raw_data[j].replace("\"", withString: "")
//                        
//                        for k in ((j+1)..<raw_data.count)
//                        {
//                            if(raw_data[k].hasSuffix("\""))
//                            {
//                                working_string = working_string + "," + raw_data[k].replace("\"", withString: "")
//                                j = k;
//                                break;
//                            }else{
//                                working_string = working_string + "," + raw_data[k]
//                            }
//                        }
//                        
//                        //print("REJOINED DATA: \(working_string)")
//                        dataVariables.append(working_string)
//                    }else{
//                        dataVariables.append(raw_data[j])
//                    }
//                }
                
                if(dataVariables.count == 0)
                {
                    continue
                }
                
                // go through all the variables from the reflection and set them to the data from the csv
                for v in (0..<variableNames.count)
                {
                    if (v >= dataVariables.count)
                    {
                        print("ERROR: no data found for \(variableNames[v]) on line \(i) of \(filename)")
                        continue
                    }
                    
                    let name = variableNames[v]
                    let value = dataVariables[v]
                    
                    // parse out all the data based on types
                    switch(variableTypes[v].lowercased())
                    {
                        case "color":
                            if !dataVariables[v].characters.contains("#")
                            {
                                object.objectVariables[name] = "#\(value)".lowercased().toColor()
                            }else{
                                object.objectVariables[name] = value.lowercased().toColor()
                            }
                            break
                        case "int":
                            object.objectVariables[name] = Int(value)
                            break
                        case "float":
                            object.objectVariables[name] = value.toFloat()
                            break
                        case "bool":
                            object.objectVariables[name] = (value.lowercased() == "true")
                            break
                        default:
                            print("\(name) is \(value)")
                            object.objectVariables[name] = value
                            break
                    }
                }
                
                // add the object to the dictionary
                allCache[allKey]![dataVariables[0]] = object
                allData[allKey]!.append(object as AnyObject)
            }
            
            
        } catch {
            print("ERROR READING FILE \(filename)")
        }
    }
    
    static func findByIntID<T>(_ id:Int) -> T?
    {
        return findByStringID("\(id)")
    }
    
    static func findByStringID<T>(_ id:String) -> T?
    {
        let return_value = allCache[allKey]![id] as! T?
        return return_value
    }
    
    static func parseInt(value : String) -> Int?
    {
        return Int(value)
    }
    
    static func parseFloat(value : String) -> Float?
    {
        return value.toFloat()
    }
    
    static func parseColor(value : String) -> UIColor?
    {
        return value.toColor()
    }
    
    static func parseBool(value : String) -> Bool?
    {
        return value.lowercased() == "true"
    }
}
