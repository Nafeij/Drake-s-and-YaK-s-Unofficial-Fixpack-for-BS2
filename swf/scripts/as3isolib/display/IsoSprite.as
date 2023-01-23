package as3isolib.display
{
   import as3isolib.core.IsoDisplayObject;
   import as3isolib.core.as3isolib_internal;
   import as3isolib.utils.IsoUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   
   public class IsoSprite extends IsoDisplayObject
   {
       
      
      protected var spritesArray:Array;
      
      protected var actualSpriteObjects:Array;
      
      as3isolib_internal var bSpritesInvalidated:Boolean = false;
      
      public function IsoSprite(param1:String, param2:Object = null)
      {
         this.spritesArray = [];
         this.actualSpriteObjects = [];
         super(param1,param2);
      }
      
      public function get sprites() : Array
      {
         return this.spritesArray;
      }
      
      public function set sprites(param1:Array) : void
      {
         var _loc2_:Object = null;
         if(this.spritesArray != param1)
         {
            this.spritesArray = param1;
            this.as3isolib_internal::bSpritesInvalidated = true;
            if(this.spritesArray)
            {
               for each(_loc2_ in this.spritesArray)
               {
                  if(!(_loc2_ is DisplayObjectWrapper))
                  {
                     throw new ArgumentError("fail");
                  }
               }
            }
         }
      }
      
      public function get actualSprites() : Array
      {
         return this.actualSpriteObjects.slice();
      }
      
      public function invalidateSkins() : void
      {
         this.as3isolib_internal::bSpritesInvalidated = true;
      }
      
      public function invalidateSprites() : void
      {
         this.as3isolib_internal::bSpritesInvalidated = true;
      }
      
      override public function get isInvalidated() : Boolean
      {
         return Boolean(as3isolib_internal::bPositionInvalidated) || this.as3isolib_internal::bSpritesInvalidated;
      }
      
      override protected function renderLogic(param1:Boolean = true) : void
      {
         if(this.as3isolib_internal::bSpritesInvalidated)
         {
            this.renderSprites();
            this.as3isolib_internal::bSpritesInvalidated = false;
         }
         super.renderLogic(param1);
      }
      
      protected function renderSprites() : void
      {
         var _loc1_:Object = null;
         this.actualSpriteObjects = [];
         mainContainer.removeAllChildren();
         for each(_loc1_ in this.spritesArray)
         {
            if(!(_loc1_ is DisplayObjectWrapper))
            {
               throw new Error("skin asset is not of the following types: BitmapData, DisplayObject, ISpriteAsset, IFactory or Class cast as DisplayOject.");
            }
            mainContainer.addChild(_loc1_ as DisplayObjectWrapper);
            this.actualSpriteObjects.push(_loc1_);
         }
      }
      
      override protected function createChildren() : void
      {
         super.createChildren();
         mainContainer = IsoUtil.createDisplayObjectWrapper();
         mainContainer.name = "container";
         attachMainContainerEventListeners();
      }
   }
}
