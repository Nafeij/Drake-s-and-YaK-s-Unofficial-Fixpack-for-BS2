package engine.anim.def
{
   import flash.display.MovieClip;
   import flash.utils.ByteArray;
   import flash.utils.getQualifiedClassName;
   
   public class AnimClipChildDef
   {
       
      
      public var url:String;
      
      public var index:int;
      
      public var name:String;
      
      public var front:Boolean;
      
      public var clip:AnimClipDef;
      
      public var clazzName:String;
      
      public var hidden:Boolean;
      
      public var parentStartFrame:int;
      
      public function AnimClipChildDef()
      {
         super();
      }
      
      public function setupChild(param1:MovieClip) : void
      {
         this.clazzName = getQualifiedClassName(param1);
         this.name = param1.name;
      }
      
      public function readBytes(param1:ByteArray) : void
      {
         this.url = param1.readUTF();
         this.name = param1.readUTF();
         this.clazzName = param1.readUTF();
         this.index = param1.readUnsignedByte();
         this.front = param1.readBoolean();
         this.parentStartFrame = param1.readShort();
      }
      
      public function writeBytes(param1:ByteArray) : void
      {
         param1.writeUTF(!!this.url ? this.url : "");
         param1.writeUTF(!!this.name ? this.name : "");
         param1.writeUTF(!!this.clazzName ? this.clazzName : "");
         if(this.index > 255)
         {
            throw new ArgumentError("AnimClipChildDef index " + this.index);
         }
         param1.writeByte(this.index);
         param1.writeBoolean(this.front);
         param1.writeShort(this.parentStartFrame);
      }
   }
}
