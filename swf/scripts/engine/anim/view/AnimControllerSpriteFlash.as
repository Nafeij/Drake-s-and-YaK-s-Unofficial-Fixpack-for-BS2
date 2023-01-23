package engine.anim.view
{
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import engine.resource.IResourceManager;
   import flash.display.Sprite;
   
   public class AnimControllerSpriteFlash extends AnimControllerSprite
   {
       
      
      public var _sprite:Sprite;
      
      public function AnimControllerSpriteFlash(param1:String, param2:AnimController, param3:ILogger, param4:IResourceManager, param5:Boolean)
      {
         this._sprite = new Sprite();
         this.displayObjectWrapper = new DisplayObjectWrapperFlash(this._sprite);
         super(param1,param2,param3,param4,param5);
         this._sprite.mouseEnabled = false;
         this._sprite.mouseChildren = false;
      }
      
      override protected function handleCreateXAnimClipSprite(param1:AnimClip) : XAnimClipSpriteBase
      {
         return new XAnimClipSpriteFlash(null,param1,logger,smoothing);
      }
   }
}
