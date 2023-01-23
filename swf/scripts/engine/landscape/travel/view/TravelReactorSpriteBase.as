package engine.landscape.travel.view
{
   import as3isolib.utils.IsoUtil;
   import com.greensock.TweenMax;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.resource.BitmapResource;
   
   public class TravelReactorSpriteBase
   {
       
      
      public var dow:DisplayObjectWrapper;
      
      public var terminated:Boolean;
      
      public var view:TravelReactorView;
      
      public var br:BitmapResource;
      
      public function TravelReactorSpriteBase(param1:BitmapResource, param2:TravelReactorView)
      {
         super();
         this.br = param1;
         this.view = param2;
         this.dow = IsoUtil.createDisplayObjectWrapper();
      }
      
      public function cleanup() : void
      {
         this.dow.removeFromParent();
         TweenMax.killTweensOf(this.dow);
         this.dow.release();
      }
      
      public function update(param1:int) : void
      {
      }
   }
}
