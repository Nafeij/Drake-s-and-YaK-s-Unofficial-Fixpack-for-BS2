package json.frigga.validator
{
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import json.frigga.report.FriggaMessage;
   import json.frigga.report.FriggaWriter;
   import json.frigga.schema.FriggaPropertyDescriptor;
   import json.frigga.schema.FriggaSchema;
   
   public class FriggaValidator
   {
       
      
      private var schema:FriggaSchema;
      
      private var validTypes:Dictionary;
      
      public function FriggaValidator(param1:FriggaSchema)
      {
         this.validTypes = new Dictionary();
         super();
         this.schema = param1;
         this.validTypes["Object"] = "object";
         this.validTypes["String"] = "string";
         this.validTypes["Number"] = "number";
         this.validTypes["Boolean"] = "boolean";
         this.validTypes["Array"] = "array";
      }
      
      public function traverse(param1:Object, param2:FriggaWriter, param3:String = "") : void
      {
         var _loc7_:* = null;
         var _loc8_:String = null;
         var _loc9_:* = undefined;
         var _loc10_:FriggaPropertyDescriptor = null;
         var _loc11_:String = null;
         var _loc12_:String = null;
         var _loc13_:* = undefined;
         var _loc14_:String = null;
         if(param1 == null)
         {
            return;
         }
         var _loc4_:FriggaPropertyDescriptor = this.schema.getPropDescriptorForPath(param3);
         var _loc5_:Boolean = true;
         if(_loc4_)
         {
            if(_loc4_.type.getHeader().type == "array")
            {
               if(_loc4_.items == null || !_loc4_.items.getHeader().name || _loc4_.items.getHeader().type == "any")
               {
                  _loc5_ = false;
               }
            }
         }
         if(_loc5_)
         {
            for(_loc7_ in param1)
            {
               _loc8_ = (param3 != "" ? param3 + "." : "") + _loc7_;
               _loc9_ = param1[_loc7_];
               _loc10_ = this.schema.getPropDescriptorForPath(_loc8_);
               if(_loc10_ == null)
               {
                  if(!(Boolean(_loc4_) && _loc4_.skip))
                  {
                     param2.writeMessage(FriggaMessage.PROPERTY_NOT_FOUND_IN_SCHEMA_ERROR,_loc8_,this.schema.getHeader().name);
                  }
               }
               else
               {
                  _loc11_ = _loc10_.type.getHeader().type;
                  _loc12_ = this.buildTypeFor(_loc9_,_loc11_);
                  if(_loc11_ != "any")
                  {
                     if(_loc11_ != _loc12_)
                     {
                        param2.writeMessage(FriggaMessage.PROPERTY_TYPE_ERROR,_loc8_,_loc12_);
                     }
                     else
                     {
                        this.validateConstraints(_loc9_,_loc10_,param2,_loc8_);
                     }
                  }
                  if(_loc9_ == null && _loc10_.defaultValue != null)
                  {
                     _loc9_ = _loc10_.defaultValue;
                  }
                  if(!_loc10_.skip)
                  {
                     if(_loc12_ == "object")
                     {
                        this.traverse(_loc9_,param2,_loc8_);
                     }
                     if(_loc12_ == "array")
                     {
                        for each(_loc13_ in _loc9_)
                        {
                           if(this.buildTypeFor(_loc13_) == "object")
                           {
                              this.traverse(_loc13_,param2,_loc8_);
                           }
                        }
                     }
                  }
               }
            }
         }
         var _loc6_:FriggaSchema = this.findSubSchemaFor(param3);
         if(_loc6_ != null)
         {
            for each(_loc14_ in _loc6_.getMandatory())
            {
               if(!this.pathExists(param1,_loc14_))
               {
                  param2.writeMessage(FriggaMessage.PROPERTY_NOT_FOUND_IN_INSTANCE_ERROR,_loc14_,param3);
               }
            }
         }
      }
      
      private function buildTypeFor(param1:*, param2:String = "any") : String
      {
         if(param1 == null)
         {
            return param2;
         }
         var _loc3_:String = getQualifiedClassName(param1);
         if(["Array","Object"].indexOf(_loc3_) != -1)
         {
            return this.validTypes[_loc3_];
         }
         if(_loc3_ == "String")
         {
            return "string";
         }
         if(_loc3_ == "Boolean")
         {
            return "boolean";
         }
         if(!isNaN(param1))
         {
            return "number";
         }
         return "object";
      }
      
      private function validateConstraints(param1:*, param2:FriggaPropertyDescriptor, param3:FriggaWriter, param4:String) : void
      {
         var _loc5_:Array = null;
         var _loc6_:Number = NaN;
         var _loc7_:String = null;
         switch(param2.type.getHeader().type)
         {
            case "array":
               _loc5_ = param1 as Array;
               if(_loc5_.length < param2.minItems)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_MIN_ITEMS_ERROR,param4,_loc5_.length);
               }
               if(_loc5_.length > param2.maxItems)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_MAX_ITEMS_ERROR,param4,_loc5_.length);
               }
               break;
            case "number":
               _loc6_ = param1 as Number;
               if(param2.minimumCanEqual)
               {
                  if(_loc6_ <= param2.minimum)
                  {
                     param3.writeMessage(FriggaMessage.PROPERTY_OUT_OF_RANGE_ERROR,param4,_loc6_);
                  }
               }
               else if(_loc6_ < param2.minimum)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_OUT_OF_RANGE_ERROR,param4,_loc6_);
               }
               if(param2.maximumCanEqual)
               {
                  if(_loc6_ >= param2.maximum)
                  {
                     param3.writeMessage(FriggaMessage.PROPERTY_OUT_OF_RANGE_ERROR,param4,_loc6_);
                  }
               }
               else if(_loc6_ > param2.maximum)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_OUT_OF_RANGE_ERROR,param4,_loc6_);
               }
               break;
            case "string":
               _loc7_ = param1 as String;
               if(_loc7_ == null)
               {
                  throw new ArgumentError("prop was not a string: " + param1 + " at " + param4);
               }
               if(param2.enum.length > 0 && param2.enum.indexOf(_loc7_) == -1)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_NOT_IN_ENUM_ERROR,param4,_loc7_);
               }
               if(_loc7_.length < param2.minLength)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_LENGTH_ERROR,param4,_loc7_);
               }
               if(_loc7_.length > param2.maxLength)
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_LENGTH_ERROR,param4,_loc7_);
               }
               if(param2.pattern != "" && !RegExp(param2.pattern).test(_loc7_))
               {
                  param3.writeMessage(FriggaMessage.PROPERTY_REGEX_ERROR,param4,_loc7_);
               }
               break;
         }
      }
      
      private function pathExists(param1:Object, param2:String) : Boolean
      {
         if(param2.indexOf(".") == -1)
         {
            return param1[param2] != null;
         }
         var _loc3_:String = param2.substr(0,param2.indexOf("."));
         var _loc4_:String = param2.substr(param2.indexOf(".") + 1,param2.length - _loc3_.length - 1);
         return this.pathExists(param1[_loc3_],_loc4_);
      }
      
      private function findSubSchemaFor(param1:String) : FriggaSchema
      {
         if(param1 == "")
         {
            return this.schema;
         }
         if(this.schema.getPropDescriptorForPath(param1) != null)
         {
            return this.schema.getPropDescriptorForPath(param1).type;
         }
         return null;
      }
   }
}
