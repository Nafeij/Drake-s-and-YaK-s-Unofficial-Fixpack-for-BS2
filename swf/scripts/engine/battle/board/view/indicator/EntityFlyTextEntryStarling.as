package engine.battle.board.view.indicator
{
   import com.stoicstudio.platform.Platform;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import flash.display.BitmapData;
   import flash.errors.IllegalOperationError;
   import starling.display.Image;
   import starling.textures.Texture;
   
   public class EntityFlyTextEntryStarling extends EntityFlyTextEntry
   {
       
      
      private var img:Image;
      
      private var texture:Texture;
      
      public function EntityFlyTextEntryStarling(param1:String, param2:EntityFlyText, param3:BitmapData)
      {
         this.texture = Texture.fromBitmapData(this,param3,false);
         this.img = new Image(this.texture);
         this.img.x = -param3.width / 2;
         this.img.y = -param3.height / 2;
         bmpWrapper = new DisplayObjectWrapperStarling(this.img);
         this.img.touchable = false;
         super(param1,param2,param3);
      }
      
      override public function cleanup() : void
      {
         if(cleanedup)
         {
            throw new IllegalOperationError("double cleanup of EntityFlyTextEntryStarling id=" + id + " ord=" + ordinal);
         }
         if(!Platform.suspended)
         {
            if(this.texture)
            {
               this.texture.dispose();
               this.texture = null;
            }
         }
         else if(this.texture)
         {
            logger.error("EntityFlyTextEntryStarling id=" + id + " ord=" + ordinal + " leaking texture " + this.texture);
         }
         super.cleanup();
      }
   }
}
