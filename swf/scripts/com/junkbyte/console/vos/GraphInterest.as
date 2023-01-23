package com.junkbyte.console.vos
{
   import com.junkbyte.console.core.Executer;
   import flash.utils.ByteArray;
   
   public class GraphInterest
   {
       
      
      private var _ref:WeakRef;
      
      public var _prop:String;
      
      private var _getValueMethod:Function;
      
      private var useExec:Boolean;
      
      public var key:String;
      
      public var col:Number;
      
      public function GraphInterest(param1:String = "", param2:Number = 0)
      {
         super();
         this.col = param2;
         this.key = param1;
      }
      
      public static function FromBytes(param1:ByteArray) : GraphInterest
      {
         return new GraphInterest(param1.readUTF(),param1.readUnsignedInt());
      }
      
      public function setObject(param1:Object, param2:String) : Number
      {
         this._ref = new WeakRef(param1);
         this._prop = param2;
         this._getValueMethod = this.getAppropriateGetValueMethod();
         return this.getCurrentValue();
      }
      
      public function setGetValueCallback(param1:Function) : void
      {
         if(param1 == null)
         {
            this._getValueMethod = this.getAppropriateGetValueMethod();
         }
         else
         {
            this._getValueMethod = param1;
         }
      }
      
      public function get obj() : Object
      {
         return this._ref != null ? this._ref.reference : undefined;
      }
      
      public function get prop() : String
      {
         return this._prop;
      }
      
      public function getCurrentValue() : Number
      {
         return this._getValueMethod(this);
      }
      
      private function getAppropriateGetValueMethod() : Function
      {
         if(this._prop.search(/[^\w\d]/) >= 0)
         {
            return this.executerValueCallback;
         }
         return this.defaultValueCallback;
      }
      
      private function defaultValueCallback(param1:GraphInterest) : Number
      {
         return this.obj[this._prop];
      }
      
      private function executerValueCallback(param1:GraphInterest) : Number
      {
         return Executer.Exec(this.obj,this._prop);
      }
      
      public function writeToBytes(param1:ByteArray) : void
      {
         param1.writeUTF(this.key);
         param1.writeUnsignedInt(this.col);
      }
   }
}
