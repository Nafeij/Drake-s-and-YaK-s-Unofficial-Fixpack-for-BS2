package engine.vfx
{
   import engine.anim.view.XAnimClipSpriteBase;
   
   public class AttachedVfx
   {
       
      
      public var isoSpriteId:String;
      
      public var isoLayerName:String;
      
      public var spriteBase:XAnimClipSpriteBase;
      
      public function AttachedVfx(param1:String, param2:String, param3:XAnimClipSpriteBase)
      {
         super();
         this.isoSpriteId = param1;
         this.isoLayerName = param2;
         this.spriteBase = param3;
      }
   }
}
