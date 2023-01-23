package json.frigga.schema
{
   import flash.utils.Dictionary;
   
   public class FriggaSchemaBuilder
   {
       
      
      private var name:String;
      
      private var description:String;
      
      private var type:String;
      
      private var mandatory:Vector.<String>;
      
      private var index:Dictionary;
      
      public function FriggaSchemaBuilder()
      {
         this.mandatory = new Vector.<String>();
         this.index = new Dictionary();
         super();
      }
      
      public function extractPropertyDescriptorsFrom(param1:Object) : FriggaSchemaBuilder
      {
         var _loc4_:* = null;
         var _loc5_:FriggaPropertyDescriptor = null;
         var _loc2_:Object = this.extractValueFromObject(param1,"properties");
         var _loc3_:Dictionary = new Dictionary();
         for(_loc4_ in _loc2_)
         {
            _loc5_ = this.buildPropertyDescriptorFrom(_loc2_[_loc4_]);
            if(!_loc5_.optional)
            {
               this.mandatory.push(_loc4_);
            }
            _loc3_[_loc4_] = _loc5_;
         }
         this.setIndex(_loc3_);
         this.setMandatory(this.mandatory);
         return this;
      }
      
      public function extractNameFrom(param1:Object) : FriggaSchemaBuilder
      {
         var _loc2_:String = this.extractValueFromObject(param1,"name") as String;
         return this.setName(_loc2_);
      }
      
      public function extractDescriptionFrom(param1:Object) : FriggaSchemaBuilder
      {
         var _loc2_:String = this.extractValueFromObject(param1,"description") as String;
         return this.setDescription(_loc2_);
      }
      
      public function extractTypeFrom(param1:Object) : FriggaSchemaBuilder
      {
         var _loc2_:String = this.extractValueFromObject(param1,"type","object") as String;
         return this.setType(_loc2_);
      }
      
      public function getIt() : FriggaSchema
      {
         return new FriggaSchema(this.index,this.mandatory,this.name,this.description,this.type);
      }
      
      public function setName(param1:String) : FriggaSchemaBuilder
      {
         this.name = param1;
         return this;
      }
      
      public function setDescription(param1:String) : FriggaSchemaBuilder
      {
         this.description = param1;
         return this;
      }
      
      public function setType(param1:String) : FriggaSchemaBuilder
      {
         this.type = param1;
         return this;
      }
      
      public function setMandatory(param1:Vector.<String>) : FriggaSchemaBuilder
      {
         this.mandatory = param1;
         return this;
      }
      
      public function setIndex(param1:Dictionary) : FriggaSchemaBuilder
      {
         this.index = param1;
         return this;
      }
      
      private function extractValueFromObject(param1:Object, param2:String, param3:* = "") : Object
      {
         if(param1 == null)
         {
            return param3;
         }
         if(param2 in param1)
         {
            return param1[param2];
         }
         return param3;
      }
      
      private function buildPropertyDescriptorFrom(param1:Object) : FriggaPropertyDescriptor
      {
         var _loc18_:FriggaSchema = null;
         var _loc2_:String = this.extractValueFromObject(param1,"title") as String;
         var _loc3_:String = this.extractValueFromObject(param1,"description") as String;
         var _loc4_:Boolean = this.extractValueFromObject(param1,"optional",false) as Boolean;
         var _loc5_:Number = this.extractValueFromObject(param1,"minimum",-Number.MAX_VALUE) as Number;
         var _loc6_:Number = this.extractValueFromObject(param1,"maximum",Number.MAX_VALUE) as Number;
         var _loc7_:Boolean = this.extractValueFromObject(param1,"minimumCanEqual",false) as Boolean;
         var _loc8_:Boolean = this.extractValueFromObject(param1,"maximumCanEqual",false) as Boolean;
         var _loc9_:Number = this.extractValueFromObject(param1,"minItems",0) as Number;
         var _loc10_:Number = this.extractValueFromObject(param1,"maxItems",Number.MAX_VALUE) as Number;
         var _loc11_:Boolean = this.extractValueFromObject(param1,"uniqueItems",false) as Boolean;
         var _loc12_:String = this.extractValueFromObject(param1,"pattern","") as String;
         var _loc13_:Number = this.extractValueFromObject(param1,"maxLength",Number.MAX_VALUE) as Number;
         var _loc14_:Number = this.extractValueFromObject(param1,"minLength",0) as Number;
         var _loc15_:Array = this.extractValueFromObject(param1,"enum",[]) as Array;
         var _loc16_:Object = this.extractValueFromObject(param1,"defaultValue","");
         var _loc17_:Boolean = Boolean(this.extractValueFromObject(param1,"skip",false));
         var _loc19_:Object = this.extractValueFromObject(param1,"type","object");
         if(_loc19_ is String)
         {
            this.validateSimpleType(_loc19_ as String);
            _loc18_ = new FriggaSchema(null,null,null,null,_loc19_ as String);
         }
         else
         {
            _loc18_ = FriggaSchema.fromObject(_loc19_);
         }
         var _loc20_:FriggaSchema = null;
         var _loc21_:Object = this.extractValueFromObject(param1,"items");
         if(_loc21_ != null)
         {
            _loc20_ = FriggaSchema.fromObject(_loc21_);
         }
         return new FriggaPropertyDescriptor(_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc18_,_loc20_,_loc17_);
      }
      
      private function validateSimpleType(param1:String) : void
      {
         if(["string","number","boolean","object","array","any"].indexOf(param1) == -1)
         {
            throw new Error("Invalid schema: Frigga only handles simple types or a schema definition as \'type\', reference to an existing schema is not supported: " + param1 as String);
         }
      }
   }
}
