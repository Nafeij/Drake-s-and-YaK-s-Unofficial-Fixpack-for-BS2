package com.demonsters.debugger
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Stage;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   internal class MonsterDebuggerUtils
   {
      
      private static var _references:Dictionary = new Dictionary(true);
      
      private static var _reference:int = 0;
       
      
      public function MonsterDebuggerUtils()
      {
         super();
      }
      
      public static function snapshot(param1:DisplayObject, param2:Rectangle = null) : BitmapData
      {
         var _loc10_:Matrix = null;
         var _loc11_:Rectangle = null;
         var _loc12_:Number = NaN;
         var _loc13_:BitmapData = null;
         if(param1 == null)
         {
            return null;
         }
         var _loc3_:Boolean = param1.visible;
         var _loc4_:Number = param1.alpha;
         var _loc5_:Number = param1.rotation;
         var _loc6_:Number = param1.scaleX;
         var _loc7_:Number = param1.scaleY;
         try
         {
            param1.visible = true;
            param1.alpha = 1;
            param1.rotation = 0;
            param1.scaleX = 1;
            param1.scaleY = 1;
         }
         catch(e1:Error)
         {
         }
         var _loc8_:Rectangle = param1.getBounds(param1);
         _loc8_.x = int(_loc8_.x + 0.5);
         _loc8_.y = int(_loc8_.y + 0.5);
         _loc8_.width = int(_loc8_.width + 0.5);
         _loc8_.height = int(_loc8_.height + 0.5);
         if(param1 is Stage)
         {
            _loc8_.x = 0;
            _loc8_.y = 0;
            _loc8_.width = Stage(param1).stageWidth;
            _loc8_.height = Stage(param1).stageHeight;
         }
         var _loc9_:BitmapData = null;
         if(_loc8_.width <= 0 || _loc8_.height <= 0)
         {
            return null;
         }
         _loc9_ = new BitmapData(_loc8_.width,_loc8_.height,false,16777215);
         _loc10_ = new Matrix();
         _loc10_.tx = -_loc8_.x;
         _loc10_.ty = -_loc8_.y;
         _loc9_.draw(param1,_loc10_,null,null,null,false);
         try
         {
            param1.visible = _loc3_;
            param1.alpha = _loc4_;
            param1.rotation = _loc5_;
            param1.scaleX = _loc6_;
            param1.scaleY = _loc7_;
         }
         catch(e2:Error)
         {
         }
         if(param2 != null)
         {
            if(_loc8_.width <= param2.width && _loc8_.height <= param2.height)
            {
               return _loc9_;
            }
            _loc11_ = _loc8_.clone();
            _loc11_.width = param2.width;
            _loc11_.height = param2.width * (_loc8_.height / _loc8_.width);
            if(_loc11_.height > param2.height)
            {
               _loc11_ = _loc8_.clone();
               _loc11_.width = param2.height * (_loc8_.width / _loc8_.height);
               _loc11_.height = param2.height;
            }
            _loc12_ = _loc11_.width / _loc8_.width;
            _loc13_ = new BitmapData(_loc11_.width,_loc11_.height,false,0);
            _loc10_ = new Matrix();
            _loc10_.scale(_loc12_,_loc12_);
            _loc13_.draw(_loc9_,_loc10_,null,null,null,true);
            return _loc13_;
         }
         return _loc9_;
      }
      
      public static function getMemory() : uint
      {
         return System.totalMemory;
      }
      
      public static function pause() : Boolean
      {
         try
         {
            System.pause();
            return true;
         }
         catch(e:Error)
         {
            return false;
         }
      }
      
      public static function resume() : Boolean
      {
         try
         {
            System.resume();
            return true;
         }
         catch(e:Error)
         {
            return false;
         }
      }
      
      public static function stackTrace() : XML
      {
         var childXML:XML = null;
         var stack:String = null;
         var lines:Array = null;
         var i:int = 0;
         var s:String = null;
         var bracketIndex:int = 0;
         var methodIndex:int = 0;
         var classname:String = null;
         var method:String = null;
         var file:String = null;
         var line:String = null;
         var functionXML:XML = null;
         var rootXML:XML = <root/>;
         childXML = <node/>;
         try
         {
            throw new Error();
         }
         catch(e:Error)
         {
            stack = e.getStackTrace();
            if(stack == null || stack == "")
            {
               return <root><error>Stack unavailable</error></root>;
            }
            stack = stack.split("\t").join("");
            lines = stack.split("\n");
            if(lines.length <= 4)
            {
               return <root><error>Stack to short</error></root>;
            }
            lines.shift();
            lines.shift();
            lines.shift();
            lines.shift();
            i = 0;
            while(i < lines.length)
            {
               s = lines[i];
               s = s.substring(3,s.length);
               bracketIndex = s.indexOf("[");
               methodIndex = s.indexOf("/");
               if(bracketIndex == -1)
               {
                  bracketIndex = s.length;
               }
               if(methodIndex == -1)
               {
                  methodIndex = bracketIndex;
               }
               classname = MonsterDebuggerUtils.parseType(s.substring(0,methodIndex));
               method = "";
               file = "";
               line = "";
               if(methodIndex != s.length && methodIndex != bracketIndex)
               {
                  method = s.substring(methodIndex + 1,bracketIndex);
               }
               if(bracketIndex != s.length)
               {
                  file = s.substring(bracketIndex + 1,s.lastIndexOf(":"));
                  line = s.substring(s.lastIndexOf(":") + 1,s.length - 1);
               }
               functionXML = <node/>;
               functionXML.@classname = classname;
               functionXML.@method = method;
               functionXML.@file = file;
               functionXML.@line = line;
               childXML.appendChild(functionXML);
               i++;
            }
            rootXML.appendChild(childXML.children());
            return rootXML;
         }
      }
      
      public static function getReferenceID(param1:*) : String
      {
         if(param1 in _references)
         {
            return _references[param1];
         }
         var _loc2_:String = "#" + String(_reference);
         _references[param1] = _loc2_;
         ++_reference;
         return _loc2_;
      }
      
      public static function getReference(param1:String) : *
      {
         var _loc2_:* = undefined;
         var _loc3_:String = null;
         if(param1.charAt(0) != "#")
         {
            return null;
         }
         for(_loc2_ in _references)
         {
            _loc3_ = _references[_loc2_];
            if(_loc3_ == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getObject(param1:*, param2:String = "", param3:int = 0) : *
      {
         var object:*;
         var splitted:Array;
         var i:int;
         var index:Number = NaN;
         var base:* = param1;
         var target:String = param2;
         var parent:int = param3;
         if(target == null || target == "")
         {
            return base;
         }
         if(target.charAt(0) == "#")
         {
            return getReference(target);
         }
         object = base;
         splitted = target.split(MonsterDebuggerConstants.DELIMITER);
         i = 0;
         while(i < splitted.length - parent)
         {
            if(splitted[i] != "")
            {
               try
               {
                  if(splitted[i] == "children()")
                  {
                     object = object.children();
                  }
                  else if(object is DisplayObjectContainer && splitted[i].indexOf("getChildAt(") == 0)
                  {
                     index = Number(splitted[i].substring(11,splitted[i].indexOf(")",11)));
                     object = DisplayObjectContainer(object).getChildAt(index);
                  }
                  else
                  {
                     object = object[splitted[i]];
                  }
               }
               catch(e:Error)
               {
                  break;
               }
            }
            i++;
         }
         return object;
      }
      
      public static function parse(param1:*, param2:String = "", param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var _loc8_:XML = null;
         var _loc13_:int = 0;
         var _loc14_:XML = null;
         var _loc6_:XML = <root/>;
         var _loc7_:XML = <node/>;
         var _loc9_:XML = new XML();
         var _loc10_:String = "";
         var _loc11_:String = "";
         var _loc12_:Boolean = false;
         if(param4 != -1 && param3 > param4)
         {
            return _loc6_;
         }
         if(param1 == null)
         {
            _loc8_ = <node/>;
            _loc8_.@icon = MonsterDebuggerConstants.ICON_WARNING;
            _loc8_.@label = "Null object";
            _loc8_.@name = "Null object";
            _loc8_.@type = MonsterDebuggerConstants.TYPE_WARNING;
            _loc7_.appendChild(_loc8_);
            _loc10_ = "null";
         }
         else
         {
            _loc9_ = MonsterDebuggerDescribeType.get(param1);
            _loc10_ = parseType(_loc9_.@name);
            _loc11_ = parseType(_loc9_.@base);
            _loc12_ = Boolean(_loc9_.@isDynamic);
            if(param1 is Class)
            {
               _loc7_.appendChild(parseClass(param1,param2,_loc9_,param3,param4,param5).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_XML)
            {
               _loc7_.appendChild(parseXML(param1,param2 + "." + "children()",param3,param4).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_XMLLIST)
            {
               _loc8_ = <node/>;
               _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               _loc8_.@type = MonsterDebuggerConstants.TYPE_UINT;
               _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READONLY;
               _loc8_.@target = param2 + "." + "length";
               _loc8_.@label = "length" + " (" + MonsterDebuggerConstants.TYPE_UINT + ") = " + param1.length();
               _loc8_.@name = "length";
               _loc8_.@value = param1.length();
               _loc13_ = 0;
               while(_loc13_ < param1.length())
               {
                  _loc8_.appendChild(parseXML(param1[_loc13_],param2 + "." + String(_loc13_) + ".children()",param3,param4).children());
                  _loc13_++;
               }
               _loc7_.appendChild(_loc8_);
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_STRING || _loc10_ == MonsterDebuggerConstants.TYPE_BOOLEAN || _loc10_ == MonsterDebuggerConstants.TYPE_NUMBER || _loc10_ == MonsterDebuggerConstants.TYPE_INT || _loc10_ == MonsterDebuggerConstants.TYPE_UINT)
            {
               _loc7_.appendChild(parseBasics(param1,param2,_loc10_).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_ARRAY || _loc10_.indexOf(MonsterDebuggerConstants.TYPE_VECTOR) == 0)
            {
               _loc7_.appendChild(parseArray(param1,param2,param3,param4).children());
            }
            else if(_loc10_ == MonsterDebuggerConstants.TYPE_OBJECT)
            {
               _loc7_.appendChild(parseObject(param1,param2,param3,param4,param5).children());
            }
            else
            {
               _loc7_.appendChild(parseClass(param1,param2,_loc9_,param3,param4,param5).children());
            }
         }
         if(param3 == 1)
         {
            _loc14_ = <node/>;
            _loc14_.@icon = MonsterDebuggerConstants.ICON_ROOT;
            _loc14_.@label = "(" + _loc10_ + ")";
            _loc14_.@type = _loc10_;
            _loc14_.@target = param2;
            _loc14_.appendChild(_loc7_.children());
            _loc6_.appendChild(_loc14_);
         }
         else
         {
            _loc6_.appendChild(_loc7_.children());
         }
         return _loc6_;
      }
      
      private static function parseBasics(param1:*, param2:String, param3:String, param4:int = 1, param5:int = 5) : XML
      {
         var _loc6_:XML = <root/>;
         var _loc7_:XML = <node/>;
         var _loc8_:Boolean = false;
         var _loc9_:XML = new XML();
         if(param3 == MonsterDebuggerConstants.TYPE_STRING)
         {
            try
            {
               _loc9_ = new XML(param1);
               _loc8_ = !_loc9_.hasSimpleContent() && _loc9_.children().length() > 0;
            }
            catch(error:TypeError)
            {
            }
         }
         if(!_loc8_)
         {
            _loc7_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
            _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc7_.@label = "(" + param3 + ") = " + printValue(param1,param3);
            _loc7_.@name = "";
            _loc7_.@type = param3;
            _loc7_.@value = printValue(param1,param3);
            _loc7_.@target = param2;
         }
         else
         {
            _loc7_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
            _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc7_.@label = "(" + MonsterDebuggerConstants.TYPE_XML + ")";
            _loc7_.@name = "";
            _loc7_.@type = MonsterDebuggerConstants.TYPE_XML;
            _loc7_.@value = "";
            _loc7_.@target = param2;
            _loc7_.appendChild(parseXML(_loc9_,param2 + "." + "children()",param4,param5).children());
         }
         _loc6_.appendChild(_loc7_);
         return _loc6_;
      }
      
      private static function parseArray(param1:*, param2:String, param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var _loc7_:XML = null;
         var _loc8_:XML = null;
         var _loc16_:* = undefined;
         var _loc6_:XML = <root/>;
         var _loc9_:String = "";
         var _loc10_:String = "";
         var _loc11_:Boolean = false;
         var _loc12_:XML = new XML();
         var _loc13_:int = 0;
         _loc7_ = <node/>;
         _loc7_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
         _loc7_.@label = "length" + " (" + MonsterDebuggerConstants.TYPE_UINT + ") = " + param1["length"];
         _loc7_.@name = "length";
         _loc7_.@type = MonsterDebuggerConstants.TYPE_UINT;
         _loc7_.@value = param1["length"];
         _loc7_.@target = param2 + "." + "length";
         _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
         _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READONLY;
         var _loc14_:Array = [];
         var _loc15_:Boolean = true;
         for(_loc16_ in param1)
         {
            if(!(_loc16_ is int))
            {
               _loc15_ = false;
            }
            _loc14_.push(_loc16_);
         }
         if(_loc15_)
         {
            _loc14_.sort(Array.NUMERIC);
         }
         else
         {
            _loc14_.sort(Array.CASEINSENSITIVE);
         }
         _loc13_ = 0;
         while(_loc13_ < _loc14_.length)
         {
            _loc9_ = parseType(MonsterDebuggerDescribeType.get(param1[_loc14_[_loc13_]]).@name);
            _loc10_ = param2 + "." + String(_loc14_[_loc13_]);
            if(_loc9_ == MonsterDebuggerConstants.TYPE_STRING || _loc9_ == MonsterDebuggerConstants.TYPE_BOOLEAN || _loc9_ == MonsterDebuggerConstants.TYPE_NUMBER || _loc9_ == MonsterDebuggerConstants.TYPE_INT || _loc9_ == MonsterDebuggerConstants.TYPE_UINT || _loc9_ == MonsterDebuggerConstants.TYPE_FUNCTION)
            {
               _loc11_ = false;
               _loc12_ = new XML();
               if(_loc9_ == MonsterDebuggerConstants.TYPE_STRING)
               {
                  try
                  {
                     _loc12_ = new XML(param1[_loc14_[_loc13_]]);
                     if(!_loc12_.hasSimpleContent() && _loc12_.children().length() > 0)
                     {
                        _loc11_ = true;
                     }
                  }
                  catch(error:TypeError)
                  {
                  }
               }
               if(!_loc11_)
               {
                  _loc8_ = <node/>;
                  _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  _loc8_.@label = "[" + _loc14_[_loc13_] + "] (" + _loc9_ + ") = " + printValue(param1[_loc14_[_loc13_]],_loc9_);
                  _loc8_.@name = "[" + _loc14_[_loc13_] + "]";
                  _loc8_.@type = _loc9_;
                  _loc8_.@value = printValue(param1[_loc14_[_loc13_]],_loc9_);
                  _loc8_.@target = _loc10_;
                  _loc7_.appendChild(_loc8_);
               }
               else
               {
                  _loc8_ = <node/>;
                  _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  _loc8_.@label = "[" + _loc14_[_loc13_] + "] (" + _loc9_ + ")";
                  _loc8_.@name = "[" + _loc14_[_loc13_] + "]";
                  _loc8_.@type = _loc9_;
                  _loc8_.@value = "";
                  _loc8_.@target = _loc10_;
                  _loc8_.appendChild(parseXML(param1[_loc14_[_loc13_]],_loc10_,param3 + 1,param4).children());
                  _loc7_.appendChild(_loc8_);
               }
            }
            else
            {
               _loc8_ = <node/>;
               _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc8_.@label = "[" + _loc14_[_loc13_] + "] (" + _loc9_ + ")";
               _loc8_.@name = "[" + _loc14_[_loc13_] + "]";
               _loc8_.@type = _loc9_;
               _loc8_.@value = "";
               _loc8_.@target = _loc10_;
               _loc8_.appendChild(parse(param1[_loc14_[_loc13_]],_loc10_,param3 + 1,param4,param5).children());
               _loc7_.appendChild(_loc8_);
            }
            _loc13_++;
         }
         _loc6_.appendChild(_loc7_);
         return _loc6_;
      }
      
      public static function parseXML(param1:*, param2:String = "", param3:int = 1, param4:int = -1) : XML
      {
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc9_:String = null;
         var _loc5_:XML = <root/>;
         var _loc8_:int = 0;
         if(param4 != -1 && param3 > param4)
         {
            return _loc5_;
         }
         if(param2.indexOf("@") != -1)
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1;
            _loc6_.@name = "";
            _loc6_.@value = param1;
            _loc6_.@target = param2;
            _loc5_.appendChild(_loc6_);
         }
         else if("name" in param1 && param1.name() == null)
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = "(" + MonsterDebuggerConstants.TYPE_XMLVALUE + ") = " + printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
            _loc6_.@name = "";
            _loc6_.@value = printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
            _loc6_.@target = param2;
            _loc5_.appendChild(_loc6_);
         }
         else if("hasSimpleContent" in param1 && Boolean(param1.hasSimpleContent()))
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1.name() + " (" + MonsterDebuggerConstants.TYPE_XMLNODE + ")";
            _loc6_.@name = param1.name();
            _loc6_.@value = "";
            _loc6_.@target = param2;
            if(param1 != "")
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLVALUE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLVALUE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "(" + MonsterDebuggerConstants.TYPE_XMLVALUE + ") = " + printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
               _loc7_.@name = "";
               _loc7_.@value = printValue(param1,MonsterDebuggerConstants.TYPE_XMLVALUE);
               _loc7_.@target = param2;
               _loc6_.appendChild(_loc7_);
            }
            _loc8_ = 0;
            while(_loc8_ < param1.attributes().length())
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "@" + param1.attributes()[_loc8_].name() + " (" + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE + ") = " + param1.attributes()[_loc8_];
               _loc7_.@name = "";
               _loc7_.@value = param1.attributes()[_loc8_];
               _loc7_.@target = param2 + "." + "@" + param1.attributes()[_loc8_].name();
               _loc6_.appendChild(_loc7_);
               _loc8_++;
            }
            _loc5_.appendChild(_loc6_);
         }
         else
         {
            _loc6_ = <node/>;
            _loc6_.@icon = MonsterDebuggerConstants.ICON_XMLNODE;
            _loc6_.@type = MonsterDebuggerConstants.TYPE_XMLNODE;
            _loc6_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
            _loc6_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
            _loc6_.@label = param1.name() + " (" + MonsterDebuggerConstants.TYPE_XMLNODE + ")";
            _loc6_.@name = param1.name();
            _loc6_.@value = "";
            _loc6_.@target = param2;
            _loc8_ = 0;
            while(_loc8_ < param1.attributes().length())
            {
               _loc7_ = <node/>;
               _loc7_.@icon = MonsterDebuggerConstants.ICON_XMLATTRIBUTE;
               _loc7_.@type = MonsterDebuggerConstants.TYPE_XMLATTRIBUTE;
               _loc7_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc7_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc7_.@label = "@" + param1.attributes()[_loc8_].name() + " (" + MonsterDebuggerConstants.TYPE_XMLATTRIBUTE + ") = " + param1.attributes()[_loc8_];
               _loc7_.@name = "";
               _loc7_.@value = param1.attributes()[_loc8_];
               _loc7_.@target = param2 + "." + "@" + param1.attributes()[_loc8_].name();
               _loc6_.appendChild(_loc7_);
               _loc8_++;
            }
            _loc8_ = 0;
            while(_loc8_ < param1.children().length())
            {
               _loc9_ = param2 + "." + "children()" + "." + _loc8_;
               _loc6_.appendChild(parseXML(param1.children()[_loc8_],_loc9_,param3 + 1,param4).children());
               _loc8_++;
            }
            _loc5_.appendChild(_loc6_);
         }
         return _loc5_;
      }
      
      private static function parseObject(param1:*, param2:String, param3:int = 1, param4:int = 5, param5:Boolean = true) : XML
      {
         var _loc8_:XML = null;
         var _loc16_:* = undefined;
         var _loc6_:XML = <root/>;
         var _loc7_:XML = <node/>;
         var _loc9_:String = "";
         var _loc10_:String = "";
         var _loc11_:Boolean = false;
         var _loc12_:XML = new XML();
         var _loc13_:int = 0;
         var _loc14_:Array = [];
         var _loc15_:Boolean = true;
         for(_loc16_ in param1)
         {
            if(!(_loc16_ is int))
            {
               _loc15_ = false;
            }
            _loc14_.push(_loc16_);
         }
         if(_loc15_)
         {
            _loc14_.sort(Array.NUMERIC);
         }
         else
         {
            _loc14_.sort(Array.CASEINSENSITIVE);
         }
         _loc13_ = 0;
         while(_loc13_ < _loc14_.length)
         {
            _loc9_ = parseType(MonsterDebuggerDescribeType.get(param1[_loc14_[_loc13_]]).@name);
            _loc10_ = param2 + "." + _loc14_[_loc13_];
            if(_loc9_ == MonsterDebuggerConstants.TYPE_STRING || _loc9_ == MonsterDebuggerConstants.TYPE_BOOLEAN || _loc9_ == MonsterDebuggerConstants.TYPE_NUMBER || _loc9_ == MonsterDebuggerConstants.TYPE_INT || _loc9_ == MonsterDebuggerConstants.TYPE_UINT || _loc9_ == MonsterDebuggerConstants.TYPE_FUNCTION)
            {
               _loc11_ = false;
               _loc12_ = new XML();
               if(_loc9_ == MonsterDebuggerConstants.TYPE_STRING)
               {
                  try
                  {
                     _loc12_ = new XML(param1[_loc14_[_loc13_]]);
                     if(!_loc12_.hasSimpleContent() && _loc12_.children().length() > 0)
                     {
                        _loc11_ = true;
                     }
                  }
                  catch(error:TypeError)
                  {
                  }
               }
               if(!_loc11_)
               {
                  _loc8_ = <node/>;
                  _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  _loc8_.@label = _loc14_[_loc13_] + " (" + _loc9_ + ") = " + printValue(param1[_loc14_[_loc13_]],_loc9_);
                  _loc8_.@name = _loc14_[_loc13_];
                  _loc8_.@type = _loc9_;
                  _loc8_.@value = printValue(param1[_loc14_[_loc13_]],_loc9_);
                  _loc8_.@target = _loc10_;
                  _loc7_.appendChild(_loc8_);
               }
               else
               {
                  _loc8_ = <node/>;
                  _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
                  _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  _loc8_.@label = _loc14_[_loc13_] + " (" + _loc9_ + ")";
                  _loc8_.@name = _loc14_[_loc13_];
                  _loc8_.@type = _loc9_;
                  _loc8_.@value = "";
                  _loc8_.@target = _loc10_;
                  _loc8_.appendChild(parseXML(param1[_loc14_[_loc13_]],_loc10_,param3 + 1,param4).children());
                  _loc7_.appendChild(_loc8_);
               }
            }
            else
            {
               _loc8_ = <node/>;
               _loc8_.@icon = MonsterDebuggerConstants.ICON_VARIABLE;
               _loc8_.@access = MonsterDebuggerConstants.ACCESS_VARIABLE;
               _loc8_.@permission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               _loc8_.@label = _loc14_[_loc13_] + " (" + _loc9_ + ")";
               _loc8_.@name = _loc14_[_loc13_];
               _loc8_.@type = _loc9_;
               _loc8_.@value = "";
               _loc8_.@target = _loc10_;
               _loc8_.appendChild(parse(param1[_loc14_[_loc13_]],_loc10_,param3 + 1,param4,param5).children());
               _loc7_.appendChild(_loc8_);
            }
            _loc13_++;
         }
         _loc6_.appendChild(_loc7_.children());
         return _loc6_;
      }
      
      private static function parseClass(param1:*, param2:String, param3:XML, param4:int = 1, param5:int = 5, param6:Boolean = true) : XML
      {
         var key:String = null;
         var itemsArrayLength:int = 0;
         var item:* = undefined;
         var itemXML:XML = null;
         var itemAccess:String = null;
         var itemPermission:String = null;
         var itemIcon:String = null;
         var itemType:String = null;
         var itemName:String = null;
         var itemTarget:String = null;
         var isXMLString:XML = null;
         var i:int = 0;
         var prop:* = undefined;
         var displayObject:DisplayObjectContainer = null;
         var displayObjects:Array = null;
         var child:DisplayObject = null;
         var object:* = param1;
         var target:String = param2;
         var description:XML = param3;
         var currentDepth:int = param4;
         var maxDepth:int = param5;
         var includeDisplayObjects:Boolean = param6;
         var rootXML:XML = <root/>;
         var nodeXML:XML = <node/>;
         var variables:XMLList = description..variable;
         var accessors:XMLList = description..accessor;
         var constants:XMLList = description..constant;
         var isDynamic:Boolean = description.@isDynamic;
         var variablesLength:int = variables.length();
         var accessorsLength:int = accessors.length();
         var constantsLength:int = constants.length();
         var childLength:int = 0;
         var keys:Object = {};
         var itemsArray:Array = [];
         var isXML:Boolean = false;
         if(isDynamic)
         {
            for(prop in object)
            {
               key = String(prop);
               if(!keys.hasOwnProperty(key))
               {
                  keys[key] = key;
                  itemName = key;
                  itemType = parseType(getQualifiedClassName(object[key]));
                  itemTarget = target + "." + key;
                  itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
                  itemsArray[itemsArray.length] = {
                     "name":itemName,
                     "type":itemType,
                     "target":itemTarget,
                     "access":itemAccess,
                     "permission":itemPermission,
                     "icon":itemIcon
                  };
               }
            }
         }
         i = 0;
         while(i < variablesLength)
         {
            key = variables[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(variables[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_VARIABLE;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         i = 0;
         while(i < accessorsLength)
         {
            key = accessors[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(accessors[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_ACCESSOR;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE;
               if(accessors[i].@access == MonsterDebuggerConstants.PERMISSION_READONLY)
               {
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
               }
               if(accessors[i].@access == MonsterDebuggerConstants.PERMISSION_WRITEONLY)
               {
                  itemPermission = MonsterDebuggerConstants.PERMISSION_WRITEONLY;
                  itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_WRITEONLY;
               }
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         i = 0;
         while(i < constantsLength)
         {
            key = constants[i].@name;
            if(!keys.hasOwnProperty(key))
            {
               keys[key] = key;
               itemName = key;
               itemType = parseType(constants[i].@type);
               itemTarget = target + "." + key;
               itemAccess = MonsterDebuggerConstants.ACCESS_CONSTANT;
               itemPermission = MonsterDebuggerConstants.PERMISSION_READONLY;
               itemIcon = MonsterDebuggerConstants.ICON_VARIABLE_READONLY;
               itemsArray[itemsArray.length] = {
                  "name":itemName,
                  "type":itemType,
                  "target":itemTarget,
                  "access":itemAccess,
                  "permission":itemPermission,
                  "icon":itemIcon
               };
            }
            i++;
         }
         itemsArray.sortOn("name",Array.CASEINSENSITIVE);
         if(includeDisplayObjects && object is DisplayObjectContainer)
         {
            displayObject = DisplayObjectContainer(object);
            displayObjects = [];
            childLength = displayObject.numChildren;
            i = 0;
            while(i < childLength)
            {
               child = null;
               try
               {
                  child = displayObject.getChildAt(i);
               }
               catch(e1:Error)
               {
               }
               if(child != null)
               {
                  itemXML = MonsterDebuggerDescribeType.get(child);
                  itemType = parseType(itemXML.@name);
                  itemName = "DisplayObject";
                  if(child.name != null)
                  {
                     itemName += " - " + child.name;
                  }
                  itemTarget = target + "." + "getChildAt(" + i + ")";
                  itemAccess = MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT;
                  itemPermission = MonsterDebuggerConstants.PERMISSION_READWRITE;
                  itemIcon = child is DisplayObjectContainer ? MonsterDebuggerConstants.ICON_ROOT : MonsterDebuggerConstants.ICON_DISPLAY_OBJECT;
                  displayObjects[displayObjects.length] = {
                     "name":itemName,
                     "type":itemType,
                     "target":itemTarget,
                     "access":itemAccess,
                     "permission":itemPermission,
                     "icon":itemIcon,
                     "index":i
                  };
               }
               i++;
            }
            displayObjects.sortOn("name",Array.CASEINSENSITIVE);
            itemsArray = displayObjects.concat(itemsArray);
         }
         itemsArrayLength = itemsArray.length;
         i = 0;
         while(i < itemsArrayLength)
         {
            itemType = itemsArray[i].type;
            itemName = itemsArray[i].name;
            itemTarget = itemsArray[i].target;
            itemPermission = itemsArray[i].permission;
            itemAccess = itemsArray[i].access;
            itemIcon = itemsArray[i].icon;
            try
            {
               if(itemAccess == MonsterDebuggerConstants.ACCESS_DISPLAY_OBJECT)
               {
                  item = DisplayObjectContainer(object).getChildAt(itemsArray[i].index);
               }
               else
               {
                  item = object[itemName];
               }
            }
            catch(e2:Error)
            {
               item = null;
            }
            if(item != null && itemPermission != MonsterDebuggerConstants.PERMISSION_WRITEONLY)
            {
               if(itemType == MonsterDebuggerConstants.TYPE_STRING || itemType == MonsterDebuggerConstants.TYPE_BOOLEAN || itemType == MonsterDebuggerConstants.TYPE_NUMBER || itemType == MonsterDebuggerConstants.TYPE_INT || itemType == MonsterDebuggerConstants.TYPE_UINT || itemType == MonsterDebuggerConstants.TYPE_FUNCTION)
               {
                  isXML = false;
                  isXMLString = new XML();
                  if(itemType == MonsterDebuggerConstants.TYPE_STRING)
                  {
                     try
                     {
                        isXMLString = new XML(item);
                        isXML = !isXMLString.hasSimpleContent() && isXMLString.children().length() > 0;
                     }
                     catch(error:TypeError)
                     {
                     }
                  }
                  if(!isXML)
                  {
                     nodeXML = <node/>;
                     nodeXML.@icon = itemIcon;
                     nodeXML.@label = itemName + " (" + itemType + ") = " + printValue(item,itemType);
                     nodeXML.@name = itemName;
                     nodeXML.@type = itemType;
                     nodeXML.@value = printValue(item,itemType);
                     nodeXML.@target = itemTarget;
                     nodeXML.@access = itemAccess;
                     nodeXML.@permission = itemPermission;
                     rootXML.appendChild(nodeXML);
                  }
                  else
                  {
                     nodeXML = <node/>;
                     nodeXML.@icon = itemIcon;
                     nodeXML.@label = itemName + " (" + itemType + ")";
                     nodeXML.@name = itemName;
                     nodeXML.@type = itemType;
                     nodeXML.@value = "";
                     nodeXML.@target = itemTarget;
                     nodeXML.@access = itemAccess;
                     nodeXML.@permission = itemPermission;
                     nodeXML.appendChild(parseXML(isXMLString,itemTarget + "." + "children()",currentDepth,maxDepth).children());
                     rootXML.appendChild(nodeXML);
                  }
               }
               else
               {
                  nodeXML = <node/>;
                  nodeXML.@icon = itemIcon;
                  nodeXML.@label = itemName + " (" + itemType + ")";
                  nodeXML.@name = itemName;
                  nodeXML.@type = itemType;
                  nodeXML.@target = itemTarget;
                  nodeXML.@access = itemAccess;
                  nodeXML.@permission = itemPermission;
                  if(item != null && itemType != MonsterDebuggerConstants.TYPE_BYTEARRAY)
                  {
                     nodeXML.appendChild(parse(item,itemTarget,currentDepth + 1,maxDepth,includeDisplayObjects).children());
                  }
                  rootXML.appendChild(nodeXML);
               }
            }
            i++;
         }
         return rootXML;
      }
      
      public static function parseFunctions(param1:*, param2:String = "") : XML
      {
         var _loc6_:XML = null;
         var _loc10_:String = null;
         var _loc15_:String = null;
         var _loc16_:XMLList = null;
         var _loc17_:int = 0;
         var _loc18_:Array = null;
         var _loc19_:String = null;
         var _loc23_:XML = null;
         var _loc24_:XML = null;
         var _loc3_:XML = <root/>;
         var _loc4_:XML = MonsterDebuggerDescribeType.get(param1);
         var _loc5_:String = parseType(_loc4_.@name);
         var _loc7_:String = "";
         var _loc8_:String = "";
         var _loc9_:String = "";
         var _loc11_:Object = {};
         var _loc12_:XMLList = _loc4_..method;
         var _loc13_:Array = [];
         var _loc14_:int = _loc12_.length();
         var _loc20_:Boolean = false;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         _loc6_ = <node/>;
         _loc6_.@icon = MonsterDebuggerConstants.ICON_DEFAULT;
         _loc6_.@label = "(" + _loc5_ + ")";
         _loc6_.@target = param2;
         _loc21_ = 0;
         for(; _loc21_ < _loc14_; _loc21_++)
         {
            _loc10_ = _loc12_[_loc21_].@name;
            try
            {
               if(!_loc11_.hasOwnProperty(_loc10_))
               {
                  _loc11_[_loc10_] = _loc10_;
                  _loc13_[_loc13_.length] = {
                     "name":_loc10_,
                     "xml":_loc12_[_loc21_],
                     "access":MonsterDebuggerConstants.ACCESS_METHOD
                  };
               }
            }
            catch(e:Error)
            {
               continue;
            }
         }
         _loc13_.sortOn("name",Array.CASEINSENSITIVE);
         _loc14_ = _loc13_.length;
         _loc21_ = 0;
         while(_loc21_ < _loc14_)
         {
            _loc7_ = MonsterDebuggerConstants.TYPE_FUNCTION;
            _loc8_ = _loc13_[_loc21_].xml.@name;
            _loc9_ = param2 + MonsterDebuggerConstants.DELIMITER + _loc8_;
            _loc15_ = parseType(_loc13_[_loc21_].xml.@returnType);
            _loc16_ = _loc13_[_loc21_].xml..parameter;
            _loc17_ = _loc16_.length();
            _loc18_ = [];
            _loc19_ = "";
            _loc20_ = false;
            _loc22_ = 0;
            while(_loc22_ < _loc17_)
            {
               if(_loc16_[_loc22_].@optional == "true" && !_loc20_)
               {
                  _loc20_ = true;
                  _loc18_[_loc18_.length] = "[";
               }
               _loc18_[_loc18_.length] = parseType(_loc16_[_loc22_].@type);
               _loc22_++;
            }
            if(_loc20_)
            {
               _loc18_[_loc18_.length] = "]";
            }
            _loc19_ = _loc18_.join(", ");
            _loc19_ = _loc19_.replace("[, ","[");
            _loc19_ = _loc19_.replace(", ]","]");
            _loc23_ = <node/>;
            _loc23_.@icon = MonsterDebuggerConstants.ICON_FUNCTION;
            _loc23_.@type = MonsterDebuggerConstants.TYPE_FUNCTION;
            _loc23_.@access = MonsterDebuggerConstants.ACCESS_METHOD;
            _loc23_.@label = _loc8_ + "(" + _loc19_ + "):" + _loc15_;
            _loc23_.@name = _loc8_;
            _loc23_.@target = _loc9_;
            _loc23_.@args = _loc19_;
            _loc23_.@returnType = _loc15_;
            _loc22_ = 0;
            while(_loc22_ < _loc17_)
            {
               _loc24_ = <node/>;
               _loc24_.@type = parseType(_loc16_[_loc22_].@type);
               _loc24_.@index = _loc16_[_loc22_].@index;
               _loc24_.@optional = _loc16_[_loc22_].@optional;
               _loc23_.appendChild(_loc24_);
               _loc22_++;
            }
            _loc6_.appendChild(_loc23_);
            _loc21_++;
         }
         _loc3_.appendChild(_loc6_);
         return _loc3_;
      }
      
      public static function parseType(param1:String) : String
      {
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1.indexOf("::") != -1)
         {
            param1 = param1.substring(param1.indexOf("::") + 2,param1.length);
         }
         if(param1.indexOf("::") != -1)
         {
            _loc2_ = param1.substring(0,param1.indexOf("<") + 1);
            _loc3_ = param1.substring(param1.indexOf("::") + 2,param1.length);
            param1 = _loc2_ + _loc3_;
         }
         param1 = param1.replace("()","");
         return param1.replace(MonsterDebuggerConstants.TYPE_METHOD,MonsterDebuggerConstants.TYPE_FUNCTION);
      }
      
      public static function isDisplayObject(param1:*) : Boolean
      {
         return param1 is DisplayObject || param1 is DisplayObjectContainer;
      }
      
      public static function printValue(param1:*, param2:String) : String
      {
         if(param2 == MonsterDebuggerConstants.TYPE_BYTEARRAY)
         {
            return param1["length"] + " bytes";
         }
         if(param1 == null)
         {
            return "null";
         }
         return String(param1);
      }
      
      public static function getObjectUnderPoint(param1:DisplayObjectContainer, param2:Point) : DisplayObject
      {
         var _loc3_:Array = null;
         var _loc4_:DisplayObject = null;
         var _loc6_:DisplayObject = null;
         if(param1.areInaccessibleObjectsUnderPoint(param2))
         {
            return param1;
         }
         _loc3_ = param1.getObjectsUnderPoint(param2);
         _loc3_.reverse();
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return param1;
         }
         _loc4_ = _loc3_[0];
         _loc3_.length = 0;
         while(true)
         {
            _loc3_[_loc3_.length] = _loc4_;
            if(_loc4_.parent == null)
            {
               break;
            }
            _loc4_ = _loc4_.parent;
         }
         _loc3_.reverse();
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc5_];
            if(!(_loc6_ is DisplayObjectContainer))
            {
               break;
            }
            _loc4_ = _loc6_;
            if(!DisplayObjectContainer(_loc6_).mouseChildren)
            {
               break;
            }
            _loc5_++;
         }
         return _loc4_;
      }
   }
}
