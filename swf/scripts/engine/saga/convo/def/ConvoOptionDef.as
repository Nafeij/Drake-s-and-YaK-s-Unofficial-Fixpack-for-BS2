package engine.saga.convo.def
{
   import engine.core.logging.ILogger;
   import engine.math.Rng;
   import engine.saga.convo.Convo;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.vars.IVariableProvider;
   import flash.utils.ByteArray;
   
   public class ConvoOptionDef implements IConvoLinkable, IConvoConditional, IConvoFlaggable
   {
       
      
      public var _text:String;
      
      public var link:ConvoLinkDef;
      
      public var branch:Boolean;
      
      public var nodeId:String;
      
      public var index:int;
      
      public var node:ConvoNodeDef;
      
      public var flags:Vector.<ConvoFlagDef>;
      
      public function ConvoOptionDef(param1:ConvoNodeDef)
      {
         super();
         if(!param1)
         {
            throw new ArgumentError("no node");
         }
         this.node = param1;
         this.nodeId = param1.id;
      }
      
      public static function comparator(param1:ConvoOptionDef, param2:ConvoOptionDef, param3:Array, param4:Boolean) : Boolean
      {
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            makeReason(param3,"ConvoOptionDef.comparator(null)");
            return false;
         }
         return param1.equals(param2,param3,param4);
      }
      
      public static function makeReason(param1:Array, param2:String) : void
      {
         if(param1)
         {
            param1.push(param2);
         }
      }
      
      public static function comparatorVectors(param1:Vector.<ConvoOptionDef>, param2:Vector.<ConvoOptionDef>, param3:Array, param4:Boolean) : Boolean
      {
         var _loc7_:ConvoOptionDef = null;
         var _loc8_:ConvoOptionDef = null;
         if(param1 == param2)
         {
            return true;
         }
         if(!param1 || !param2)
         {
            makeReason(param3,"ConvoOptionDef.comparatorVectors(null)");
            return false;
         }
         if(param1.length != param2.length)
         {
            makeReason(param3,"ConvoOptionDef.comparatorVectors(len)");
            return false;
         }
         var _loc5_:int = int(param1.length);
         var _loc6_:int = 0;
         while(_loc6_ < _loc5_)
         {
            _loc7_ = param1[_loc6_];
            _loc8_ = param2[_loc6_];
            if(!comparator(_loc7_,_loc8_,param3,param4))
            {
               makeReason(param3,"ConvoOptionDef.vect(compare)");
               return false;
            }
            _loc6_++;
         }
         return true;
      }
      
      public function getComparisonString() : String
      {
         var _loc1_:String = "";
         _loc1_ += this._text;
         _loc1_ += this.getFlagsComparisonString();
         return _loc1_ + this.getLinkComparisonString();
      }
      
      public function getFlagsComparisonString() : String
      {
         var _loc2_:ConvoFlagDef = null;
         var _loc1_:String = "";
         if(this.flags)
         {
            for each(_loc2_ in this.flags)
            {
               _loc1_ += _loc2_.raw;
            }
         }
         return _loc1_;
      }
      
      public function getLinkComparisonString() : String
      {
         if(this.link)
         {
            return this.link.getComparisonString();
         }
         return "";
      }
      
      public function equals(param1:ConvoOptionDef, param2:Array, param3:Boolean) : Boolean
      {
         if(this._text != param1._text)
         {
            makeReason(param2,"ConvoOption(text)");
            return false;
         }
         if(!ConvoFlagDef.comparatorVectors(this.flags,param1.flags))
         {
            makeReason(param2,"ConvoOption(flags)");
            return false;
         }
         if(!ConvoLinkDef.comparator(this.link,param1.link,param2,param3))
         {
            makeReason(param2,"ConvoOption(link)");
            return false;
         }
         if(this.branch != param1.branch)
         {
            makeReason(param2,"ConvoOption(branch)");
            return false;
         }
         if(param3)
         {
            if(this.node._text != param1.node._text)
            {
               makeReason(param2,"ConvoOption(node text)");
               return false;
            }
         }
         else if(this.nodeId != param1.nodeId)
         {
            makeReason(param2,"ConvoOption(nodeId)");
            return false;
         }
         if(this.index != param1.index)
         {
            makeReason(param2,"ConvoOption(index)");
            return false;
         }
         return true;
      }
      
      public function get labelString() : String
      {
         return "(" + (!!this.link ? this.link.path : "null") + ") " + this._text;
      }
      
      public function get varString() : String
      {
         return this.nodeId + "_opt_" + this.index;
      }
      
      public function toString() : String
      {
         return this.labelString;
      }
      
      public function scrapeText(param1:int) : String
      {
         var _loc2_:* = "\t" + param1 + "\t";
         _loc2_ += "\t";
         var _loc3_:String = ConvoNodeDef.unparseInkleCodes(this._text);
         return _loc2_ + (_loc3_ + "\n");
      }
      
      public function getOptionText(param1:ConvoDef, param2:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc5_:Array = null;
         if(param1.strings)
         {
            _loc3_ = param1.strings.options[this.nodeId];
            if(param2)
            {
               _loc5_ = param1.strings.options[this.nodeId + param2];
               if(Boolean(_loc5_) && _loc5_.length > this.index)
               {
                  _loc4_ = String(_loc5_[this.index]);
               }
            }
            if(!_loc4_)
            {
               if(Boolean(_loc3_) && _loc3_.length > this.index)
               {
                  _loc4_ = String(_loc3_[this.index]);
               }
            }
            if(!_loc4_ && !param2)
            {
               return this.getOptionText(param1,"^m");
            }
            return _loc4_;
         }
         return this._text;
      }
      
      public function readBytes(param1:ByteArray, param2:ILogger) : ConvoOptionDef
      {
         var _loc3_:int = param1.readByte();
         var _loc4_:* = (_loc3_ & 1) != 0;
         var _loc5_:* = (_loc3_ & 2) != 0;
         this._text = param1.readUTF();
         this._text = ConvoNodeDef.parseInkleCodes(this._text);
         if(_loc4_)
         {
            this.link = new ConvoLinkDef(this.node.convo).readBytes(param1);
         }
         this.branch = param1.readBoolean();
         if(_loc5_)
         {
            this.flags = ConvoNodeDef.readFlagsVector(param1,param2);
         }
         return this;
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         _loc2_ |= !!this.link ? 1 : 0;
         _loc2_ |= Boolean(this.flags) && Boolean(this.flags.length) ? 2 : 0;
         param1.writeByte(_loc2_);
         param1.writeUTF(!!this._text ? this._text : "");
         if(this.link)
         {
            this.link.writeBytes(param1);
         }
         param1.writeBoolean(this.branch);
         if(Boolean(this.flags) && Boolean(this.flags.length))
         {
            ConvoNodeDef.writeFlagsVector(param1,this.flags);
         }
      }
      
      public function createLink(param1:String) : void
      {
         if(!param1 || param1 == "END")
         {
            return;
         }
         if(!this.link)
         {
            this.link = new ConvoLinkDef(this.node.convo);
         }
         this.link.path = param1;
      }
      
      public function getLink() : ConvoLinkDef
      {
         return this.link;
      }
      
      public function getConditions() : ConvoConditionsDef
      {
         return !!this.link ? this.link.conditions : null;
      }
      
      public function addIfCondition(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         if(!this.link)
         {
            this.link = new ConvoLinkDef(this.node.convo);
         }
         this.link.addIfCondition(param1);
      }
      
      public function addFlagFromString(param1:String, param2:ILogger) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc3_:ConvoFlagDef = new ConvoFlagDef();
         _loc3_.parse(param1,param2);
         this.flags = this.addFlagTo(_loc3_,this.flags);
      }
      
      public function addFlags(param1:Vector.<ConvoFlagDef>) : void
      {
         var _loc2_:ConvoFlagDef = null;
         for each(_loc2_ in param1)
         {
            this.flags = this.addFlagTo(_loc2_,this.flags);
         }
      }
      
      public function addFlagTo(param1:ConvoFlagDef, param2:Vector.<ConvoFlagDef>) : Vector.<ConvoFlagDef>
      {
         if(!param2)
         {
            param2 = new Vector.<ConvoFlagDef>();
         }
         param2.push(param1);
         return param2;
      }
      
      public function getDebugStringFlags() : String
      {
         var _loc2_:ConvoFlagDef = null;
         var _loc1_:String = "";
         if(this.flags)
         {
            for each(_loc2_ in this.flags)
            {
               _loc1_ += "~(" + _loc2_.labelString + ") ";
            }
         }
         return _loc1_;
      }
      
      public function applyFlags(param1:IHappeningProvider, param2:IVariableProvider, param3:Convo, param4:Rng) : void
      {
         var _loc5_:ConvoFlagDef = null;
         if(this.flags)
         {
            for each(_loc5_ in this.flags)
            {
               _loc5_.apply(param1,param2,param3,param4);
            }
         }
      }
   }
}
