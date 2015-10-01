//
//  BaseModel.swift
//  trace
//
//  Created by Edie Woelfle on 4/13/15.
//  Copyright (c) 2015 Dragon Army. All rights reserved.
//

import Foundation
import UIKit

class BaseModel
{
    // static variables for the basemodel
    static var allCache = Dictionary<String, Dictionary<String, AnyObject>>()
    static var allData = Dictionary<String, [AnyObject]>()
    
    // private variables for each object
    var objectVariables = Dictionary<String, AnyObject>()
    
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
    static func loadFromData(filename:String)
    {
        allData[allKey] = [AnyObject]()
        allCache[allKey] = Dictionary<String, AnyObject>()
        
        // load the data from the bundle
        do
        {
            var data = try String(contentsOfURL: NSBundle.mainBundle().URLForResource(filename, withExtension: ".csv")!, encoding: NSUTF8StringEncoding)
            // removing the trailing whitespace if there is any
            data = data.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            
            // split the data based on a newline character
            let text = data.split("\n")
            
            //we require 2 rows:
            // 1) column name
            // 2) column type
            if(text.count < 2)
            {
                print("ERROR: \(filename) does not contain enough information. Please update the google spreadsheet and try again.")
                return
            }
            
            // get the variable names and types -- simple split! no commas allowed in name/type fields
            let variableNames = text[0].componentsSeparatedByString(",")
            let variableTypes = text[1].componentsSeparatedByString(",")
            
            // if there isn't an id, remove it
            if (variableNames.count == 0)
            {
                print("ERROR: no data found in \(filename)")
                return
            }
            
            // parse through all the data
            for var i = 2; i < text.count; i++
            {
                let objectData = text[i]
                
                // if the string is empty, skip it
                if(objectData.isEmpty)
                {
                    continue
                }
                
                //create an object and assign variables from
                let object = self.init();
                
                // get the variables from the data
                var raw_data = objectData.componentsSeparatedByString(",")
                var dataVariables = [String]()
                
                for(var i = 0; i < raw_data.count; i++)
                {
                    
                    
                    //check to see if we have quotes
                    if(raw_data[i] == "\"\""){
                        //empty string kinda screws up the logic below
                        dataVariables.append(raw_data[i])
                    }else if(i < raw_data.count - 1 && raw_data[i].hasPrefix("\"")){
                        var working_string = raw_data[i].replace("\"", withString: "")
                        
                        for(var j = i+1; j < raw_data.count; j++)
                        {
                            if(raw_data[j].hasSuffix("\""))
                            {
                                working_string = working_string + "," + raw_data[j].replace("\"", withString: "")
                                i = j;
                                break;
                            }else{
                                working_string = working_string + "," + raw_data[j]
                            }
                        }
                        
                        //                        print("REJOINED DATA: \(working_string)")
                        dataVariables.append(working_string)
                    }else{
                        dataVariables.append(raw_data[i])
                    }
                }
                
                if(dataVariables.count == 0)
                {
                    continue
                }
                
                // go through all the variables from the reflection and set them to the data from the csv
                for var variable = 0; variable < variableNames.count; variable++
                {
                    if (variable >= dataVariables.count)
                    {
                        print("ERROR: no data found for \(variableNames[variable]) on line \(i) of \(filename)")
                        continue
                    }
                    
                    // parse out all the data based on types
                    switch(variableTypes[variable].lowercaseString)
                    {
                    case "color":
                        if !dataVariables[variable].characters.contains("#")
                        {
                            object.objectVariables[variableNames[variable]] = ("#" + dataVariables[variable]).lowercaseString.toColor()
                        }
                        else
                        {
                            object.objectVariables[variableNames[variable]] = dataVariables[variable].lowercaseString.toColor()
                        }
                        break
                    case "int":
                        object.objectVariables[variableNames[variable]] = Int(dataVariables[variable])
                        break
                    case "float":
                        object.objectVariables[variableNames[variable]] = dataVariables[variable].toFloat()
                        break
                    case "bool":
                        object.objectVariables[variableNames[variable]] = dataVariables[variable].lowercaseString == "true"
                        break
                    default:
                        object.objectVariables[variableNames[variable]] = dataVariables[variable]
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
    
    static func find<T>(id:Int) -> T?
    {
        return find("\(id)")
    }
    
    static func find<T>(id:String) -> T?
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
        return value.lowercaseString == "true"
    }
}