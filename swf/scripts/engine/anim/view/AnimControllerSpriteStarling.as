package engine.anim.view
{
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapperStarling;
   import engine.resource.IResourceManager;
   import starling.display.Sprite;
   
   public class AnimControllerSpriteStarling extends AnimControllerSprite
   {
       
      
      public var _sprite:Sprite;
      
      public function AnimControllerSpriteStarling(param1:String, param2:AnimController, param3:ILogger, param4:IResourceManager, param5:Boolean)
      {
         this._sprite = new Sprite();
         this.displayObjectWrapper = new DisplayObjectWrapperStarling(this._sprite);
         super(param1,param2,param3,param4,param5);
         this._sprite.touchable = false;
      }
      
      override protected function handleCreateXAnimClipSprite(param1:AnimClip) : XAnimClipSpriteBase
      {
         return new XAnimClipSpriteStarling(null,param1,logger,smoothing);
      }
   }
}
