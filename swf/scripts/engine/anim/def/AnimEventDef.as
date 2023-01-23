package engine.anim.def
{
   import flash.utils.ByteArray;
   
   public class AnimEventDef implements IAnimEventDef
   {
       
      
      public var _id:String;
      
      public var _frameNumber:int;
      
      public function AnimEventDef()
      {
         super();
      }
      
      public function get frameNumber() : int
      {
         return this._frameNumber;
      }
      
      public function get id() : String
      {
         return this._id;
      }
      
      public function set frameNumber(param1:int) : void
      {
         this._frameNumber = param1;
      }
      
      public function set id(param1:String) : void
      {
         this._id = param1;
      }
      
      public function get numBytes() : int
      {
         return 8 + (!!this._id ? this._id.length : 0);
      }
      
      public function readBytes(param1:ByteArray) : void
      {
         this._id = param1.readUTF();
         this._frameNumber = param1.readUnsignedShort();
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         param1.writeUTF(!!this._id ? this._id : "");
         param1.writeShort(this._frameNumber);
      }
   }
}
