package starling.textures
{
   import flash.display3D.Context3DTextureFormat;
   import flash.display3D.textures.TextureBase;
   import flash.utils.getQualifiedClassName;
   
   internal class ConcreteVideoTexture extends ConcreteTexture
   {
       
      
      public function ConcreteVideoTexture(param1:Object, param2:TextureBase, param3:Number = 1)
      {
         var _loc4_:String = Context3DTextureFormat.BGRA;
         var _loc5_:Number = "videoWidth" in param2 ? Number(param2["videoWidth"]) : 0;
         var _loc6_:Number = "videoHeight" in param2 ? Number(param2["videoHeight"]) : 0;
         super(param1,param2,_loc4_,_loc5_,_loc6_,false,false,false,param3,false);
         if(getQualifiedClassName(param2) != "flash.display3D.textures::VideoTexture")
         {
            throw new ArgumentError("\'base\' must be VideoTexture");
         }
      }
      
      override public function get nativeWidth() : Number
      {
         return base["videoWidth"];
      }
      
      override public function get nativeHeight() : Number
      {
         return base["videoHeight"];
      }
      
      override public function get width() : Number
      {
         return this.nativeWidth / scale;
      }
      
      override public function get height() : Number
      {
         return this.nativeHeight / scale;
      }
   }
}
