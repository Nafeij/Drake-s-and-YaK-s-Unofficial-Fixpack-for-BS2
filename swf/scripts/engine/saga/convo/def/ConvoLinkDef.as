package engine.saga.convo.def
{
   import flash.utils.ByteArray;
   
   public class ConvoLinkDef
   {
       
      
      public var path:String;
      
      public var conditions:ConvoConditionsDef;
      
      public var convo:ConvoDef;
      
      public function ConvoLinkDef(param1:ConvoDef)
      {
         this.conditions = new ConvoConditionsDef();
         super();
         this.convo = param1;
      }
      
      public static function makeReason(param1:Array, param2:String) : void
      {
         if(param1)
         {
            param1.push(param2);
         }
      }
      
      public static function comparator(param1:ConvoLinkDef, param2:ConvoLinkDef, param3:Array, param4:Boolean) : Boolean
      {
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            makeReason(param3,"ConvoLink.comp(null)");
            return false;
         }
         return param1.equals(param2,param3,param4);
      }
      
      public function toString() : String
      {
         return "link-to " + this.path;
      }
      
      public function getComparisonString() : String
      {
         var _loc2_:ConvoConditionsDef = null;
         var _loc1_:String = "";
         _loc1_ += this.path;
         if(this.conditions)
         {
            for each(_loc2_ in this.conditions)
            {
               _loc1_ += _loc2_.getComparisonString();
            }
         }
         return _loc1_;
      }
      
      public function getConditions() : ConvoConditionsDef
      {
         return this.conditions;
      }
      
      public function addIfCondition(param1:String) : void
      {
         if(this.conditions)
         {
            this.conditions.addIfCondition(param1);
         }
      }
      
      public function equals(param1:ConvoLinkDef, param2:Array, param3:Boolean) : Boolean
      {
         var _loc4_:ConvoNodeDef = null;
         var _loc5_:ConvoNodeDef = null;
         if(param3)
         {
            _loc4_ = this.convo.getNodeDef(this.path);
            _loc5_ = param1.convo.getNodeDef(param1.path);
            if(_loc4_._text != _loc5_._text)
            {
               makeReason(param2,"ConvoLink(path-node)");
               return false;
            }
         }
         else if(this.path != param1.path)
         {
            makeReason(param2,"ConvoLink(path)");
            return false;
         }
         if(!ConvoConditionsDef.comparator(this.conditions,param1.conditions))
         {
            makeReason(param2,"ConvoLink(cond)");
            return false;
         }
         return true;
      }
      
      public function readBytes(param1:ByteArray) : ConvoLinkDef
      {
         var _loc2_:int = param1.readByte();
         var _loc3_:* = (_loc2_ & 1) != 0;
         var _loc4_:* = (_loc2_ & 2) != 0;
         if(_loc4_)
         {
            this.path = param1.readUTF();
         }
         if(_loc3_)
         {
            this.conditions = new ConvoConditionsDef().readBytes(param1);
         }
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         _loc2_ |= Boolean(this.conditions) && this.conditions.hasConditions ? 1 : 0;
         _loc2_ |= !!this.path ? 2 : 0;
         param1.writeByte(_loc2_);
         if(this.path)
         {
            param1.writeUTF(this.path);
         }
         if(Boolean(this.conditions) && this.conditions.hasConditions)
         {
            this.conditions.writeBytes(param1);
         }
      }
   }
}
